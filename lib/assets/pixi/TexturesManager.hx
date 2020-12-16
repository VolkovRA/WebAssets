package assets.pixi;

import assets.pixi.TextureResource;

/**
 * Менеджер текстур PixiJS.
 */
class TexturesManager extends Manager<TextureResource, TextureParams>
{
    /**
     * Создать менеджер текстур для PixiJS.
     */
    public function new() {
        super(ResourceType.TEXTURE, TextureResource, "textures");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[TexturesManager total=" + total + "]";
    }
}