package assets.l10n;

import js.html.RequestInit;
import l10n.LocalizationID;

/**
 * Параметры подключаемой локализации.
 * @see Библиотека `l10n`: https://github.com/VolkovRA/WebL10n
 */
typedef L10nParams =
{
    /**
     * ID Ресурса.  
     * Если не задан, будет использовано значение **url**.
     */
    @:optional var id:String;

    /**
     * ID Локализации для добавления.  
     * Не может быть `null`
     */
    var localization:LocalizationID;

    /**
     * URL Адрес для загрузки данных.  
     * Не может быть `null`
     */
    var url:String;

    /**
     * Дополнительные параметры для [fetch()](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
     * запроса.  
     * По умолчанию: `null`
     */
    @:optional var fetchParams:RequestInit;
}