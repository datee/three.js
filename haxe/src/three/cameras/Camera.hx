package three.cameras;

import three.core.Object3D;
import three.math.Matrix4;
import three.math.Vector3;

/**
 * Abstract base class for cameras.
 */
class Camera extends Object3D
{
    public var matrixWorldInverse:Matrix4;
    public var projectionMatrix:Matrix4;
    public var projectionMatrixInverse:Matrix4;

    public var coordinateSystem:Int;

    public var isCamera(default, never):Bool = true;

    public function new()
    {
        super();

        type = "Camera";

        matrixWorldInverse = new Matrix4();
        projectionMatrix = new Matrix4();
        projectionMatrixInverse = new Matrix4();

        coordinateSystem = 2000; // WebGLCoordinateSystem
    }

    public function copyCamera(source:Camera, recursive:Bool = true):Camera
    {
        super.copyFrom(source, recursive);

        matrixWorldInverse.copy(source.matrixWorldInverse);
        projectionMatrix.copy(source.projectionMatrix);
        projectionMatrixInverse.copy(source.projectionMatrixInverse);
        coordinateSystem = source.coordinateSystem;

        return this;
    }

    override public function getWorldDirection(target:Vector3):Vector3
    {
        updateMatrixWorld(true);

        var e = matrixWorld.elements;

        return target.set(-e[8], -e[9], -e[10]).normalize();
    }

    override public function updateMatrixWorld(force:Bool = false):Void
    {
        super.updateMatrixWorld(force);

        matrixWorldInverse.copy(matrixWorld).invert();
    }

    override public function updateWorldMatrix(updateParents:Bool, updateChildren:Bool):Void
    {
        super.updateWorldMatrix(updateParents, updateChildren);

        matrixWorldInverse.copy(matrixWorld).invert();
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new Camera().copyCamera(this, recursive);
    }
}
