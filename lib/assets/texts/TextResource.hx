package assets.texts;

import js.Browser;
import js.html.RequestInit;
import js.lib.Error;

/**
 * Обычные, текстовые данные.  
 * Объект просто загружает и хранит текстовые данные.
 */
class TextResource extends Resource<TextResource, TextParams>
{
    /**
     * Создать загрузчик текстовых данных.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:TextsManager, params:TextParams) {
        super(manager, params.id==null?params.url:params.id, ResourceType.TEXT, params);

        if (params.url == null)
            throw new Error("The url of texts data cannot be null");
    
        this.url = params.url;
        this.fetchParams = params.fetchParams==null?null:params.fetchParams;
    }

    /**
     * URL Адрес для загрузки данных.  
     * Не может быть `null`
     */
    public var url(default, null):String;

    /**
     * Дополнительные параметры для [fetch()](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
     * запроса.  
     * По умолчанию: `null`
     */
    public var fetchParams:RequestInit;

    /**
     * Загруженные, текстовые данные.  
     * По умолчанию: `null`
     */
    public var data:String = null;

    /**
     * Начать загрузку.  
     */
    override private function load():Void {
        if (isLoading || isComplete || isDisposed)
            return;

        isLoading = true;

        Browser.window.fetch(url, fetchParams).then(
            function (response) {
                if (isDisposed)
                    return;

                if (response.ok) {
                    response.text().then(
                        function(str) {
                            if (isDisposed)
                                return;

                            data = str;
                            isComplete = true;
                            isLoading = false;
                            onComplete.emit(this);
                        },
                        function(err) {
                            if (isDisposed)
                                return;

                            error = err;
                            isComplete = true;
                            isLoading = false;
                            onComplete.emit(this);
                        }
                    );
                }
                else {
                    error = new Error('Failed to load text data: ' + response.status + ' ' + response.statusText + ' "' + url + '"');
                    isComplete = true;
                    isLoading = false;
                    onComplete.emit(this);
                }
            },
            function (err) {
                if (isDisposed)
                    return;

                error = err;
                isComplete = true;
                isLoading = false;
                onComplete.emit(this);
            }
        );
    }

    /**
     * Уничтожить эти текстовые данные. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Очищает свойство `data=null`.
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

        data = null;

        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[TextResource id=" + id + "]";
    }
}

/**
 * Параметры загружаемого текста.
 */
typedef TextParams =
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
     * Дополнительные параметры для [fetch()](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
     * запроса.  
     * По умолчанию: `null`
     */
    @:optional var fetchParams:RequestInit;
}