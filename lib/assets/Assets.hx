package assets;

import js.Browser;
import js.Syntax;
import js.lib.Error;
import js.html.ErrorEvent;
import js.html.ProgressEvent;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;

/**
 * Хранилище ресурсов.
 * Содержит простое и удобное API только с самым необходимым.
 * Работает на основе `XMLHttpRequest`, потому что `fetch()` - не позволяет отслеживать прогресс загрузки.
 * Может быть использован совместно в различных Haxe проектах на одной странице, например, для реализаци лаунчера.
 * @see Документация: https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
 */
class Assets 
{
    /**
     * Создать хранилище ресурсов.
     */
    public function new() {
    }



    ////////////////
    //   STATIC   //
    ////////////////

    /**
     * Глобальное хранилище ресурсов по умолчанию.
     * - Является общим хранилищем для всей web страницы, хранится в `window.assets`.
     * - Хранилище инициализируется при первом доступе к нему.
     * - Через это свойство вы можете получить доступ к ресурсам, загруженных **другим** Haxe приложением.
     * 
     * Не может быть `null`
     */
    static public var shared(get, never):Assets;

    static function get_shared():Assets {
        var v:Assets = untyped Browser.window.assets;
        if (v == null) {
            v = new Assets();
            untyped Browser.window.assets = v;
        }

        return v;
    }

    static private function typeToXhr(type:ResourceType):XMLHttpRequestResponseType {
        switch (type) {
            case BUFFER:    return XMLHttpRequestResponseType.ARRAYBUFFER;
            case BLOB:      return XMLHttpRequestResponseType.BLOB;
            case XML:       return XMLHttpRequestResponseType.DOCUMENT;
            case JSON:      return XMLHttpRequestResponseType.JSON;
            default:        return XMLHttpRequestResponseType.TEXT;
        }
    }



    ////////////////////
    //   PROPERTIES   //
    ////////////////////

    /**
     * Загруженные данные с ключом `URL` и значением `Resource`.
     * 
     * Не рекомендуется **изменять** этот объект, так-как это может привести к некорректной работе.
     * Доступ открыт для удобства, например, для пробега по всем ресурсам циклом.
     * 
     * Не может быть `null`
     */
    public var data(default, null):Dynamic = {};

    /**
     * Колбек прогресса загрузки.
     * 
     * На вход получает:
     * 1. Количество загруженных данных. (Байт)
     * 2. Общее количество всех данных. (Байт)
     * 
     * По умолчанию: `null`
     */
    public var onProgress:Int->Int->Void = null;

    /**
     * Колбек завершения загрузки.
     * 
     * Вызывается один раз после завершения загрузки **всех** ресурсов.
     * Если после этого вы добавите в менеджер ещё ресурсов, этот колбек будет
     * вызван снова после их завершения.
     * 
     * По умолчанию: `null`
     */
    public var onComplete:Void->Void = null;

    /**
     * Колбек ошибки загрузки ресурса.
     * 
     * Этот колбек вызывается **для каждого** проблемного ресурса во время загрузки.
     * На вход получает:
     * 1. Объект ошибки.
     * 2. Проблемный ресурс.
     * 
     * По умолчанию: `null`
     */
    public var onError:Dynamic->Resource->Void = null;

    /**
     * ID Таймаута.
     * Используется внутренней реализацией для обновления и вызова колбеков этого менеджера ресурсов.
     * 
     * По умолчанию: `0`
     */
    private var timeout:Int = 0;



    /////////////////
    //   METHODS   //
    /////////////////

    /**
     * Получить загруженные данные.
     * 
     * Этот метод возвращает загруженные данные, соответствующие их `ResourceType`.
     * Может вернуть `null`, если данных нет. (См. класс: `Resource.data`)
     * @param   url URL Ресурса.
     * @return  Загруженные данные или `null`.
     */
    public function get(url:String):Dynamic {
        var r:Resource = data[untyped url];
        if (r == null)
            return null;
        
        return r.data;
    }

    /**
     * Получить объект `Resource`.
     * 
     * Возвращает *контейнер* для загружаемых данных по указанному URL или `null`,
     * если такой URL не передавался в менеджер ресурсов.
     * @param   url URL Ресурса.
     * @return  Контейнер с загружаемых данных.
     */
    public inline function getResource(url:String):Resource {
        var r:Resource = data[untyped url];
        if (r == null)
            return null;
        
        return r;
    }

    /**
     * Добавить ресурс для загрузки.
     * - Если для указанного URL уже содержится ресурс в этом менеджере, он удаляется.
     * - Вызов игнорируется, если в url передан `null`.
     * @param url URL Ресурса.
     * @param type Тип ресурса. Это влияет на его анализ браузером.
     */
    public function add(url:String, type:ResourceType = ResourceType.TEXT):Void {
        if (url == null)
            return;
        
        var r:Resource = data[untyped url];
        if (r != null)
            stopLoad(r);

        r = {
            url:            url,
            type:           type,
            data:           null,
            error:          null,
            loaded:         false,
            bytesTotal:     0,
            bytesLoaded:    0,
            xhr:            null
        }

        data[untyped url] = r;
    }

    /**
     * Начать загрузку всех ресурсов.
     * - Инициирует загрузку для всех новых, добавленных ресурсов в менджер.
     * - Повторный вызов игнорируется, если в менеджере нет новых ресурсов.
     * 
     * Используйте колбеки менеджера ресурсов для получения уведомления о ходе загрузки.
     */
    public function load():Void {
        var key = null;
        Syntax.code("for ({0} in {1}) {", key, data); // for start
            var res:Resource = data[key];
            if (res.loaded == false && res.xhr == null)
                loadRes(res);
        Syntax.code("}"); // for end
    }

    /**
     * Инициировать загрузку ресурса.
     * @param res Загружаемый ресурс.
     */
    private function loadRes(res:Resource):Void {
        res.xhr = new XMLHttpRequest();
        res.xhr.responseType = typeToXhr(res.type);
        
        // Прогресс:
        res.xhr.onprogress = function(e:ProgressEvent) {
            untyped res.bytesLoaded = e.loaded;
            untyped res.bytesTotal  = e.total;

            if (timeout == 0)
                timeout = Browser.window.setTimeout(update, 50);
        };

        // Ошибка:
        res.xhr.onerror = function(e:ErrorEvent) {
            untyped res.error   = (e == null?null:e);
            untyped res.loaded  = true;

            if (timeout == 0)
                timeout = Browser.window.setTimeout(update, 50);
            
            if (onError != null)
                onError(e, res);
        };

        // Готово:
        res.xhr.onloadend = function(e:ProgressEvent) {
            untyped res.data        = res.xhr.response;
            untyped res.bytesLoaded = e.loaded;
            untyped res.bytesTotal  = e.total;
            untyped res.loaded      = true;

            if (timeout == 0)
                timeout = Browser.window.setTimeout(update, 50);

            // 404 and other:
            if (res.xhr.status >= 400 && onError != null)
                onError(new Error(res.xhr.status + " (" + res.xhr.statusText + ")" + (res.xhr.responseURL == null ? "" : (" " + res.xhr.responseURL))), res);
        };

        res.xhr.open("GET", res.url, true);
        res.xhr.send();
    }

    /**
     * Удалить данные.
     * - Прерывает активную загрузку для указанного URL, если такова имеется.
     * - Удаляет объект `Resource` из менеджера ресурсов.
     * - Возвращает `true`, если ресурс по указанному URL был найден.
     * - Колбеки не вызываются.
     * @param   url URL Ресурса.
     * @return  Возвращает `true`, если ресурс по указанному URL был найден и удалён.
     */
    public function remove(url:String):Bool {
        var r:Resource = data[untyped url];
        if (r == null)
            return false;

        stopLoad(r);

        Syntax.code("delete {0}[{1}];", data, url);

        return true;
    }

    /**
     * Вызов колбеков.
     */
    private function update():Void {
        timeout = 0;

        var count = 0;
        var bytesTotal = 0;
        var bytesLoaded = 0;
        var hasXhr = false;
        var completed = true;

        var key = null;
        Syntax.code("for ({0} in {1}) {", key, data); // for start
            var res:Resource = data[key];
            
            count ++;

            bytesTotal += res.bytesTotal;
            bytesLoaded += res.bytesLoaded;

            if (res.xhr != null) {
                hasXhr = true;

                if (res.loaded)
                    res.xhr = null;
                else
                    completed = false;
            }
        Syntax.code("}"); // for end

        if (count == 0)
            return;
        
        if (onComplete != null && hasXhr && completed)
            onComplete();

        if (onProgress != null && hasXhr && !completed)
            onProgress(bytesLoaded, bytesTotal);
    }

    /**
     * Удалить все ресурсы.
     * - Прерывает активную загрузку для всех не загруженных ресурсов.
     * - Удаляет все ресурсы из менеджера ресурсов.
     * - Колбеки не вызываются.
     */
    public function clear():Void {
        cancel();

        data = {};

        if (timeout > 0) {
            Browser.window.clearTimeout(timeout);
            timeout = 0;
        }
    }

    /**
     * Отменить загрузку всех ресурсов.
     * - Прерывает толлько активную загрузку ресурсов, если таковы имеются.
     * - Уже загруженные данные не удаляются.
     * - Колбеки не вызываются.
     */
    public function cancel():Void {
        var key = null;
        Syntax.code("for ({0} in {1}) {", key, data); // for start
            stopLoad(data[key]);
        Syntax.code("}"); // for end
    }

    /**
     * Отменить загрузку ресурса.
     * - Прерывает активную загрузку ресурса, если она выполняется в данный момент.
     * - Никаких колбеков не вызывается.
     * - Вызов игнорируется, если ресурс не загружается или уже был загружен.
     * @param res Ресурс.
     */
    private function stopLoad(res:Resource):Void {
        if (res.xhr == null)
            return;
        
        Syntax.code("try {"); 
            res.xhr.onprogress = null;
            res.xhr.onerror = null;
            res.xhr.onloadend = null;

            res.xhr.abort();
            res.xhr = null;

            untyped res.loaded = true;
        Syntax.code("} catch(err){}"); 
    }
}