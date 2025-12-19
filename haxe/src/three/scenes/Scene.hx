package three.scenes;

import three.core.Object3D;
import three.math.Color;

/**
 * Scenes allow you to set up what and where is to be rendered by three.js.
 * This is where you place objects, lights, and cameras.
 */
class Scene extends Object3D
{
    public var background:Dynamic; // Color, Texture, or null
    public var environment:Dynamic; // Texture or null
    public var fog:Dynamic; // Fog or null
    public var backgroundBlurriness:Float;
    public var backgroundIntensity:Float;
    public var backgroundRotation:three.math.Euler;
    public var environmentIntensity:Float;
    public var environmentRotation:three.math.Euler;
    public var overrideMaterial:Dynamic; // Material or null

    public var isScene(default, never):Bool = true;

    public function new()
    {
        super();

        type = "Scene";

        background = null;
        environment = null;
        fog = null;

        backgroundBlurriness = 0;
        backgroundIntensity = 1;
        backgroundRotation = new three.math.Euler();

        environmentIntensity = 1;
        environmentRotation = new three.math.Euler();

        overrideMaterial = null;
    }

    public function copy(source:Scene, recursive:Bool = true):Scene
    {
        super.copyFrom(source, recursive);

        if (source.background != null)
        {
            if (Std.isOfType(source.background, Color))
            {
                background = cast(source.background, Color).clone();
            }
            else
            {
                background = source.background;
            }
        }

        if (source.environment != null)
        {
            environment = source.environment;
        }

        if (source.fog != null)
        {
            fog = source.fog;
        }

        backgroundBlurriness = source.backgroundBlurriness;
        backgroundIntensity = source.backgroundIntensity;
        backgroundRotation.copy(source.backgroundRotation);

        environmentIntensity = source.environmentIntensity;
        environmentRotation.copy(source.environmentRotation);

        if (source.overrideMaterial != null)
        {
            overrideMaterial = source.overrideMaterial;
        }

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new Scene().copy(this, recursive);
    }
}
