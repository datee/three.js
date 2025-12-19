package three.core;

/**
 * Event data structure
 */
typedef Event =
{
    var type:String;
    @:optional var target:Dynamic;
}

/**
 * JavaScript-style event dispatcher
 */
class EventDispatcher
{
    private var _listeners:Map<String, Array<Event -> Void>>;

    public function new()
    {
        _listeners = new Map();
    }

    public function addEventListener(type:String, listener:Event -> Void):Void
    {
        if (!_listeners.exists(type))
        {
            _listeners.set(type, []);
        }

        var listeners = _listeners.get(type);
        if (listeners.indexOf(listener) == -1)
        {
            listeners.push(listener);
        }
    }

    public function hasEventListener(type:String, listener:Event -> Void):Bool
    {
        if (!_listeners.exists(type))
        {
            return false;
        }
        return _listeners.get(type).indexOf(listener) != -1;
    }

    public function removeEventListener(type:String, listener:Event -> Void):Void
    {
        if (!_listeners.exists(type))
        {
            return;
        }

        var listeners = _listeners.get(type);
        var index = listeners.indexOf(listener);
        if (index != -1)
        {
            listeners.splice(index, 1);
        }
    }

    public function dispatchEvent(event:Event):Void
    {
        if (!_listeners.exists(event.type))
        {
            return;
        }

        event.target = this;

        var listeners = _listeners.get(event.type).copy();
        for (listener in listeners)
        {
            listener(event);
        }
    }
}
