package three.geometries;

import three.core.BufferGeometry;
import three.core.BufferAttribute;
import three.math.Vector3;

/**
 * A class for generating box geometries.
 */
class BoxGeometry extends BufferGeometry
{
    public var parameters:{
        width:Float,
        height:Float,
        depth:Float,
        widthSegments:Int,
        heightSegments:Int,
        depthSegments:Int
    };

    public function new(
        width:Float = 1,
        height:Float = 1,
        depth:Float = 1,
        widthSegments:Int = 1,
        heightSegments:Int = 1,
        depthSegments:Int = 1
    )
    {
        super();

        type = "BoxGeometry";

        parameters = {
            width: width,
            height: height,
            depth: depth,
            widthSegments: widthSegments,
            heightSegments: heightSegments,
            depthSegments: depthSegments
        };

        // Build the geometry
        var indices:Array<Float> = [];
        var vertices:Array<Float> = [];
        var normals:Array<Float> = [];
        var uvs:Array<Float> = [];

        var numberOfVertices = 0;
        var groupStart = 0;

        // Define buildPlane as a local function BEFORE calling it
        var buildPlane = function(
            u:Int, v:Int, w:Int,
            udir:Int, vdir:Int,
            planeWidth:Float, planeHeight:Float, planeDepth:Float,
            gridX:Int, gridY:Int,
            materialIndex:Int
        ):Void
        {
            var segmentWidth = planeWidth / gridX;
            var segmentHeight = planeHeight / gridY;

            var widthHalf = planeWidth / 2;
            var heightHalf = planeHeight / 2;
            var depthHalf = planeDepth / 2;

            var gridX1 = gridX + 1;
            var gridY1 = gridY + 1;

            var vertexCounter = 0;
            var groupCount = 0;

            var vector = new Vector3();

            // Generate vertices, normals and uvs
            for (iy in 0...gridY1)
            {
                var y = iy * segmentHeight - heightHalf;

                for (ix in 0...gridX1)
                {
                    var x = ix * segmentWidth - widthHalf;

                    // Set values to correct vector component
                    vector.setComponent(u, x * udir);
                    vector.setComponent(v, y * vdir);
                    vector.setComponent(w, depthHalf);

                    // Now apply vector to vertex buffer
                    vertices.push(vector.x);
                    vertices.push(vector.y);
                    vertices.push(vector.z);

                    // Set values to correct vector component
                    vector.setComponent(u, 0);
                    vector.setComponent(v, 0);
                    vector.setComponent(w, planeDepth > 0 ? 1 : -1);

                    // Now apply vector to normal buffer
                    normals.push(vector.x);
                    normals.push(vector.y);
                    normals.push(vector.z);

                    // uvs
                    uvs.push(ix / gridX);
                    uvs.push(1 - (iy / gridY));

                    // counters
                    vertexCounter++;
                }
            }

            // Indices
            for (iy in 0...gridY)
            {
                for (ix in 0...gridX)
                {
                    var a = numberOfVertices + ix + gridX1 * iy;
                    var b = numberOfVertices + ix + gridX1 * (iy + 1);
                    var c = numberOfVertices + (ix + 1) + gridX1 * (iy + 1);
                    var d = numberOfVertices + (ix + 1) + gridX1 * iy;

                    // faces
                    indices.push(a);
                    indices.push(b);
                    indices.push(d);

                    indices.push(b);
                    indices.push(c);
                    indices.push(d);

                    // increase counter
                    groupCount += 6;
                }
            }

            // Add a group to the geometry
            addGroup(groupStart, groupCount, materialIndex);

            // Calculate new start value for groups
            groupStart += groupCount;

            // Update total number of vertices
            numberOfVertices += vertexCounter;
        };

        // Build each side of the box
        buildPlane(2, 1, 0, -1, -1, depth, height, width, depthSegments, heightSegments, 0); // px
        buildPlane(2, 1, 0, 1, -1, depth, height, -width, depthSegments, heightSegments, 1); // nx
        buildPlane(0, 2, 1, 1, 1, width, depth, height, widthSegments, depthSegments, 2); // py
        buildPlane(0, 2, 1, 1, -1, width, depth, -height, widthSegments, depthSegments, 3); // ny
        buildPlane(0, 1, 2, 1, -1, width, height, depth, widthSegments, heightSegments, 4); // pz
        buildPlane(0, 1, 2, -1, -1, width, height, -depth, widthSegments, heightSegments, 5); // nz

        // Build geometry
        setIndex(indices);
        setAttribute("position", new Float32BufferAttribute(vertices, 3));
        setAttribute("normal", new Float32BufferAttribute(normals, 3));
        setAttribute("uv", new Float32BufferAttribute(uvs, 2));
    }

    public function copyBox(source:BoxGeometry):BoxGeometry
    {
        super.copy(source);
        parameters = {
            width: source.parameters.width,
            height: source.parameters.height,
            depth: source.parameters.depth,
            widthSegments: source.parameters.widthSegments,
            heightSegments: source.parameters.heightSegments,
            depthSegments: source.parameters.depthSegments
        };
        return this;
    }

    override public function clone():BufferGeometry
    {
        return new BoxGeometry().copyBox(this);
    }

    public static function fromJSON(data:Dynamic):BoxGeometry
    {
        return new BoxGeometry(
            data.width,
            data.height,
            data.depth,
            data.widthSegments,
            data.heightSegments,
            data.depthSegments
        );
    }
}
