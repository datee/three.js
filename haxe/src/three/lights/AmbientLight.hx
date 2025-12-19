package three.lights;

import three.lights.Light;
import three.core.Object3D;

/**
 * This light globally illuminates all objects in the scene equally.
 *
 * This light cannot be used to cast shadows as it does not have a direction.
 */
class AmbientLight extends Light
{
    public var isAmbientLight(default, never):Bool = true;

    public function new(?color:Dynamic, intensity:Float = 1)
    {
        super(color, intensity);

        type = "AmbientLight";
    }

    public function copyAmbient(source:AmbientLight, recursive:Bool = true):AmbientLight
    {
        super.copyLight(source, recursive);
        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new AmbientLight().copyAmbient(this, recursive);
    }
}
