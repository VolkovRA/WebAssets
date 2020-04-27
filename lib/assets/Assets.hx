package assets;

import js.Browser;
import js.Syntax;
import js.html.ErrorEvent;
import js.html.ProgressEvent;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import js.lib.Error;

/**
 * Хранилище ресурсов.
 * Содержит простое и удобное API только с самым необходимым.
 * Работает на основе XMLHttpRequest, потому что fetch - не позволяет отслеживать прогресс загрузки.
 * Может быть использован совместно в различных Haxe проектах на одной странице, например, для реализаци лаунчера.
 * Документация: https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
 * @author VolkovRA
 */
class Assets 
{
	/**
	 * Создать хранилище ресурсов.
	 */
	public function new() {
	}
	
	
	
	////////////////
	//   STATIC   //
	////////////////
	
	/**
	 * Глобальное хранилище ресурсов по умолчанию.
	 * Является общим хранилищем для всей web страницы:
	 * <code>window.Assets</code>
	 * 
	 * Хранилище инициализируется при первом доступе к нему.
	 * Через это свойство вы можете получить доступ к ресурсам, загруженным <b>другим</b> Haxe приложением.
	 * Не может быть null.
	 */
	static public var instance(get, never):Assets;
	
	static function get_instance():Assets {
		var v:Assets = untyped Browser.window.Assets;
		if (v == null) {
			v = new Assets();
			untyped Browser.window.Assets = v;
		}
		
		return v;
	}
	
	static private function toXhrType(type:ResourceType):XMLHttpRequestResponseType {
		switch (type) {
			case BUFFER:	return XMLHttpRequestResponseType.ARRAYBUFFER;
			case BLOB:		return XMLHttpRequestResponseType.BLOB;
			case XML:		return XMLHttpRequestResponseType.DOCUMENT;
			case JSON:		return XMLHttpRequestResponseType.JSON;
			default:		return XMLHttpRequestResponseType.TEXT;
		}
	}
	
	
	
	////////////////////
	//   PROPERTIES   //
	////////////////////
	
	/**
	 * Загруженные данные с ключом по ID.
	 * Настоятельно <b>не рекомендуется</b> изменять этот объект, так-как это приведёт к некорректной работе Assets.
	 * Доступ открыт для более удобной работы, например, для пробега по всем ресурсам циклом.
	 * Не может быть null.
	 */
	public var data(default, null):Dynamic = {};
	
	/**
	 * Объём загруженных данных хранилища в байтах.
	 * По умолчанию: 0.
	 */
	public var bytesLoaded(default, null):Int = 0;
	
	/**
	 * Общий объём данных хранилища в байтах. (Загруженных и не загруженных)
	 * По умолчанию: 0.
	 */
	public var bytesTotal(default, null):Int = 0;
	
	/**
	 * Счётчик ресурсов.
	 * По умолчанию: 0.
	 */
	public var length(default, null):Int = 0;
	
	/**
	 * Колбек прогресса загрузки.
	 * На вход получает: `bytesLoaded` и `bytesTotal`. (В указанном порядке)
	 * По умолчанию: null.
	 */
	public var onProgress:Int->Int->Void = null;
	
	/**
	 * Колбек завершения загрузки.
	 * Вызывается после завершения загрузки последнего, не загруженного ресурса.
	 * По умолчанию: null.
	 */
	public var onComplete:Void->Void = null;
	
	/**
	 * ID Таймаута.
	 * Используется для вызова обновления объекта Assets.
	 * По умолчанию: 0.
	 */
	private var setTimeoutID:Int = 0;
	
	
	
	/////////////////
	//   METHODS   //
	/////////////////
	
	/**
	 * Получить загруженные данные.
	 * Возвращает загруженные данные по указанному ID или null, если таких данных нет.
	 * @param	id ID Ресурса.
	 * @return	Загруженные данные.
	 */
	public function get(id:String):Dynamic {
		var r:Resource = untyped data[id];
		if (r == null)
			return null;
		
		return r.data;
	}
	
	/**
	 * Получить контейнер загружаемых данных.
	 * Возвращает контейнер загружаемых данных по указанному ID или null, если такого ID нет.
	 * @param	id ID Загружаемых ресурсов.
	 * @return	Контейнер с загружаемыми данными.
	 */
	public inline function getItem(id:String):Resource {
		return untyped data[id];
	}
	
	/**
	 * Удалить загруженные данные.
	 * Возвращает true, если данные по указанному ID удалены.
	 * Этот метод не прерывает уже начатую загрузку, а просто удаляет ссылку для сбора мусора.
	 * @param	id ID Загружаемых ресурсов.
	 * @return	True, если ресурс с указанным ID был удалён.
	 */
	public function remove(id:String):Bool {
		var item = getItem(id);
		if (item == null)
			return false;
		
		Syntax.code("delete {0}[{1}];", data, id); // for start
		
		return true;
	}
	
	/**
	 * Загрузить ресурс.
	 * Сразу начинает процесс загрузки указанного ресурса.
	 * @param	id		ID Ресурса.
	 * @param	url		URL Адрес ресурса.
	 * @param	type	Тип загружаемого ресурса.
	 * @return	Возвращает зарегистрированный объект Resource для запрошенного ресурса.
	 */
	public function load(id:String, url:String, type:ResourceType = ResourceType.TEXT):Resource {
		if (id == null)
			throw new Error("ID Ресурса не должен быть null");
		
		var item:Resource = untyped data[id];
		if (item != null)
			throw new Error("Ресурс с id=" + id + " уже был зарегистрирован ранее");
		
		item = {
			type:			type,
			data:			null,
			error:			null,
			loaded:			false,
			bytesTotal:		0,
			bytesLoaded:	0
		};
		untyped data[id] = item;
		
		var xhr = new XMLHttpRequest();
		xhr.responseType = toXhrType(type);
		xhr.onprogress = function(e:ProgressEvent) {
			untyped item.bytesLoaded	= e.loaded;
			untyped item.bytesTotal		= e.total;
			
			if (setTimeoutID == 0)
				setTimeoutID = Browser.window.setTimeout(update, 50);
		}
		xhr.onerror = function(e:ErrorEvent) {
			untyped item.error			= e == null?null:e;
			
			if (setTimeoutID == 0)
				setTimeoutID = Browser.window.setTimeout(update, 50);
		}
		xhr.onloadend = function(e:ProgressEvent) {
			untyped item.loaded			= true;
			untyped item.bytesLoaded	= e.loaded;
			untyped item.bytesTotal		= e.total;
			untyped item.data			= xhr.response;
			
			if (setTimeoutID == 0)
				setTimeoutID = Browser.window.setTimeout(update, 50);
		}
		
		xhr.open("GET", url, true);
		xhr.send();
		
		return item;
	}
	
	/**
	 * Обновить содержимое Assets.
	 * Этот метод вызывается во время загрузки и после её завершения для расчёта прогресса и вызова колбеков.
	 */
	private function update():Void {
		setTimeoutID = 0;
		
		length		= 0;
		bytesTotal	= 0;
		bytesLoaded	= 0;
		
		// Нативный цикл, так-как Haxe генерирует не оптимальный код:
		var key:String = null;
		var completed:Bool = true;
		Syntax.code("for ({0} in {1}) {", key, data); // for start
			
			var item:Resource = untyped data[key];
			bytesTotal += item.bytesTotal;
			bytesLoaded += item.bytesLoaded;
			length ++;
			
			if (!item.loaded)
				completed = false;
				
		Syntax.code("}"); // for end
		
		// Колбеки:
		if (onProgress != null)
			onProgress(bytesLoaded, bytesTotal);
			
		if (completed && onComplete != null)
			onComplete();
	}
}