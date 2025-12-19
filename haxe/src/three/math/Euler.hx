package three.math;

import three.math.MathUtils;

/**
 * Euler order enumeration
 */
enum abstract EulerOrder(String) to String
{
    var XYZ = "XYZ";
    var YXZ = "YXZ";
    var ZXY = "ZXY";
    var ZYX = "ZYX";
    var YZX = "YZX";
    var XZY = "XZY";
}

/**
 * Euler angles representing a rotation
 */
class Euler
{
    // Use backing fields for x, y, z with getters/setters to trigger onChange
    private var _x:Float;
    private var _y:Float;
    private var _z:Float;
    private var _order:EulerOrder;

    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var order(get, set):EulerOrder;

    public var isEuler(default, never):Bool = true;

    private var _onChangeCallback:Void -> Void;

    public static var DEFAULT_ORDER:EulerOrder = EulerOrder.XYZ;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, ?order:EulerOrder)
    {
        _x = x;
        _y = y;
        _z = z;
        _order = order != null ? order : DEFAULT_ORDER;
    }

    // Property getters and setters
    private function get_x():Float
    {
        return _x;
    }

    private function set_x(value:Float):Float
    {
        _x = value;
        onChangeCallback();
        return _x;
    }

    private function get_y():Float
    {
        return _y;
    }

    private function set_y(value:Float):Float
    {
        _y = value;
        onChangeCallback();
        return _y;
    }

    private function get_z():Float
    {
        return _z;
    }

    private function set_z(value:Float):Float
    {
        _z = value;
        onChangeCallback();
        return _z;
    }

    private function get_order():EulerOrder
    {
        return _order;
    }

    private function set_order(value:EulerOrder):EulerOrder
    {
        _order = value;
        onChangeCallback();
        return _order;
    }

    public function set(x:Float, y:Float, z:Float, ?order:EulerOrder):Euler
    {
        _x = x;
        _y = y;
        _z = z;
        if (order != null) _order = order;

        onChangeCallback();

        return this;
    }

    public function clone():Euler
    {
        return new Euler(_x, _y, _z, _order);
    }

    public function copy(euler:Euler):Euler
    {
        _x = euler._x;
        _y = euler._y;
        _z = euler._z;
        _order = euler._order;

        onChangeCallback();

        return this;
    }

    public function setFromRotationMatrix(m:Matrix4, ?order:EulerOrder, update:Bool = true):Euler
    {
        var te = m.elements;
        var m11 = te[0], m12 = te[4], m13 = te[8];
        var m21 = te[1], m22 = te[5], m23 = te[9];
        var m31 = te[2], m32 = te[6], m33 = te[10];

        if (order != null) _order = order;

        switch (_order)
        {
            case EulerOrder.XYZ:
                _y = Math.asin(MathUtils.clamp(m13, -1, 1));
                if (Math.abs(m13) < 0.9999999)
                {
                    _x = Math.atan2(-m23, m33);
                    _z = Math.atan2(-m12, m11);
                }
                else
                {
                    _x = Math.atan2(m32, m22);
                    _z = 0;
                }

            case EulerOrder.YXZ:
                _x = Math.asin(-MathUtils.clamp(m23, -1, 1));
                if (Math.abs(m23) < 0.9999999)
                {
                    _y = Math.atan2(m13, m33);
                    _z = Math.atan2(m21, m22);
                }
                else
                {
                    _y = Math.atan2(-m31, m11);
                    _z = 0;
                }

            case EulerOrder.ZXY:
                _x = Math.asin(MathUtils.clamp(m32, -1, 1));
                if (Math.abs(m32) < 0.9999999)
                {
                    _y = Math.atan2(-m31, m33);
                    _z = Math.atan2(-m12, m22);
                }
                else
                {
                    _y = 0;
                    _z = Math.atan2(m21, m11);
                }

            case EulerOrder.ZYX:
                _y = Math.asin(-MathUtils.clamp(m31, -1, 1));
                if (Math.abs(m31) < 0.9999999)
                {
                    _x = Math.atan2(m32, m33);
                    _z = Math.atan2(m21, m11);
                }
                else
                {
                    _x = 0;
                    _z = Math.atan2(-m12, m22);
                }

            case EulerOrder.YZX:
                _z = Math.asin(MathUtils.clamp(m21, -1, 1));
                if (Math.abs(m21) < 0.9999999)
                {
                    _x = Math.atan2(-m23, m22);
                    _y = Math.atan2(-m31, m11);
                }
                else
                {
                    _x = 0;
                    _y = Math.atan2(m13, m33);
                }

            case EulerOrder.XZY:
                _z = Math.asin(-MathUtils.clamp(m12, -1, 1));
                if (Math.abs(m12) < 0.9999999)
                {
                    _x = Math.atan2(m32, m22);
                    _y = Math.atan2(m13, m11);
                }
                else
                {
                    _x = Math.atan2(-m23, m33);
                    _y = 0;
                }
        }

        if (update) onChangeCallback();

        return this;
    }

    public function setFromQuaternion(q:Quaternion, ?order:EulerOrder, update:Bool = true):Euler
    {
        _matrix.makeRotationFromQuaternion(q);
        return setFromRotationMatrix(_matrix, order, update);
    }

    public function setFromVector3(v:Vector3, ?order:EulerOrder):Euler
    {
        return set(v.x, v.y, v.z, order);
    }

    public function reorder(newOrder:EulerOrder):Euler
    {
        _quaternion.setFromEuler(this);
        return setFromQuaternion(_quaternion, newOrder);
    }

    public function equals(euler:Euler):Bool
    {
        return euler._x == _x && euler._y == _y && euler._z == _z && euler._order == _order;
    }

    public function fromArray(array:Array<Float>):Euler
    {
        _x = array[0];
        _y = array[1];
        _z = array[2];
        if (array.length > 3)
        {
            // Order would need to be parsed from string
        }

        onChangeCallback();

        return this;
    }

    public function toArray(?array:Array<Float>, offset:Int = 0):Array<Float>
    {
        if (array == null) array = [];
        array[offset] = _x;
        array[offset + 1] = _y;
        array[offset + 2] = _z;
        return array;
    }

    public function onChange(callback:Void -> Void):Euler
    {
        _onChangeCallback = callback;
        return this;
    }

    private function onChangeCallback():Void
    {
        if (_onChangeCallback != null)
        {
            _onChangeCallback();
        }
    }

    // Static helpers
    private static var _matrix:Matrix4 = new Matrix4();
    private static var _quaternion:Quaternion = new Quaternion();
}
