# Three.hx - Haxe port of Three.js

A minimal Haxe port of Three.js targeting JavaScript. This port provides the basic functionality needed to render a spinning cube using WebGL.

## Features

- **Math utilities**: Vector3, Matrix4, Quaternion, Euler, Color, MathUtils
- **Core classes**: EventDispatcher, Object3D, BufferGeometry, BufferAttribute
- **Scene graph**: Scene
- **Cameras**: Camera, PerspectiveCamera
- **Materials**: Material, MeshBasicMaterial
- **Objects**: Mesh
- **Geometries**: BoxGeometry
- **Rendering**: WebGLRenderer (JavaScript target only)

## Building

Make sure you have [Haxe](https://haxe.org/) installed, then run:

```bash
cd haxe
haxe build.hxml
```

This will generate `bin/three.js`.

## Running the Example

Open `bin/index.html` in a web browser to see a spinning green cube.

## Usage

```haxe
import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshBasicMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;

// Create scene
var scene = new Scene();

// Create camera
var camera = new PerspectiveCamera(75, 800 / 600, 0.1, 1000);
camera.position.z = 5;

// Create cube
var geometry = new BoxGeometry(1, 1, 1);
var material = new MeshBasicMaterial({color: 0x00ff00});
var cube = new Mesh(geometry, material);
scene.add(cube);

// Create renderer
var renderer = new WebGLRenderer();
renderer.setSize(800, 600);

// Animation loop
function animate(time:Float):Void
{
    js.Browser.window.requestAnimationFrame(animate);

    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;
    cube.updateMatrix();

    renderer.render(scene, camera);
}

animate(0);
```

## API Compatibility

This port follows the Three.js API as closely as possible while adapting to Haxe conventions:

- Uses Allman-style braces
- Properties use Haxe getter/setter syntax
- Enums use Haxe abstract enums
- JavaScript-specific code is conditionally compiled with `#if js`

## Limitations

This is a minimal port focused on getting a basic spinning cube working. The following features are not yet implemented:

- Textures
- Lights and lighting materials (MeshPhongMaterial, MeshStandardMaterial, etc.)
- Shadows
- Post-processing
- Loaders
- Animation system
- Raycasting
- Helpers
- And many more...

## License

MIT License (same as Three.js)
