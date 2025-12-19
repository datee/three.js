package three.materials;

import three.materials.Material;
import three.math.Color;
import three.math.Euler;

/**
 * A material for drawing geometries in a simple shaded (flat or wireframe) way.
 * This material is not affected by lights.
 */
class MeshBasicMaterial extends Material
{
    public var color:Color;

    public var map:Dynamic; // Texture
    public var lightMap:Dynamic; // Texture
    public var lightMapIntensity:Float;
    public var aoMap:Dynamic; // Texture
    public var aoMapIntensity:Float;
    public var specularMap:Dynamic; // Texture
    public var alphaMap:Dynamic; // Texture
    public var envMap:Dynamic; // Texture
    public var envMapRotation:Euler;
    public var combine:Int;
    public var reflectivity:Float;
    public var refractionRatio:Float;

    public var wireframe:Bool;
    public var wireframeLinewidth:Float;
    public var wireframeLinecap:String;
    public var wireframeLinejoin:String;

    public var fog:Bool;

    public var isMeshBasicMaterial(default, never):Bool = true;

    public function new(?parameters:Dynamic)
    {
        super();

        type = "MeshBasicMaterial";

        color = new Color(0xffffff);

        map = null;
        lightMap = null;
        lightMapIntensity = 1.0;
        aoMap = null;
        aoMapIntensity = 1.0;
        specularMap = null;
        alphaMap = null;
        envMap = null;
        envMapRotation = new Euler();
        combine = 0; // MultiplyOperation
        reflectivity = 1;
        refractionRatio = 0.98;

        wireframe = false;
        wireframeLinewidth = 1;
        wireframeLinecap = "round";
        wireframeLinejoin = "round";

        fog = true;

        if (parameters != null)
        {
            setValues(parameters);
        }
    }

    override public function setValues(values:Dynamic):Void
    {
        if (values == null) return;

        var fields = Reflect.fields(values);
        for (key in fields)
        {
            var newValue = Reflect.field(values, key);

            if (key == "color")
            {
                color.set(newValue);
            }
            else if (Reflect.hasField(this, key))
            {
                Reflect.setField(this, key, newValue);
            }
        }
    }

    public function copyMeshBasic(source:MeshBasicMaterial):MeshBasicMaterial
    {
        super.copy(source);

        color.copy(source.color);

        map = source.map;
        lightMap = source.lightMap;
        lightMapIntensity = source.lightMapIntensity;
        aoMap = source.aoMap;
        aoMapIntensity = source.aoMapIntensity;
        specularMap = source.specularMap;
        alphaMap = source.alphaMap;
        envMap = source.envMap;
        envMapRotation.copy(source.envMapRotation);
        combine = source.combine;
        reflectivity = source.reflectivity;
        refractionRatio = source.refractionRatio;

        wireframe = source.wireframe;
        wireframeLinewidth = source.wireframeLinewidth;
        wireframeLinecap = source.wireframeLinecap;
        wireframeLinejoin = source.wireframeLinejoin;

        fog = source.fog;

        return this;
    }

    override public function clone():Material
    {
        return new MeshBasicMaterial().copyMeshBasic(this);
    }
}
