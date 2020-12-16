package assets.fonts;

import assets.fonts.FontResource;

/**
 * Менеджер шрифтов.
 */
class FontsManager extends Manager<FontResource, FontParams>
{
    /**
     * Создать менеджер для подключения шрифтов.
     */
    public function new() {
        super(ResourceType.FONT, FontResource, "fonts");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[FontsManager total=" + total + "]";
    }
}