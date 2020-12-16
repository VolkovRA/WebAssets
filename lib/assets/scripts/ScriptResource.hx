package assets.scripts;

import js.Browser;
import js.html.Event;
import js.lib.Error;
import js.html.ScriptElement;

/**
 * Скрипт JS.  
 * Объект выполняет подключение внешнего JavaScript кода.
 * Код добавляется в раздел `head` текущей web страницы.
 */
class ScriptResource extends Resource<ScriptResource, ScriptParams>
{
    /**
     * Создать загрузчик JavaScript кода.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:ScriptsManager, params:ScriptParams) {
        super(manager, params.id==null?params.url:params.id, ResourceType.SCRIPT, params);

        if (params.url == null)
            throw new Error("The url of script cannot be null");

        this.url = params.url;
        this.async = params.async==null?null:params.async;
        this.defer = params.defer==null?null:params.defer;
        this.crossOrigin = params.crossOrigin==null?null:params.crossOrigin;
        this.script = Browser.document.createScriptElement();
    }

    /**
     * URL Адрес расположения подключаемого скрипта.  
     * Не может быть `null`.
     */
    public var url(default, null):String;

    /**
     * Тег `script` для загружаемого кода JavaScript.  
     * Не может быть `null`
     */
    public var script(default, null):ScriptElement;

    /**
     * Политика безопасности [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
     * для загрузки этого JavaScript.  
     * Смотрите: https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/crossorigin
     * 
     * По умолчанию: `null`
     */
    public var crossOrigin(default, null):String;

    /**
     * Флаг выполнения до загрузки DOM.
     * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script
     * 
     * По умолчанию: `null`
     */
    public var defer:Bool;

    /**
     * Флаг асинхронного выполнения.
     * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script
     * 
     * По умолчанию: `null`
     */
    public var async:Bool;

    /**
     * Начать загрузку.  
     */
    override private function load():Void {
        if (isLoading || isComplete || isDisposed)
            return;

        isLoading = true;

        if (async != null)          script.async = async;
        if (defer != null)          script.defer = defer;
        if (crossOrigin != null)    script.crossOrigin = crossOrigin;

        script.addEventListener("load", onLoad);
        script.addEventListener("error", onLoadError);
        script.src = url;

        if (Browser.document.head == null)
            Browser.document.addEventListener("DOMContentLoaded", onDOMLoaded);
        else
            onDOMLoaded();
    }

    private function onDOMLoaded():Void {
        Browser.document.removeEventListener("DOMContentLoaded", onDOMLoaded);
        Browser.document.head.appendChild(script);
    }

    private function onLoad(e:Event):Void {
        isComplete = true;
        isLoading = false;

        script.removeEventListener("load", onLoad);
        script.removeEventListener("error", onLoadError);

        onComplete.emit(this);
    }

    private function onLoadError(e:Event):Void {
        isComplete = true;
        isLoading = false;

        error = new Error("Failed to load script resource: " + url);

        script.removeEventListener("load", onLoad);
        script.removeEventListener("error", onLoadError);

        onComplete.emit(this);
    }

    /**
     * Уничтожить этот скрипт. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Выгружает все данные, связанные с этим ресурсом.
     * - Удаляет скрипт со страницы.
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

        if (script != null) {
            if (script.parentNode != null)
                script.parentNode.removeChild(script);

            script.removeEventListener("load", onLoad);
            script.removeEventListener("error", onLoadError);
            script = null;
        }

        Browser.document.removeEventListener("DOMContentLoaded", onDOMLoaded);
        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[ScriptResource id=" + id + "]";
    }
}

/**
 * Параметры для создания подключаемого скрипта.
 */
typedef ScriptParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **url**.
     */
    @:optional var id:String;

    /**
     * URL Адрес для загрузки данных.  
     * Не может быть `null`
     */
    var url:String;

    /**
     * Политика безопасности [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
     * для загрузки этого JavaScript.  
     * Смотрите: https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/crossorigin
     * 
     * По умолчанию: `null`
     */
    @:optional var crossOrigin:String;

    /**
     * Флаг выполнения до загрузки DOM.
     * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script
     * 
     * По умолчанию: `null`
     */
    @:optional var defer:Bool;

    /**
     * Флаг асинхронного выполнения.
     * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script
     * 
     * По умолчанию: `null`
     */
    @:optional var async:Bool;
}