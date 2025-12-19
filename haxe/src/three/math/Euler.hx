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
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var order:EulerOrder;

    public var isEuler(default, never):Bool = true;

    private var _onChangeCallback:Void -> Void;

    public static var DEFAULT_ORDER:EulerOrder = EulerOrder.XYZ;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, ?order:EulerOrder)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.order = order != null ? order : DEFAULT_ORDER;
    }

    public function set(x:Float, y:Float, z:Float, ?order:EulerOrder):Euler
    {
        this.x = x;
        this.y = y;
        this.z = z;
        if (order != null) this.order = order;

        onChangeCallback();

        return this;
    }

    public function clone():Euler
    {
        return new Euler(x, y, z, order);
    }

    public function copy(euler:Euler):Euler
    {
        x = euler.x;
        y = euler.y;
        z = euler.z;
        order = euler.order;

        onChangeCallback();

        return this;
    }

    public function setFromRotationMatrix(m:Matrix4, ?order:EulerOrder, update:Bool = true):Euler
    {
        var te = m.elements;
        var m11 = te[0], m12 = te[4], m13 = te[8];
        var m21 = te[1], m22 = te[5], m23 = te[9];
        var m31 = te[2], m32 = te[6], m33 = te[10];

        if (order != null) this.order = order;

        switch (this.order)
        {
            case EulerOrder.XYZ:
                y = Math.asin(MathUtils.clamp(m13, -1, 1));
                if (Math.abs(m13) < 0.9999999)
                {
                    x = Math.atan2(-m23, m33);
                    z = Math.atan2(-m12, m11);
                }
                else
                {
                    x = Math.atan2(m32, m22);
                    z = 0;
                }

            case EulerOrder.YXZ:
                x = Math.asin(-MathUtils.clamp(m23, -1, 1));
                if (Math.abs(m23) < 0.9999999)
                {
                    y = Math.atan2(m13, m33);
                    z = Math.atan2(m21, m22);
                }
                else
                {
                    y = Math.atan2(-m31, m11);
                    z = 0;
                }

            case EulerOrder.ZXY:
                x = Math.asin(MathUtils.clamp(m32, -1, 1));
                if (Math.abs(m32) < 0.9999999)
                {
                    y = Math.atan2(-m31, m33);
                    z = Math.atan2(-m12, m22);
                }
                else
                {
                    y = 0;
                    z = Math.atan2(m21, m11);
                }

            case EulerOrder.ZYX:
                y = Math.asin(-MathUtils.clamp(m31, -1, 1));
                if (Math.abs(m31) < 0.9999999)
                {
                    x = Math.atan2(m32, m33);
                    z = Math.atan2(m21, m11);
                }
                else
                {
                    x = 0;
                    z = Math.atan2(-m12, m22);
                }

            case EulerOrder.YZX:
                z = Math.asin(MathUtils.clamp(m21, -1, 1));
                if (Math.abs(m21) < 0.9999999)
                {
                    x = Math.atan2(-m23, m22);
                    y = Math.atan2(-m31, m11);
                }
                else
                {
                    x = 0;
                    y = Math.atan2(m13, m33);
                }

            case EulerOrder.XZY:
                z = Math.asin(-MathUtils.clamp(m12, -1, 1));
                if (Math.abs(m12) < 0.9999999)
                {
                    x = Math.atan2(m32, m22);
                    y = Math.atan2(m13, m11);
                }
                else
                {
                    x = Math.atan2(-m23, m33);
                    y = 0;
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
        return euler.x == x && euler.y == y && euler.z == z && euler.order == order;
    }

    public function fromArray(array:Array<Float>):Euler
    {
        x = array[0];
        y = array[1];
        z = array[2];
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
        array[offset] = x;
        array[offset + 1] = y;
        array[offset + 2] = z;
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
