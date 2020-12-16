package assets.l10n;

import js.Browser;
import js.html.RequestInit;
import js.lib.Error;
import l10n.LocalizationID;
import l10n.Texts;

/**
 * Локализация.  
 * Объект загружает и подключает файл локализации.
 */
class L10nResource extends Resource<L10nResource, L10nParams>
{
    /**
     * Создать загрузчик локализации.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:L10nManager, params:L10nParams) {
        super(manager, params.id==null?params.url:params.id, ResourceType.L10N, params);

        if (params.url == null)
            throw new Error("The url of localization cannot be null");
        if (params.localization == null)
            throw new Error("The localization id cannot be null");
    
        this.url = params.url;
        this.fetchParams = params.fetchParams==null?null:params.fetchParams;
        this.localization = params.localization;
    }

    /**
     * ID Локализации для добавления.  
     * Не может быть `null`
     */
    public var localization(default, null):LocalizationID;

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
                        function(data) {
                            if (isDisposed)
                                return;

                            try {
                                Texts.shared.add(Texts.parse(data), localization);
                            }
                            catch (err:Any) {
                                error = new Error('Failed to parse localization data: "' + url + '"\n' + Std.string(err));
                                isComplete = true;
                                isLoading = false;
                                onComplete.emit(this);
                                return;
                            }

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
                    error = new Error('Failed to load localization data: ' + response.status + ' ' + response.statusText + ' "' + url + '"');
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
     * Уничтожить эту локализацию. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Выгружает все данные, связанные с этим ресурсом.
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

        // Texts.shared.remove(localizlocalization); // <-- Метод не реализован

        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[L10nResource id=" + id + "]";
    }
}