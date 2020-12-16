package assets.pixi;

import js.html.RequestInit;

/**
 * Параметры загружаемого звука.
 */
typedef SoundParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **url**.
     */
    @:optional var id:String;

    /**
     * URL Адрес звука.  
     * Не может быть `null`
     */
    var url:String;

    /**
     * Параметры для инициализации звука.  
     * Список этих параметров передаётся в [API PixiJS Sound](https://pixijs.io/pixi-sound/docs/PIXI.sound.html#add)
     * при регистрации нового звука.
     * 
     * По умолчанию: `null`
     */
    @:optional var options:SoundOptions;

    /**
     * URL Адрес файла с описанием звуковых спрайтов. (Атлас)  
     * Если не задано, звук будет подключен как единичный.  
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