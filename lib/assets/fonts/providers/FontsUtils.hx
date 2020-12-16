package assets.fonts.providers;

import js.Syntax;

/**
 * Вспомогательные утилиты для подключения шрифтов.  
 * Статический класс.
 */
class FontsUtils
{
    /**
     * Проверка наличия поддержки **FontFace** API.  
     * Возвращает `true`, если текущая среда поддерживает это API.
     * @return Возвращает `true`, если текущая среда поддерживает это API.
     * @see https://developer.mozilla.org/en-US/docs/Web/API/FontFace/FontFace
     */
    static public function isSupportedFontFaceAPI():Bool {
        var api:Dynamic = null;
        try {
            api = Syntax.code("window.FontFace;");
        }
        catch (err:Dynamic) {
            api = null;
        }

        return api != null;
    }

    /**
     * Получить валидный адрес шрифта для API FontFace.
     * @param value Указанный адрес.
     * @return Адрес в формате FontFace API.
     */
    static public function parseSource(value:Dynamic):String {
        if (value == null)
            return null;

        if (isArray(value)) {
            var i:Int = 0;
            var len:Int = value.length;
            var str:String = "";
            while (i < len)
                str += 'url("' + Std.string(value[i++]) + '"), ';

            if (str == "")
                return null;

            return str.substring(0, str.length-2); 
        }
        else {
            return 'url("' + Std.string(value) + '")';
        }
    }

    /**
     * Проверить объект на массив.
     * @param value Проверяемый объект.
     * @return Возвращает `true`, если переданный объект является массивом JavaScript.
     */
    inline static public function isArray(value:Dynamic):Bool {
        return Syntax.code('Array.isArray({0})', value);
    }

    /**
     * Получить теккущее время. (mc)  
     * Метод возвращает количество миллисекунд, прошедших с 1 января 1970 года 00:00:00
     * по UTC по текущий момент времени в качестве числа.
     * @return Текущее время.
     * @see Документация по [Date.now()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/now)
     */
    inline static public function now():Float {
        return Syntax.code('Date.now()');
    }
}