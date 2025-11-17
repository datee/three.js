# Three.js to Haxe Port Analysis

## Executive Summary

This document analyzes the feasibility and requirements for porting three.js (v0.181.0) to Haxe across two phases:
- **Phase 1**: Haxe targeting JavaScript (maintaining WebGL compatibility)
- **Phase 2**: DirectX 11 backend implementation

**Project Scale**: 58,390 LOC across 716 files, 193 classes, zero external dependencies

---

## Phase 1: Haxe → JavaScript Port

### 1.1 Language Feature Mapping

#### Core OOP Features (High Compatibility ✓)

**JavaScript/Three.js Pattern** → **Haxe Equivalent**

```javascript
// Three.js ES6 Classes
class Object3D extends EventDispatcher {
    constructor() {
        super();
        this.position = new Vector3();
    }

    get matrixWorld() { return this._matrixWorld; }
    set matrixWorld(value) { this._matrixWorld = value; }
}
```

```haxe
// Haxe Translation
class Object3D extends EventDispatcher {
    public var position:Vector3;

    public function new() {
        super();
        position = new Vector3();
    }

    public var matrixWorld(get, set):Matrix4;
    function get_matrixWorld():Matrix4 return _matrixWorld;
    function set_matrixWorld(value:Matrix4):Matrix4 return _matrixWorld = value;
}
```

**Compatibility**: ✓ Excellent (Haxe has superior class system with compile-time type checking)

---

#### Type System Challenges

**Three.js Dynamic Patterns**:
```javascript
// Runtime type flags (193 instances)
this.isObject3D = true;
this.isMesh = true;
this.isCamera = true;

// Dynamic property assignment
material.uniforms = { time: { value: 0.0 } };
geometry.attributes.position = new BufferAttribute();
```

**Haxe Solutions**:
```haxe
// Option 1: Type system (preferred)
if (Std.isOfType(obj, Mesh)) { }

// Option 2: Abstract types for runtime compatibility
@:forward abstract Object3D(Object3DImpl) {
    public var isObject3D(get, never):Bool;
    inline function get_isObject3D() return true;
}

// Option 3: Dynamic for uniforms (JS target only)
var uniforms:Dynamic<UniformValue> = {};
uniforms.time = { value: 0.0 };
```

**Effort**: Medium (2-3 weeks to establish patterns, minimal after that)

---

#### Closures & Function References

**Three.js Pattern**:
```javascript
// Module-level temporary objects for performance
const _v1 = new Vector3();
const _q1 = new Quaternion();

function updateMatrix() {
    _v1.set(x, y, z);  // Reuses temp object
}
```

**Haxe Equivalent**:
```haxe
// Static private fields work identically
private static var _v1 = new Vector3();
private static var _q1 = new Quaternion();

function updateMatrix():Void {
    _v1.set(x, y, z);
}
```

**Compatibility**: ✓ Perfect match

---

#### Getters/Setters (1,312 getters + 981 setters)

**Three.js**:
```javascript
Object.defineProperty(this, 'id', { value: _id++ });

get modelViewMatrix() {
    return this._modelViewMatrix;
}
```

**Haxe**:
```haxe
// Read-only property
public var id(default, null):Int = _idCounter++;

// Computed property
public var modelViewMatrix(get, never):Matrix4;
function get_modelViewMatrix():Matrix4 return _modelViewMatrix;
```

**Compatibility**: ✓ Excellent (Haxe properties are more explicit and compile-time safe)

---

#### Events System

**Three.js**:
```javascript
class EventDispatcher {
    addEventListener(type, listener) { }
    dispatchEvent(event) { }
}

object.addEventListener('added', (e) => console.log(e));
```

**Haxe Options**:

**Option A - Direct Port**:
```haxe
typedef EventListener = Dynamic->Void;

class EventDispatcher {
    var _listeners:Map<String, Array<EventListener>>;

    public function addEventListener(type:String, listener:EventListener):Void { }
    public function dispatchEvent(event:Dynamic):Void { }
}
```

**Option B - Haxe Signals (cleaner)**:
```haxe
import haxe.Signals;

class Object3D {
    public var onAdded:Signal<Object3D->Void>;
    public var onRemoved:Signal<Object3D->Void>;
}
```

**Recommendation**: Start with Option A (1:1 compatibility), migrate to Option B over time
**Effort**: 1-2 weeks initial, ongoing refactoring optional

---

### 1.2 Architecture Compatibility Analysis

#### Core Modules (src/core/) - 18 files

| Module | LOC | Haxe Compatibility | Notes |
|--------|-----|-------------------|-------|
| Object3D.js | 1,100+ | ✓ High | Standard OOP, getters/setters map well |
| BufferGeometry.js | 33 KB | ✓ High | Typed arrays supported via js.lib.TypedArray |
| BufferAttribute.js | Large | ⚠ Medium | Float32Array/Uint16Array → haxe.io.Float32Array |
| EventDispatcher.js | Small | ✓ High | Simple pattern, direct translation |
| Layers.js | Small | ✓ High | Bitwise operations fully supported |

**Total Effort**: 2-3 weeks

---

#### Math Library (src/math/) - 24 files, 13,795 LOC

**Excellent Haxe Compatibility** - Pure computational code with minimal side effects.

Example - Vector3.js:
```javascript
class Vector3 {
    x; y; z;

    add(v) {
        this.x += v.x;
        this.y += v.y;
        this.z += v.z;
        return this;
    }

    cross(v) {
        return this.crossVectors(this, v);
    }
}
```

Haxe translation:
```haxe
class Vector3 {
    public var x:Float;
    public var y:Float;
    public var z:Float;

    public inline function add(v:Vector3):Vector3 {
        x += v.x;
        y += v.y;
        z += v.z;
        return this;
    }

    public inline function cross(v:Vector3):Vector3 {
        return crossVectors(this, v);
    }
}
```

**Advantages in Haxe**:
- `inline` keyword for zero-overhead method calls (critical for performance)
- Compile-time type checking prevents dimension mismatches
- Math operations compile to identical JavaScript

**Classes to Port**:
- Vector2, Vector3, Vector4
- Matrix3, Matrix4
- Quaternion, Euler
- Color, Spherical, Cylindrical
- Box2, Box3, Sphere, Plane, Frustum
- Ray, Triangle
- Interpolant subclasses

**Total Effort**: 3-4 weeks (straightforward but extensive testing needed)

---

#### WebGL Renderer (src/renderers/) - 261 files, ~350 KB

**Critical Path for Phase 1**

**Structure**:
```
renderers/
├── WebGLRenderer.js (3,514 LOC - main orchestrator)
└── webgl/
    ├── WebGLAttributes.js
    ├── WebGLBindingStates.js
    ├── WebGLBufferRenderer.js
    ├── WebGLCapabilities.js
    ├── WebGLGeometries.js
    ├── WebGLPrograms.js
    ├── WebGLShader.js
    ├── WebGLState.js
    ├── WebGLTextures.js
    ├── WebGLUniforms.js
    └── ... (20+ subsystems)
```

**WebGL API Access in Haxe**:

```haxe
import js.html.webgl.RenderingContext as GL;
import js.html.webgl.GL2RenderingContext as GL2;

class WebGLRenderer {
    var gl:GL2;

    public function new(parameters:WebGLRendererParams) {
        var canvas:js.html.CanvasElement = parameters.canvas;
        gl = canvas.getContext("webgl2");

        // Direct API access - identical to JavaScript
        gl.enable(GL.DEPTH_TEST);
        gl.clearColor(0, 0, 0, 1);
    }

    public function render(scene:Scene, camera:Camera):Void {
        gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
        // ... rendering logic
    }
}
```

**Browser API Compatibility**:
- ✓ WebGL2RenderingContext fully exposed via `js.html.webgl`
- ✓ Canvas, Image, HTMLElement via `js.html.*`
- ✓ TypedArrays via `js.lib.*`
- ✓ requestAnimationFrame via `js.Browser.window`

**Shader System (109 GLSL chunks)**:

Three.js uses string concatenation for shaders:
```javascript
// ShaderLib/meshbasic.glsl.js
export const vertex = /* glsl */`
    #include <common>
    #include <uv_pars_vertex>
    void main() {
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
`;
```

Haxe equivalent:
```haxe
class MeshBasicShader {
    public static var vertex:String = '
        #include <common>
        #include <uv_pars_vertex>
        void main() {
            gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
    ';
}

// Shader chunk system
class ShaderChunk {
    static var chunks:Map<String, String> = [
        "common" => "...",
        "uv_pars_vertex" => "..."
    ];

    public static function include(shader:String):String {
        // Replace #include directives
        var pattern = ~/#include <(\w+)>/g;
        return pattern.map(shader, (r) -> {
            return chunks.get(r.matched(1));
        });
    }
}
```

**Compatibility**: ✓ Perfect (GLSL is platform-agnostic text)

**Total Effort**: 8-10 weeks (most complex subsystem)

---

#### Materials System (src/materials/) - 19 files

18+ material types inheriting from Material base class.

**JavaScript Pattern**:
```javascript
class Material {
    constructor() {
        this.uuid = generateUUID();
        this.type = this.constructor.name;
        this.opacity = 1.0;
        this.transparent = false;
    }
}

class MeshStandardMaterial extends Material {
    constructor(parameters) {
        super();
        this.roughness = 1.0;
        this.metalness = 0.0;
        this.map = null;
    }
}
```

**Haxe Translation**:
```haxe
class Material {
    public var uuid:String;
    public var type:String;
    public var opacity:Float = 1.0;
    public var transparent:Bool = false;

    public function new() {
        uuid = generateUUID();
        type = Type.getClassName(Type.getClass(this));
    }
}

class MeshStandardMaterial extends Material {
    public var roughness:Float = 1.0;
    public var metalness:Float = 0.0;
    public var map:Null<Texture> = null;

    public function new(?parameters:MeshStandardMaterialParams) {
        super();
        if (parameters != null) {
            // Apply parameters
        }
    }
}
```

**Challenge**: Optional parameters object pattern

**Three.js**:
```javascript
const material = new MeshStandardMaterial({
    color: 0xff0000,
    roughness: 0.5,
    map: texture
});
```

**Haxe Solutions**:

**Option 1 - Typedef**:
```haxe
typedef MeshStandardMaterialParams = {
    ?color:Int,
    ?roughness:Float,
    ?metalness:Float,
    ?map:Texture
}

class MeshStandardMaterial extends Material {
    public function new(?params:MeshStandardMaterialParams) {
        super();
        if (params != null) {
            if (params.color != null) color.setHex(params.color);
            if (params.roughness != null) roughness = params.roughness;
        }
    }
}
```

**Option 2 - Builder Pattern** (more Haxe-idiomatic):
```haxe
var material = new MeshStandardMaterial()
    .setColor(0xff0000)
    .setRoughness(0.5)
    .setMap(texture);
```

**Recommendation**: Use Option 1 for Phase 1 (easier migration), Option 2 for new Haxe APIs

**Total Effort**: 2-3 weeks

---

#### Geometries (src/geometries/) - 22 files

Primitive shapes + complex generators (ExtrudeGeometry, TubeGeometry).

**High Compatibility** - computational geometry code translates directly.

Example - BoxGeometry:
```haxe
class BoxGeometry extends BufferGeometry {
    public function new(width:Float = 1, height:Float = 1, depth:Float = 1,
                        widthSegments:Int = 1, heightSegments:Int = 1, depthSegments:Int = 1) {
        super();

        // Vertex generation logic - pure math, perfect compatibility
        var vertices:Array<Float> = [];
        var indices:Array<Int> = [];

        // ... generation code identical to JS ...

        setAttribute('position', new Float32BufferAttribute(vertices, 3));
        setIndex(indices);
    }
}
```

**Total Effort**: 2-3 weeks

---

#### Loaders (src/loaders/) - 16 files

Async file loading via XMLHttpRequest/fetch.

**Haxe Web APIs**:
```haxe
import js.html.XMLHttpRequest;
import haxe.Http;

class FileLoader {
    public function load(url:String, onLoad:String->Void, ?onProgress:Dynamic->Void, ?onError:Dynamic->Void):Void {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);

        xhr.onload = function(e) {
            if (xhr.status == 200) {
                onLoad(xhr.responseText);
            }
        };

        xhr.onerror = onError;
        xhr.send();
    }
}
```

**Compatibility**: ✓ Excellent (js.html.* provides full browser API)

**Total Effort**: 1-2 weeks

---

#### Animation System (src/animation/) - 8 files

Keyframe interpolation + mixer system.

**High Compatibility** - Time-based calculations, no platform dependencies.

**Total Effort**: 1-2 weeks

---

### 1.3 Build System & Tooling

**Current (JavaScript)**:
- Rollup for bundling
- ES6 modules
- No TypeScript (pure JavaScript)

**Haxe Approach**:

**Option 1 - Module per Class (recommended)**:
```hxml
# build.hxml
-cp src
-main three.Main
-js build/three.js
-D js-es=6
```

File structure:
```
src/
├── three/
│   ├── core/
│   │   ├── Object3D.hx
│   │   ├── BufferGeometry.hx
│   ├── math/
│   │   ├── Vector3.hx
│   │   ├── Matrix4.hx
│   └── Main.hx (exports all classes)
```

**Option 2 - Generate Type Definitions for IDE Support**:
```haxe
// Compile to .d.ts for TypeScript compatibility
-D dts-gen=build/three.d.ts
```

**Distribution**:
- Minified: `build/three.min.js` (via terser)
- Module: `build/three.module.js` (ES6)
- CommonJS: `build/three.cjs` (via --commonjs flag)

**Total Effort**: 1 week initial setup

---

### 1.4 Phase 1 Effort Estimation

| Component | LOC | Complexity | Estimated Time | Priority |
|-----------|-----|------------|----------------|----------|
| Core (Object3D, BufferGeometry, Events) | ~8K | Medium | 3 weeks | P0 |
| Math Library (23 classes) | 13.8K | Low | 4 weeks | P0 |
| WebGLRenderer + Subsystems | ~35K | High | 10 weeks | P0 |
| Materials (18 types) | ~8K | Low-Med | 3 weeks | P0 |
| Geometries (22 types) | ~6K | Low | 2 weeks | P1 |
| Textures (15 types) | ~4K | Low-Med | 2 weeks | P1 |
| Loaders (16 types) | ~5K | Medium | 2 weeks | P2 |
| Animation System | ~3K | Medium | 2 weeks | P2 |
| Lights (7 types) | ~3K | Low | 1 week | P1 |
| Cameras (4 types) | ~2K | Low | 1 week | P1 |
| Objects (Mesh, Line, Points, etc) | ~4K | Low-Med | 2 weeks | P1 |
| Build System & Testing | N/A | Medium | 2 weeks | P0 |
| **TOTAL** | **~58K** | **Mixed** | **34 weeks** | |

**Parallelization Opportunities**:
- Math library can be developed independently (4 weeks)
- Geometries/Materials can proceed concurrently with renderer (overlap 6 weeks)
- With 3-person team: **14-16 weeks** for 80% feature parity

**Phase 1 Deliverable**: Haxe library that compiles to JavaScript, maintains WebGL rendering compatibility, passes three.js test suite.

---

## Phase 2: DirectX 11 Backend

### 2.1 Architecture Overview

**Goal**: Replace WebGL rendering backend with DirectX 11 while maintaining three.js scene graph/material API.

**Haxe Target**: C++ (using hxcpp) with DirectX 11 bindings

---

### 2.2 Rendering API Abstraction

**Current Architecture**:
```
Scene/Camera/Materials
        ↓
  WebGLRenderer ← Tightly coupled to WebGL2 API
        ↓
    WebGL2
```

**Required Architecture**:
```
Scene/Camera/Materials
        ↓
   RenderBackend (interface) ← Abstract rendering interface
        ↙         ↘
WebGLBackend   DirectX11Backend
     ↓               ↓
   WebGL2         DirectX 11
```

---

### 2.3 Abstraction Layer Design

**Step 1: Define Rendering Interface**

```haxe
// Platform-agnostic rendering primitives
interface IRenderBackend {
    function initialize(width:Int, height:Int):Void;
    function clear(color:Color, depth:Float, stencil:Int):Void;

    // Buffer management
    function createBuffer(data:BufferData, usage:BufferUsage):BufferId;
    function updateBuffer(id:BufferId, data:BufferData):Void;
    function deleteBuffer(id:BufferId):Void;

    // Shader management
    function createShader(vertex:String, fragment:String):ShaderId;
    function useShader(id:ShaderId):Void;
    function setUniform(name:String, value:UniformValue):Void;

    // Texture management
    function createTexture(image:ImageData, format:TextureFormat):TextureId;
    function bindTexture(slot:Int, id:TextureId):Void;

    // Render state
    function setDepthTest(enabled:Bool):Void;
    function setBlending(mode:BlendMode):Void;
    function setCullFace(mode:CullMode):Void;

    // Draw calls
    function drawArrays(mode:DrawMode, first:Int, count:Int):Void;
    function drawElements(mode:DrawMode, count:Int, type:IndexType):Void;

    // Render targets
    function createRenderTarget(width:Int, height:Int, format:TextureFormat):RenderTargetId;
    function setRenderTarget(id:Null<RenderTargetId>):Void;
}
```

**Step 2: WebGL Implementation** (refactor existing code)

```haxe
class WebGLBackend implements IRenderBackend {
    var gl:GL2;

    public function initialize(width:Int, height:Int):Void {
        // Existing WebGLRenderer initialization
    }

    public function createBuffer(data:BufferData, usage:BufferUsage):BufferId {
        var buffer = gl.createBuffer();
        gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
        gl.bufferData(GL.ARRAY_BUFFER, data, convertUsage(usage));
        return new BufferId(buffer);
    }

    public function createShader(vertex:String, fragment:String):ShaderId {
        var vs = compileShader(GL.VERTEX_SHADER, vertex);
        var fs = compileShader(GL.FRAGMENT_SHADER, fragment);
        var program = gl.createProgram();
        gl.attachShader(program, vs);
        gl.attachShader(program, fs);
        gl.linkProgram(program);
        return new ShaderId(program);
    }

    // ... implement all interface methods ...
}
```

**Step 3: DirectX 11 Implementation**

```haxe
@:headerInclude("d3d11.h")
@:headerInclude("d3dcompiler.h")
class DirectX11Backend implements IRenderBackend {
    var device:cpp.Pointer<ID3D11Device>;
    var context:cpp.Pointer<ID3D11DeviceContext>;
    var swapChain:cpp.Pointer<IDXGISwapChain>;

    public function initialize(width:Int, height:Int):Void {
        untyped __cpp__('
            DXGI_SWAP_CHAIN_DESC sd = {};
            sd.BufferCount = 1;
            sd.BufferDesc.Width = {0};
            sd.BufferDesc.Height = {1};
            sd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
            sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
            sd.OutputWindow = hWnd;
            sd.SampleDesc.Count = 1;
            sd.Windowing = TRUE;

            D3D11CreateDeviceAndSwapChain(
                nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0,
                nullptr, 0, D3D11_SDK_VERSION,
                &sd, &swapChain, &device, nullptr, &context
            );
        ', width, height);
    }

    public function createBuffer(data:BufferData, usage:BufferUsage):BufferId {
        var buffer:cpp.Pointer<ID3D11Buffer>;
        untyped __cpp__('
            D3D11_BUFFER_DESC desc = {};
            desc.ByteWidth = {0};
            desc.Usage = {1};
            desc.BindFlags = D3D11_BIND_VERTEX_BUFFER;

            D3D11_SUBRESOURCE_DATA initData = {};
            initData.pSysMem = {2};

            device->CreateBuffer(&desc, &initData, &buffer);
        ', data.byteLength, convertUsage(usage), data.pointer);

        return new BufferId(buffer);
    }

    public function createShader(vertex:String, fragment:String):ShaderId {
        // Compile HLSL (converted from GLSL)
        var vsBlob:cpp.Pointer<ID3DBlob>;
        var psBlob:cpp.Pointer<ID3DBlob>;

        untyped __cpp__('
            D3DCompile(
                {0}, strlen({0}), "VS", nullptr, nullptr, "main", "vs_5_0",
                0, 0, &vsBlob, nullptr
            );
            D3DCompile(
                {1}, strlen({1}), "PS", nullptr, nullptr, "main", "ps_5_0",
                0, 0, &psBlob, nullptr
            );
        ', vertex, fragment);

        var vs:cpp.Pointer<ID3D11VertexShader>;
        var ps:cpp.Pointer<ID3D11PixelShader>;

        untyped __cpp__('
            device->CreateVertexShader(vsBlob->GetBufferPointer(), vsBlob->GetBufferSize(), nullptr, &vs);
            device->CreatePixelShader(psBlob->GetBufferPointer(), psBlob->GetBufferSize(), nullptr, &ps);
        ');

        return new ShaderId(vs, ps);
    }

    public function drawElements(mode:DrawMode, count:Int, type:IndexType):Void {
        untyped __cpp__('
            context->DrawIndexed({0}, 0, 0);
        ', count);
    }

    // ... implement all interface methods ...
}
```

---

### 2.4 Shader Translation (GLSL → HLSL)

**Major Challenge**: Three.js has 109 GLSL shader chunks that must be converted to HLSL.

**Differences**:

| GLSL (WebGL) | HLSL (DirectX 11) |
|--------------|-------------------|
| `attribute vec3 position;` | `float3 position : POSITION;` |
| `varying vec2 vUv;` | VS output: `float2 uv : TEXCOORD0;` |
| `uniform mat4 modelViewMatrix;` | `cbuffer Matrices { float4x4 modelViewMatrix; }` |
| `texture2D(map, uv)` | `map.Sample(samplerState, uv)` |
| `gl_Position` | Output: `float4 position : SV_POSITION;` |
| `gl_FragColor` | Output: `float4 color : SV_TARGET;` |

**Conversion Strategies**:

**Option 1 - Manual Conversion** (109 shaders × 2 hours = ~220 hours = 5.5 weeks)
- Translate each shader chunk individually
- Maintain parallel GLSL/HLSL versions
- High accuracy but labor-intensive

**Option 2 - Automated Translator** (3 weeks to build + 2 weeks refinement)
```haxe
class GLSLToHLSL {
    public static function convert(glsl:String):String {
        var hlsl = glsl;

        // Attribute/varying conversion
        hlsl = ~/attribute\s+(\w+)\s+(\w+);/g.map(hlsl, (r) -> {
            return '${r.matched(1)} ${r.matched(2)} : ${getSemanticForType(r.matched(1))};';
        });

        // Uniform conversion
        hlsl = ~/uniform\s+(\w+)\s+(\w+);/g.map(hlsl, (r) -> {
            return 'cbuffer CB { ${r.matched(1)} ${r.matched(2)}; }';
        });

        // Texture sampling
        hlsl = ~/texture2D\((\w+),\s*(\w+)\)/g.replace(hlsl, '$1.Sample(sampler$1, $2)');

        // Built-ins
        hlsl = hlsl.replace('gl_Position', 'output.position');
        hlsl = hlsl.replace('gl_FragColor', 'return');

        return hlsl;
    }
}
```

**Option 3 - Runtime Transpiler** (using spirv-cross or similar)
- GLSL → SPIR-V → HLSL
- Automated but adds runtime dependency
- May not preserve exact shader structure

**Recommendation**: Option 2 (automated translator) + manual refinement for complex shaders

---

### 2.5 Platform-Specific Considerations

**Windowing System**:
- WebGL: Uses HTML Canvas
- DirectX 11: Requires native window (Win32 API)

```haxe
#if js
    // Browser canvas
    var canvas:js.html.CanvasElement = js.Browser.document.createCanvasElement();
    var backend:IRenderBackend = new WebGLBackend(canvas);
#elseif cpp
    // Win32 window
    var window:cpp.Pointer<HWND> = createWin32Window(800, 600);
    var backend:IRenderBackend = new DirectX11Backend(window);
#end
```

**Input Handling**:
```haxe
#if js
    canvas.addEventListener('mousemove', onMouseMove);
#elseif cpp
    // Win32 message loop
    untyped __cpp__('MSG msg; while (GetMessage(&msg, nullptr, 0, 0)) { ... }');
#end
```

---

### 2.6 DirectX 11 Bindings

**Haxe does NOT have built-in DirectX bindings** - must create custom externs.

**Required Bindings**:

```haxe
// d3d11.hx
@:include("d3d11.h")
@:native("ID3D11Device")
extern class ID3D11Device {
    @:native("CreateBuffer")
    function CreateBuffer(desc:cpp.Pointer<D3D11_BUFFER_DESC>,
                         data:cpp.Pointer<D3D11_SUBRESOURCE_DATA>,
                         buffer:cpp.Pointer<cpp.Pointer<ID3D11Buffer>>):Int;

    @:native("CreateTexture2D")
    function CreateTexture2D(desc:cpp.Pointer<D3D11_TEXTURE2D_DESC>,
                            data:cpp.Pointer<D3D11_SUBRESOURCE_DATA>,
                            texture:cpp.Pointer<cpp.Pointer<ID3D11Texture2D>>):Int;
}

@:include("d3d11.h")
@:native("ID3D11DeviceContext")
extern class ID3D11DeviceContext {
    @:native("Draw")
    function Draw(vertexCount:Int, startVertexLocation:Int):Void;

    @:native("DrawIndexed")
    function DrawIndexed(indexCount:Int, startIndexLocation:Int, baseVertexLocation:Int):Void;
}

// ... 50+ more DirectX types ...
```

**Effort Estimation**:
- Core DirectX 11 API bindings: 2-3 weeks
- Testing & validation: 1 week
- Total: 3-4 weeks

**Alternative**: Use existing hxcpp DirectX wrappers if available (check Haxe library ecosystem)

---

### 2.7 Phase 2 Effort Estimation

| Task | Complexity | Estimated Time | Dependencies |
|------|------------|----------------|--------------|
| Design Rendering Abstraction Layer | High | 2 weeks | Phase 1 complete |
| Refactor WebGLRenderer to use Interface | High | 4 weeks | Abstraction design |
| Create DirectX 11 Bindings (hxcpp) | High | 4 weeks | None |
| Implement DirectX11Backend | Very High | 8 weeks | Bindings |
| Shader Translation (GLSL→HLSL) | High | 6 weeks | Parser dev |
| Platform Abstraction (Window/Input) | Medium | 2 weeks | DirectX Backend |
| Testing & Debugging | High | 4 weeks | All above |
| Performance Optimization | Medium | 3 weeks | Testing |
| **TOTAL** | | **33 weeks** | |

**With 2-person team**: 18-20 weeks

---

## Summary & Recommendations

### Phase 1: Haxe → JavaScript (WebGL)

**Feasibility**: ✓ **Highly Feasible**

**Advantages**:
- Haxe's type system catches errors at compile-time
- Superior OOP features map perfectly to three.js architecture
- `inline` keyword enables zero-cost abstractions for math
- Full access to browser APIs via `js.html.*`
- Can generate .d.ts files for TypeScript interop

**Challenges**:
- Dynamic property patterns require careful typing
- Event system needs design decision (direct port vs Haxe signals)
- Build system setup & module organization

**Estimated Timeline**:
- Solo developer: 34 weeks (full port)
- 3-person team: 14-16 weeks (80% feature parity)

**Recommended First Milestones**:
1. Math library (4 weeks) - validates toolchain & performance
2. Core classes (3 weeks) - Object3D, BufferGeometry, Scene
3. Basic WebGL renderer (6 weeks) - minimal feature set
4. Materials + Geometries (4 weeks) - enable real-world usage
5. Full renderer features (8 weeks) - shadows, post-processing, etc.

---

### Phase 2: DirectX 11 Backend

**Feasibility**: ✓ **Feasible with Significant Effort**

**Advantages**:
- Haxe's conditional compilation (#if cpp) enables single codebase
- Abstract rendering interface enables future backends (Vulkan, Metal)
- DirectX 11 is mature, well-documented API

**Challenges**:
- Requires extensive DirectX 11 bindings (50+ types)
- GLSL→HLSL shader translation (109 shaders)
- Platform-specific windowing/input code
- Testing requires Windows environment

**Critical Dependencies**:
- Phase 1 must be complete and stable
- Abstraction layer must not degrade WebGL performance
- Shader translator must handle all three.js shader patterns

**Estimated Timeline**:
- Solo developer: 33 weeks
- 2-person team: 18-20 weeks

**Risk Mitigation**:
1. Build DirectX bindings first (validates hxcpp workflow)
2. Create minimal DirectX11Backend with 1 shader (validates architecture)
3. Port shaders incrementally (test each material type)
4. Maintain WebGL compatibility throughout

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Haxe performance < JavaScript | Medium | Use `inline`, benchmark early, profile generated JS |
| DirectX bindings incomplete | High | Audit hxcpp ecosystem, budget time for custom bindings |
| GLSL→HLSL conversion errors | High | Build automated tests, validate against reference renderer |
| Abstraction layer overhead | Medium | Design for zero-cost abstractions, profile both backends |
| Haxe ecosystem instability | Low | Pin dependency versions, contribute fixes upstream |

---

## Conclusion

**Phase 1 (Haxe→JS)** is a straightforward port with excellent language compatibility and significant long-term benefits (type safety, multi-platform potential).

**Phase 2 (DirectX 11)** is architecturally sound but requires substantial engineering effort, particularly in shader translation and API bindings.

**Total Effort**: 67 weeks solo (16 months) OR 32-36 weeks with small team (8-9 months)

**Go/No-Go Recommendation**:
- **Phase 1: GO** - Strong ROI, validates toolchain
- **Phase 2: GO if Phase 1 succeeds** - Builds on proven foundation

**Next Steps**:
1. Create proof-of-concept: Vector3/Matrix4 in Haxe (1 week)
2. Benchmark math performance Haxe vs three.js (3 days)
3. Prototype WebGL context creation + simple triangle (1 week)
4. Evaluate DirectX binding libraries (3 days)
5. Build minimal DirectX11Backend rendering triangle (2 weeks)

**Decision Point**: After step 3, assess whether to commit to full Phase 1 port.
