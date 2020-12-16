package assets;

import haxe.Constraints.Function;

/**
 * Простой диспетчер событий.
 * 
 * Используется для возможности подписки и уведомления внешних
 * слушателей о произошедшем событии. Имеет очень простую
 * реализацию, чтобы не тянуть лишние зависимости.
 * 
 * *п.с. Для каждого **типа** события должен быть создан отдельный
 * экземпляр этого диспетчера.*
 */
class Dispatcher<T:Function>
{
    private var arr:Array<ListenerData> = new Array();
    private var dirt:Bool = false;

    /**
     * Создать новый диспетчер событий.
     */
    public function new() {
    }

    /**
     * Количество зарегистрированных слушателей.  
     * По умолчанию: `0`
     */
    public var length(default, null):Int = 0;

    /**
     * Добавить новый колбек для вызова.  
     * - Проверка на уникальность не выполняется, можно добавить один и тот
     *   же колбек дважды и тогда он будет вызван дважды!
     * - Вызов колбеков будет происходить в порядке их добавления в диспетчер.
     * - Вызов игнорируется, если в параметре `callback` передан `null`.
     * @param callback Функция для внешнего вызова.
     */
    public function on(callback:T):Void {
        if (callback == null)
            return;

        arr.push({
            callback: callback,
            one: false
        });
        length ++;
    }

    /**
     * Добавить новый колбек для вызова только один раз.  
     * Метод аналогичен `on()` с той разницей, что после первого вызова слушатель
     * будет автоматически удалён. (Только один вызов)
     * @param callback Функция для внешнего вызова.
     */
    public function once(callback:T):Void {
        if (callback == null)
            return;

        arr.push({
            callback: callback,
            one: true
        });
        length ++;
    }

    /**
     * Удалить колбек.  
     * Возвращается `true`, если был удалён один или более слушателей.
     * @param callback Функция внешнего вызова.
     * @return Возвращается `true`, если был удалён один или более слушателей.
     */
    public function off(callback:T):Bool {
        if (callback == null)
            return false;

        var i = arr.length;
        var result = false;
        while (i -- != 0) {
            var data = arr[i];
            if (data != null && data.callback == callback) {
                arr[i] = null;
                result = true;
                dirt = true;
                length --;
            }
        }

        return result;
    }

    /**
     * Удалить все слушатели.  
     * Приводит диспетчер в изначальное состояние.
     */
    public function clear():Void {
        arr = new Array();
        dirt = false;
        length = 0;
    }

    /**
     * Вызвать все зарегистрированные слушатели.  
     * - Вызов слушателей производится в порядке их добавления в диспетчер.
     * - Если в момент диспетчерезации будут добавлены новые слушатели, они
     *   не будут вызваны в **этом цикле** диспетчерезации.
     * - Если в момент диспетчерезации будут удалены некоторые слушатели,
     *   они не будут вызваны в **этом цикле** диспетчерезации.
     * - Если в момент диспетчерезации будет вызван метод `clear()`, дальнейшая
     *   диспетчерезация прекратится.
     * @param arg1 Первый аргумент, передаваемый в слушатели. (Опционально)
     * @param arg2 Второй аргумент, передаваемый в слушатели. (Опционально)
     * @param arg3 Третий аргумент, передаваемый в слушатели. (Опционально)
     */
    public function emit(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic):Void {
        if (length == 0)
            return;

        // Список может быть изменён:
        var i = 0;
        var arr2 = arr;
        var end = arr2.length;
        while (i < end) {
            if (arr2 != arr)
                return;

            var data = arr2[i];
            if (data != null) {
                if (data.one)
                    arr2[i] = null;

                if (arg3 != null)
                    data.callback(arg1, arg2, arg3);
                else if (arg2 != null)
                    data.callback(arg1, arg2);
                else if (arg1 != null)
                    data.callback(arg1);
                else
                    data.callback();
            }
            i ++;
        }

        // Подрезание списка при удалении из него элементов:
        if (dirt && arr2 == arr) {
            dirt = false;
            end = arr2.length;
            i = 0;
            
            var index = 0;
            while (i < end) {
                if (arr2[i] == null)
                    i ++;
                else
                    arr2[index++] = arr2[i++];
            }
            arr2.resize(index);
        }
    }

    /**
     * Проверить наличие слушателя в диспетчере.
     * - Возвращает `true`, если диспетчер содержит один или несколько указанных слушателей.
     * - Возвращает `false` во всех остальных случаях или при передаче `null`.
     * @param callback Слушатель.
     * @return Возвращает `true`, если диспетчер содержит один или несколько указанных слушателей. 
     */
    public function has(callback:T):Bool {
        if (callback == null || length == 0)
            return false;

        var i = arr.length;
        while (i-- != 0) {
            if (arr[i] != null && arr[i].callback == callback)
                return true;
        }

        return false;
    }
}

/**
 * Данные зарегистрированного слушателя.
 */
private typedef ListenerData =
{
    /**
     * Функция слушателя.
     */
    var callback:Function;

    /**
     * Только один вызов.
     */
    var one:Bool;
}