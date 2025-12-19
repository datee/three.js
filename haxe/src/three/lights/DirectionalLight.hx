package three.lights;

import three.lights.Light;
import three.core.Object3D;
import three.math.Vector3;

/**
 * A light that gets emitted in a specific direction.
 * This light will behave as though it is infinitely far away
 * and the rays produced from it are all parallel.
 *
 * A common use case for this is to simulate daylight.
 */
class DirectionalLight extends Light
{
    public var isDirectionalLight(default, never):Bool = true;

    public var target:Object3D;

    public function new(?color:Dynamic, intensity:Float = 1)
    {
        super(color, intensity);

        type = "DirectionalLight";

        position.copy(Object3D.DEFAULT_UP);
        updateMatrix();

        target = new Object3D();
    }

    public function copyDirectional(source:DirectionalLight, recursive:Bool = true):DirectionalLight
    {
        super.copyLight(source, recursive);

        target = source.target.clone();

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new DirectionalLight().copyDirectional(this, recursive);
    }

    override public function dispose():Void
    {
        // DirectionalLight doesn't have shadow by default in this basic implementation
    }
}
