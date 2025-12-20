package three.math;

import three.math.MathUtils;

/**
 * Class representing a color
 */
class Color
{
    public var r:Float;
    public var g:Float;
    public var b:Float;

    public var isColor(default, never):Bool = true;

    public function new(?r:Dynamic, ?g:Float, ?b:Float)
    {
        this.r = 1;
        this.g = 1;
        this.b = 1;

        if (r != null)
        {
            set(r, g, b);
        }
    }

    public function set(?r:Dynamic, ?g:Float, ?b:Float):Color
    {
        if (g == null && b == null)
        {
            // r is hex, string, or Color
            if (Std.isOfType(r, Color))
            {
                copy(r);
            }
            else if (Std.isOfType(r, String))
            {
                setStyle(r);
            }
            else if (Std.isOfType(r, Int) || Std.isOfType(r, Float))
            {
                // In JavaScript, all numbers are floats, so check both Int and Float
                // Treat any number as a hex color value
                setHex(Std.int(r));
            }
        }
        else
        {
            setRGB(r, g, b);
        }

        return this;
    }

    public function setScalar(scalar:Float):Color
    {
        r = scalar;
        g = scalar;
        b = scalar;
        return this;
    }

    public function setHex(hex:Int):Color
    {
        r = ((hex >> 16) & 255) / 255;
        g = ((hex >> 8) & 255) / 255;
        b = (hex & 255) / 255;
        return this;
    }

    public function setRGB(r:Float, g:Float, b:Float):Color
    {
        this.r = r;
        this.g = g;
        this.b = b;
        return this;
    }

    public function setHSL(h:Float, s:Float, l:Float):Color
    {
        h = MathUtils.euclideanModulo(h, 1);
        s = MathUtils.clamp(s, 0, 1);
        l = MathUtils.clamp(l, 0, 1);

        if (s == 0)
        {
            r = g = b = l;
        }
        else
        {
            var p = l <= 0.5 ? l * (1 + s) : l + s - (l * s);
            var q = (2 * l) - p;

            r = hue2rgb(q, p, h + 1 / 3);
            g = hue2rgb(q, p, h);
            b = hue2rgb(q, p, h - 1 / 3);
        }

        return this;
    }

    private function hue2rgb(p:Float, q:Float, t:Float):Float
    {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * 6 * (2 / 3 - t);
        return p;
    }

    public function setStyle(style:String):Color
    {
        // Handle hex color
        if (StringTools.startsWith(style, "#"))
        {
            var hex = style.substr(1);
            if (hex.length == 3)
            {
                // Short form #RGB
                var r = Std.parseInt("0x" + hex.charAt(0));
                var g = Std.parseInt("0x" + hex.charAt(1));
                var b = Std.parseInt("0x" + hex.charAt(2));
                setRGB(r / 15, g / 15, b / 15);
            }
            else if (hex.length == 6)
            {
                // Long form #RRGGBB
                var hexInt = Std.parseInt("0x" + hex);
                setHex(hexInt);
            }
        }
        // Handle rgb() format
        else if (StringTools.startsWith(style, "rgb"))
        {
            var start = style.indexOf("(");
            var end = style.indexOf(")");
            if (start != -1 && end != -1)
            {
                var values = style.substring(start + 1, end).split(",");
                if (values.length >= 3)
                {
                    var rv = StringTools.trim(values[0]);
                    var gv = StringTools.trim(values[1]);
                    var bv = StringTools.trim(values[2]);

                    if (StringTools.endsWith(rv, "%"))
                    {
                        setRGB(
                            Std.parseFloat(rv.substr(0, rv.length - 1)) / 100,
                            Std.parseFloat(gv.substr(0, gv.length - 1)) / 100,
                            Std.parseFloat(bv.substr(0, bv.length - 1)) / 100
                        );
                    }
                    else
                    {
                        setRGB(
                            Std.parseFloat(rv) / 255,
                            Std.parseFloat(gv) / 255,
                            Std.parseFloat(bv) / 255
                        );
                    }
                }
            }
        }
        // Handle color names (basic set)
        else
        {
            var colorName = style.toLowerCase();
            var namedColors = getNamedColors();
            if (namedColors.exists(colorName))
            {
                setHex(namedColors.get(colorName));
            }
        }

        return this;
    }

    private static function getNamedColors():Map<String, Int>
    {
        if (_namedColors == null)
        {
            _namedColors = [
                "black" => 0x000000,
                "white" => 0xFFFFFF,
                "red" => 0xFF0000,
                "green" => 0x00FF00,
                "blue" => 0x0000FF,
                "yellow" => 0xFFFF00,
                "cyan" => 0x00FFFF,
                "magenta" => 0xFF00FF,
                "gray" => 0x808080,
                "grey" => 0x808080,
                "orange" => 0xFFA500,
                "purple" => 0x800080,
                "pink" => 0xFFC0CB,
                "brown" => 0xA52A2A,
                "lime" => 0x00FF00,
                "navy" => 0x000080,
                "teal" => 0x008080,
                "olive" => 0x808000,
                "maroon" => 0x800000,
                "silver" => 0xC0C0C0,
                "aqua" => 0x00FFFF,
                "fuchsia" => 0xFF00FF
            ];
        }
        return _namedColors;
    }

    private static var _namedColors:Map<String, Int>;

    public function clone():Color
    {
        return new Color(r, g, b);
    }

    public function copy(color:Color):Color
    {
        r = color.r;
        g = color.g;
        b = color.b;
        return this;
    }

    public function getHex():Int
    {
        return Std.int(MathUtils.clamp(r * 255, 0, 255)) * 65536 +
               Std.int(MathUtils.clamp(g * 255, 0, 255)) * 256 +
               Std.int(MathUtils.clamp(b * 255, 0, 255));
    }

    public function getHexString():String
    {
        return StringTools.hex(getHex(), 6).toLowerCase();
    }

    public function getHSL(target:{h:Float, s:Float, l:Float}):{h:Float, s:Float, l:Float}
    {
        var max = Math.max(r, Math.max(g, b));
        var min = Math.min(r, Math.min(g, b));

        var hue:Float = 0;
        var saturation:Float = 0;
        var lightness = (min + max) / 2.0;

        if (min != max)
        {
            var delta = max - min;
            saturation = lightness <= 0.5 ? delta / (max + min) : delta / (2 - max - min);

            if (max == r) hue = (g - b) / delta + (g < b ? 6 : 0);
            else if (max == g) hue = (b - r) / delta + 2;
            else if (max == b) hue = (r - g) / delta + 4;

            hue /= 6;
        }

        target.h = hue;
        target.s = saturation;
        target.l = lightness;

        return target;
    }

    public function getStyle():String
    {
        return "rgb(" + Std.int(r * 255) + "," + Std.int(g * 255) + "," + Std.int(b * 255) + ")";
    }

    public function add(color:Color):Color
    {
        r += color.r;
        g += color.g;
        b += color.b;
        return this;
    }

    public function addColors(color1:Color, color2:Color):Color
    {
        r = color1.r + color2.r;
        g = color1.g + color2.g;
        b = color1.b + color2.b;
        return this;
    }

    public function addScalar(s:Float):Color
    {
        r += s;
        g += s;
        b += s;
        return this;
    }

    public function sub(color:Color):Color
    {
        r = Math.max(0, r - color.r);
        g = Math.max(0, g - color.g);
        b = Math.max(0, b - color.b);
        return this;
    }

    public function multiply(color:Color):Color
    {
        r *= color.r;
        g *= color.g;
        b *= color.b;
        return this;
    }

    public function multiplyScalar(s:Float):Color
    {
        r *= s;
        g *= s;
        b *= s;
        return this;
    }

    public function lerp(color:Color, alpha:Float):Color
    {
        r += (color.r - r) * alpha;
        g += (color.g - g) * alpha;
        b += (color.b - b) * alpha;
        return this;
    }

    public function lerpColors(color1:Color, color2:Color, alpha:Float):Color
    {
        r = color1.r + (color2.r - color1.r) * alpha;
        g = color1.g + (color2.g - color1.g) * alpha;
        b = color1.b + (color2.b - color1.b) * alpha;
        return this;
    }

    public function equals(c:Color):Bool
    {
        return c.r == r && c.g == g && c.b == b;
    }

    public function fromArray(array:Array<Float>, offset:Int = 0):Color
    {
        r = array[offset];
        g = array[offset + 1];
        b = array[offset + 2];
        return this;
    }

    public function toArray(?array:Array<Float>, offset:Int = 0):Array<Float>
    {
        if (array == null) array = [];
        array[offset] = r;
        array[offset + 1] = g;
        array[offset + 2] = b;
        return array;
    }

    public function toJSON():Int
    {
        return getHex();
    }
}
