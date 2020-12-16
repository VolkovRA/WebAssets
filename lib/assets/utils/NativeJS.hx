package assets.utils;

import js.Syntax;

/**
 * Нативный JavaScript.  
 * Используется для прямых вызовов JS, чтобы упростить реализацию и сделать
 * её более эффективной, чем стандартные Haxe обёртки. Или чтобы просто добавить
 * некоторый функционал JS, которого нет в Haxe.
 * 
 * Статический класс.
 */
@:dce
class NativeJS
{
    /**
     * Проверка на `undefined`. *(Нативный JS)*  
     * Производит сравнение: `value === undefined`
     * @param value Проверяемое значение.
     * @return Результат проверки.
     */
    inline static public function isUndefined(value:Dynamic):Bool {
        return Syntax.code('({0} === undefined)', value);
    }
}