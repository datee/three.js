package three;

#if js
import js.Browser;
import js.html.Window;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshPhongMaterial;
import three.materials.MeshLambertMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.math.Color;
import three.lights.AmbientLight;
import three.lights.DirectionalLight;
import three.lights.PointLight;

/**
 * Lit Cube Example
 *
 * This demonstrates the lighting system in Three.hx:
 * - Ambient light for global illumination
 * - Directional light for sunlight-like lighting
 * - Point light for local light sources
 * - MeshPhongMaterial for shiny surfaces
 */
class LitExample
{
    static var scene:Scene;
    static var camera:PerspectiveCamera;
    static var renderer:WebGLRenderer;
    static var cube:Mesh;
    static var pointLight:PointLight;

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
        var geometry = new BoxGeometry(2, 2, 2);

        // Create a shiny Phong material
        var material = new MeshPhongMaterial({
            color: 0x00aaff,
            specular: 0xffffff,
            shininess: 100
        });

        // Create the mesh
        cube = new Mesh(geometry, material);
        scene.add(cube);

        // Add ambient light for base illumination
        var ambientLight = new AmbientLight(0x404040, 0.5);
        scene.add(ambientLight);

        // Add directional light (like sunlight)
        var directionalLight = new DirectionalLight(0xffffff, 1.0);
        directionalLight.position.set(5, 5, 5);
        scene.add(directionalLight);

        // Add point light that will orbit around the cube
        pointLight = new PointLight(0xff6600, 1.5, 10, 2);
        pointLight.position.set(3, 0, 0);
        scene.add(pointLight);

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

        // Orbit the point light around the cube
        var orbitSpeed = time * 0.001;
        pointLight.position.x = Math.cos(orbitSpeed) * 4;
        pointLight.position.z = Math.sin(orbitSpeed) * 4;
        pointLight.position.y = Math.sin(orbitSpeed * 0.5) * 2;

        // Update matrices
        cube.updateMatrix();
        pointLight.updateMatrix();

        // Render the scene
        renderer.render(scene, camera);
    }
    #end
}
