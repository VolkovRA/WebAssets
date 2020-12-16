package assets.l10n;

/**
 * Менеджер локализаций.
 */
class L10nManager extends Manager<L10nResource, L10nParams>
{
    /**
     * Создать менеджер для подключения локализаций.
     */
    public function new() {
        super(ResourceType.L10N, L10nResource, "l10n");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[l10nManager total=" + total + "]";
    }
}