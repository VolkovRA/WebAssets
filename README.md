# Haxe Менеджер ресурсов для WEB

Описание
------------------------------

Очередной менеджер для загрузки ассетов.
Чем он лучше всех остальных:
1. Максимально простой, ничего лишнего, простое API.
2. Размер генерируемого JS кода неприлично мал и оптимизирован.
3. Позволяет связать ресурсы разных Haxe проектов на одной странице. (Например, для реализации прелоадера)
4. Самодостаточный, нет никаких зависимостей, кроме наличия браузера.

Как использовать
------------------------------

```
package;

import assets.Assets;
import assets.ResourceType;

class Main 
{
	static function main() 
	{
		Assets.instance.load("cat", "cat.jpg", ResourceType.BLOB);
		Assets.instance.load("in", "index.html", ResourceType.BUFFER);
		Assets.instance.load("js", "index.js", ResourceType.TEXT);
		Assets.instance.onProgress = function(l, t){ trace(l, t, l / t); };
		Assets.instance.onComplete = function(){ trace("Finish!"); trace(Assets.instance); };
	}
}
```

Подключение в Haxe
------------------------------

1. Установите haxelib, чтобы можно было использовать библиотеки Haxe.
2. Выполните в терминале команду, чтобы установить библиотеку WebAssets глобально себе на локальную машину:
```
haxelib git WebAssets https://github.com/VolkovRA/WebAssets.git master
```
Синтаксис команды:
```
haxelib git [project-name] [git-clone-path] [branch]
haxelib git minject https://github.com/massiveinteractive/minject.git         # Use HTTP git path.
haxelib git minject git@github.com:massiveinteractive/minject.git             # Use SSH git path.
haxelib git minject git@github.com:massiveinteractive/minject.git v2          # Checkout branch or tag `v2`.
```
3. Добавьте в свой проект библиотеку WebAssets, чтобы использовать её в коде. Если вы используете HaxeDevelop, то просто добавьте в файл .hxproj запись:
```
<haxelib>
	<library name="WebAssets" />
</haxelib>
```

Смотрите дополнительную информацию:
 * [Документация Haxelib](https://lib.haxe.org/documentation/using-haxelib/ "Using Haxelib")
 * [Документация HaxeDevelop](https://haxedevelop.org/configure-haxe.html "Configure Haxe")