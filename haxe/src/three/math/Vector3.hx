package three.math;

import three.math.MathUtils;

/**
 * Class representing a 3D vector
 */
class Vector3
{
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public var isVector3(default, never):Bool = true;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function set(x:Float, y:Float, z:Float):Vector3
    {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    public function setScalar(scalar:Float):Vector3
    {
        this.x = scalar;
        this.y = scalar;
        this.z = scalar;
        return this;
    }

    public function setX(x:Float):Vector3
    {
        this.x = x;
        return this;
    }

    public function setY(y:Float):Vector3
    {
        this.y = y;
        return this;
    }

    public function setZ(z:Float):Vector3
    {
        this.z = z;
        return this;
    }

    public function setComponent(index:Int, value:Float):Vector3
    {
        switch (index)
        {
            case 0: x = value;
            case 1: y = value;
            case 2: z = value;
            default: throw "index out of range: " + index;
        }
        return this;
    }

    public function getComponent(index:Int):Float
    {
        switch (index)
        {
            case 0: return x;
            case 1: return y;
            case 2: return z;
            default: throw "index out of range: " + index;
        }
    }

    public function clone():Vector3
    {
        return new Vector3(x, y, z);
    }

    public function copy(v:Vector3):Vector3
    {
        x = v.x;
        y = v.y;
        z = v.z;
        return this;
    }

    public function add(v:Vector3):Vector3
    {
        x += v.x;
        y += v.y;
        z += v.z;
        return this;
    }

    public function addScalar(s:Float):Vector3
    {
        x += s;
        y += s;
        z += s;
        return this;
    }

    public function addVectors(a:Vector3, b:Vector3):Vector3
    {
        x = a.x + b.x;
        y = a.y + b.y;
        z = a.z + b.z;
        return this;
    }

    public function addScaledVector(v:Vector3, s:Float):Vector3
    {
        x += v.x * s;
        y += v.y * s;
        z += v.z * s;
        return this;
    }

    public function sub(v:Vector3):Vector3
    {
        x -= v.x;
        y -= v.y;
        z -= v.z;
        return this;
    }

    public function subScalar(s:Float):Vector3
    {
        x -= s;
        y -= s;
        z -= s;
        return this;
    }

    public function subVectors(a:Vector3, b:Vector3):Vector3
    {
        x = a.x - b.x;
        y = a.y - b.y;
        z = a.z - b.z;
        return this;
    }

    public function multiply(v:Vector3):Vector3
    {
        x *= v.x;
        y *= v.y;
        z *= v.z;
        return this;
    }

    public function multiplyScalar(scalar:Float):Vector3
    {
        x *= scalar;
        y *= scalar;
        z *= scalar;
        return this;
    }

    public function multiplyVectors(a:Vector3, b:Vector3):Vector3
    {
        x = a.x * b.x;
        y = a.y * b.y;
        z = a.z * b.z;
        return this;
    }

    public function applyMatrix3(m:Matrix3):Vector3
    {
        var tx = x;
        var ty = y;
        var tz = z;
        var e = m.elements;

        x = e[0] * tx + e[3] * ty + e[6] * tz;
        y = e[1] * tx + e[4] * ty + e[7] * tz;
        z = e[2] * tx + e[5] * ty + e[8] * tz;

        return this;
    }

    public function applyMatrix4(m:Matrix4):Vector3
    {
        var tx = x;
        var ty = y;
        var tz = z;
        var e = m.elements;

        var w = 1.0 / (e[3] * tx + e[7] * ty + e[11] * tz + e[15]);

        x = (e[0] * tx + e[4] * ty + e[8] * tz + e[12]) * w;
        y = (e[1] * tx + e[5] * ty + e[9] * tz + e[13]) * w;
        z = (e[2] * tx + e[6] * ty + e[10] * tz + e[14]) * w;

        return this;
    }

    public function applyQuaternion(q:Quaternion):Vector3
    {
        var vx = x;
        var vy = y;
        var vz = z;
        var qx = q.x;
        var qy = q.y;
        var qz = q.z;
        var qw = q.w;

        // t = 2 * cross(q.xyz, v)
        var tx = 2 * (qy * vz - qz * vy);
        var ty = 2 * (qz * vx - qx * vz);
        var tz = 2 * (qx * vy - qy * vx);

        // v + q.w * t + cross(q.xyz, t)
        x = vx + qw * tx + qy * tz - qz * ty;
        y = vy + qw * ty + qz * tx - qx * tz;
        z = vz + qw * tz + qx * ty - qy * tx;

        return this;
    }

    public function divide(v:Vector3):Vector3
    {
        x /= v.x;
        y /= v.y;
        z /= v.z;
        return this;
    }

    public function divideScalar(scalar:Float):Vector3
    {
        return multiplyScalar(1.0 / scalar);
    }

    public function min(v:Vector3):Vector3
    {
        x = Math.min(x, v.x);
        y = Math.min(y, v.y);
        z = Math.min(z, v.z);
        return this;
    }

    public function max(v:Vector3):Vector3
    {
        x = Math.max(x, v.x);
        y = Math.max(y, v.y);
        z = Math.max(z, v.z);
        return this;
    }

    public function clamp(min:Vector3, max:Vector3):Vector3
    {
        x = Math.max(min.x, Math.min(max.x, x));
        y = Math.max(min.y, Math.min(max.y, y));
        z = Math.max(min.z, Math.min(max.z, z));
        return this;
    }

    public function clampScalar(minVal:Float, maxVal:Float):Vector3
    {
        x = Math.max(minVal, Math.min(maxVal, x));
        y = Math.max(minVal, Math.min(maxVal, y));
        z = Math.max(minVal, Math.min(maxVal, z));
        return this;
    }

    public function clampLength(min:Float, max:Float):Vector3
    {
        var len = length();
        return divideScalar(len != 0 ? len : 1).multiplyScalar(Math.max(min, Math.min(max, len)));
    }

    public function floor():Vector3
    {
        x = Math.floor(x);
        y = Math.floor(y);
        z = Math.floor(z);
        return this;
    }

    public function ceil():Vector3
    {
        x = Math.ceil(x);
        y = Math.ceil(y);
        z = Math.ceil(z);
        return this;
    }

    public function round():Vector3
    {
        x = Math.round(x);
        y = Math.round(y);
        z = Math.round(z);
        return this;
    }

    public function roundToZero():Vector3
    {
        x = Math.floor(x);
        if (x < 0) x = Math.ceil(x);
        y = Math.floor(y);
        if (y < 0) y = Math.ceil(y);
        z = Math.floor(z);
        if (z < 0) z = Math.ceil(z);
        return this;
    }

    public function negate():Vector3
    {
        x = -x;
        y = -y;
        z = -z;
        return this;
    }

    public function dot(v:Vector3):Float
    {
        return x * v.x + y * v.y + z * v.z;
    }

    public function lengthSq():Float
    {
        return x * x + y * y + z * z;
    }

    public function length():Float
    {
        return Math.sqrt(x * x + y * y + z * z);
    }

    public function manhattanLength():Float
    {
        return Math.abs(x) + Math.abs(y) + Math.abs(z);
    }

    public function normalize():Vector3
    {
        return divideScalar(length() != 0 ? length() : 1);
    }

    public function setLength(len:Float):Vector3
    {
        return normalize().multiplyScalar(len);
    }

    public function lerp(v:Vector3, alpha:Float):Vector3
    {
        x += (v.x - x) * alpha;
        y += (v.y - y) * alpha;
        z += (v.z - z) * alpha;
        return this;
    }

    public function lerpVectors(v1:Vector3, v2:Vector3, alpha:Float):Vector3
    {
        x = v1.x + (v2.x - v1.x) * alpha;
        y = v1.y + (v2.y - v1.y) * alpha;
        z = v1.z + (v2.z - v1.z) * alpha;
        return this;
    }

    public function cross(v:Vector3):Vector3
    {
        return crossVectors(this, v);
    }

    public function crossVectors(a:Vector3, b:Vector3):Vector3
    {
        var ax = a.x;
        var ay = a.y;
        var az = a.z;
        var bx = b.x;
        var by = b.y;
        var bz = b.z;

        x = ay * bz - az * by;
        y = az * bx - ax * bz;
        z = ax * by - ay * bx;

        return this;
    }

    public function projectOnVector(v:Vector3):Vector3
    {
        var denominator = v.lengthSq();
        if (denominator == 0) return set(0, 0, 0);

        var scalar = v.dot(this) / denominator;
        return copy(v).multiplyScalar(scalar);
    }

    public function reflect(normal:Vector3):Vector3
    {
        // reflect incident vector off plane orthogonal to normal
        // normal is assumed to have unit length
        return sub(_vector.copy(normal).multiplyScalar(2 * dot(normal)));
    }

    public function angleTo(v:Vector3):Float
    {
        var denominator = Math.sqrt(lengthSq() * v.lengthSq());
        if (denominator == 0) return Math.PI / 2;

        var theta = dot(v) / denominator;
        return Math.acos(MathUtils.clamp(theta, -1, 1));
    }

    public function distanceTo(v:Vector3):Float
    {
        return Math.sqrt(distanceToSquared(v));
    }

    public function distanceToSquared(v:Vector3):Float
    {
        var dx = x - v.x;
        var dy = y - v.y;
        var dz = z - v.z;
        return dx * dx + dy * dy + dz * dz;
    }

    public function manhattanDistanceTo(v:Vector3):Float
    {
        return Math.abs(x - v.x) + Math.abs(y - v.y) + Math.abs(z - v.z);
    }

    public function setFromMatrixPosition(m:Matrix4):Vector3
    {
        var e = m.elements;
        x = e[12];
        y = e[13];
        z = e[14];
        return this;
    }

    public function setFromMatrixScale(m:Matrix4):Vector3
    {
        var sx = setFromMatrixColumn(m, 0).length();
        var sy = setFromMatrixColumn(m, 1).length();
        var sz = setFromMatrixColumn(m, 2).length();

        x = sx;
        y = sy;
        z = sz;

        return this;
    }

    public function setFromMatrixColumn(m:Matrix4, index:Int):Vector3
    {
        return fromArray(m.elements, index * 4);
    }

    public function setFromMatrix3Column(m:Matrix3, index:Int):Vector3
    {
        return fromArray(m.elements, index * 3);
    }

    public function equals(v:Vector3):Bool
    {
        return v.x == x && v.y == y && v.z == z;
    }

    public function fromArray(array:Array<Float>, offset:Int = 0):Vector3
    {
        x = array[offset];
        y = array[offset + 1];
        z = array[offset + 2];
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

    public function random():Vector3
    {
        x = Math.random();
        y = Math.random();
        z = Math.random();
        return this;
    }

    public function randomDirection():Vector3
    {
        var theta = Math.random() * Math.PI * 2;
        var u = Math.random() * 2 - 1;
        var c = Math.sqrt(1 - u * u);

        x = c * Math.cos(theta);
        y = u;
        z = c * Math.sin(theta);

        return this;
    }

    public function fromBufferAttribute(attribute:three.core.BufferAttribute, index:Int):Vector3
    {
        x = attribute.getX(index);
        y = attribute.getY(index);
        z = attribute.getZ(index);
        return this;
    }

    public function transformDirection(m:Matrix4):Vector3
    {
        var tx = x, ty = y, tz = z;
        var e = m.elements;

        x = e[0] * tx + e[4] * ty + e[8] * tz;
        y = e[1] * tx + e[5] * ty + e[9] * tz;
        z = e[2] * tx + e[6] * ty + e[10] * tz;

        return normalize();
    }

    // Static helper
    private static var _vector:Vector3 = new Vector3();
}
