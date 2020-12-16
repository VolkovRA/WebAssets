package assets;

import haxe.DynamicAccess;
import js.Syntax;
import js.lib.Error;

/**
 * Менеджер ресурсов. 🌱  
 * Это абстрактный, базовый класс для менеджеров всех типов
 * ресурсов. Скорее всего, вы заходите использовать
 * специализированный тип менеджера, а не этот. Например:
 * `assets.fonts.FontsManager`.
 * 
 * Зачем нужно
 * ------------
 * Этот интерфейс описывает общее API для всех типов менеджеров.
 * Деление на типы необходимо, так как все ресурсы загружаются и
 * подключаются по разному. Каждый конкретный **тип** менеджера
 * работает с специфичным только для него **типом** ресурсов,
 * обеспечивая таким образом их корректную загрузку, подключение
 * и инициализацию.
 * 
 * Этот интерфейс абстрагирует общее API для всех типов менеджеров.
 * 
 * Реализация
 * ------------
 * - `FontsManager` Занимается загрузкой и подключением внешних
 *   шрифтов на web страницу.
 * - `TextsManager` Занимается загрузкой и хранением обычных,
 *   текстовых данных, ничего с ними больше не делая.
 * - `ScriptsManager` Занимается загрузкой и внедрением JavaScript
 *   кода, библиотек, фреймворков и т. д., на web страницу.
 * - `L10nsManager` Занимается загрузкой и подключением файлов
 *   локализаций для библиотеки [webl10n](https://github.com/VolkovRA/WebL10n).
 * - `PixiSpritesManager` Занимается загрузкой и инициализацией
 *   графики для фреймворка [PixiJS](http://pixijs.download/release/docs/index.html).
 * - `PixiSoundsManager` Занимается загрузкой и подключением звука
 *   для доп. фреймворка [PixiJS Sound](https://pixijs.io/pixi-sound/examples/).
 * 
 * Добавление новых типов ресурсов
 * ------------
 * Для добавления новых типов ресурсов вы должны сделать:
 * 1. Создать папку в `assets`, чтобы хранить в ней классы
 *    для нового типа ресурсов. (По аналогии с другими типами)
 * 2. Расширить класс `assets.Manager`, для создания менеджера
 *    ресурсов нового типа.  
 *    В нём необходимо:
 *      - Переопределить метод: `add()`. (Опционально)
 *      - Переопределить метод: `toString()`. (Опционально)
 * 3. Расширить класс `assets.Resource`, который будет загружать
 *    и подключать ресурсы нового типа.  
 *    В нём необходимо:
 *      - Переопределить метод: `load()`. Реализовать загрузку
 *        и подключение ресурса, вызвать колбек в конце.
 *      - Переопределить метод: `dispose()`. (Опционально)
 *      - Переопределить метод: `toString()`. (Опционально)
 * 4. Добавить новый менеджер в `assets.Assets`.
 * 5. Добавить новые типы в `assets.Manifest`.
 */
class Manager<R:Resource<R,P>, P>
{
    /**
     * Список ресурсов, где ключ - id ресурса.  
     * Не может быть `null`.
     */
    private var map:DynamicAccess<R> = {};

    /**
     * Ссылка на класс ресурса для создания новых экземпляров.  
     * Не может быть `null`.
     */
    private var cls(default, null):Class<Resource<R,P>>;

    /**
     * Ключ данных в `Manifest` файле для разбора этим менеджером.  
     * Не может быть `null`.
     */
    private var manifestKey(default, null):String;

    /**
     * Создать менеджер ресурсов.
     * @param type Тип ресурсов.
     * @param cls Ссылка на класс для создания новых экземпляров ресурсов.
     * @param manifestKey Ключ данных в `Manifest` файле для разбора этим менеджером.
     * @throws Error Тип менеджера не должен быть `null`.
     */
    private function new(type:ResourceType, cls:Class<Resource<R,P>>, manifestKey:String) {
        if (type == null) throw new Error("Manager type cannot be null");
        if (cls == null) throw new Error("The class of items cannot be null");
        if (manifestKey == null) throw new Error("The manifest key cannot be null");

        this.type = type;
        this.cls = cls;
        this.manifestKey = manifestKey;
        this.onComplete = new Dispatcher();
        this.onCompleteAll = new Dispatcher();
    }

    /**
     * Тип ресурсов. 🙈  
     * Удобно для быстрой проверки **типа** менеджера и какими
     * ресурсами он заведует.
     * 
     * Не может быть `null`
     */
    public var type(default, null):ResourceType;

    /**
     * Общее количество добавленных ресурсов. (Штук)  
     * Может быть полезно для отслеживания прогресса загрузки.
     * 
     * По умолчанию: `0`
     */
    public var total(default, null):Int = 0;

    /**
     * Количество загружаемых ресурсов в данный момент. (Штук)  
     * Может быть полезно для отслеживания прогресса загрузки.
     * 
     * По умолчанию: `0`
     */
    public var loading(default, null):Int = 0;

    /**
     * Количество готовых ресурсов. (Штук)  
     * Может быть полезно для отслеживания прогресса загрузки.
     * 
     * По умолчанию: `0`
     */
    public var loaded(default, null):Int = 0;

    /**
     * Событие готовности одного из ресурсов.
     * 
     * Используется для уведомления о завершении загрузки и разбора
     * одного из ресурсов. Это событие может быть полезно для
     * отслеживания прогресса загрузки.
     * 
     * Особенности:
     * - Это событие посылается один раз для каждого добавленного
     *   ресурса после завершения его загрузки и разбора.
     * - Это событие посылается всегда, даже если загрузка или
     *   инициализация завершились ошибкой. В этом случае описание
     *   ошибки будет содержаться в свойстве: `resource.error`.
     * 
     * Пример:
     * ```
     * manager.onComplete.on(function(res){ trace("Complete!", res, res.error); });
     * ```
     * Не может быть `null`
     */
    public var onComplete(default, null):Dispatcher<R->Void>;

    /**
     * Событие общей готовности всех ресурсов.
     * 
     * Используется для уведомления о завершении и инициализации
     * всех добавленных ресурсов в этот менеджер. Это событие
     * диспетчерезируется только один раз и всегда в самом конце.
     * 
     * Особенности:
     * - Если после завершения загрузки вы добавите ещё один или
     *   более новых ресурсов, это событие будет вызвано **повторно**
     *   после обработки и подключения всех новых данных.
     * - Это событие диспетчерезируется всегда, даже если была
     *   **ошибка** во время загрузки одного, нескольких или всех ресурсов.
     * 
     * Пример:
     * ```
     * manager.onCompleteAll.once(function(){ trace("All complete!"); });
     * ```
     * Не может быть `null`
     */
    public var onCompleteAll(default, null):Dispatcher<Void->Void>;

    /**
     * Получить экземпляр данных ресурса по его ID.  
     * Возвращает экземпляр данных ресурса или `null`, если
     * объекта с таким ID нет в списке.
     * @param id ID Искомого ресурса.
     * @return Экземпляр данных ресурса или `null`.
     */
    public function get(id:String):R {
        var item = map[id];
        if (item == null)
            return null;

        return item;
    }

    /**
     * Добавить новый ресурс.  
     * Создаёт новый ресурс на основе переданных параметров.
     * @param params Параметры для нового ресурса.
     * @return Новый ресурс.
     * @throws Error Объект параметров не должен быть `null`.
     */
    public function add(params:P):R {
        if (params == null)
            throw new Error("The resource params cannot be null");

        var item:R = untyped Type.createInstance(cls, [this, params]);
        map[item.id] = item;
        total ++;

        return item;
    }

    /**
     * Добавить список ресурсов из `Manifest` файла.  
     * Это аналог метода `add()`, только добавляется сразу много.
     * @param manifest Описание добавляемых ресурсов.
     */
    public function addManifest(manifest:Manifest):Void {
        if (manifest == null)
            return;

        var arr:Array<P> = untyped manifest[manifestKey];
        if (arr == null)
            return;

        var i = 0;
        while (i < arr.length)
            add(arr[i++]);
    }

    /**
     * Удалить ресурс из списка по его ID.  
     * Для удаляемого ресурса будет вызва метод `dispose()` 🔥  
     * Возвращает экземпляр данных удалённого ресурса или `null`,
     * если объекта с таким ID не было в списке.
     * @param id ID Удаляемого объекта.
     * @param dispose Вызвать метод `dispose()` для удалённого ресурса.
     * @return Экземпляр удалённого ресурса или `null`.
     */
    public function remove(id:String):R {
        var item = map[id];
        if (item == null)
            return null;

        total --;
        if (item.isComplete) loaded --;
        if (item.isLoading) loading --;

        map.remove(id);
        if (!item.isDisposed)
            item.dispose();

        return item;
    }

    /**
     * Удалить все ресурсы.  
     * Для каждого объекта в списке будет вызван метод `dispose()` 🔥  
     */
    public function clear():Void {
        var old = map;
        map = {};

        total = 0;
        loaded = 0;
        loading = 0;

        var key:Dynamic = null;
        Syntax.code('for ({0} in {1}) {', key, old);
            old[key].dispose();
        Syntax.code('}');
    }

    /**
     * Начать загрузку новых ресурсов. 🐌  
     * Возвращает `true`, если один или несколько ресурсов были
     * поставлены на загрузку.
     * - Перед вызовом этого метода подпишитесь на соответствующие
     *   события для получения уведомлений о результатах загрузки,
     *   если вы этого ещё не сделали.
     * - Этот вызов не влияет на загружаемые или уже загруженные
     *   ресурсы, он просто начинает загрузку новых.
     * - Колбек вызывается **мгновенно**, если в данный момент все
     *   ресурсы загружены и вы не добавили новых.
     * @param callback Колбек, который будет вызван после завершения загрузки всех данных.
     *                 Аналогично вызову: `manager.onCompleteAll.once(callback);`
     * @return Возвращает `true`, если один или несколько ресурсов
     *         былипоставлены на загрузку.
     */
    public function load(?callback:Void->Void):Bool {
        var key:Dynamic = null;
        var hasNewLoads:Bool = false;
        Syntax.code('for ({0} in {1}) {', key, map);
            var item = map[key];
            if (!item.isLoading && !item.isComplete && !item.isDisposed) {
                hasNewLoads = true;
                item.onComplete.once(onLoadComplete);
                item.load();
            }
        Syntax.code('}');
        return hasNewLoads;
    }

    private function onLoadComplete(res:R):Void {
        var hasNewItems:Bool = false;
        var hasLoading:Bool = false;
        var key:Dynamic = null;

        total = 0;
        loaded = 0;
        loading = 0;

        // Сбор информации:
        Syntax.code('for ({0} in {1}) {', key, map);
            var item = map[key];
           
            // Счётчики:
            total ++;
            if (item.isLoading)
                loading ++;
            if (item.isComplete)
                loaded ++;

            // Диспетчеризация конечного события:
            if (!item.isEmitCompleteAll) {
                hasNewItems = true;
                if (item.isLoading)
                    hasLoading = true;
            }
        Syntax.code('}');

        // Промежуточное событие:
        onComplete.emit(res);

        // Конечное событие: (Если не добавили ещё)
        if ((hasNewItems && !hasLoading) && loading == 0) {
            var key:Dynamic = null;
            Syntax.code('for ({0} in {1}) {', key, map);
                map[key].isEmitCompleteAll = true;
            Syntax.code('}');
            onCompleteAll.emit();
        }
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    public function toString():String {
        return '[Manager type=' + type + ', total=' + total + ']';
    }
}