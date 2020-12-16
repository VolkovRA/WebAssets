package assets.pixi;

import js.Browser;
import js.html.Event;
import js.html.Image;
import js.html.RequestInit;
import js.lib.Error;
import pixi.textures.BaseTexture;
import pixi.textures.Texture;
import pixi.utils.Spritesheet;

/**
 * Обычные, текстовые данные.  
 * Объект занимается загрузкой и подключением текстур для [PixiJS](https://pixijs.download/dev/docs/index.html).
 */
class TextureResource extends Resource<TextureResource, TextureParams>
{
    private var img:Image = null;
    private var map:Dynamic = null;
    private var isImgReady:Bool = false;
    private var isMapReady:Bool = false;
    private var base:BaseTexture = null;

    /**
     * Создать загрузчик текстовых данных.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:TexturesManager, params:TextureParams) {
        super(manager, params.id==null?params.url:params.id, ResourceType.TEXTURE, params);

        if (params.url == null)
            throw new Error("The url of texture cannot be null");

        this.url = params.url;
        this.sprites = params.sprites==null?null:params.sprites;
        this.fetchParams = params.fetchParams==null?null:params.fetchParams;
    }

    /**
     * URL Адрес изображения.  
     * Не может быть `null`
     */
    public var url(default, null):String;

    /**
     * URL Адрес файла с описанием текстур. (Атлас)  
     * Если не задано, изображение будет подключено как единичная текстура.  
     * По умолчанию: `null`
     */
    public var sprites(default, null):String;

    /**
     * Дополнительные параметры для [fetch()](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
     * запроса.  
     * По умолчанию: `null`
     */
    public var fetchParams(default, null):RequestInit;

    /**
     * Начать загрузку.  
     */
    override private function load():Void {
        if (isLoading || isComplete || isDisposed)
            return;

        isLoading = true;

        // Загрузка текстуры:
        img = new Image();
        img.addEventListener("load", function(e:Event) {
            if (isDisposed || isComplete)
                return;

            isImgReady = true;
            checkComplete();
        });
        img.addEventListener("error", function(e:Event) {
            if (isDisposed || isComplete)
                return;

            error = new Error('Failed to load texture source: "' + url + '"');
            isLoading = false;
            isComplete = true;
            onComplete.emit(this);
        });
        img.src = url;

        // Загрузка мапы спрайтов:
        if (sprites != null) {
            Browser.window.fetch(sprites, fetchParams).then(
                function(response) {
                    if (isDisposed || isComplete)
                        return;

                    if (response.ok) {
                        response.json().then(
                            function(data) {
                                if (isDisposed || isComplete)
                                    return;

                                map = data;
                                isMapReady = true;
                                checkComplete();
                            },
                            function(err) {
                                if (isDisposed || isComplete)
                                    return;

                                error = new Error('Failed to parse texture sprites data: "' + sprites + '"\n' + Std.string(err));
                                isComplete = true;
                                isLoading = false;
                                onComplete.emit(this);
                            }
                        );
                    }
                    else {
                        error = new Error('Failed to load texture sprites data: ' + response.status + ' ' + response.statusText + ' "' + sprites + '"');
                        isComplete = true;
                        isLoading = false;
                        onComplete.emit(this);
                    }
                },
                function(err) {
                    if (isDisposed || isComplete)
                        return;

                    error = err;
                    isComplete = true;
                    isLoading = false;
                    onComplete.emit(this);
                }
            );
        }
    }

    private function checkComplete():Void {
        if (sprites == null) {
            if (!isImgReady)
                return;

            // Одиночная текстура:
            base = new BaseTexture(img);
            BaseTexture.addToCache(base, id);

            var t = new Texture(base);
            Texture.addToCache(t, id);

            isComplete = true;
            isLoading = false;
            onComplete.emit(this);
        }
        else {
            if (!isImgReady || !isMapReady)
                return;

            // Атлас:
            base = new BaseTexture(img);
            BaseTexture.addToCache(base, id);

            var ss = new Spritesheet(base, map);
            ss.parse(function(data){
                isComplete = true;
                isLoading = false;
                onComplete.emit(this);
            });
        }
    }

    /**
     * Уничтожить эту текстуру. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Удаляет все связанные данные с этой текстурой.
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

        if (base != null) {
            base.destroy();
            base.dispose();
            base = null;
        }

        img = null;
        map = null;

        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[TextureResource id=" + id + "]";
    }
}

/**
 * Параметры загружаемой текстуры.
 */
typedef TextureParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **url**.
     */
    @:optional var id:String;

    /**
     * URL Адрес изображения.  
     * Не может быть `null`
     */
    var url:String;

    /**
     * URL Адрес файла с описанием текстур. (Атлас)  
     * Если не задано, изображение будет подключено как единичная текстура.  
     * По умолчанию: `null`
     */
    @:optional var sprites:String;

    /**
     * Дополнительные параметры для [fetch()](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
     * запроса.  
     * Используется при загрузке данных спрайтов, если указан `sprites`.
     * 
     * По умолчанию: `null`
     */
    @:optional var fetchParams:RequestInit;
}