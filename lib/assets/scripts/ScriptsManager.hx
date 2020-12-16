package assets.scripts;

import assets.scripts.ScriptResource;

/**
 * Менеджер скриптов.
 */
class ScriptsManager extends Manager<ScriptResource, ScriptParams>
{
    /**
     * Создать менеджер для подключения скриптов.
     */
    public function new() {
        super(ResourceType.SCRIPT, ScriptResource, "scripts");
    }

    /**
     * Получить строковое описание этого экземпляра.
     * @return Строковое представление объекта.
     */
    @:keep
    @:noCompletion
    override public function toString():String {
        return "[ScriptsManager total=" + total + "]";
    }
}