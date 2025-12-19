package three.lights;

import three.core.Object3D;
import three.math.Color;

/**
 * Abstract base class for lights.
 * All other light types inherit from this class.
 */
class Light extends Object3D
{
    public var color:Color;
    public var intensity:Float;

    public var isLight(default, never):Bool = true;

    public function new(?color:Dynamic, intensity:Float = 1)
    {
        super();

        type = "Light";

        this.color = new Color(color != null ? color : 0xffffff);
        this.intensity = intensity;
    }

    public function copyLight(source:Light, recursive:Bool = true):Light
    {
        super.copyFrom(source, recursive);

        color.copy(source.color);
        intensity = source.intensity;

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new Light().copyLight(this, recursive);
    }

    public function dispose():Void
    {
        // Subclasses may override to clean up resources
    }
}
