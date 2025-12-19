package three.math;

import three.math.MathUtils;
import three.math.Euler.EulerOrder;

/**
 * Quaternion representing a rotation
 */
class Quaternion
{
    // Use backing fields for x, y, z, w with getters/setters to trigger onChange
    private var _x:Float;
    private var _y:Float;
    private var _z:Float;
    private var _w:Float;

    public var x(get, set):Float;
    public var y(get, set):Float;
    public var z(get, set):Float;
    public var w(get, set):Float;

    public var isQuaternion(default, never):Bool = true;

    private var _onChangeCallback:Void -> Void;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1)
    {
        _x = x;
        _y = y;
        _z = z;
        _w = w;
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

    private function get_w():Float
    {
        return _w;
    }

    private function set_w(value:Float):Float
    {
        _w = value;
        onChangeCallback();
        return _w;
    }

    public function set(x:Float, y:Float, z:Float, w:Float):Quaternion
    {
        _x = x;
        _y = y;
        _z = z;
        _w = w;

        onChangeCallback();

        return this;
    }

    public function clone():Quaternion
    {
        return new Quaternion(_x, _y, _z, _w);
    }

    public function copy(q:Quaternion):Quaternion
    {
        _x = q._x;
        _y = q._y;
        _z = q._z;
        _w = q._w;

        onChangeCallback();

        return this;
    }

    public function setFromEuler(euler:Euler, update:Bool = true):Quaternion
    {
        var ex = euler.x;
        var ey = euler.y;
        var ez = euler.z;
        var order = euler.order;

        var c1 = Math.cos(ex / 2);
        var c2 = Math.cos(ey / 2);
        var c3 = Math.cos(ez / 2);

        var s1 = Math.sin(ex / 2);
        var s2 = Math.sin(ey / 2);
        var s3 = Math.sin(ez / 2);

        var orderStr:String = order;
        if (orderStr == "XYZ")
        {
            _x = s1 * c2 * c3 + c1 * s2 * s3;
            _y = c1 * s2 * c3 - s1 * c2 * s3;
            _z = c1 * c2 * s3 + s1 * s2 * c3;
            _w = c1 * c2 * c3 - s1 * s2 * s3;
        }
        else if (orderStr == "YXZ")
        {
            _x = s1 * c2 * c3 + c1 * s2 * s3;
            _y = c1 * s2 * c3 - s1 * c2 * s3;
            _z = c1 * c2 * s3 - s1 * s2 * c3;
            _w = c1 * c2 * c3 + s1 * s2 * s3;
        }
        else if (orderStr == "ZXY")
        {
            _x = s1 * c2 * c3 - c1 * s2 * s3;
            _y = c1 * s2 * c3 + s1 * c2 * s3;
            _z = c1 * c2 * s3 + s1 * s2 * c3;
            _w = c1 * c2 * c3 - s1 * s2 * s3;
        }
        else if (orderStr == "ZYX")
        {
            _x = s1 * c2 * c3 - c1 * s2 * s3;
            _y = c1 * s2 * c3 + s1 * c2 * s3;
            _z = c1 * c2 * s3 - s1 * s2 * c3;
            _w = c1 * c2 * c3 + s1 * s2 * s3;
        }
        else if (orderStr == "YZX")
        {
            _x = s1 * c2 * c3 + c1 * s2 * s3;
            _y = c1 * s2 * c3 + s1 * c2 * s3;
            _z = c1 * c2 * s3 - s1 * s2 * c3;
            _w = c1 * c2 * c3 - s1 * s2 * s3;
        }
        else if (orderStr == "XZY")
        {
            _x = s1 * c2 * c3 - c1 * s2 * s3;
            _y = c1 * s2 * c3 - s1 * c2 * s3;
            _z = c1 * c2 * s3 + s1 * s2 * c3;
            _w = c1 * c2 * c3 + s1 * s2 * s3;
        }

        if (update) onChangeCallback();

        return this;
    }

    public function setFromAxisAngle(axis:Vector3, angle:Float):Quaternion
    {
        var halfAngle = angle / 2;
        var s = Math.sin(halfAngle);

        _x = axis.x * s;
        _y = axis.y * s;
        _z = axis.z * s;
        _w = Math.cos(halfAngle);

        onChangeCallback();

        return this;
    }

    public function setFromRotationMatrix(m:Matrix4):Quaternion
    {
        var te = m.elements;

        var m11 = te[0], m12 = te[4], m13 = te[8];
        var m21 = te[1], m22 = te[5], m23 = te[9];
        var m31 = te[2], m32 = te[6], m33 = te[10];

        var trace = m11 + m22 + m33;

        if (trace > 0)
        {
            var s = 0.5 / Math.sqrt(trace + 1.0);
            _w = 0.25 / s;
            _x = (m32 - m23) * s;
            _y = (m13 - m31) * s;
            _z = (m21 - m12) * s;
        }
        else if (m11 > m22 && m11 > m33)
        {
            var s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
            _w = (m32 - m23) / s;
            _x = 0.25 * s;
            _y = (m12 + m21) / s;
            _z = (m13 + m31) / s;
        }
        else if (m22 > m33)
        {
            var s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
            _w = (m13 - m31) / s;
            _x = (m12 + m21) / s;
            _y = 0.25 * s;
            _z = (m23 + m32) / s;
        }
        else
        {
            var s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);
            _w = (m21 - m12) / s;
            _x = (m13 + m31) / s;
            _y = (m23 + m32) / s;
            _z = 0.25 * s;
        }

        onChangeCallback();

        return this;
    }

    public function setFromUnitVectors(vFrom:Vector3, vTo:Vector3):Quaternion
    {
        var r = vFrom.dot(vTo) + 1;

        if (r < 0.0000001)
        {
            r = 0;

            if (Math.abs(vFrom.x) > Math.abs(vFrom.z))
            {
                _x = -vFrom.y;
                _y = vFrom.x;
                _z = 0;
                _w = r;
            }
            else
            {
                _x = 0;
                _y = -vFrom.z;
                _z = vFrom.y;
                _w = r;
            }
        }
        else
        {
            _x = vFrom.y * vTo.z - vFrom.z * vTo.y;
            _y = vFrom.z * vTo.x - vFrom.x * vTo.z;
            _z = vFrom.x * vTo.y - vFrom.y * vTo.x;
            _w = r;
        }

        return normalize();
    }

    public function angleTo(q:Quaternion):Float
    {
        return 2 * Math.acos(Math.abs(MathUtils.clamp(dot(q), -1, 1)));
    }

    public function rotateTowards(q:Quaternion, step:Float):Quaternion
    {
        var angle = angleTo(q);

        if (angle == 0) return this;

        var t = Math.min(1, step / angle);

        slerp(q, t);

        return this;
    }

    public function identity():Quaternion
    {
        return set(0, 0, 0, 1);
    }

    public function invert():Quaternion
    {
        return conjugate();
    }

    public function conjugate():Quaternion
    {
        _x *= -1;
        _y *= -1;
        _z *= -1;

        onChangeCallback();

        return this;
    }

    public function dot(v:Quaternion):Float
    {
        return _x * v._x + _y * v._y + _z * v._z + _w * v._w;
    }

    public function lengthSq():Float
    {
        return _x * _x + _y * _y + _z * _z + _w * _w;
    }

    public function length():Float
    {
        return Math.sqrt(_x * _x + _y * _y + _z * _z + _w * _w);
    }

    public function normalize():Quaternion
    {
        var l = length();

        if (l == 0)
        {
            _x = 0;
            _y = 0;
            _z = 0;
            _w = 1;
        }
        else
        {
            l = 1 / l;
            _x *= l;
            _y *= l;
            _z *= l;
            _w *= l;
        }

        onChangeCallback();

        return this;
    }

    public function multiply(q:Quaternion):Quaternion
    {
        return multiplyQuaternions(this, q);
    }

    public function premultiply(q:Quaternion):Quaternion
    {
        return multiplyQuaternions(q, this);
    }

    public function multiplyQuaternions(a:Quaternion, b:Quaternion):Quaternion
    {
        var qax = a._x, qay = a._y, qaz = a._z, qaw = a._w;
        var qbx = b._x, qby = b._y, qbz = b._z, qbw = b._w;

        _x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
        _y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
        _z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
        _w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

        onChangeCallback();

        return this;
    }

    public function slerp(qb:Quaternion, t:Float):Quaternion
    {
        if (t == 0) return this;
        if (t == 1) return copy(qb);

        var x0 = _x, y0 = _y, z0 = _z, w0 = _w;

        var cosHalfTheta = w0 * qb._w + x0 * qb._x + y0 * qb._y + z0 * qb._z;

        if (cosHalfTheta < 0)
        {
            _w = -qb._w;
            _x = -qb._x;
            _y = -qb._y;
            _z = -qb._z;
            cosHalfTheta = -cosHalfTheta;
        }
        else
        {
            copy(qb);
        }

        if (cosHalfTheta >= 1.0)
        {
            _w = w0;
            _x = x0;
            _y = y0;
            _z = z0;
            return this;
        }

        var sqrSinHalfTheta = 1.0 - cosHalfTheta * cosHalfTheta;

        if (sqrSinHalfTheta <= 0.0000001)
        {
            var s = 1 - t;
            _w = s * w0 + t * _w;
            _x = s * x0 + t * _x;
            _y = s * y0 + t * _y;
            _z = s * z0 + t * _z;
            normalize();
            return this;
        }

        var sinHalfTheta = Math.sqrt(sqrSinHalfTheta);
        var halfTheta = Math.atan2(sinHalfTheta, cosHalfTheta);
        var ratioA = Math.sin((1 - t) * halfTheta) / sinHalfTheta;
        var ratioB = Math.sin(t * halfTheta) / sinHalfTheta;

        _w = w0 * ratioA + _w * ratioB;
        _x = x0 * ratioA + _x * ratioB;
        _y = y0 * ratioA + _y * ratioB;
        _z = z0 * ratioA + _z * ratioB;

        onChangeCallback();

        return this;
    }

    public function slerpQuaternions(qa:Quaternion, qb:Quaternion, t:Float):Quaternion
    {
        return copy(qa).slerp(qb, t);
    }

    public function random():Quaternion
    {
        var theta1 = 2 * Math.PI * Math.random();
        var theta2 = 2 * Math.PI * Math.random();
        var x0 = Math.random();
        var r1 = Math.sqrt(1 - x0);
        var r2 = Math.sqrt(x0);

        return set(
            r1 * Math.sin(theta1),
            r1 * Math.cos(theta1),
            r2 * Math.sin(theta2),
            r2 * Math.cos(theta2)
        );
    }

    public function equals(q:Quaternion):Bool
    {
        return q._x == _x && q._y == _y && q._z == _z && q._w == _w;
    }

    public function fromArray(array:Array<Float>, offset:Int = 0):Quaternion
    {
        _x = array[offset];
        _y = array[offset + 1];
        _z = array[offset + 2];
        _w = array[offset + 3];

        onChangeCallback();

        return this;
    }

    public function toArray(?array:Array<Float>, offset:Int = 0):Array<Float>
    {
        if (array == null) array = [];
        array[offset] = _x;
        array[offset + 1] = _y;
        array[offset + 2] = _z;
        array[offset + 3] = _w;
        return array;
    }

    public function onChange(callback:Void -> Void):Quaternion
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
}
