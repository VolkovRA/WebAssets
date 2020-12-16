package assets.l10ns;

import assets.l10ns.L10nResource;

/**
 * Менеджер локализаций.
 */
class L10nsManager extends Manager<L10nResource, L10nParams>
{
    /**
     * Создать менеджер для подключения локализаций.
     */
    public function new() {
        super(ResourceType.L10N, L10nResource, "l10ns");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    override public function toString():String {
        return "[L10nsManager total=" + total + "]";
    }
}