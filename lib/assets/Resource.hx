package assets;

import js.lib.Error;
import assets.utils.Dispatcher;

/**
 * Внешний ресурс.  
 * Это абстрактный, базовый класс для всех типов ресурсов. Скорее всего вы
 * захотите использовать не этот класс, а конкретный тип ресурса, например:
 * `assets.fonts.FontResource`.
 * 
 * Этот класс используется для абстрагирования общих параметров всех типов
 * ресурсов и для дальнейшего расширения класса и добавления уникальной
 * логики загрузки/инициализации каждого конкретного типа ресурса.
 */
class Resource<R:Resource<R,P>, P>
{
    /**
     * Создать новый ресурс.
     * @param manager Родительский менеджер, к которому принадлежит этот ресурс.
     * @param id ID Ресурса.
     * @param type Тип ресурса.
     * @param params Дополнительные параметры.
     * @throws Error Менеджер не должен быть `null`
     * @throws Error ID Ресурса не должен быть `null`
     * @throws Error Тип ресурса не должен быть `null`
     * @throws Error Параметры ресурса не должны быть `null`
     */
    private function new(manager:Manager<R,P>, id:String, type:ResourceType, params:P) {
        if (manager == null)    throw new Error("The parent manager cannot be null");
        if (id == null)         throw new Error("Resource id cannot be null");
        if (type == null)       throw new Error("Resource type cannot be null");
        if (params == null)     throw new Error("Resource params cannot be null");

        this.manager = manager;
        this.id = id;
        this.type = type;
        this.params = params;
        this.onComplete = new Dispatcher();
    }

    /**
     * Событие `onCompleteAll` для этого ресурса не посылалось.  
     * Используется внутренней реализацией менеджера ресурсов для
     * корректной диспетчерезации этого события.
     * 
     * По умолчанию: `false`
     */
    @:allow(assets.Manager)
    private var isEmitCompleteAll:Bool = false;

    /**
     * ID Ресурса.  
     * Уникален в рамках своего родительского менеджера `manager`.
     * 
     * Не может быть `null`
     */
    public var id(default, null):String;

    /**
     * Тип ресурса.  
     * Удобно использовать для быстрого определения типа этого
     * ресурса. (Класса)
     * 
     * Не может быть `null`
     */
    public var type(default, null):ResourceType;

    /**
     * Список дополнительных параметров, переданных в конструктор.  
     * Не может быть `null`
     */
    public var params(default, null):P;

    /**
     * Родительский менеджер ресурсов.  
     * Каждый экземпляр ресурса имеет ссылку на свой родительский
     * менеджер, к которому он относится. Это используется, в
     * основном для внутренней реализации.
     *  
     * Не может быть `null`
     */
    public var manager(default, null):Manager<R,P>;

    /**
     * Событие готовности.  
     * Используется для уведомления о полном завершении загрузки и
     * разбора этого ресурса.
     * 
     * Пример:
     * ```
     * resource.onComplete.once(function(res){ trace("Сomplete!", res.error); });
     * ```
     * Не может быть `null`
     */
    public var onComplete(default, null):Dispatcher<R->Void>;

    /**
     * Ресурс загружается.  
     * Флаг равен `true`, если в данный момент этот ресурс загружается.
     * 
     * По умолчанию: `false`
     */
    public var isLoading(default, null):Bool = false;

    /**
     * Ресурс загружен и готов к использованию.  
     * Перед доступом к данным проверьте свойство `error` на предмет
     * наличия ошибки.
     * 
     * По умолчанию: `false`
     */
    public var isComplete(default, null):Bool = false;

    /**
     * Ресурс выгружен.  
     * Это свойство равно `true`, если был вызван метод `dispose()`.
     * Такой ресурс более не может быть использован, все его данные
     * уничтожены.
     * 
     * По умолчанию: `false`
     */
    public var isDisposed(default, null):Bool = false;

    /**
     * Ошибка.  
     * Это свойство содержит описание ошибки, если такая произошла
     * во время загрузки или разбора данных этого ресурса.
     * 
     * По умолчанию: `null`
     */
    public var error:Error = null;

    /**
     * Начать загрузку ресурса.  
     * Метод внутренней реализации, должен быть переопределён в
     * подклассе. Вызов родительского метода не требуется!
     * @throws Error Метод должен быть переопределён в подклассе.
     */
    @:allow(assets.Manager)
    private function load():Void {
        throw new Error("Method not implemented");
    }

    /**
     * Уничтожить этот ресурс. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Выгружает все данные, связанные с этим ресурсом.
     * - Очищает список слушателей `onComplete=null`.
     * - Удаляет объект из родительского менеджера `manager=null`.
     * - Удаляет ошибку `error=null`.
     * - Устанавливает свойство `isDisposed=true`.
     * 
     * Вы больше не должны использовать этот объект!
     */
    public function dispose():Void {
        if (isDisposed)
            return;

        isDisposed = true;

        manager.remove(id);
        onComplete.clear();

        onComplete = null;
        manager = null;
        error = null;
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    public function toString():String {
        return "[Resource id=" + id + "]";
    }
}