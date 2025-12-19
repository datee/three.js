package three.lights;

import three.lights.Light;
import three.core.Object3D;

/**
 * A light that gets emitted from a single point in all directions.
 *
 * A common use case for this is to replicate the light emitted from a bare lightbulb.
 */
class PointLight extends Light
{
    public var isPointLight(default, never):Bool = true;

    /**
     * The distance from the light where the intensity is 0.
     * When set to 0, then the light never stops.
     */
    public var distance:Float;

    /**
     * The amount the light dims along the distance of the light.
     * For physically correct lighting, set this to 2.
     */
    public var decay:Float;

    public function new(?color:Dynamic, intensity:Float = 1, distance:Float = 0, decay:Float = 2)
    {
        super(color, intensity);

        type = "PointLight";

        this.distance = distance;
        this.decay = decay;
    }

    /**
     * Computes the light's power.
     * Power = intensity * 4π
     */
    public function getPower():Float
    {
        return intensity * 4 * Math.PI;
    }

    /**
     * Sets the light's power.
     * Power = intensity * 4π
     */
    public function setPower(power:Float):Void
    {
        intensity = power / (4 * Math.PI);
    }

    public function copyPoint(source:PointLight, recursive:Bool = true):PointLight
    {
        super.copyLight(source, recursive);

        distance = source.distance;
        decay = source.decay;

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new PointLight().copyPoint(this, recursive);
    }

    override public function dispose():Void
    {
        // PointLight doesn't have shadow by default in this basic implementation
    }
}
