package assets.fonts.providers;

import haxe.DynamicAccess;
import js.Browser;
import js.Syntax;
import js.html.DivElement;
import js.html.SpanElement;
import js.html.StyleElement;
import js.lib.Error;

/**
 * Загрузка и подключение шрифтов с помощью CSS.
 * 
 * Класс подключает указанный шрифт через CSS и отслеживает изменения
 * страницы для фиксации факта завершения загрузки шрифта. Костыльно,
 * но работает в условиях отсутствия [FontFace API](https://developer.mozilla.org/en-US/docs/Web/API/FontFace).
 */
class CSSProvider implements IProvider
{
    private var map:DynamicAccess<ItemData> = {};
    private var div:DivElement;
    private var intervalID:Int = -1;

    /**
     * Создать объект для внедрения шрифтов.
     */
    public function new() {
    }

    private function add(font:FontResource, callback:FontResource->Error->Void):Void {
        if (font == null)
            return;
        if (div == null) {
            div = Browser.document.createDivElement();
            div.classList.add("fonts_loader", "css_loader");
            div.style.position = "fixed";
        }

        var res:ItemData = {
            data: font,
            callback: callback,
            style: createStyle(font),
            span1: createSpan(font.family, "serif", font.testString),
            span2: createSpan(font.family, "sans-serif", font.testString),
            span3: createSpan(font.family, "monospace", font.testString),
            date: FontsUtils.now(),
        }
        map[font.id] = res;

        Browser.document.head.appendChild(res.style);
        div.appendChild(res.span1);
        div.appendChild(res.span2);
        div.appendChild(res.span3);

        if (intervalID == -1)
            intervalID = Browser.window.setInterval(check, 50);
    }

    private function remove(font:FontResource):Void {
        if (font == null)
            return;

        var res = map[font.id];
        if (res == null)
            return;

        if (res.style.parentNode != null) res.style.parentNode.removeChild(res.style);
        if (res.span1.parentNode != null) res.span1.parentNode.removeChild(res.span1);
        if (res.span2.parentNode != null) res.span2.parentNode.removeChild(res.span2);
        if (res.span3.parentNode != null) res.span3.parentNode.removeChild(res.span3);

        map.remove(font.id);
    }

    private  function check():Void {
        var now = FontsUtils.now();
        var hasLoading:Bool = false;
        var key:Dynamic = null;

        Syntax.code('for ({0} in {1}) {', key, map);
            var res:ItemData = map[key];
            if (!res.isLoaded) {
                var size1 = res.span1.offsetWidth;
                var size2 = res.span2.offsetWidth;
                var size3 = res.span3.offsetWidth;

                if (size1 != 0 && size1 == size2 && size2 == size3) {
                    res.isLoaded = true;

                    if (res.span1.parentNode != null) res.span1.parentNode.removeChild(res.span1);
                    if (res.span2.parentNode != null) res.span2.parentNode.removeChild(res.span2);
                    if (res.span3.parentNode != null) res.span3.parentNode.removeChild(res.span3);

                    res.callback(res.data, null);
                }
                else {
                    if (res.date + res.data.timeout < now) {
                        res.isLoaded = true;

                        if (res.span1.parentNode != null) res.span1.parentNode.removeChild(res.span1);
                        if (res.span2.parentNode != null) res.span2.parentNode.removeChild(res.span2);
                        if (res.span3.parentNode != null) res.span3.parentNode.removeChild(res.span3);

                        res.callback(res.data, new Error("Timeout of loading font/s: " + Std.string(res.data.source)));
                    }
                    else {
                        hasLoading = true;
                    }
                }
            }
        Syntax.code('}');

        // Наличие загрузок:
        if (hasLoading) {
            if (div.parentNode == null) {
                var body = Browser.document.getElementsByTagName("body")[0];
                if (body != null)
                    body.appendChild(div);
            }
        }
        else {
            if (intervalID != -1) {
                Browser.window.clearInterval(intervalID);
                intervalID = -1;
            }
            if (div.parentNode != null)
                div.parentNode.removeChild(div);
        }
    }

    static private function createStyle(data:FontResource):StyleElement {
        var style = Browser.document.createStyleElement();
        var params:String = '';

        if (data.descriptors != null) {
            if (data.descriptors.display != null)           params += '  font-display: ' + data.descriptors.display + ';\n';
            if (data.descriptors.stretch != null)           params += '  font-stretch: ' + data.descriptors.stretch + ';\n';
            if (data.descriptors.style != null)             params += '  font-style: ' + data.descriptors.style + ';\n';
            if (data.descriptors.weight != null)            params += '  font-weight: ' + data.descriptors.weight + ';\n';
            if (data.descriptors.variant != null)           params += '  font-variant: ' + data.descriptors.variant + ';\n';
            if (data.descriptors.featureSettings != null)   params += '  font-feature-settings: ' + data.descriptors.featureSettings + ';\n';
            if (data.descriptors.variationSettings != null) params += '  font-variation-settings: ' + data.descriptors.variationSettings + ';\n';
            if (data.descriptors.unicodeRange != null)      params += '  unicode-range: ' + data.descriptors.unicodeRange + ';\n';
        }

        style.textContent =
            '/* FontResource id=' + data.id + ' */\n' +
            '@font-face {\n' +
            '  src: ' + FontsUtils.parseSource(data.source) + ';\n' +
            '  font-family: "' + data.family + '";\n' + 
            params +
            '}';

        return style;
    }

    static private function createSpan(family1:String, family2:String, text:String):SpanElement {
        var span = Browser.document.createSpanElement();
        span.setAttribute('aria-hidden', 'true');
        span.style.fontFamily = '"' + family1 + '", ' + family2;
        span.style.display = "inline-block";
        span.style.fontSize = "100px"; // Большой размер повышает точность, так как clientWidth - округляется!
        span.style.fontStretch = "normal";
        span.style.fontStyle = "normal";
        span.style.fontVariant = "normal";
        span.style.fontWeight = "normal";
        span.style.whiteSpace = "nowrap";
        span.style.fontSynthesis = "none";
        span.style.maxWidth = "none";
        span.style.width = "auto";
        span.style.margin = "0";
        span.style.padding = "0";
        span.style.overflow = "hidden";
        span.style.position = "absolute";
        span.style.userSelect = "none";
        span.style.top = "999999px";
        span.style.border = "0";
        span.textContent = text;
        return span;
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
     * Ссылка на первый тег `span`. **sans-serif**
     */
    var span1:SpanElement;

    /**
     * Ссылка на второй тег `span`. **serif**
     */
    var span2:SpanElement;

    /**
     * Ссылка на третий тег `span`. **monospace**
     */
    var span3:SpanElement;

    /**
     * Ссылка на тег `style` для этого шрифта.
     */
    var style:StyleElement;

    /**
     * Дата начала загрузки шрифта для определения таймаута. (mc)
     */
    var date:Float;

    /**
     * Шрифт полностью загружен.
     */
    @:optional var isLoaded:Bool;
}