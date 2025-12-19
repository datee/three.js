package three.examples;

/**
 * Three.js Example Port: webgl_interactive_cubes (simplified)
 *
 * 2000 randomly positioned and colored cubes with an orbiting camera.
 * Original: https://threejs.org/examples/#webgl_interactive_cubes
 *
 * Note: Raycasting/interaction not yet implemented in Haxe port.
 */

#if js
import js.Browser;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshLambertMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.lights.DirectionalLight;
import three.math.Color;

class RandomCubes
{
    static var camera:PerspectiveCamera;
    static var scene:Scene;
    static var renderer:WebGLRenderer;

    static var theta:Float = 0;
    static inline var RADIUS:Float = 5;
    static inline var NUM_CUBES:Int = 500; // Reduced from 2000 for performance

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
        // Camera
        camera = new PerspectiveCamera(70, Browser.window.innerWidth / Browser.window.innerHeight, 0.1, 100);

        // Scene
        scene = new Scene();
        scene.background = new Color(0xf0f0f0);

        // Directional light
        var light = new DirectionalLight(0xffffff, 3);
        light.position.set(1, 1, 1);
        scene.add(light);

        // Create many cubes
        var geometry = new BoxGeometry(1, 1, 1);

        for (i in 0...NUM_CUBES)
        {
            // Random color for each cube
            var color = Std.int(Math.random() * 0xffffff);
            var material = new MeshLambertMaterial({color: color});

            var mesh = new Mesh(geometry, material);

            // Random position
            mesh.position.x = Math.random() * 40 - 20;
            mesh.position.y = Math.random() * 40 - 20;
            mesh.position.z = Math.random() * 40 - 20;

            // Random rotation
            mesh.rotation.x = Math.random() * 2 * Math.PI;
            mesh.rotation.y = Math.random() * 2 * Math.PI;
            mesh.rotation.z = Math.random() * 2 * Math.PI;

            // Random scale
            mesh.scale.x = Math.random() + 0.5;
            mesh.scale.y = Math.random() + 0.5;
            mesh.scale.z = Math.random() + 0.5;

            scene.add(mesh);
        }

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

    static function animate(_:Float):Void
    {
        Browser.window.requestAnimationFrame(animate);

        // Orbit camera around scene
        theta += 0.1;

        var radians = theta * Math.PI / 180;
        camera.position.x = RADIUS * Math.sin(radians);
        camera.position.y = RADIUS * Math.sin(radians);
        camera.position.z = RADIUS * Math.cos(radians);
        camera.lookAtVector(scene.position);

        renderer.render(scene, camera);
    }
    #end
}
