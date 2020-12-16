package assets.fonts.providers;

import haxe.DynamicAccess;
import js.Browser;
import js.html.FontFace;
import js.lib.Error;

/**
 * Загрузка и подключение шрифтов с помощью [FontFace API](https://developer.mozilla.org/en-US/docs/Web/API/FontFace).
 * 
 * Может быть использовано только в средах с поддержкой этого API.
 * В остальных случаях вы должны использовать `CSSProvider`.
 */
class FontFaceProvider implements IProvider
{
    private var map:DynamicAccess<ItemData> = {};

    /**
     * Создать объект для внедрения шрифтов.
     */
    public function new() {
    }

    private function add(font:FontResource, callback:FontResource->Error->Void):Void {
        if (font == null)
            return;

        var item:ItemData = {
            data: font,
            callback: callback,
            face: new FontFace(font.family, FontsUtils.parseSource(font.source), font.descriptors),
        }

        map[font.id] = item;
        Browser.document.fonts.add(item.face);

        item.face.load().then(
            function(v) {
                if (item.callback != null)
                    item.callback(font, null);
            },
            function(err) {
                if (item.callback != null)
                    item.callback(font, err);
            }
        );
    }

    private function remove(font:FontResource):Void {
        if (font == null)
            return;

        var item = map[font.id];
        if (item == null)
            return;

        item.callback = null;

        map.remove(font.id);
        Browser.document.fonts.delete(item.face);
    }
}

/**
 * Данные шрифта, подключенного через CSS метод.
 */
private typedef ItemData =
{
    /**
     * Ссылка на экземпляр данных подключаемого шрифта.
     */
    var data:FontResource;

    /**
     * Колбек для уведомления о завершении подключения.
     */
    var callback:FontResource->Error->Void;

    /**
     * Экземпляр шрифта для API.
     */
    var face:FontFace;
}