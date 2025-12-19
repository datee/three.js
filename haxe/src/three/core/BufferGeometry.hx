package three.core;

import three.core.EventDispatcher;
import three.core.BufferAttribute;
import three.math.Vector3;
import three.math.Matrix4;
import three.math.Matrix3;
import three.math.MathUtils;

/**
 * Group definition for geometry
 */
typedef GeometryGroup =
{
    var start:Int;
    var count:Int;
    var materialIndex:Int;
}

/**
 * Buffer geometry class for storing mesh data
 */
class BufferGeometry extends EventDispatcher
{
    private static var _id:Int = 0;

    public var id(default, null):Int;
    public var uuid:String;
    public var name:String;
    public var type:String;

    public var index:BufferAttribute;
    public var attributes:Map<String, BufferAttribute>;

    public var morphAttributes:Map<String, Array<BufferAttribute>>;
    public var morphTargetsRelative:Bool;

    public var groups:Array<GeometryGroup>;

    public var boundingBox:Box3;
    public var boundingSphere:Sphere;

    public var drawRange:{start:Int, count:Int};

    public var userData:Dynamic;

    public var isBufferGeometry(default, never):Bool = true;

    public function new()
    {
        super();

        id = _id++;
        uuid = MathUtils.generateUUID();
        name = "";
        type = "BufferGeometry";

        index = null;
        attributes = new Map();

        morphAttributes = new Map();
        morphTargetsRelative = false;

        groups = [];

        boundingBox = null;
        boundingSphere = null;

        drawRange = {start: 0, count: 999999999};

        userData = {};
    }

    public function getIndex():BufferAttribute
    {
        return index;
    }

    public function setIndex(indexData:Dynamic):BufferGeometry
    {
        if (Std.isOfType(indexData, Array))
        {
            var arr:Array<Dynamic> = indexData;
            var floatArr:Array<Float> = [];
            for (v in arr) floatArr.push(v);
            index = new BufferAttribute(floatArr, 1);
        }
        else
        {
            index = indexData;
        }
        return this;
    }

    public function getAttribute(name:String):BufferAttribute
    {
        return attributes.get(name);
    }

    public function setAttribute(name:String, attribute:BufferAttribute):BufferGeometry
    {
        attributes.set(name, attribute);
        return this;
    }

    public function deleteAttribute(name:String):BufferGeometry
    {
        attributes.remove(name);
        return this;
    }

    public function hasAttribute(name:String):Bool
    {
        return attributes.exists(name);
    }

    public function addGroup(start:Int, count:Int, materialIndex:Int = 0):Void
    {
        groups.push({
            start: start,
            count: count,
            materialIndex: materialIndex
        });
    }

    public function clearGroups():Void
    {
        groups = [];
    }

    public function setDrawRange(start:Int, count:Int):Void
    {
        drawRange.start = start;
        drawRange.count = count;
    }

    public function applyMatrix4(m:Matrix4):BufferGeometry
    {
        var position = attributes.get("position");

        if (position != null)
        {
            position.applyMatrix4(m);
            position.needsUpdate(true);
        }

        var normal = attributes.get("normal");

        if (normal != null)
        {
            var normalMatrix = new Matrix3().getNormalMatrix(m);
            normal.applyNormalMatrix(normalMatrix);
            normal.needsUpdate(true);
        }

        var tangent = attributes.get("tangent");

        if (tangent != null)
        {
            tangent.transformDirection(m);
            tangent.needsUpdate(true);
        }

        if (boundingBox != null)
        {
            computeBoundingBox();
        }

        if (boundingSphere != null)
        {
            computeBoundingSphere();
        }

        return this;
    }

    public function applyQuaternion(q:three.math.Quaternion):BufferGeometry
    {
        _m1.makeRotationFromQuaternion(q);
        applyMatrix4(_m1);
        return this;
    }

    public function rotateX(angle:Float):BufferGeometry
    {
        _m1.makeRotationX(angle);
        applyMatrix4(_m1);
        return this;
    }

    public function rotateY(angle:Float):BufferGeometry
    {
        _m1.makeRotationY(angle);
        applyMatrix4(_m1);
        return this;
    }

    public function rotateZ(angle:Float):BufferGeometry
    {
        _m1.makeRotationZ(angle);
        applyMatrix4(_m1);
        return this;
    }

    public function translate(x:Float, y:Float, z:Float):BufferGeometry
    {
        _m1.makeTranslation(x, y, z);
        applyMatrix4(_m1);
        return this;
    }

    public function scale(x:Float, y:Float, z:Float):BufferGeometry
    {
        _m1.makeScale(x, y, z);
        applyMatrix4(_m1);
        return this;
    }

    public function center():BufferGeometry
    {
        computeBoundingBox();
        boundingBox.getCenter(_offset).negate();
        translate(_offset.x, _offset.y, _offset.z);
        return this;
    }

    public function computeBoundingBox():Void
    {
        if (boundingBox == null)
        {
            boundingBox = new Box3();
        }

        var position = attributes.get("position");
        var morphAttributesPosition = morphAttributes.get("position");

        if (position != null)
        {
            boundingBox.setFromBufferAttribute(position);

            if (morphAttributesPosition != null)
            {
                for (morphAttribute in morphAttributesPosition)
                {
                    _box.setFromBufferAttribute(morphAttribute);

                    if (morphTargetsRelative)
                    {
                        _vector.addVectors(boundingBox.min, _box.min);
                        boundingBox.expandByPoint(_vector);
                        _vector.addVectors(boundingBox.max, _box.max);
                        boundingBox.expandByPoint(_vector);
                    }
                    else
                    {
                        boundingBox.expandByPoint(_box.min);
                        boundingBox.expandByPoint(_box.max);
                    }
                }
            }
        }
        else
        {
            boundingBox.makeEmpty();
        }
    }

    public function computeBoundingSphere():Void
    {
        if (boundingSphere == null)
        {
            boundingSphere = new Sphere();
        }

        var position = attributes.get("position");
        var morphAttributesPosition = morphAttributes.get("position");

        if (position != null)
        {
            var center = boundingSphere.center;

            _box.setFromBufferAttribute(position);

            if (morphAttributesPosition != null)
            {
                for (morphAttribute in morphAttributesPosition)
                {
                    _boxMorphTargets.setFromBufferAttribute(morphAttribute);

                    if (morphTargetsRelative)
                    {
                        _vector.addVectors(_box.min, _boxMorphTargets.min);
                        _box.expandByPoint(_vector);
                        _vector.addVectors(_box.max, _boxMorphTargets.max);
                        _box.expandByPoint(_vector);
                    }
                    else
                    {
                        _box.expandByPoint(_boxMorphTargets.min);
                        _box.expandByPoint(_boxMorphTargets.max);
                    }
                }
            }

            _box.getCenter(center);

            var maxRadiusSq:Float = 0;

            for (i in 0...position.count)
            {
                _vector.fromBufferAttribute(position, i);
                maxRadiusSq = Math.max(maxRadiusSq, center.distanceToSquared(_vector));
            }

            if (morphAttributesPosition != null)
            {
                for (morphAttribute in morphAttributesPosition)
                {
                    var morphTargetsRelative = this.morphTargetsRelative;

                    for (i in 0...morphAttribute.count)
                    {
                        _vector.fromBufferAttribute(morphAttribute, i);

                        if (morphTargetsRelative)
                        {
                            _offset.fromBufferAttribute(position, i);
                            _vector.add(_offset);
                        }

                        maxRadiusSq = Math.max(maxRadiusSq, center.distanceToSquared(_vector));
                    }
                }
            }

            boundingSphere.radius = Math.sqrt(maxRadiusSq);
        }
    }

    public function computeVertexNormals():Void
    {
        var index = this.index;
        var positionAttribute = getAttribute("position");

        if (positionAttribute != null)
        {
            var normalAttribute = getAttribute("normal");

            if (normalAttribute == null)
            {
                var normals:Array<Float> = [];
                for (i in 0...positionAttribute.count * 3)
                {
                    normals.push(0);
                }
                normalAttribute = new BufferAttribute(normals, 3);
                setAttribute("normal", normalAttribute);
            }
            else
            {
                // Reset existing normals to zero
                for (i in 0...normalAttribute.count)
                {
                    normalAttribute.setXYZ(i, 0, 0, 0);
                }
            }

            var pA = new Vector3(), pB = new Vector3(), pC = new Vector3();
            var nA = new Vector3(), nB = new Vector3(), nC = new Vector3();
            var cb = new Vector3(), ab = new Vector3();

            if (index != null)
            {
                var i = 0;
                while (i < index.count)
                {
                    var vA = Std.int(index.getX(i));
                    var vB = Std.int(index.getX(i + 1));
                    var vC = Std.int(index.getX(i + 2));

                    pA.fromBufferAttribute(positionAttribute, vA);
                    pB.fromBufferAttribute(positionAttribute, vB);
                    pC.fromBufferAttribute(positionAttribute, vC);

                    cb.subVectors(pC, pB);
                    ab.subVectors(pA, pB);
                    cb.cross(ab);

                    nA.fromBufferAttribute(normalAttribute, vA);
                    nB.fromBufferAttribute(normalAttribute, vB);
                    nC.fromBufferAttribute(normalAttribute, vC);

                    nA.add(cb);
                    nB.add(cb);
                    nC.add(cb);

                    normalAttribute.setXYZ(vA, nA.x, nA.y, nA.z);
                    normalAttribute.setXYZ(vB, nB.x, nB.y, nB.z);
                    normalAttribute.setXYZ(vC, nC.x, nC.y, nC.z);

                    i += 3;
                }
            }
            else
            {
                var i = 0;
                while (i < positionAttribute.count)
                {
                    pA.fromBufferAttribute(positionAttribute, i);
                    pB.fromBufferAttribute(positionAttribute, i + 1);
                    pC.fromBufferAttribute(positionAttribute, i + 2);

                    cb.subVectors(pC, pB);
                    ab.subVectors(pA, pB);
                    cb.cross(ab);

                    normalAttribute.setXYZ(i, cb.x, cb.y, cb.z);
                    normalAttribute.setXYZ(i + 1, cb.x, cb.y, cb.z);
                    normalAttribute.setXYZ(i + 2, cb.x, cb.y, cb.z);

                    i += 3;
                }
            }

            normalizeNormals();

            normalAttribute.needsUpdate(true);
        }
    }

    public function normalizeNormals():Void
    {
        var normals = getAttribute("normal");

        for (i in 0...normals.count)
        {
            _vector.fromBufferAttribute(normals, i);
            _vector.normalize();
            normals.setXYZ(i, _vector.x, _vector.y, _vector.z);
        }
    }

    public function copy(source:BufferGeometry):BufferGeometry
    {
        // Reset
        index = null;
        attributes = new Map();
        morphAttributes = new Map();
        groups = [];
        boundingBox = null;
        boundingSphere = null;

        name = source.name;

        if (source.index != null)
        {
            index = source.index.clone();
        }

        for (name in source.attributes.keys())
        {
            attributes.set(name, source.attributes.get(name).clone());
        }

        for (name in source.morphAttributes.keys())
        {
            var array:Array<BufferAttribute> = [];
            var morphAttribute = source.morphAttributes.get(name);

            for (attr in morphAttribute)
            {
                array.push(attr.clone());
            }

            morphAttributes.set(name, array);
        }

        morphTargetsRelative = source.morphTargetsRelative;

        for (group in source.groups)
        {
            addGroup(group.start, group.count, group.materialIndex);
        }

        if (source.boundingBox != null)
        {
            boundingBox = source.boundingBox.clone();
        }

        if (source.boundingSphere != null)
        {
            boundingSphere = source.boundingSphere.clone();
        }

        drawRange.start = source.drawRange.start;
        drawRange.count = source.drawRange.count;

        userData = source.userData;

        return this;
    }

    public function clone():BufferGeometry
    {
        return new BufferGeometry().copy(this);
    }

    public function dispose():Void
    {
        dispatchEvent({type: "dispose"});
    }

    // Static helpers
    private static var _m1:Matrix4 = new Matrix4();
    private static var _offset:Vector3 = new Vector3();
    private static var _box:Box3 = new Box3();
    private static var _boxMorphTargets:Box3 = new Box3();
    private static var _vector:Vector3 = new Vector3();
}

/**
 * Simple bounding box
 */
class Box3
{
    public var min:Vector3;
    public var max:Vector3;

    public function new(?min:Vector3, ?max:Vector3)
    {
        this.min = min != null ? min : new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        this.max = max != null ? max : new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);
    }

    public function setFromBufferAttribute(attribute:BufferAttribute):Box3
    {
        var minX = Math.POSITIVE_INFINITY;
        var minY = Math.POSITIVE_INFINITY;
        var minZ = Math.POSITIVE_INFINITY;

        var maxX = Math.NEGATIVE_INFINITY;
        var maxY = Math.NEGATIVE_INFINITY;
        var maxZ = Math.NEGATIVE_INFINITY;

        for (i in 0...attribute.count)
        {
            var x = attribute.getX(i);
            var y = attribute.getY(i);
            var z = attribute.getZ(i);

            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (z < minZ) minZ = z;

            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
            if (z > maxZ) maxZ = z;
        }

        min.set(minX, minY, minZ);
        max.set(maxX, maxY, maxZ);

        return this;
    }

    public function makeEmpty():Box3
    {
        min.x = min.y = min.z = Math.POSITIVE_INFINITY;
        max.x = max.y = max.z = Math.NEGATIVE_INFINITY;
        return this;
    }

    public function expandByPoint(point:Vector3):Box3
    {
        min.min(point);
        max.max(point);
        return this;
    }

    public function getCenter(target:Vector3):Vector3
    {
        return target.addVectors(min, max).multiplyScalar(0.5);
    }

    public function clone():Box3
    {
        return new Box3(min.clone(), max.clone());
    }
}

/**
 * Simple bounding sphere
 */
class Sphere
{
    public var center:Vector3;
    public var radius:Float;

    public function new(?center:Vector3, radius:Float = -1)
    {
        this.center = center != null ? center : new Vector3();
        this.radius = radius;
    }

    public function clone():Sphere
    {
        return new Sphere(center.clone(), radius);
    }
}
