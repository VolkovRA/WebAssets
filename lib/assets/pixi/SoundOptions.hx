package assets.pixi;

import pixi.sound.Sound.CompleteCallback;

/**
 * Параметры звука, передаваемые в API.
 * 
 * Этот объект является частью API библиотеки PixiJS Sound.
 * Он нужен для того, что бы указать список поддерживаемых
 * параметров загрузчиком. Так как загрузчик реализует
 * собственный механизм поставки, некоторые свойства из
 * оригинального API игнорируются.
 * 
 * Этот объект перечисляет **поддерживаемые** параметры для
 * инициализации звука из [оригинального API](https://pixijs.io/pixi-sound/docs/PIXI.sound.html).
 */
typedef SoundOptions =
{
    /**
     * `true` to play after loading.  
     * Default: `false`
     */
    @:optional var autoPlay:Bool;

    /**
     * `true` to disallow playing multiple layered instances at once.  
     * Default: `false`
     */
    @:optional var singleInstance:Bool;

    /**
     * The amount of volume `1` = 100%.  
     * Default: `1`
     */
    @:optional var volume:Float;

    /**
     * The playback rate where `1` is 100% speed.  
     * Default: `1`
     */
    @:optional var speed:Float;

    /**
     * Global complete callback when play is finished.  
     * Default: `null`
     */
    @:optional var complete:CompleteCallback;

    /**
     * `true` to loop the audio playback.  
     * Default: `false`
     */
    @:optional var loop:Bool;
}