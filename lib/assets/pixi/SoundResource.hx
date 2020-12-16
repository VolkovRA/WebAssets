package assets.pixi;

import js.Browser;
import js.html.RequestInit;
import js.lib.Error;
import pixi.sound.Sounds;

/**
 * Звуковые данные.  
 * Объект занимается загрузкой и подключением звука
 * для [PixiJS Sound](https://pixijs.io/pixi-sound/examples/).
 */
class SoundResource extends Resource<SoundResource, SoundParams>
{
    /**
     * Создать загрузчик звуковых данных.
     * @param manager Родительский менеджер загрузчика.
     * @param params Параметры для создания ресурса.
     */
    private function new(manager:SoundsManager, params:SoundParams) {
        super(manager, params.id==null?params.url:params.id, ResourceType.SOUND, params);

        if (params.url == null)
            throw new Error("The url of sound cannot be null");

        this.url = params.url;
        this.options = params.options==null?null:params.options;
        this.sprites = params.sprites==null?null:params.sprites;
        this.fetchParams = params.fetchParams==null?null:params.fetchParams;
    }

    /**
     * URL Адрес звука.  
     * Не может быть `null`
     */
    public var url(default, null):String;

    /**
     * Параметры для инициализации звука.  
     * Список этих параметров передаётся в [API PixiJS Sound](https://pixijs.io/pixi-sound/docs/PIXI.sound.html#add)
     * при регистрации нового звука.
     * 
     * По умолчанию: `null`
     */
    public var options(default, null):SoundOptions;

    /**
     * URL Адрес файла с описанием звуковых спрайтов. (Атлас)  
     * Если не задано, звук будет подключен как единичный.  
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

        // Баг в либе. 😢
        // К сожалению, реализация либы имеет баг и не позволяет
        // использовать для загрузки звука тег Audio, очень жаль.
        // А дизайн API диктует нам сперва загрузить JSON. 😫

        if (sprites == null) {
            // Одиночый звук:
            var opt = getSupportedParams(options);
            opt.url = url;
            opt.preload = true;
            opt.loaded = function(err, sound, instance) {
                if (isDisposed || isComplete)
                    return;
                if (err != null) {
                    error = err;
                    isComplete = true;
                    isLoading = false;
                    onComplete.emit(this);
                    return;
                }

                isComplete = true;
                isLoading = false;
                onComplete.emit(this);
            }
            Sounds.add(id, untyped opt);
        }
        else {
            // Спрайты: (Сперва грузим JSON)
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

                                    // Подключаем звук:
                                    var opt = getSupportedParams(options);
                                    opt.url = url;
                                    opt.preload = true;
                                    opt.sprites = data;
                                    opt.loaded = function(err, sound, instance) {
                                        if (isDisposed || isComplete)
                                            return;
                                        if (err != null) {
                                            error = err;
                                            isComplete = true;
                                            isLoading = false;
                                            onComplete.emit(this);
                                            return;
                                        }

                                        isComplete = true;
                                        isLoading = false;
                                        onComplete.emit(this);
                                    }
                                    Sounds.add(id, untyped opt);
                                },
                                function(err) {
                                    if (isDisposed || isComplete)
                                        return;

                                    error = new Error('Failed to parse sound sprites data: "' + sprites + '"\n' + Std.string(err));
                                    isComplete = true;
                                    isLoading = false;
                                    onComplete.emit(this);
                                }
                            );
                        }
                        else {
                            error = new Error('Failed to load sound sprites data: ' + response.status + ' ' + response.statusText + ' "' + sprites + '"');
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
    }

    /**
     * Уничтожить этот звук. 🔥  
     * Вызов игнорируется, если этот ресурс уже был выгружен.
     * - Удаляет все связанные данные с этим звуком.
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

        Sounds.remove(id);

        super.dispose();
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[SoundResource id=" + id + "]";
    }

    /**
     * Взять поддерживаемые опций. (Маппинг)
     * @param options Список опций.
     * @return Копия объекта только с поддерживаемыми свойствами.
     */
    static private function getSupportedParams(options:SoundOptions):Dynamic {
        if (options == null)
            return {};
        
        var params:Dynamic = {};
        if (options.autoPlay != null)       params.autoPlay = options.autoPlay;
        if (options.singleInstance != null) params.singleInstance = options.singleInstance;
        if (options.volume != null)         params.volume = options.volume;
        if (options.speed != null)          params.speed = options.speed;
        if (options.complete != null)       params.complete = options.complete;
        if (options.loop != null)           params.loop = options.loop;

        return params;
    }
}