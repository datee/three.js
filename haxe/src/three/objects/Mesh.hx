package three.objects;

import three.core.Object3D;
import three.core.BufferGeometry;
import three.materials.Material;
import three.math.Vector3;
import three.math.Matrix4;

/**
 * Class representing triangular polygon mesh based objects.
 */
class Mesh extends Object3D
{
    public var geometry:BufferGeometry;
    public var material:Dynamic; // Material or Array<Material>

    public var isMesh(default, never):Bool = true;

    public function new(?geometry:BufferGeometry, ?material:Dynamic)
    {
        super();

        type = "Mesh";

        this.geometry = geometry != null ? geometry : new BufferGeometry();
        this.material = material != null ? material : new MeshBasicMaterial();
    }

    public function copyMesh(source:Mesh, recursive:Bool = true):Mesh
    {
        super.copyFrom(source, recursive);

        if (source.geometry != null)
        {
            geometry = source.geometry;
        }

        if (source.material != null)
        {
            if (Std.isOfType(source.material, Array))
            {
                material = cast(source.material, Array<Dynamic>).copy();
            }
            else
            {
                material = source.material;
            }
        }

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new Mesh(geometry, material).copyMesh(this, recursive);
    }

    public function updateMorphTargets():Void
    {
        var morphAttributes = geometry.morphAttributes;
        var keys = [for (k in morphAttributes.keys()) k];

        if (keys.length > 0)
        {
            var morphAttribute = morphAttributes.get(keys[0]);

            if (morphAttribute != null)
            {
                // TODO: Implement morph target support
            }
        }
    }

    public function getVertexPosition(index:Int, target:Vector3):Vector3
    {
        var position = geometry.getAttribute("position");
        target.fromBufferAttribute(position, index);

        // TODO: Apply morph targets

        return target;
    }
}

// Import for default material
import three.materials.MeshBasicMaterial;
