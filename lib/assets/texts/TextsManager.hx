package assets.texts;

import assets.texts.TextResource;

/**
 * Менеджер текстовых данных.
 */
class TextsManager extends Manager<TextResource, TextParams>
{
    /**
     * Создать менеджер для загрузка текстовых данных.
     */
    public function new() {
        super(ResourceType.TEXT, TextResource, "texts");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[TextsManager total=" + total + "]";
    }
}