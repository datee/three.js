package three.examples;

/**
 * Three.js Example: Cube Grid
 *
 * A 5x5x5 grid of colorful cubes with Phong shading.
 * Demonstrates batch rendering and lighting on many objects.
 */

#if js
import js.Browser;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshPhongMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.lights.AmbientLight;
import three.lights.DirectionalLight;
import three.lights.PointLight;
import three.math.Color;

class CubeGrid
{
    static var camera:PerspectiveCamera;
    static var scene:Scene;
    static var renderer:WebGLRenderer;
    static var cubes:Array<Mesh> = [];
    static var time:Float = 0;

    static inline var GRID_SIZE:Int = 5;
    static inline var SPACING:Float = 2.0;
    static inline var CUBE_SIZE:Float = 0.8;

    public static function main():Void
    {
        #if js
        init();
        animate(0);
        #else
        trace("This example requires the JavaScript target.");
        #end
    }

    #if js
    static function init():Void
    {
        // Scene (must be created first for lookAt)
        scene = new Scene();
        scene.background = new Color(0x111122);

        // Camera
        camera = new PerspectiveCamera(60, Browser.window.innerWidth / Browser.window.innerHeight, 0.1, 1000);
        camera.position.set(15, 15, 15);
        camera.lookAtVector(scene.position);

        // Geometry (shared by all cubes)
        var geometry = new BoxGeometry(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);

        // Create cube grid
        var offset = (GRID_SIZE - 1) * SPACING / 2;

        for (x in 0...GRID_SIZE)
        {
            for (y in 0...GRID_SIZE)
            {
                for (z in 0...GRID_SIZE)
                {
                    // Create color based on position
                    var r = x / (GRID_SIZE - 1);
                    var g = y / (GRID_SIZE - 1);
                    var b = z / (GRID_SIZE - 1);

                    var color = new Color();
                    color.setRGB(r, g, b);

                    var material = new MeshPhongMaterial({
                        color: Std.int(color.getHex()),
                        specular: 0x444444,
                        shininess: 30
                    });

                    var cube = new Mesh(geometry, material);
                    cube.position.x = x * SPACING - offset;
                    cube.position.y = y * SPACING - offset;
                    cube.position.z = z * SPACING - offset;

                    scene.add(cube);
                    cubes.push(cube);
                }
            }
        }

        // Ambient light
        var ambientLight = new AmbientLight(0x404040, 0.3);
        scene.add(ambientLight);

        // Directional light from above
        var directionalLight = new DirectionalLight(0xffffff, 1.0);
        directionalLight.position.set(10, 20, 10);
        scene.add(directionalLight);

        // Point light that will orbit
        var pointLight = new PointLight(0xffaa00, 1.5, 30, 2);
        pointLight.position.set(0, 10, 0);
        scene.add(pointLight);

        // Renderer
        renderer = new WebGLRenderer({antialias: true});
        renderer.setPixelRatio(Browser.window.devicePixelRatio);
        renderer.setSize(Browser.window.innerWidth, Browser.window.innerHeight);
        Browser.document.body.appendChild(renderer.domElement);

        // Handle resize
        Browser.window.addEventListener("resize", onWindowResize);
    }

    static function onWindowResize(_):Void
    {
        camera.aspect = Browser.window.innerWidth / Browser.window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(Browser.window.innerWidth, Browser.window.innerHeight);
    }

    static function animate(timestamp:Float):Void
    {
        Browser.window.requestAnimationFrame(animate);

        time = timestamp * 0.001;

        // Rotate camera around the grid
        var radius = 20;
        camera.position.x = Math.cos(time * 0.3) * radius;
        camera.position.z = Math.sin(time * 0.3) * radius;
        camera.position.y = 10 + Math.sin(time * 0.2) * 5;
        camera.lookAtVector(scene.position);

        // Animate each cube with a wave effect
        for (i in 0...cubes.length)
        {
            var cube = cubes[i];
            var offset = i * 0.1;
            cube.rotation.x = time + offset;
            cube.rotation.y = time * 0.5 + offset;
        }

        renderer.render(scene, camera);
    }
    #end
}
