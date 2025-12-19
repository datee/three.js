package three.materials;

import three.materials.Material;
import three.math.Color;
import three.math.Euler;

/**
 * A material for non-shiny surfaces, without specular highlights.
 *
 * The material uses a non-physically based Lambertian model for calculating reflectance.
 * This can simulate some surfaces (such as untreated wood or stone) well, but cannot
 * simulate shiny surfaces with specular highlights (such as varnished wood).
 *
 * This material is affected by lights.
 */
class MeshLambertMaterial extends Material
{
    public var color:Color;
    public var emissive:Color;
    public var emissiveIntensity:Float;

    public var map:Dynamic; // Texture
    public var lightMap:Dynamic; // Texture
    public var lightMapIntensity:Float;
    public var aoMap:Dynamic; // Texture
    public var aoMapIntensity:Float;
    public var emissiveMap:Dynamic; // Texture
    public var bumpMap:Dynamic; // Texture
    public var bumpScale:Float;
    public var normalMap:Dynamic; // Texture
    public var normalMapType:Int;
    public var normalScale:Dynamic; // Vector2
    public var displacementMap:Dynamic; // Texture
    public var displacementScale:Float;
    public var displacementBias:Float;
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

    public var flatShading:Bool;
    public var fog:Bool;

    public var isMeshLambertMaterial(default, never):Bool = true;

    public function new(?parameters:Dynamic)
    {
        super();

        type = "MeshLambertMaterial";

        color = new Color(0xffffff);
        emissive = new Color(0x000000);
        emissiveIntensity = 1.0;

        map = null;
        lightMap = null;
        lightMapIntensity = 1.0;
        aoMap = null;
        aoMapIntensity = 1.0;
        emissiveMap = null;
        bumpMap = null;
        bumpScale = 1;
        normalMap = null;
        normalMapType = 0; // TangentSpaceNormalMap
        normalScale = null; // Should be Vector2(1, 1)
        displacementMap = null;
        displacementScale = 1;
        displacementBias = 0;
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

        flatShading = false;
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
            else if (key == "emissive")
            {
                emissive.set(newValue);
            }
            else if (Reflect.hasField(this, key))
            {
                Reflect.setField(this, key, newValue);
            }
        }
    }

    public function copyMeshLambert(source:MeshLambertMaterial):MeshLambertMaterial
    {
        super.copy(source);

        color.copy(source.color);
        emissive.copy(source.emissive);
        emissiveIntensity = source.emissiveIntensity;

        map = source.map;
        lightMap = source.lightMap;
        lightMapIntensity = source.lightMapIntensity;
        aoMap = source.aoMap;
        aoMapIntensity = source.aoMapIntensity;
        emissiveMap = source.emissiveMap;
        bumpMap = source.bumpMap;
        bumpScale = source.bumpScale;
        normalMap = source.normalMap;
        normalMapType = source.normalMapType;
        normalScale = source.normalScale;
        displacementMap = source.displacementMap;
        displacementScale = source.displacementScale;
        displacementBias = source.displacementBias;
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

        flatShading = source.flatShading;
        fog = source.fog;

        return this;
    }

    override public function clone():Material
    {
        return new MeshLambertMaterial().copyMeshLambert(this);
    }
}
