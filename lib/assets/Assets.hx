package assets;

import haxe.DynamicAccess;
import js.Browser;
import js.lib.Error;
import assets.Manifest;
import assets.fonts.FontsManager;
import assets.scripts.ScriptsManager;
import assets.texts.TextsManager;
import assets.utils.Dispatcher;

/**
 * Мастер менеджер ресурсов.  
 * 
 * Зачем это нужно
 * ------------
 * Ресурсы, используемые в игре очень разные, а способы их
 * доставки и инициализации - темболее! Этот объект выполняет
 * одну очень простую по смыслу задачу:  
 * *Я указал список, а ты загрузи и подключи всё как надо!*
 * 
 * Это общий объект для управления всеми **типами** ресурсов.
 * Он включает в себя несколько более простых менеджеров,
 * специализированных на конкретном типе данных. Более
 * подробное описание по типам данных можно почитать в описании
 * абстрактного класса: `assets.Manager`.
 * 
 * Как использовать
 * ------------
 * Сперва вы должны получить объект `Assets`, который будет
 * заведовать всеми ресурсами. Рекомендуется использовать уже
 * готовый, глобальный объект: `Assets.global`. Таким образом
 * доступ к загруженным данным сможет получить любая JS программа
 * в рамках данной web страницы. Но вы можете создать и отдельный
 * экземпляр `Assets`.
 * 
 * Далее нужно выбрать способ загрузки: по одному файлу или с
 * помощью описания всех необходимых ресурсов (Манифест). Вторым
 * способом пользоваться удобнее.  
 * Пример:
 * ```
 * var manifest:Manifest =
 * {
 *     fonts: [
 *         { family:"Sansita One", source:"fonts/Sansita One.ttf" },
 *     ],
 *     scripts:[
 *         { url:"js/lib/pixi.min.js", },
 *         { url:"js/lib/pixi-filters.js", },
 *         { url:"js/lib/pixi-sound.js", },
 *     ],
 *     l10n:[
 *         { localization:"ru", url:"lang/ru.csv" },
 *         { localization:"en", url:"lang/en.csv" },
 *     ],
 * }
 * Assets.global.add(manifest);
 * Assets.global.load(function(){ trace("All data loaded!"); });
 * ```
 * Когда ресурсы будут загружены и готовы к использованию, вы
 * увидите в консоли сообщение: `All data loaded!`.
 */
class Assets
{
    private var map:DynamicAccess<Manager<Dynamic, Dynamic>> = {};
    private var arr:Array<Manager<Dynamic, Dynamic>> = [];

    /**
     * Создать новый менеджер внешних ресурсов.
     */
    public function new() {
        onComplete = new Dispatcher();
        onCompleteAll = new Dispatcher();

        // Базовые типы ресурсов:
        addManager(new FontsManager());
        addManager(new ScriptsManager());
        addManager(new TextsManager());

        // Расширения:
        #if l10n
        addManager(new assets.l10n.L10nManager());
        #end
        
        #if pixi
        addManager(new assets.pixi.SoundsManager());
        addManager(new assets.pixi.TexturesManager());
        #end
    }

    /**
     * Добавить менеджер для нового типа данных.  
     * С помощью этого метода можно удобно добавлять обработчики
     * для новых типов ресурсов.  
     * Вызов игнорируется, если был передан `null`.
     * @param manager Менеджер по обработке нового типа данных.
     * @throws Error Менеджер для данного типа ресурсов уже зарегистрирован.
     */
    public function addManager(manager:Manager<Dynamic,Dynamic>):Void {
        if (manager == null)
            return;
        if (map[manager.type] != null)
            throw new Error("The Manager for data type=" + manager.type + " is already added");

        manager.onComplete.on(onResourceComplete);

        map[manager.type] = manager;
        arr.push(manager);
    }

    /**
     * Получить менеджер по обработке данных указанного типа.  
     * Возвращает менеджер ресурсов для указанного типа, или `null`,
     * если такого не зарегистрировано.
     * @param type Тип ресурсов.
     * @return Менеджер ресурсов указанного типа.
     */
    public function getManager(type:ResourceType):Manager<Dynamic, Dynamic> {
        var item = map[type];
        if (item == null)
            return null;

        return untyped item;
    }

    /**
     * Глобальный объект менеджера ресурсов для всей web страницы.
     * - Используется по умолчанию, содержится на странице в `window.assets`.
     * - Доступ к этому экземпляру может получить любое Haxe приложение.
     * - Экземпляр менеджера создаётся при первом вызове этого геттера.
     * 
     * Не может быть `null`
     */
    static public var global(get, null):Assets;
    @:noCompletion
    static public function get_global():Assets {
        var v:Assets = untyped Browser.window.assets;
        if (v == null) {
            v = new Assets();
            untyped Browser.window.assets = v;
        }
        return v;
    }

    /**
     * Общее количество всех добавленных ресурсов. (Штук)
     * 
     * Может быть полезно для отслеживания прогресса загрузки.
     * При вызове этот счётчик подсчитывает общую сумму `total`
     * среди всех своих дочерних менеджеров.
     * 
     * По умолчанию: `0`
     */
    public var total(get, never):Int;
    @:noCompletion
    function get_total():Int {
        var sum = 0;
        var i = arr.length;
        while (i-- != 0)
            sum += arr[i].total;
        return sum;
    }

    /**
     * Количество загружаемых ресурсов в данный момент. (Штук)  
     * 
     * Может быть полезно для отслеживания прогресса загрузки.
     * При вызове этот счётчик подсчитывает общую сумму `loading`
     * среди всех своих дочерних менеджеров.
     * 
     * По умолчанию: `0`
     */
    public var loading(get, never):Int;
    @:noCompletion
    function get_loading():Int {
        var sum = 0;
        var i = arr.length;
        while (i-- != 0)
            sum += arr[i].loading;
        return sum;
    }

    /**
     * Общее количество загруженных ресурсов, готовых к работе. (Штук)
     * 
     * Может быть полезно для отслеживания прогресса загрузки.
     * При вызове этот счётчик подсчитывает общую сумму `loaded`
     * среди всех своих дочерних менеджеров.
     * 
     * По умолчанию: `0`
     */
    public var loaded(get, never):Int;
    @:noCompletion
    function get_loaded():Int {
        var sum = 0;
        var i = arr.length;
        while (i-- != 0)
            sum += arr[i].loaded;
        return sum;
    }

    /**
     * Событие готовности одного из ресурсов.
     * 
     * Используется для уведомления о завершении загрузки и разбора одного
     * из ресурсов. Это событие может быть полезно для отслеживания прогресса
     * загрузки.
     * 
     * Особенности:
     * - Это событие посылается один раз для каждого добавленного ресурса
     *   после завершения его загрузки и разбора.
     * - Это событие посылается всегда, даже если загрузка или инициализация
     *   завершились ошибкой. В этом случае описание ошибки будет содержаться
     *   в свойстве: `resource.error`.
     * 
     * Пример:
     * ```
     * Assets.global.onComplete.on(function(res){ trace("Complete!", res, res.error); });
     * ```
     * Не может быть `null`
     */
    public var onComplete(default, null):Dispatcher<Resource<Dynamic,Dynamic>->Void>;

    /**
     * Событие общей готовности всех ресурсов.
     * 
     * Используется для уведомления о завершении и инициализации всех
     * добавленных ресурсов в этот менеджер. Это событие диспетчерезируется
     * только один раз и всегда в самом конце.
     * 
     * Особенности:
     * - Если после завершения загрузки вы добавите ещё один или более
     *   новых ресурсов, это событие будет вызвано **повторно** после
     *   обработки и подключения всех новых данных.
     * - Это событие диспетчерезируется всегда, даже если была **ошибка**
     *   во время загрузки одного, нескольких или всех ресурсов.
     * 
     * Пример:
     * ```
     * Assets.global.onCompleteAll.once(function(){ trace("All complete!"); });
     * ```
     * Не может быть `null`
     */
    public var onCompleteAll(default, null):Dispatcher<Void->Void>;

    /**
     * Добавить описание загружаемых ресурсов.  
     * Этот метод удобен для добавления сразу нескольких ресурсов за раз.
     * Но вы также можете использовать добавление ресурсов по отдельности
     * в каждом конкретном менеджере ресурсов.
     * @param manifest Объект с описанием загружаемых ресурсов.
     */
    public function add(manifest:Manifest):Void {
        var i = arr.length;
        while (i-- != 0)
            arr[i].addManifest(manifest);
    }

    /**
     * Начать загрузку новых ресурсов. 🐌  
     * Возвращает `true`, если один или несколько ресурсов были поставлены на загрузку.
     * - Перед вызовом этого метода подпишитесь на соответствующие события для
     *   получения уведомлений о результатах загрузки, если вы этого ещё не сделали.
     * - Этот вызов не влияет на уже загружаемые или загруженные ресурсы, он
     *   просто начинает загрузку новых.
     * - Колбек вызывается мгновенно, если в данный момент все ресурсы загружены.
     *   (Вы передали пустой манифест?)
     * @param callback Колбек, который будет вызван после завершения загрузки всех данных.
     *                 Аналогично вызову: `assets.onCompleteAll.once(callback);`
     * @return Возвращает `true`, если один или несколько ресурсов были поставлены на загрузку.
     */
    public function load(?callback:Void->Void):Bool {
        var hasNewLoads = false;
        var i = arr.length;
        while (i-- != 0) {
            if (arr[i].load())
                hasNewLoads = true;
        }

        if (hasNewLoads)
            onCompleteAll.once(callback);
        else
            callback();

        return hasNewLoads;
    }

    private function onResourceComplete(res:Resource<Dynamic, Dynamic>) {
        onComplete.emit(res);
        if (total == loaded)
            onCompleteAll.emit();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    public function toString():String {
        return '[Assets total=' + total + ']';
    }
}