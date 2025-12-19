package three.math;

import three.math.MathUtils;

/**
 * Quaternion representing a rotation
 */
class Quaternion
{
    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var w:Float;

    public var isQuaternion(default, never):Bool = true;

    private var _onChangeCallback:Void -> Void;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public function set(x:Float, y:Float, z:Float, w:Float):Quaternion
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;

        onChangeCallback();

        return this;
    }

    public function clone():Quaternion
    {
        return new Quaternion(x, y, z, w);
    }

    public function copy(q:Quaternion):Quaternion
    {
        x = q.x;
        y = q.y;
        z = q.z;
        w = q.w;

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

        switch (order)
        {
            case EulerOrder.XYZ:
                x = s1 * c2 * c3 + c1 * s2 * s3;
                y = c1 * s2 * c3 - s1 * c2 * s3;
                z = c1 * c2 * s3 + s1 * s2 * c3;
                w = c1 * c2 * c3 - s1 * s2 * s3;

            case EulerOrder.YXZ:
                x = s1 * c2 * c3 + c1 * s2 * s3;
                y = c1 * s2 * c3 - s1 * c2 * s3;
                z = c1 * c2 * s3 - s1 * s2 * c3;
                w = c1 * c2 * c3 + s1 * s2 * s3;

            case EulerOrder.ZXY:
                x = s1 * c2 * c3 - c1 * s2 * s3;
                y = c1 * s2 * c3 + s1 * c2 * s3;
                z = c1 * c2 * s3 + s1 * s2 * c3;
                w = c1 * c2 * c3 - s1 * s2 * s3;

            case EulerOrder.ZYX:
                x = s1 * c2 * c3 - c1 * s2 * s3;
                y = c1 * s2 * c3 + s1 * c2 * s3;
                z = c1 * c2 * s3 - s1 * s2 * c3;
                w = c1 * c2 * c3 + s1 * s2 * s3;

            case EulerOrder.YZX:
                x = s1 * c2 * c3 + c1 * s2 * s3;
                y = c1 * s2 * c3 + s1 * c2 * s3;
                z = c1 * c2 * s3 - s1 * s2 * c3;
                w = c1 * c2 * c3 - s1 * s2 * s3;

            case EulerOrder.XZY:
                x = s1 * c2 * c3 - c1 * s2 * s3;
                y = c1 * s2 * c3 - s1 * c2 * s3;
                z = c1 * c2 * s3 + s1 * s2 * c3;
                w = c1 * c2 * c3 + s1 * s2 * s3;
        }

        if (update) onChangeCallback();

        return this;
    }

    public function setFromAxisAngle(axis:Vector3, angle:Float):Quaternion
    {
        var halfAngle = angle / 2;
        var s = Math.sin(halfAngle);

        x = axis.x * s;
        y = axis.y * s;
        z = axis.z * s;
        w = Math.cos(halfAngle);

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
            w = 0.25 / s;
            x = (m32 - m23) * s;
            y = (m13 - m31) * s;
            z = (m21 - m12) * s;
        }
        else if (m11 > m22 && m11 > m33)
        {
            var s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
            w = (m32 - m23) / s;
            x = 0.25 * s;
            y = (m12 + m21) / s;
            z = (m13 + m31) / s;
        }
        else if (m22 > m33)
        {
            var s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
            w = (m13 - m31) / s;
            x = (m12 + m21) / s;
            y = 0.25 * s;
            z = (m23 + m32) / s;
        }
        else
        {
            var s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);
            w = (m21 - m12) / s;
            x = (m13 + m31) / s;
            y = (m23 + m32) / s;
            z = 0.25 * s;
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
                x = -vFrom.y;
                y = vFrom.x;
                z = 0;
                w = r;
            }
            else
            {
                x = 0;
                y = -vFrom.z;
                z = vFrom.y;
                w = r;
            }
        }
        else
        {
            x = vFrom.y * vTo.z - vFrom.z * vTo.y;
            y = vFrom.z * vTo.x - vFrom.x * vTo.z;
            z = vFrom.x * vTo.y - vFrom.y * vTo.x;
            w = r;
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
        x *= -1;
        y *= -1;
        z *= -1;

        onChangeCallback();

        return this;
    }

    public function dot(v:Quaternion):Float
    {
        return x * v.x + y * v.y + z * v.z + w * v.w;
    }

    public function lengthSq():Float
    {
        return x * x + y * y + z * z + w * w;
    }

    public function length():Float
    {
        return Math.sqrt(x * x + y * y + z * z + w * w);
    }

    public function normalize():Quaternion
    {
        var l = length();

        if (l == 0)
        {
            x = 0;
            y = 0;
            z = 0;
            w = 1;
        }
        else
        {
            l = 1 / l;
            x *= l;
            y *= l;
            z *= l;
            w *= l;
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
        var qax = a.x, qay = a.y, qaz = a.z, qaw = a.w;
        var qbx = b.x, qby = b.y, qbz = b.z, qbw = b.w;

        x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
        y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
        z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
        w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

        onChangeCallback();

        return this;
    }

    public function slerp(qb:Quaternion, t:Float):Quaternion
    {
        if (t == 0) return this;
        if (t == 1) return copy(qb);

        var x0 = x, y0 = y, z0 = z, w0 = w;

        var cosHalfTheta = w0 * qb.w + x0 * qb.x + y0 * qb.y + z0 * qb.z;

        if (cosHalfTheta < 0)
        {
            w = -qb.w;
            x = -qb.x;
            y = -qb.y;
            z = -qb.z;
            cosHalfTheta = -cosHalfTheta;
        }
        else
        {
            copy(qb);
        }

        if (cosHalfTheta >= 1.0)
        {
            w = w0;
            x = x0;
            y = y0;
            z = z0;
            return this;
        }

        var sqrSinHalfTheta = 1.0 - cosHalfTheta * cosHalfTheta;

        if (sqrSinHalfTheta <= 0.0000001)
        {
            var s = 1 - t;
            w = s * w0 + t * w;
            x = s * x0 + t * x;
            y = s * y0 + t * y;
            z = s * z0 + t * z;
            normalize();
            return this;
        }

        var sinHalfTheta = Math.sqrt(sqrSinHalfTheta);
        var halfTheta = Math.atan2(sinHalfTheta, cosHalfTheta);
        var ratioA = Math.sin((1 - t) * halfTheta) / sinHalfTheta;
        var ratioB = Math.sin(t * halfTheta) / sinHalfTheta;

        w = w0 * ratioA + w * ratioB;
        x = x0 * ratioA + x * ratioB;
        y = y0 * ratioA + y * ratioB;
        z = z0 * ratioA + z * ratioB;

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
        return q.x == x && q.y == y && q.z == z && q.w == w;
    }

    public function fromArray(array:Array<Float>, offset:Int = 0):Quaternion
    {
        x = array[offset];
        y = array[offset + 1];
        z = array[offset + 2];
        w = array[offset + 3];

        onChangeCallback();

        return this;
    }

    public function toArray(?array:Array<Float>, offset:Int = 0):Array<Float>
    {
        if (array == null) array = [];
        array[offset] = x;
        array[offset + 1] = y;
        array[offset + 2] = z;
        array[offset + 3] = w;
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
