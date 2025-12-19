package three.core;

import three.math.MathUtils;

/**
 * Buffer attribute storing vertex data
 */
class BufferAttribute
{
    public var name:String;
    public var array:Array<Float>;
    public var itemSize:Int;
    public var count(get, never):Int;
    public var normalized:Bool;
    public var usage:Int;
    public var updateRange:{offset:Int, count:Int};

    public var version:Int;

    public var isBufferAttribute(default, never):Bool = true;

    public function new(?array:Array<Float>, itemSize:Int = 1, normalized:Bool = false)
    {
        name = "";
        this.array = array != null ? array : [];
        this.itemSize = itemSize;
        this.normalized = normalized;

        usage = 35044; // StaticDrawUsage
        updateRange = {offset: 0, count: -1};

        version = 0;
    }

    private function get_count():Int
    {
        return Std.int(array.length / itemSize);
    }

    public function setUsage(usage:Int):BufferAttribute
    {
        this.usage = usage;
        return this;
    }

    public function copy(source:BufferAttribute):BufferAttribute
    {
        name = source.name;
        array = source.array.copy();
        itemSize = source.itemSize;
        normalized = source.normalized;
        usage = source.usage;
        return this;
    }

    public function copyAt(index1:Int, attribute:BufferAttribute, index2:Int):BufferAttribute
    {
        index1 *= itemSize;
        index2 *= attribute.itemSize;

        for (i in 0...itemSize)
        {
            array[index1 + i] = attribute.array[index2 + i];
        }

        return this;
    }

    public function copyArray(arr:Array<Float>):BufferAttribute
    {
        array = arr.copy();
        return this;
    }

    public function applyMatrix3(m:three.math.Matrix3):BufferAttribute
    {
        var i = 0;
        while (i < count)
        {
            _vector.fromBufferAttribute(this, i);
            _vector.applyMatrix3(m);
            setXYZ(i, _vector.x, _vector.y, _vector.z);
            i++;
        }
        return this;
    }

    public function applyMatrix4(m:three.math.Matrix4):BufferAttribute
    {
        var i = 0;
        while (i < count)
        {
            _vector.fromBufferAttribute(this, i);
            _vector.applyMatrix4(m);
            setXYZ(i, _vector.x, _vector.y, _vector.z);
            i++;
        }
        return this;
    }

    public function applyNormalMatrix(m:three.math.Matrix3):BufferAttribute
    {
        var i = 0;
        while (i < count)
        {
            _vector.fromBufferAttribute(this, i);
            _vector.applyMatrix3(m).normalize();
            setXYZ(i, _vector.x, _vector.y, _vector.z);
            i++;
        }
        return this;
    }

    public function transformDirection(m:three.math.Matrix4):BufferAttribute
    {
        var i = 0;
        while (i < count)
        {
            _vector.fromBufferAttribute(this, i);
            _vector.transformDirection(m);
            setXYZ(i, _vector.x, _vector.y, _vector.z);
            i++;
        }
        return this;
    }

    public function set(value:Array<Float>, offset:Int = 0):BufferAttribute
    {
        for (i in 0...value.length)
        {
            array[offset + i] = value[i];
        }
        return this;
    }

    public function getComponent(index:Int, component:Int):Float
    {
        return array[index * itemSize + component];
    }

    public function setComponent(index:Int, component:Int, value:Float):BufferAttribute
    {
        array[index * itemSize + component] = value;
        return this;
    }

    public function getX(index:Int):Float
    {
        return array[index * itemSize];
    }

    public function setX(index:Int, x:Float):BufferAttribute
    {
        array[index * itemSize] = x;
        return this;
    }

    public function getY(index:Int):Float
    {
        return array[index * itemSize + 1];
    }

    public function setY(index:Int, y:Float):BufferAttribute
    {
        array[index * itemSize + 1] = y;
        return this;
    }

    public function getZ(index:Int):Float
    {
        return array[index * itemSize + 2];
    }

    public function setZ(index:Int, z:Float):BufferAttribute
    {
        array[index * itemSize + 2] = z;
        return this;
    }

    public function getW(index:Int):Float
    {
        return array[index * itemSize + 3];
    }

    public function setW(index:Int, w:Float):BufferAttribute
    {
        array[index * itemSize + 3] = w;
        return this;
    }

    public function setXY(index:Int, x:Float, y:Float):BufferAttribute
    {
        index *= itemSize;
        array[index] = x;
        array[index + 1] = y;
        return this;
    }

    public function setXYZ(index:Int, x:Float, y:Float, z:Float):BufferAttribute
    {
        index *= itemSize;
        array[index] = x;
        array[index + 1] = y;
        array[index + 2] = z;
        return this;
    }

    public function setXYZW(index:Int, x:Float, y:Float, z:Float, w:Float):BufferAttribute
    {
        index *= itemSize;
        array[index] = x;
        array[index + 1] = y;
        array[index + 2] = z;
        array[index + 3] = w;
        return this;
    }

    public function clone():BufferAttribute
    {
        return new BufferAttribute(array.copy(), itemSize, normalized).copy(this);
    }

    public function needsUpdate(value:Bool):Void
    {
        if (value) version++;
    }

    // Static helper
    private static var _vector:Vector3Helper = new Vector3Helper();
}

// Helper class to avoid circular dependency
private class Vector3Helper
{
    public var x:Float = 0;
    public var y:Float = 0;
    public var z:Float = 0;

    public function new() {}

    public function fromBufferAttribute(attr:BufferAttribute, index:Int):Vector3Helper
    {
        x = attr.getX(index);
        y = attr.getY(index);
        z = attr.getZ(index);
        return this;
    }

    public function applyMatrix3(m:three.math.Matrix3):Vector3Helper
    {
        var tx = x, ty = y, tz = z;
        var e = m.elements;
        x = e[0] * tx + e[3] * ty + e[6] * tz;
        y = e[1] * tx + e[4] * ty + e[7] * tz;
        z = e[2] * tx + e[5] * ty + e[8] * tz;
        return this;
    }

    public function applyMatrix4(m:three.math.Matrix4):Vector3Helper
    {
        var tx = x, ty = y, tz = z;
        var e = m.elements;
        var w = 1.0 / (e[3] * tx + e[7] * ty + e[11] * tz + e[15]);
        x = (e[0] * tx + e[4] * ty + e[8] * tz + e[12]) * w;
        y = (e[1] * tx + e[5] * ty + e[9] * tz + e[13]) * w;
        z = (e[2] * tx + e[6] * ty + e[10] * tz + e[14]) * w;
        return this;
    }

    public function normalize():Vector3Helper
    {
        var len = Math.sqrt(x * x + y * y + z * z);
        if (len > 0)
        {
            x /= len;
            y /= len;
            z /= len;
        }
        return this;
    }

    public function transformDirection(m:three.math.Matrix4):Vector3Helper
    {
        var tx = x, ty = y, tz = z;
        var e = m.elements;
        x = e[0] * tx + e[4] * ty + e[8] * tz;
        y = e[1] * tx + e[5] * ty + e[9] * tz;
        z = e[2] * tx + e[6] * ty + e[10] * tz;
        return normalize();
    }
}

/**
 * Float32 buffer attribute
 */
class Float32BufferAttribute extends BufferAttribute
{
    public function new(array:Array<Float>, itemSize:Int, normalized:Bool = false)
    {
        super(array, itemSize, normalized);
    }
}

/**
 * Int32 buffer attribute (for indices)
 */
class Uint32BufferAttribute extends BufferAttribute
{
    public function new(array:Array<Float>, itemSize:Int, normalized:Bool = false)
    {
        super(array, itemSize, normalized);
    }
}

/**
 * Int16 buffer attribute (for indices)
 */
class Uint16BufferAttribute extends BufferAttribute
{
    public function new(array:Array<Float>, itemSize:Int, normalized:Bool = false)
    {
        super(array, itemSize, normalized);
    }
}
