package three.renderers;

import three.math.Color;
import three.math.Vector3;
import three.math.Matrix4;
import three.math.Matrix3;
import three.scenes.Scene;
import three.cameras.Camera;
import three.cameras.PerspectiveCamera;
import three.core.Object3D;
import three.core.BufferGeometry;
import three.core.BufferAttribute;
import three.objects.Mesh;
import three.materials.Material;
import three.materials.MeshBasicMaterial;
import three.materials.MeshLambertMaterial;
import three.materials.MeshPhongMaterial;
import three.lights.Light;
import three.lights.AmbientLight;
import three.lights.DirectionalLight;
import three.lights.PointLight;

#if js
import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.RenderingContext;
import js.html.webgl.GL;
import js.html.webgl.Program;
import js.html.webgl.Shader;
import js.html.webgl.Buffer;
import js.html.webgl.UniformLocation;
#end

/**
 * WebGL renderer parameters
 */
typedef WebGLRendererParameters =
{
    @:optional var canvas:Dynamic;
    @:optional var antialias:Bool;
    @:optional var alpha:Bool;
    @:optional var depth:Bool;
    @:optional var stencil:Bool;
    @:optional var premultipliedAlpha:Bool;
    @:optional var preserveDrawingBuffer:Bool;
    @:optional var powerPreference:String;
}

/**
 * The WebGL renderer displays your beautifully crafted scenes using WebGL.
 */
class WebGLRenderer
{
    #if js
    public var domElement:CanvasElement;
    private var gl:RenderingContext;
    #else
    public var domElement:Dynamic;
    private var gl:Dynamic;
    #end

    public var autoClear:Bool;
    public var autoClearColor:Bool;
    public var autoClearDepth:Bool;
    public var autoClearStencil:Bool;

    public var sortObjects:Bool;

    private var _width:Int;
    private var _height:Int;
    private var _pixelRatio:Float;

    private var _clearColor:Color;
    private var _clearAlpha:Float;

    // Shader program cache
    private var _programs:Map<String, ProgramInfo>;

    // Buffer cache
    private var _geometryBuffers:Map<Int, GeometryBuffers>;

    // Matrices for rendering
    private var _projScreenMatrix:Matrix4;
    private var _vector3:Vector3;

    // Light state
    private var _ambientLight:Color;
    private var _directionalLights:Array<DirectionalLightData>;
    private var _pointLights:Array<PointLightData>;

    public var isWebGLRenderer(default, never):Bool = true;

    public function new(?parameters:WebGLRendererParameters)
    {
        if (parameters == null) parameters = {};

        _width = 800;
        _height = 600;
        _pixelRatio = 1;

        _clearColor = new Color(0x000000);
        _clearAlpha = 0;

        autoClear = true;
        autoClearColor = true;
        autoClearDepth = true;
        autoClearStencil = true;

        sortObjects = true;

        _programs = new Map();
        _geometryBuffers = new Map();

        _projScreenMatrix = new Matrix4();
        _vector3 = new Vector3();

        // Initialize light storage
        _ambientLight = new Color(0x000000);
        _directionalLights = [];
        _pointLights = [];

        #if js
        // Create or use provided canvas
        if (parameters.canvas != null)
        {
            domElement = parameters.canvas;
        }
        else
        {
            domElement = Browser.document.createCanvasElement();
            domElement.style.display = "block";
        }

        // Get WebGL context
        var contextAttributes:js.html.webgl.ContextAttributes = {
            alpha: parameters.alpha != null ? parameters.alpha : false,
            depth: parameters.depth != null ? parameters.depth : true,
            stencil: parameters.stencil != null ? parameters.stencil : false,
            antialias: parameters.antialias != null ? parameters.antialias : false,
            premultipliedAlpha: parameters.premultipliedAlpha != null ? parameters.premultipliedAlpha : true,
            preserveDrawingBuffer: parameters.preserveDrawingBuffer != null ? parameters.preserveDrawingBuffer : false
        };

        gl = domElement.getContextWebGL(contextAttributes);

        if (gl == null)
        {
            gl = domElement.getContextWebGL();
        }

        if (gl == null)
        {
            throw "Unable to initialize WebGL";
        }

        // Enable depth testing
        gl.enable(GL.DEPTH_TEST);
        gl.depthFunc(GL.LEQUAL);

        // Enable backface culling
        gl.enable(GL.CULL_FACE);
        gl.cullFace(GL.BACK);
        #end
    }

    public function getContext():Dynamic
    {
        return gl;
    }

    public function getSize():{width:Int, height:Int}
    {
        return {width: _width, height: _height};
    }

    public function setSize(width:Int, height:Int, updateStyle:Bool = true):Void
    {
        _width = width;
        _height = height;

        #if js
        domElement.width = Std.int(width * _pixelRatio);
        domElement.height = Std.int(height * _pixelRatio);

        if (updateStyle)
        {
            domElement.style.width = width + "px";
            domElement.style.height = height + "px";
        }

        setViewport(0, 0, width, height);
        #end
    }

    public function setViewport(x:Int, y:Int, width:Int, height:Int):Void
    {
        #if js
        gl.viewport(x, y, Std.int(width * _pixelRatio), Std.int(height * _pixelRatio));
        #end
    }

    public function setPixelRatio(value:Float):Void
    {
        _pixelRatio = value;
        setSize(_width, _height, false);
    }

    public function getPixelRatio():Float
    {
        return _pixelRatio;
    }

    public function setClearColor(color:Dynamic, alpha:Float = 1):Void
    {
        _clearColor.set(color);
        _clearAlpha = alpha;
    }

    public function getClearColor(target:Color):Color
    {
        return target.copy(_clearColor);
    }

    public function getClearAlpha():Float
    {
        return _clearAlpha;
    }

    public function clear(color:Bool = true, depth:Bool = true, stencil:Bool = true):Void
    {
        #if js
        var bits = 0;

        if (color)
        {
            gl.clearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearAlpha);
            bits |= GL.COLOR_BUFFER_BIT;
        }

        if (depth)
        {
            gl.clearDepth(1);
            bits |= GL.DEPTH_BUFFER_BIT;
        }

        if (stencil)
        {
            gl.clearStencil(0);
            bits |= GL.STENCIL_BUFFER_BIT;
        }

        gl.clear(bits);
        #end
    }

    public function render(scene:Scene, camera:Camera):Void
    {
        #if js
        // Update scene matrices
        if (scene.matrixWorldAutoUpdate) scene.updateMatrixWorld();

        // Update camera matrices
        if (camera.parent == null && camera.matrixWorldAutoUpdate) camera.updateMatrixWorld();

        // Compute projection-view matrix
        _projScreenMatrix.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse);

        // Collect lights from scene (pass camera for view space transformation)
        collectLights(scene, camera);

        // Clear if needed
        if (autoClear)
        {
            clear(autoClearColor, autoClearDepth, autoClearStencil);
        }

        // Render all objects
        renderObjects(scene.children, scene, camera);
        #end
    }

    #if js
    // Store view matrix for light transformation
    private var _viewMatrix:Matrix4;
    private static var _debugLightOnce:Bool = false;

    private function collectLights(scene:Scene, camera:Camera):Void
    {
        // Reset light state
        _ambientLight.setRGB(0, 0, 0);
        _directionalLights = [];
        _pointLights = [];

        // Store view matrix for transforming lights to view space
        _viewMatrix = camera.matrixWorldInverse;

        // Traverse scene to collect lights
        collectLightsFromObject(scene);

        // Debug output once
        if (!_debugLightOnce)
        {
            _debugLightOnce = true;
            trace("=== LIGHT DEBUG ===");
            trace("Ambient: " + _ambientLight.r + ", " + _ambientLight.g + ", " + _ambientLight.b);
            trace("Directional count: " + _directionalLights.length);
            trace("Point count: " + _pointLights.length);
        }
    }

    private function collectLightsFromObject(object:Object3D):Void
    {
        if (Std.isOfType(object, AmbientLight))
        {
            var light:AmbientLight = cast object;
            _ambientLight.r += light.color.r * light.intensity;
            _ambientLight.g += light.color.g * light.intensity;
            _ambientLight.b += light.color.b * light.intensity;
        }
        else if (Std.isOfType(object, DirectionalLight))
        {
            var light:DirectionalLight = cast object;

            // Update target's matrix (it's not in the scene graph)
            light.target.updateMatrixWorld();

            // Get direction in world space
            var direction = new Vector3();
            direction.setFromMatrixPosition(light.matrixWorld);
            var targetPos = new Vector3();
            targetPos.setFromMatrixPosition(light.target.matrixWorld);
            direction.sub(targetPos);
            direction.normalize();

            // Transform direction to view space (rotation only)
            direction.transformDirection(_viewMatrix);

            _directionalLights.push({
                color: light.color,
                intensity: light.intensity,
                direction: direction
            });
        }
        else if (Std.isOfType(object, PointLight))
        {
            var light:PointLight = cast object;
            var position = new Vector3();
            position.setFromMatrixPosition(light.matrixWorld);

            // Transform position to view space
            position.applyMatrix4(_viewMatrix);

            _pointLights.push({
                color: light.color,
                intensity: light.intensity,
                position: position,
                distance: light.distance,
                decay: light.decay
            });
        }

        // Recurse to children
        for (child in object.children)
        {
            collectLightsFromObject(child);
        }
    }

    private function renderObjects(objects:Array<Object3D>, scene:Scene, camera:Camera):Void
    {
        for (object in objects)
        {
            if (!object.visible) continue;

            if (Std.isOfType(object, Mesh))
            {
                renderMesh(cast object, scene, camera);
            }

            // Render children
            if (object.children.length > 0)
            {
                renderObjects(object.children, scene, camera);
            }
        }
    }

    private static var _debugMeshOnce:Bool = false;

    private function renderMesh(mesh:Mesh, scene:Scene, camera:Camera):Void
    {
        var geometry = mesh.geometry;
        var material = mesh.material;

        if (geometry == null || material == null) return;

        // Update mesh's world matrix
        mesh.modelViewMatrix.multiplyMatrices(camera.matrixWorldInverse, mesh.matrixWorld);
        mesh.normalMatrix.getNormalMatrix(mesh.modelViewMatrix);

        // Determine material type and get program
        var programKey = getMaterialKey(material);
        var program = getProgram(programKey);

        // Debug output once
        if (!_debugMeshOnce)
        {
            _debugMeshOnce = true;
            trace("=== MESH DEBUG ===");
            trace("Material type: " + material.type);
            trace("Program key: " + programKey);
            trace("Is Phong: " + Std.isOfType(material, MeshPhongMaterial));
            trace("Is Lambert: " + Std.isOfType(material, MeshLambertMaterial));
            trace("Is Basic: " + Std.isOfType(material, MeshBasicMaterial));
        }
        gl.useProgram(program.program);

        // Set common uniforms
        var mvpMatrix = new Matrix4();
        mvpMatrix.multiplyMatrices(_projScreenMatrix, mesh.matrixWorld);
        gl.uniformMatrix4fv(program.uniforms.get("uMVPMatrix"), false, new js.lib.Float32Array(mvpMatrix.elements));

        // Set material-specific uniforms
        if (Std.isOfType(material, MeshPhongMaterial))
        {
            var phongMat:MeshPhongMaterial = cast material;
            setPhongUniforms(program, phongMat, mesh, camera);
        }
        else if (Std.isOfType(material, MeshLambertMaterial))
        {
            var lambertMat:MeshLambertMaterial = cast material;
            setLambertUniforms(program, lambertMat, mesh, camera);
        }
        else if (Std.isOfType(material, MeshBasicMaterial))
        {
            var basicMat:MeshBasicMaterial = cast material;
            gl.uniform3f(program.uniforms.get("uColor"), basicMat.color.r, basicMat.color.g, basicMat.color.b);
            gl.uniform1f(program.uniforms.get("uOpacity"), basicMat.opacity);
        }

        // Get or create buffers
        var buffers = getGeometryBuffers(geometry);

        // Bind position buffer
        gl.bindBuffer(GL.ARRAY_BUFFER, buffers.position);
        var posLoc = program.attributes.get("aPosition");
        if (posLoc >= 0)
        {
            gl.enableVertexAttribArray(posLoc);
            gl.vertexAttribPointer(posLoc, 3, GL.FLOAT, false, 0, 0);
        }

        // Bind normal buffer if exists
        if (buffers.normal != null)
        {
            var normalLoc = program.attributes.get("aNormal");
            if (normalLoc >= 0)
            {
                gl.bindBuffer(GL.ARRAY_BUFFER, buffers.normal);
                gl.enableVertexAttribArray(normalLoc);
                gl.vertexAttribPointer(normalLoc, 3, GL.FLOAT, false, 0, 0);
            }
        }

        // Draw
        if (buffers.index != null)
        {
            gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffers.index);
            gl.drawElements(GL.TRIANGLES, buffers.indexCount, GL.UNSIGNED_SHORT, 0);
        }
        else
        {
            gl.drawArrays(GL.TRIANGLES, 0, buffers.vertexCount);
        }
    }

    private function setPhongUniforms(program:ProgramInfo, material:MeshPhongMaterial, mesh:Mesh, camera:Camera):Void
    {
        // Colors
        gl.uniform3f(program.uniforms.get("uColor"), material.color.r, material.color.g, material.color.b);
        gl.uniform3f(program.uniforms.get("uSpecular"), material.specular.r, material.specular.g, material.specular.b);
        gl.uniform1f(program.uniforms.get("uShininess"), material.shininess);
        gl.uniform3f(program.uniforms.get("uEmissive"),
            material.emissive.r * material.emissiveIntensity,
            material.emissive.g * material.emissiveIntensity,
            material.emissive.b * material.emissiveIntensity);
        gl.uniform1f(program.uniforms.get("uOpacity"), material.opacity);

        // Matrices
        gl.uniformMatrix4fv(program.uniforms.get("uModelViewMatrix"), false, new js.lib.Float32Array(mesh.modelViewMatrix.elements));
        gl.uniformMatrix3fv(program.uniforms.get("uNormalMatrix"), false, new js.lib.Float32Array(mesh.normalMatrix.elements));

        // Camera position
        var camPos = new Vector3();
        camPos.setFromMatrixPosition(camera.matrixWorld);
        gl.uniform3f(program.uniforms.get("uCameraPosition"), camPos.x, camPos.y, camPos.z);

        // Lights
        setLightUniforms(program);
    }

    private function setLambertUniforms(program:ProgramInfo, material:MeshLambertMaterial, mesh:Mesh, camera:Camera):Void
    {
        // Colors
        gl.uniform3f(program.uniforms.get("uColor"), material.color.r, material.color.g, material.color.b);
        gl.uniform3f(program.uniforms.get("uEmissive"),
            material.emissive.r * material.emissiveIntensity,
            material.emissive.g * material.emissiveIntensity,
            material.emissive.b * material.emissiveIntensity);
        gl.uniform1f(program.uniforms.get("uOpacity"), material.opacity);

        // Matrices
        gl.uniformMatrix4fv(program.uniforms.get("uModelViewMatrix"), false, new js.lib.Float32Array(mesh.modelViewMatrix.elements));
        gl.uniformMatrix3fv(program.uniforms.get("uNormalMatrix"), false, new js.lib.Float32Array(mesh.normalMatrix.elements));

        // Lights
        setLightUniforms(program);
    }

    private function setLightUniforms(program:ProgramInfo):Void
    {
        // Ambient light
        gl.uniform3f(program.uniforms.get("uAmbientLight"), _ambientLight.r, _ambientLight.g, _ambientLight.b);

        // Number of lights
        gl.uniform1i(program.uniforms.get("uNumDirectionalLights"), _directionalLights.length);
        gl.uniform1i(program.uniforms.get("uNumPointLights"), _pointLights.length);

        // Directional lights (up to 4)
        for (i in 0...4)
        {
            if (i < _directionalLights.length)
            {
                var light = _directionalLights[i];
                gl.uniform3f(program.uniforms.get("uDirectionalLights[" + i + "].direction"),
                    light.direction.x, light.direction.y, light.direction.z);
                gl.uniform3f(program.uniforms.get("uDirectionalLights[" + i + "].color"),
                    light.color.r * light.intensity,
                    light.color.g * light.intensity,
                    light.color.b * light.intensity);
            }
        }

        // Point lights (up to 4)
        for (i in 0...4)
        {
            if (i < _pointLights.length)
            {
                var light = _pointLights[i];
                gl.uniform3f(program.uniforms.get("uPointLights[" + i + "].position"),
                    light.position.x, light.position.y, light.position.z);
                gl.uniform3f(program.uniforms.get("uPointLights[" + i + "].color"),
                    light.color.r * light.intensity,
                    light.color.g * light.intensity,
                    light.color.b * light.intensity);
                gl.uniform1f(program.uniforms.get("uPointLights[" + i + "].distance"), light.distance);
                gl.uniform1f(program.uniforms.get("uPointLights[" + i + "].decay"), light.decay);
            }
        }
    }

    private function getMaterialKey(material:Material):String
    {
        if (Std.isOfType(material, MeshPhongMaterial)) return "phong";
        if (Std.isOfType(material, MeshLambertMaterial)) return "lambert";
        return "basic";
    }

    private function getProgram(key:String):ProgramInfo
    {
        if (_programs.exists(key))
        {
            return _programs.get(key);
        }

        var vertexShader:String;
        var fragmentShader:String;

        switch (key)
        {
            case "phong":
                vertexShader = getPhongVertexShader();
                fragmentShader = getPhongFragmentShader();
            case "lambert":
                vertexShader = getLambertVertexShader();
                fragmentShader = getLambertFragmentShader();
            default:
                vertexShader = getBasicVertexShader();
                fragmentShader = getBasicFragmentShader();
        }

        var program = createProgram(vertexShader, fragmentShader);

        var programInfo:ProgramInfo = {
            program: program,
            attributes: new Map(),
            uniforms: new Map()
        };

        // Get common attribute locations
        programInfo.attributes.set("aPosition", gl.getAttribLocation(program, "aPosition"));
        programInfo.attributes.set("aNormal", gl.getAttribLocation(program, "aNormal"));

        // Get uniform locations based on shader type
        programInfo.uniforms.set("uMVPMatrix", gl.getUniformLocation(program, "uMVPMatrix"));
        programInfo.uniforms.set("uColor", gl.getUniformLocation(program, "uColor"));
        programInfo.uniforms.set("uOpacity", gl.getUniformLocation(program, "uOpacity"));

        if (key == "phong" || key == "lambert")
        {
            programInfo.uniforms.set("uModelViewMatrix", gl.getUniformLocation(program, "uModelViewMatrix"));
            programInfo.uniforms.set("uNormalMatrix", gl.getUniformLocation(program, "uNormalMatrix"));
            programInfo.uniforms.set("uEmissive", gl.getUniformLocation(program, "uEmissive"));
            programInfo.uniforms.set("uAmbientLight", gl.getUniformLocation(program, "uAmbientLight"));
            programInfo.uniforms.set("uNumDirectionalLights", gl.getUniformLocation(program, "uNumDirectionalLights"));
            programInfo.uniforms.set("uNumPointLights", gl.getUniformLocation(program, "uNumPointLights"));

            // Directional light uniforms
            for (i in 0...4)
            {
                programInfo.uniforms.set("uDirectionalLights[" + i + "].direction",
                    gl.getUniformLocation(program, "uDirectionalLights[" + i + "].direction"));
                programInfo.uniforms.set("uDirectionalLights[" + i + "].color",
                    gl.getUniformLocation(program, "uDirectionalLights[" + i + "].color"));
            }

            // Point light uniforms
            for (i in 0...4)
            {
                programInfo.uniforms.set("uPointLights[" + i + "].position",
                    gl.getUniformLocation(program, "uPointLights[" + i + "].position"));
                programInfo.uniforms.set("uPointLights[" + i + "].color",
                    gl.getUniformLocation(program, "uPointLights[" + i + "].color"));
                programInfo.uniforms.set("uPointLights[" + i + "].distance",
                    gl.getUniformLocation(program, "uPointLights[" + i + "].distance"));
                programInfo.uniforms.set("uPointLights[" + i + "].decay",
                    gl.getUniformLocation(program, "uPointLights[" + i + "].decay"));
            }
        }

        if (key == "phong")
        {
            programInfo.uniforms.set("uSpecular", gl.getUniformLocation(program, "uSpecular"));
            programInfo.uniforms.set("uShininess", gl.getUniformLocation(program, "uShininess"));
            programInfo.uniforms.set("uCameraPosition", gl.getUniformLocation(program, "uCameraPosition"));
        }

        _programs.set(key, programInfo);
        return programInfo;
    }

    private function getBasicVertexShader():String
    {
        return "
            attribute vec3 aPosition;
            attribute vec3 aNormal;
            uniform mat4 uMVPMatrix;
            varying vec3 vNormal;
            void main() {
                vNormal = aNormal;
                gl_Position = uMVPMatrix * vec4(aPosition, 1.0);
            }
        ";
    }

    private function getBasicFragmentShader():String
    {
        return "
            precision mediump float;
            uniform vec3 uColor;
            uniform float uOpacity;
            varying vec3 vNormal;
            void main() {
                vec3 light = normalize(vec3(0.5, 0.5, 1.0));
                float diffuse = max(dot(normalize(vNormal), light), 0.2);
                gl_FragColor = vec4(uColor * diffuse, uOpacity);
            }
        ";
    }

    private function getLambertVertexShader():String
    {
        return "
            attribute vec3 aPosition;
            attribute vec3 aNormal;
            uniform mat4 uMVPMatrix;
            uniform mat4 uModelViewMatrix;
            uniform mat3 uNormalMatrix;
            varying vec3 vNormal;
            varying vec3 vViewPosition;
            void main() {
                vec4 mvPosition = uModelViewMatrix * vec4(aPosition, 1.0);
                vViewPosition = -mvPosition.xyz;
                vNormal = normalize(uNormalMatrix * aNormal);
                gl_Position = uMVPMatrix * vec4(aPosition, 1.0);
            }
        ";
    }

    private function getLambertFragmentShader():String
    {
        return "
            precision mediump float;

            uniform vec3 uColor;
            uniform vec3 uEmissive;
            uniform float uOpacity;
            uniform vec3 uAmbientLight;

            uniform int uNumDirectionalLights;
            uniform int uNumPointLights;

            struct DirectionalLight {
                vec3 direction;
                vec3 color;
            };
            uniform DirectionalLight uDirectionalLights[4];

            struct PointLight {
                vec3 position;
                vec3 color;
                float distance;
                float decay;
            };
            uniform PointLight uPointLights[4];

            varying vec3 vNormal;
            varying vec3 vViewPosition;

            void main() {
                vec3 normal = normalize(vNormal);
                vec3 diffuseColor = uColor;

                // Start with ambient and emissive
                vec3 outgoingLight = uEmissive + diffuseColor * uAmbientLight;

                // Add directional lights (avoid break with uniform condition)
                for (int i = 0; i < 4; i++) {
                    if (i < uNumDirectionalLights) {
                        vec3 lightDir = normalize(uDirectionalLights[i].direction);
                        float dotNL = max(dot(normal, lightDir), 0.0);
                        outgoingLight += diffuseColor * uDirectionalLights[i].color * dotNL;
                    }
                }

                // Add point lights (avoid break with uniform condition)
                for (int i = 0; i < 4; i++) {
                    if (i < uNumPointLights) {
                        vec3 lightVector = uPointLights[i].position + vViewPosition;
                        float lightDistance = length(lightVector);
                        vec3 lightDir = normalize(lightVector);

                        float dotNL = max(dot(normal, lightDir), 0.0);

                        // Attenuation
                        float attenuation = 1.0;
                        if (uPointLights[i].distance > 0.0) {
                            float distanceFactor = lightDistance / uPointLights[i].distance;
                            attenuation = max(1.0 - distanceFactor, 0.0);
                            attenuation *= attenuation;
                        }

                        outgoingLight += diffuseColor * uPointLights[i].color * dotNL * attenuation;
                    }
                }

                gl_FragColor = vec4(outgoingLight, uOpacity);
            }
        ";
    }

    private function getPhongVertexShader():String
    {
        return "
            attribute vec3 aPosition;
            attribute vec3 aNormal;
            uniform mat4 uMVPMatrix;
            uniform mat4 uModelViewMatrix;
            uniform mat3 uNormalMatrix;
            varying vec3 vNormal;
            varying vec3 vViewPosition;
            varying vec3 vWorldPosition;
            void main() {
                vec4 mvPosition = uModelViewMatrix * vec4(aPosition, 1.0);
                vViewPosition = -mvPosition.xyz;
                vNormal = normalize(uNormalMatrix * aNormal);
                vWorldPosition = aPosition;
                gl_Position = uMVPMatrix * vec4(aPosition, 1.0);
            }
        ";
    }

    private function getPhongFragmentShader():String
    {
        return "
            precision mediump float;

            uniform vec3 uColor;
            uniform vec3 uSpecular;
            uniform float uShininess;
            uniform vec3 uEmissive;
            uniform float uOpacity;
            uniform vec3 uAmbientLight;
            uniform vec3 uCameraPosition;

            uniform int uNumDirectionalLights;
            uniform int uNumPointLights;

            struct DirectionalLight {
                vec3 direction;
                vec3 color;
            };
            uniform DirectionalLight uDirectionalLights[4];

            struct PointLight {
                vec3 position;
                vec3 color;
                float distance;
                float decay;
            };
            uniform PointLight uPointLights[4];

            varying vec3 vNormal;
            varying vec3 vViewPosition;
            varying vec3 vWorldPosition;

            void main() {
                vec3 normal = normalize(vNormal);
                vec3 viewDir = normalize(vViewPosition);
                vec3 diffuseColor = uColor;

                // Start with ambient and emissive
                vec3 outgoingLight = uEmissive + diffuseColor * uAmbientLight;
                vec3 specularSum = vec3(0.0);

                // Add directional lights (avoid break with uniform condition)
                for (int i = 0; i < 4; i++) {
                    if (i < uNumDirectionalLights) {
                        vec3 lightDir = normalize(uDirectionalLights[i].direction);

                        // Diffuse
                        float dotNL = max(dot(normal, lightDir), 0.0);
                        outgoingLight += diffuseColor * uDirectionalLights[i].color * dotNL;

                        // Specular (Blinn-Phong)
                        vec3 halfDir = normalize(lightDir + viewDir);
                        float dotNH = max(dot(normal, halfDir), 0.0);
                        float specularFactor = pow(dotNH, uShininess);
                        specularSum += uSpecular * uDirectionalLights[i].color * specularFactor * dotNL;
                    }
                }

                // Add point lights (avoid break with uniform condition)
                for (int i = 0; i < 4; i++) {
                    if (i < uNumPointLights) {
                        vec3 lightVector = uPointLights[i].position + vViewPosition;
                        float lightDistance = length(lightVector);
                        vec3 lightDir = normalize(lightVector);

                        float dotNL = max(dot(normal, lightDir), 0.0);

                        // Attenuation
                        float attenuation = 1.0;
                        if (uPointLights[i].distance > 0.0) {
                            float distanceFactor = lightDistance / uPointLights[i].distance;
                            attenuation = max(1.0 - distanceFactor, 0.0);
                            attenuation *= attenuation;
                        }

                        // Diffuse
                        outgoingLight += diffuseColor * uPointLights[i].color * dotNL * attenuation;

                        // Specular (Blinn-Phong)
                        vec3 halfDir = normalize(lightDir + viewDir);
                        float dotNH = max(dot(normal, halfDir), 0.0);
                        float specularFactor = pow(dotNH, uShininess);
                        specularSum += uSpecular * uPointLights[i].color * specularFactor * dotNL * attenuation;
                    }
                }

                outgoingLight += specularSum;

                gl_FragColor = vec4(outgoingLight, uOpacity);
            }
        ";
    }

    private function createProgram(vertexSource:String, fragmentSource:String):Program
    {
        var vertexShader = compileShader(GL.VERTEX_SHADER, vertexSource);
        var fragmentShader = compileShader(GL.FRAGMENT_SHADER, fragmentSource);

        var program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (!gl.getProgramParameter(program, GL.LINK_STATUS))
        {
            throw "Program link error: " + gl.getProgramInfoLog(program);
        }

        return program;
    }

    private function compileShader(type:Int, source:String):Shader
    {
        var shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, GL.COMPILE_STATUS))
        {
            throw "Shader compile error: " + gl.getShaderInfoLog(shader);
        }

        return shader;
    }

    private function getGeometryBuffers(geometry:BufferGeometry):GeometryBuffers
    {
        if (_geometryBuffers.exists(geometry.id))
        {
            return _geometryBuffers.get(geometry.id);
        }

        var buffers:GeometryBuffers = {
            position: null,
            normal: null,
            uv: null,
            index: null,
            vertexCount: 0,
            indexCount: 0
        };

        // Position buffer
        var positionAttr = geometry.getAttribute("position");
        if (positionAttr != null)
        {
            buffers.position = gl.createBuffer();
            gl.bindBuffer(GL.ARRAY_BUFFER, buffers.position);
            gl.bufferData(GL.ARRAY_BUFFER, new js.lib.Float32Array(positionAttr.array), GL.STATIC_DRAW);
            buffers.vertexCount = positionAttr.count;
        }

        // Normal buffer
        var normalAttr = geometry.getAttribute("normal");
        if (normalAttr != null)
        {
            buffers.normal = gl.createBuffer();
            gl.bindBuffer(GL.ARRAY_BUFFER, buffers.normal);
            gl.bufferData(GL.ARRAY_BUFFER, new js.lib.Float32Array(normalAttr.array), GL.STATIC_DRAW);
        }

        // UV buffer
        var uvAttr = geometry.getAttribute("uv");
        if (uvAttr != null)
        {
            buffers.uv = gl.createBuffer();
            gl.bindBuffer(GL.ARRAY_BUFFER, buffers.uv);
            gl.bufferData(GL.ARRAY_BUFFER, new js.lib.Float32Array(uvAttr.array), GL.STATIC_DRAW);
        }

        // Index buffer
        var indexAttr = geometry.getIndex();
        if (indexAttr != null)
        {
            buffers.index = gl.createBuffer();
            gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffers.index);

            // Convert to Uint16Array for indices
            var indices:Array<Int> = [];
            for (v in indexAttr.array) indices.push(Std.int(v));
            gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, new js.lib.Uint16Array(indices), GL.STATIC_DRAW);
            buffers.indexCount = indexAttr.count;
        }

        _geometryBuffers.set(geometry.id, buffers);
        return buffers;
    }
    #end

    public function dispose():Void
    {
        #if js
        // Clean up WebGL resources
        for (key in _programs.keys())
        {
            gl.deleteProgram(_programs.get(key).program);
        }
        _programs.clear();

        for (id in _geometryBuffers.keys())
        {
            var buffers = _geometryBuffers.get(id);
            if (buffers.position != null) gl.deleteBuffer(buffers.position);
            if (buffers.normal != null) gl.deleteBuffer(buffers.normal);
            if (buffers.uv != null) gl.deleteBuffer(buffers.uv);
            if (buffers.index != null) gl.deleteBuffer(buffers.index);
        }
        _geometryBuffers.clear();
        #end
    }
}

#if js
private typedef ProgramInfo =
{
    var program:Program;
    var attributes:Map<String, Int>;
    var uniforms:Map<String, UniformLocation>;
}

private typedef GeometryBuffers =
{
    var position:Buffer;
    var normal:Buffer;
    var uv:Buffer;
    var index:Buffer;
    var vertexCount:Int;
    var indexCount:Int;
}

private typedef DirectionalLightData =
{
    var color:Color;
    var intensity:Float;
    var direction:Vector3;
}

private typedef PointLightData =
{
    var color:Color;
    var intensity:Float;
    var position:Vector3;
    var distance:Float;
    var decay:Float;
}
#end
