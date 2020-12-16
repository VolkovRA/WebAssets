package assets;

/**
 * Тип ресурса.  
 * Содержит константы для каждого класса подключаемого ресурса.
 * Удобно для быстрого определения **типа** ресурса. (Класса)
 */
enum abstract ResourceType(String) to String from String
{
    /**
     * Шрифт.
     */
    var FONT = "font";

    /**
     * Текстовые данные.
     */
    var TEXT = "text";

    /**
     * Скрипт JS.
     */
    var SCRIPT = "script";

    #if l10n
    /**
     * Локализация.
     * 
     * ---
     * Требуемая библиотека для локализаций: https://github.com/VolkovRA/WebL10n
     */
    var L10N = "l10n";
    #end

    #if pixi
    /**
     * Текстуры для PixiJS.
     */
    var TEXTURE = "texture";

    /**
     * Звук PixiJS Sound.
     * 
     * --- 
     * Требуемая библиотека для PixiJS: https://github.com/VolkovRA/HaxePixiJS
     */
    var SOUND = "sound";
    #end
}