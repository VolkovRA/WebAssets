package assets.fonts;

import js.html.FontFaceDescriptors;
import js.lib.Error;
import assets.fonts.providers.CSSProvider;
import assets.fonts.providers.FontFaceProvider;
import assets.fonts.providers.FontsUtils;
import assets.fonts.providers.IProvider;

/**
 * Шрифт.  
 * Объект выполняет загрузку и подключение внешнего файла шрифта
 * для использования его на странице, canvas или в CSS стилях.
 * 
 * Этот загрузчик использует два разных способа подключения в
 * зависимости от рантайма и переданных параметров. Более подробно
 * см.: `assets.fonts.providers.IProvider`
 */
class FontResource extends Resource<FontResource, FontParams>
{
    /**
     * Поддержка [FontFace API](https://developer.mozilla.org/en-US/docs/Web/API/FontFace/FontFace).
     */
    static private var isFontFaceSupported:Bool = null;
    static private var providerAPI:IProvider = new FontFaceProvider();
    static private var providerCSS:IProvider = new CSSProvider();

    /**
     * Создать ресурс для подключения шрифта.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:FontsManager, params:FontParams) {
        super(manager, params.id==null?Std.string(params.source):params.id, ResourceType.FONT, params);

        this.family = params.family;
        this.source = params.source;
        this.descriptors = params.descriptors==null?null:params.descriptors;
        this.legacy = !!params.legacy;
        this.testString = (params.testString == null || params.testString == "")?"0123456789":params.testString;
        this.timeout = params.timeout == null?10000:params.timeout;

        if (isFontFaceSupported == null)
            isFontFaceSupported = FontsUtils.isSupportedFontFaceAPI();
    }

    /**
     * Способ загрузки и подключения шрифта на страницу.  
     * Может быть `null`
     */
    private var provider(default, null):IProvider = null;

    /**
     * Семейство шрифтов, содержащееся в этом файле.  
     * Эта строка эквивалентна `@font-face/font-family` дескриптору.
     * 
     * Не может быть `null`
     */
    public var family(default, null):String;

    /**
     * URL Адрес расположения данных шрифта для загрузки.  
     * Допустимые значения:
     * - `String` - URL Адрес с шрифтом.
     * - `Array[String]` - Массив с URL адресами шрифта.
     */
    public var source(default, null):Dynamic;

    /**
     * Набор дополнительных параметров для шрифта передаваемых
     * при его инициализации.
     */
    public var descriptors(default, null):FontFaceDescriptors;

    /**
     * Использовать старый способ подключения шрифта при помощи CSS.
     * 
     * Если `true`, для подключения этого шрифта будет использован 
     * старый способ, даже если в браузере есть поддержка FontFace API.
     * Может быть полезно для тестов или на этапе разработки.
     * 
     * По умолчанию: `false` *(Использовать FontFace API, если есть)*
     */
    public var legacy(default, null):Bool;

    /**
     * Тестовая строка для определения факта загрузки шрифта.
     * 
     * Это набор символов, на основе которого будет проверяться факт
     * загрузки шрифта. Это значение используется только при CSS
     * загрузке шрифтов, когда **FontFace** API недоступен, или явно
     * задан флаг `legacy`.
     * 
     * **Важно:** Эти символы должны присутствовать в загружаемом шрифте!
     * Иначе скрипт не зафиксирует успешную загрузку. 👀
     * 
     * По умолчанию: `0123456789` *(Набор чисел, как самый вероятный перечень символов в любом шрифте)*
     */
    public var testString(default, null):String;

    /**
     * Таймут для загузки шрифта. (mc)
     * 
     * Это значение используется только при CSS загрузке. (`legacy=true`)
     * Так как загрузка с помощью CSS не идеальна и теоритически может
     * зависнуть, требуется такое ограничение. В случае истечения времени,
     * загрузка шрифта будет завершена с ошибкой таймаута.
     * 
     * По умолчанию: `10000` *(10 Секунд)*
     */
    public var timeout(default, null):Int;

    /**
     * Начать загрузку шрифта.  
     */
    override private function load():Void {
        if (isLoading || isComplete || isDisposed)
            return;

        // Загрузка и подключение:
        isLoading = true;
        provider = (legacy || !isFontFaceSupported) ? providerCSS : providerAPI;
        provider.add(this, onLoaded);
    }

    private function onLoaded(res:FontResource, err:Error):Void {
        if (isDisposed)
            return;

        isLoading = false;
        isComplete = true;

        error = err;

        onComplete.emit(this);
    }

    /**
     * Уничтожить этот шрифт. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Выгружает все данные, связанные с этим ресурсом.
     * - Удаляет шрифт со страницы.
     * - Очищает список слушателей `onComplete=null`.
     * - Удаляет объект из родительского менеджера `manager=null`.
     * - Удаляет ошибку `error=null`.
     * - Устанавливает свойство `isDisposed=true`.
     * 
     * Вы больше не должны использовать этот объект!
     */
    override public function dispose():Void {
        if (isDisposed)
            return;

        if (provider != null) {
            provider.remove(this);
            provider = null;
        }

        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[FontResource id=" + id + "]";
    }
}

/**
 * Параметры для создания нового шрифта.
 */
typedef FontParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **source**.
     */
    @:optional var id:String;

    /**
     * Семейство шрифтов.  
     * Эта строка эквивалентна значению `@font-face/font-family` CSS стилей.
     * 
     * Не может быть `null`
     */
    var family:String;

    /**
     * URL Адрес расположения данных шрифта для загрузки.  
     * Допустимые значения:
     * - `String` - URL Адрес с шрифтом.
     * - `Array[String]` - Массив с URL адресами шрифта.
     */
    var source:Dynamic;

    /**
     * Набор дополнительных параметров для шрифта передаваемых
     * при его инициализации.
     */
    @:optional var descriptors:FontFaceDescriptors;

    /**
     * Использовать старый способ подключения шрифта при помощи CSS.
     * 
     * Если `true`, для подключения этого шрифта будет использован 
     * старый способ, даже если в браузере есть поддержка FontFace API.
     * Может быть полезно для тестов или на этапе разработки.
     * 
     * По умолчанию: `false` *(Использовать FontFace API, если есть)*
     * 
     * @see Интерфейс подключения шрифтов: `assets.fonts.providers.IProvider`
     */
    @:optional var legacy:Bool;

    /**
     * Тестовая строка для определения факта загрузки шрифта.
     * 
     * Это набор символов, на основе которого будет проверяться факт
     * загрузки шрифта. Это значение используется только при CSS
     * загрузке шрифтов, когда **FontFace** API недоступен, или явно
     * задан флаг `legacy`.
     * 
     * **Важно:** Эти символы должны присутствовать в загружаемом шрифте!
     * Иначе скрипт не зафиксирует успешную загрузку. 👀
     * 
     * По умолчанию: `0123456789` *(Набор чисел, как самый вероятный перечень символов в любом шрифте)*
     */
    @:optional var testString:String;

    /**
     * Таймут для загузки шрифта. (mc)
     * 
     * Это значение используется только при CSS загрузке. (`legacy=true`)
     * Так как загрузка с помощью CSS не идеальна и теоритически может
     * зависнуть, требуется такое ограничение. В случае истечения времени,
     * загрузка шрифта будет завершена с ошибкой таймаута.
     * 
     * По умолчанию: `10000` *(10 Секунд)*
     */
    @:optional var timeout:Int;
}