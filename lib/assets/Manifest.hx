package assets;

import assets.fonts.FontResource;
import assets.scripts.ScriptResource;
import assets.texts.TextResource;

/**
 * Манифест внешних ресурсов.
 * 
 * Тип описывает все внешние ресурсы, загружаемые менеджером
 * ресурсов `assets.Assets`. Это самый высокоуровневый способ
 * для подключения ресурсов, используемый как декларативный
 * способ программирования.
 * 
 * Вы просто перечисляете всё необходимое, а менеджер сделает
 * всё остальное и уведомит вас об успешном завершении! (Или
 * не успешном)
 */
typedef Manifest =
{
    /**
     * Шрифты.  
     * Содержит список подключаемых шрифтов для использования
     * на странице или в CSS стилях.
     */
    @:optional var fonts:Array<FontParams>;

    /**
     * Дополнительные JS скрипты и библиотеки.  
     * Список загружаемых на страницу JS скриптов и библиотек.
     * Загруженные скрипты добавляются в раздел `head` страницы.
     */
    @:optional var scripts:Array<ScriptParams>;

    /**
     * Текстовые данные.  
     * Эти данные просто загружаются и хранятся в памяти в виде
     * обычного текста, для их дальнейшего использования.
     */
    @:optional var texts:Array<TextParams>;

    #if pixi
    /**
     * Текстуры для [PixiJS](https://pixijs.download/dev/docs/PIXI.BaseTexture.html).
     * 
     * **Обратите внимание**, что перед использованием этого
     * загрузчика вы должны подключить JS движок на страницу,
     * что бы все основные классы для загрузки текстур были
     * доступны.
     * 
     * --- 
     * Требуемая библиотека для PixiJS: https://github.com/VolkovRA/HaxePixiJS
     */
    @:optional var textures:Array<assets.pixi.TextureParams>;

    /**
     * Звуки для [PixiJS Sound](https://pixijs.io/pixi-sound/examples/).
     * 
     * **Обратите внимание**, что перед использованием этого
     * загрузчика вы должны подключить JS движок и библиотеку
     * для звуков на страницу, что бы все основные классы для
     * загрузки звука были доступны.
     * 
     * --- 
     * Требуемая библиотека для PixiJS: https://github.com/VolkovRA/HaxePixiJS
     */
    @:optional var sounds:Array<assets.pixi.SoundParams>;
    #end

    #if l10n
    /**
     * Данные локализаций.  
     * Список загружаемых и подключаемых файлов локализаций для
     * использования их в библиотеке: `l10n`
     * 
     * ---
     * Требуемая библиотека для локализаций: https://github.com/VolkovRA/WebL10n
     */
    @:optional var l10n:Array<assets.l10n.L10nParams>;
    #end
}