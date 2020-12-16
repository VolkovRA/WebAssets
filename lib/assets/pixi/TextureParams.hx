package assets.pixi;

import js.html.RequestInit;

/**
 * Параметры загружаемой текстуры.
 */
typedef TextureParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **url**.
     */
    @:optional var id:String;

    /**
     * URL Адрес изображения.  
     * Не может быть `null`
     */
    var url:String;

    /**
     * URL Адрес файла с описанием текстур. (Атлас)  
     * Если не задано, изображение будет подключено как единичная текстура.  
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