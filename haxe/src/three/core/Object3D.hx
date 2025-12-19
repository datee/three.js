package three.core;

import three.core.EventDispatcher;
import three.math.Vector3;
import three.math.Matrix4;
import three.math.Matrix3;
import three.math.Quaternion;
import three.math.Euler;
import three.math.Euler.EulerOrder;
import three.math.MathUtils;

/**
 * Base class for all 3D objects
 */
class Object3D extends EventDispatcher
{
    public static var DEFAULT_UP:Vector3 = new Vector3(0, 1, 0);
    public static var DEFAULT_MATRIX_AUTO_UPDATE:Bool = true;
    public static var DEFAULT_MATRIX_WORLD_AUTO_UPDATE:Bool = true;

    private static var _object3DId:Int = 0;

    public var id(default, null):Int;
    public var uuid:String;
    public var name:String;
    public var type:String;

    public var parent:Object3D;
    public var children:Array<Object3D>;

    public var up:Vector3;

    public var position(default, null):Vector3;
    public var rotation(default, null):Euler;
    public var quaternion(default, null):Quaternion;
    public var scale(default, null):Vector3;

    public var modelViewMatrix:Matrix4;
    public var normalMatrix:Matrix3;

    public var matrix:Matrix4;
    public var matrixWorld:Matrix4;

    public var matrixAutoUpdate:Bool;
    public var matrixWorldAutoUpdate:Bool;
    public var matrixWorldNeedsUpdate:Bool;

    public var visible:Bool;

    public var castShadow:Bool;
    public var receiveShadow:Bool;

    public var frustumCulled:Bool;
    public var renderOrder:Int;

    public var userData:Dynamic;

    public var isObject3D(default, never):Bool = true;

    public function new()
    {
        super();

        id = _object3DId++;
        uuid = MathUtils.generateUUID();
        name = "";
        type = "Object3D";

        parent = null;
        children = [];

        up = DEFAULT_UP.clone();

        position = new Vector3();
        rotation = new Euler();
        quaternion = new Quaternion();
        scale = new Vector3(1, 1, 1);

        // Link rotation and quaternion
        rotation.onChange(onRotationChange);
        quaternion.onChange(onQuaternionChange);

        modelViewMatrix = new Matrix4();
        normalMatrix = new Matrix3();

        matrix = new Matrix4();
        matrixWorld = new Matrix4();

        matrixAutoUpdate = DEFAULT_MATRIX_AUTO_UPDATE;
        matrixWorldAutoUpdate = DEFAULT_MATRIX_WORLD_AUTO_UPDATE;
        matrixWorldNeedsUpdate = false;

        visible = true;

        castShadow = false;
        receiveShadow = false;

        frustumCulled = true;
        renderOrder = 0;

        userData = {};
    }

    private function onRotationChange():Void
    {
        quaternion.setFromEuler(rotation, false);
    }

    private function onQuaternionChange():Void
    {
        rotation.setFromQuaternion(quaternion, null, false);
    }

    public function applyMatrix4(m:Matrix4):Void
    {
        if (matrixAutoUpdate) updateMatrix();
        matrix.premultiply(m);
        matrix.decompose(position, quaternion, scale);
    }

    public function applyQuaternion(q:Quaternion):Object3D
    {
        quaternion.premultiply(q);
        return this;
    }

    public function setRotationFromAxisAngle(axis:Vector3, angle:Float):Void
    {
        quaternion.setFromAxisAngle(axis, angle);
    }

    public function setRotationFromEuler(euler:Euler):Void
    {
        quaternion.setFromEuler(euler, true);
    }

    public function setRotationFromMatrix(m:Matrix4):Void
    {
        quaternion.setFromRotationMatrix(m);
    }

    public function setRotationFromQuaternion(q:Quaternion):Void
    {
        quaternion.copy(q);
    }

    public function rotateOnAxis(axis:Vector3, angle:Float):Object3D
    {
        _q1.setFromAxisAngle(axis, angle);
        quaternion.multiply(_q1);
        return this;
    }

    public function rotateOnWorldAxis(axis:Vector3, angle:Float):Object3D
    {
        _q1.setFromAxisAngle(axis, angle);
        quaternion.premultiply(_q1);
        return this;
    }

    public function rotateX(angle:Float):Object3D
    {
        return rotateOnAxis(_xAxis, angle);
    }

    public function rotateY(angle:Float):Object3D
    {
        return rotateOnAxis(_yAxis, angle);
    }

    public function rotateZ(angle:Float):Object3D
    {
        return rotateOnAxis(_zAxis, angle);
    }

    public function translateOnAxis(axis:Vector3, distance:Float):Object3D
    {
        _v1.copy(axis).applyQuaternion(quaternion);
        position.add(_v1.multiplyScalar(distance));
        return this;
    }

    public function translateX(distance:Float):Object3D
    {
        return translateOnAxis(_xAxis, distance);
    }

    public function translateY(distance:Float):Object3D
    {
        return translateOnAxis(_yAxis, distance);
    }

    public function translateZ(distance:Float):Object3D
    {
        return translateOnAxis(_zAxis, distance);
    }

    public function localToWorld(vector:Vector3):Vector3
    {
        updateMatrixWorld(true);
        return vector.applyMatrix4(matrixWorld);
    }

    public function worldToLocal(vector:Vector3):Vector3
    {
        updateMatrixWorld(true);
        return vector.applyMatrix4(_m1.copy(matrixWorld).invert());
    }

    public function lookAt(x:Float, y:Float, z:Float):Void
    {
        _target.set(x, y, z);

        var parent = this.parent;

        updateMatrixWorld(true);

        _position.setFromMatrixPosition(matrixWorld);

        if (Std.isOfType(this, Camera) || Std.isOfType(this, Light))
        {
            _m1.lookAt(_position, _target, up);
        }
        else
        {
            _m1.lookAt(_target, _position, up);
        }

        quaternion.setFromRotationMatrix(_m1);

        if (parent != null)
        {
            _m1.extractRotation(parent.matrixWorld);
            _q1.setFromRotationMatrix(_m1);
            quaternion.premultiply(_q1.invert());
        }
    }

    public function lookAtVector(target:Vector3):Void
    {
        lookAt(target.x, target.y, target.z);
    }

    public function add(object:Object3D):Object3D
    {
        if (object == this)
        {
            trace("Object3D.add: object can't be added as a child of itself.");
            return this;
        }

        if (object != null)
        {
            if (object.parent != null)
            {
                object.parent.remove(object);
            }

            object.parent = this;
            children.push(object);

            object.dispatchEvent({type: "added"});
        }

        return this;
    }

    public function remove(object:Object3D):Object3D
    {
        var index = children.indexOf(object);

        if (index != -1)
        {
            object.parent = null;
            children.splice(index, 1);

            object.dispatchEvent({type: "removed"});
        }

        return this;
    }

    public function removeFromParent():Object3D
    {
        if (parent != null)
        {
            parent.remove(this);
        }
        return this;
    }

    public function clear():Object3D
    {
        for (object in children)
        {
            object.parent = null;
            object.dispatchEvent({type: "removed"});
        }
        children = [];
        return this;
    }

    public function attach(object:Object3D):Object3D
    {
        updateMatrixWorld(true);

        _m1.copy(matrixWorld).invert();

        if (object.parent != null)
        {
            object.parent.updateMatrixWorld(true);
            _m1.multiply(object.parent.matrixWorld);
        }

        object.applyMatrix4(_m1);
        add(object);
        object.updateMatrixWorld(true);

        return this;
    }

    public function getObjectById(id:Int):Object3D
    {
        return getObjectByProperty("id", id);
    }

    public function getObjectByName(name:String):Object3D
    {
        return getObjectByProperty("name", name);
    }

    public function getObjectByProperty(name:String, value:Dynamic):Object3D
    {
        if (Reflect.field(this, name) == value) return this;

        for (child in children)
        {
            var object = child.getObjectByProperty(name, value);
            if (object != null) return object;
        }

        return null;
    }

    public function getWorldPosition(target:Vector3):Vector3
    {
        updateMatrixWorld(true);
        return target.setFromMatrixPosition(matrixWorld);
    }

    public function getWorldQuaternion(target:Quaternion):Quaternion
    {
        updateMatrixWorld(true);
        matrixWorld.decompose(_position, target, _scale);
        return target;
    }

    public function getWorldScale(target:Vector3):Vector3
    {
        updateMatrixWorld(true);
        matrixWorld.decompose(_position, _quaternion, target);
        return target;
    }

    public function getWorldDirection(target:Vector3):Vector3
    {
        updateMatrixWorld(true);

        var e = matrixWorld.elements;
        return target.set(e[8], e[9], e[10]).normalize();
    }

    public function traverse(callback:Object3D -> Void):Void
    {
        callback(this);

        for (child in children)
        {
            child.traverse(callback);
        }
    }

    public function traverseVisible(callback:Object3D -> Void):Void
    {
        if (!visible) return;

        callback(this);

        for (child in children)
        {
            child.traverseVisible(callback);
        }
    }

    public function traverseAncestors(callback:Object3D -> Void):Void
    {
        if (parent != null)
        {
            callback(parent);
            parent.traverseAncestors(callback);
        }
    }

    public function updateMatrix():Void
    {
        matrix.compose(position, quaternion, scale);
        matrixWorldNeedsUpdate = true;
    }

    public function updateMatrixWorld(force:Bool = false):Void
    {
        if (matrixAutoUpdate) updateMatrix();

        if (matrixWorldNeedsUpdate || force)
        {
            if (parent == null)
            {
                matrixWorld.copy(matrix);
            }
            else
            {
                matrixWorld.multiplyMatrices(parent.matrixWorld, matrix);
            }

            matrixWorldNeedsUpdate = false;
            force = true;
        }

        for (child in children)
        {
            if (child.matrixWorldAutoUpdate || force)
            {
                child.updateMatrixWorld(force);
            }
        }
    }

    public function updateWorldMatrix(updateParents:Bool, updateChildren:Bool):Void
    {
        if (updateParents && parent != null)
        {
            parent.updateWorldMatrix(true, false);
        }

        if (matrixAutoUpdate) updateMatrix();

        if (parent == null)
        {
            matrixWorld.copy(matrix);
        }
        else
        {
            matrixWorld.multiplyMatrices(parent.matrixWorld, matrix);
        }

        if (updateChildren)
        {
            for (child in children)
            {
                child.updateWorldMatrix(false, true);
            }
        }
    }

    public function clone(recursive:Bool = true):Object3D
    {
        return new Object3D().copyFrom(this, recursive);
    }

    public function copyFrom(source:Object3D, recursive:Bool = true):Object3D
    {
        name = source.name;

        up.copy(source.up);

        position.copy(source.position);
        rotation.copy(source.rotation);
        quaternion.copy(source.quaternion);
        scale.copy(source.scale);

        matrix.copy(source.matrix);
        matrixWorld.copy(source.matrixWorld);

        matrixAutoUpdate = source.matrixAutoUpdate;
        matrixWorldAutoUpdate = source.matrixWorldAutoUpdate;
        matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate;

        visible = source.visible;

        castShadow = source.castShadow;
        receiveShadow = source.receiveShadow;

        frustumCulled = source.frustumCulled;
        renderOrder = source.renderOrder;

        userData = source.userData;

        if (recursive)
        {
            for (child in source.children)
            {
                add(child.clone());
            }
        }

        return this;
    }

    // Static helper objects
    private static var _v1:Vector3 = new Vector3();
    private static var _q1:Quaternion = new Quaternion();
    private static var _m1:Matrix4 = new Matrix4();
    private static var _target:Vector3 = new Vector3();
    private static var _position:Vector3 = new Vector3();
    private static var _scale:Vector3 = new Vector3();
    private static var _quaternion:Quaternion = new Quaternion();
    private static var _xAxis:Vector3 = new Vector3(1, 0, 0);
    private static var _yAxis:Vector3 = new Vector3(0, 1, 0);
    private static var _zAxis:Vector3 = new Vector3(0, 0, 1);
}

// Forward declarations for type checking in lookAt
private class Camera {}
private class Light {}
