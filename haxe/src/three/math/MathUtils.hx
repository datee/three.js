package three.math;

/**
 * Math utility functions
 */
class MathUtils
{
    public static var DEG2RAD:Float = 0.017453292519943295; // Math.PI / 180
    public static var RAD2DEG:Float = 57.29577951308232; // 180 / Math.PI

    private static var _lut:Array<String> = null;

    /**
     * Generates a UUID string
     */
    public static function generateUUID():String
    {
        if (_lut == null)
        {
            _lut = [];
            for (i in 0...256)
            {
                _lut.push((i < 16 ? "0" : "") + StringTools.hex(i).toLowerCase());
            }
        }

        var d0 = Std.int(Math.random() * 0xffffffff);
        var d1 = Std.int(Math.random() * 0xffffffff);
        var d2 = Std.int(Math.random() * 0xffffffff);
        var d3 = Std.int(Math.random() * 0xffffffff);

        var uuid = _lut[d0 & 0xff] + _lut[(d0 >> 8) & 0xff] + _lut[(d0 >> 16) & 0xff] + _lut[(d0 >> 24) & 0xff] + "-" +
                   _lut[d1 & 0xff] + _lut[(d1 >> 8) & 0xff] + "-" +
                   _lut[((d1 >> 16) & 0x0f) | 0x40] + _lut[(d1 >> 24) & 0xff] + "-" +
                   _lut[(d2 & 0x3f) | 0x80] + _lut[(d2 >> 8) & 0xff] + "-" +
                   _lut[(d2 >> 16) & 0xff] + _lut[(d2 >> 24) & 0xff] +
                   _lut[d3 & 0xff] + _lut[(d3 >> 8) & 0xff] + _lut[(d3 >> 16) & 0xff] + _lut[(d3 >> 24) & 0xff];

        return uuid.toUpperCase();
    }

    /**
     * Clamps value between min and max
     */
    public static inline function clamp(value:Float, min:Float, max:Float):Float
    {
        return Math.max(min, Math.min(max, value));
    }

    /**
     * Euclidean modulo (always positive)
     */
    public static inline function euclideanModulo(n:Float, m:Float):Float
    {
        return ((n % m) + m) % m;
    }

    /**
     * Linear interpolation between x and y
     */
    public static inline function lerp(x:Float, y:Float, t:Float):Float
    {
        return (1 - t) * x + t * y;
    }

    /**
     * Maps value from one range to another
     */
    public static function mapLinear(x:Float, a1:Float, a2:Float, b1:Float, b2:Float):Float
    {
        return b1 + (x - a1) * (b2 - b1) / (a2 - a1);
    }

    /**
     * Inverse linear interpolation
     */
    public static function inverseLerp(x:Float, y:Float, value:Float):Float
    {
        if (x != y)
        {
            return (value - x) / (y - x);
        }
        else
        {
            return 0;
        }
    }

    /**
     * Converts degrees to radians
     */
    public static inline function degToRad(degrees:Float):Float
    {
        return degrees * DEG2RAD;
    }

    /**
     * Converts radians to degrees
     */
    public static inline function radToDeg(radians:Float):Float
    {
        return radians * RAD2DEG;
    }

    /**
     * Checks if value is power of two
     */
    public static inline function isPowerOfTwo(value:Int):Bool
    {
        return (value & (value - 1)) == 0 && value != 0;
    }

    /**
     * Returns the smallest power of two >= value
     */
    public static function ceilPowerOfTwo(value:Float):Int
    {
        return Std.int(Math.pow(2, Math.ceil(Math.log(value) / Math.log(2))));
    }

    /**
     * Returns the largest power of two <= value
     */
    public static function floorPowerOfTwo(value:Float):Int
    {
        return Std.int(Math.pow(2, Math.floor(Math.log(value) / Math.log(2))));
    }

    /**
     * Smooth step function
     */
    public static function smoothstep(x:Float, min:Float, max:Float):Float
    {
        if (x <= min) return 0;
        if (x >= max) return 1;

        x = (x - min) / (max - min);
        return x * x * (3 - 2 * x);
    }

    /**
     * Smoother step function
     */
    public static function smootherstep(x:Float, min:Float, max:Float):Float
    {
        if (x <= min) return 0;
        if (x >= max) return 1;

        x = (x - min) / (max - min);
        return x * x * x * (x * (x * 6 - 15) + 10);
    }

    /**
     * Random integer in range [low, high]
     */
    public static function randInt(low:Int, high:Int):Int
    {
        return low + Std.int(Math.random() * (high - low + 1));
    }

    /**
     * Random float in range [low, high]
     */
    public static function randFloat(low:Float, high:Float):Float
    {
        return low + Math.random() * (high - low);
    }

    /**
     * Random float in range [-range/2, range/2]
     */
    public static inline function randFloatSpread(range:Float):Float
    {
        return range * (0.5 - Math.random());
    }

    /**
     * Ping pong value between 0 and length
     */
    public static function pingpong(x:Float, length:Float = 1):Float
    {
        return length - Math.abs(euclideanModulo(x, length * 2) - length);
    }
}
