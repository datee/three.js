package three.examples;

/**
 * Three.js Example Port: webgl_geometry_cube
 *
 * A simple spinning cube - the "Hello World" of 3D graphics.
 * Original: https://threejs.org/examples/#webgl_geometry_cube
 */

#if js
import js.Browser;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshBasicMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.math.Color;

class GeometryCube
{
    static var camera:PerspectiveCamera;
    static var scene:Scene;
    static var renderer:WebGLRenderer;
    static var mesh:Mesh;

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
        camera.position.z = 2;

        // Scene
        scene = new Scene();
        scene.background = new Color(0x000000);

        // Geometry and Material
        var geometry = new BoxGeometry(1, 1, 1);
        var material = new MeshBasicMaterial({color: 0x00ff00});

        // Mesh
        mesh = new Mesh(geometry, material);
        scene.add(mesh);

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

        mesh.rotation.x += 0.005;
        mesh.rotation.y += 0.01;

        renderer.render(scene, camera);
    }
    #end
}
