package assets.pixi;

import assets.pixi.SoundResource;

/**
 * Менеджер звуков PixiJS.
 */
class SoundsManager extends Manager<SoundResource, SoundParams>
{
    /**
     * Создать менеджер звуков для PixiJS.
     */
    public function new() {
        super(ResourceType.SOUND, SoundResource, "sounds");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[SoundsManager total=" + total + "]";
    }
}