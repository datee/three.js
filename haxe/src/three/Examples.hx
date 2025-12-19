package three;

#if js
import js.Browser;
import js.html.Window;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshBasicMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.math.Color;

/**
 * Spinning Cube Example
 *
 * This demonstrates the basic usage of the Three.hx library:
 * - Creating a scene
 * - Adding a camera
 * - Creating a mesh with geometry and material
 * - Setting up a renderer
 * - Animation loop
 */
class Examples
{
    static var scene:Scene;
    static var camera:PerspectiveCamera;
    static var renderer:WebGLRenderer;
    static var cube:Mesh;

    static function main():Void
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
        // Create the scene
        scene = new Scene();
        scene.background = new Color(0x1a1a2e);

        // Create the camera
        var aspect = Browser.window.innerWidth / Browser.window.innerHeight;
        camera = new PerspectiveCamera(75, aspect, 0.1, 1000);
        camera.position.z = 5;

        // Create the geometry
        var geometry = new BoxGeometry(1, 1, 1);

        // Create the material
        var material = new MeshBasicMaterial({color: 0x00ff88});

        // Create the mesh
        cube = new Mesh(geometry, material);
        scene.add(cube);

        // Create the renderer
        renderer = new WebGLRenderer({antialias: true});
        renderer.setSize(Browser.window.innerWidth, Browser.window.innerHeight);
        renderer.setPixelRatio(Browser.window.devicePixelRatio);

        // Add the renderer to the DOM
        Browser.document.body.appendChild(renderer.domElement);

        // Handle window resize
        Browser.window.addEventListener("resize", function(_)
        {
            var width = Browser.window.innerWidth;
            var height = Browser.window.innerHeight;

            camera.aspect = width / height;
            camera.updateProjectionMatrix();

            renderer.setSize(width, height);
        });
    }

    static function animate(time:Float):Void
    {
        // Request next frame
        Browser.window.requestAnimationFrame(animate);

        // Rotate the cube
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;

        // Update matrices
        cube.updateMatrix();

        // Render the scene
        renderer.render(scene, camera);
    }
    #end
}
