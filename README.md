# Haxe менеджер ресурсов для WEB

Зачем это надо
------------------------------

Позволяет загрузить и правильно **инициализировать** ресурсы, для их дальнейшего использования в приложении. Решает вопросы с правильным подключением шрифтов на страницу, загрузку текстур, звуков и т.п.

Описание
------------------------------

Очередной менеджер для загрузки ресурсов.
Чем он лучше всех остальных:
1. Максимально простой, ничего лишнего, простое API.
2. Размер генерируемого JS кода неприлично мал и оптимизирован.
3. Позволяет связать ресурсы разных Haxe проектов на одной странице. (Например, для реализации прелоадера)
4. Самодостаточный, нет никаких зависимостей, кроме наличия браузера.
5. Позволяет расширять функциональность менеджера для загрузки специализированных ресуросв. Например - текстуры для pixiJS. Можно расширить функциональность своими типами данных и способом их инициализации.

Как использовать
------------------------------

```
// todo: Написать пример для версии 3.0.0
```

Подключение в Haxe
------------------------------

1. Установите haxelib, чтобы можно было использовать библиотеки Haxe.
2. Выполните в терминале команду, чтобы установить библиотеку WebAssets глобально себе на локальную машину:
```
haxelib git webassets https://github.com/VolkovRA/WebAssets.git master
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
	<library name="webassets" />
</haxelib>
```

Смотрите дополнительную информацию:
 * [Документация Haxelib](https://lib.haxe.org/documentation/using-haxelib/ "Using Haxelib")
 * [Документация HaxeDevelop](https://haxedevelop.org/configure-haxe.html "Configure Haxe")