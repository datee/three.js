package three.examples;

/**
 * Three.js Example: Lights Demo
 *
 * Demonstrates all three light types supported by the Haxe port:
 * - AmbientLight: Global illumination
 * - DirectionalLight: Parallel rays (like sunlight)
 * - PointLight: Omnidirectional light with falloff
 *
 * Features three cubes with different materials to show lighting effects.
 */

#if js
import js.Browser;
#end

import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.geometries.BoxGeometry;
import three.materials.MeshBasicMaterial;
import three.materials.MeshLambertMaterial;
import three.materials.MeshPhongMaterial;
import three.objects.Mesh;
import three.renderers.WebGLRenderer;
import three.lights.AmbientLight;
import three.lights.DirectionalLight;
import three.lights.PointLight;
import three.math.Color;

class Lights
{
    static var camera:PerspectiveCamera;
    static var scene:Scene;
    static var renderer:WebGLRenderer;

    static var cubeBasic:Mesh;
    static var cubeLambert:Mesh;
    static var cubePhong:Mesh;

    static var pointLight:PointLight;
    static var time:Float = 0;

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
        // Scene
        scene = new Scene();
        scene.background = new Color(0x1a1a2e);

        // Camera
        camera = new PerspectiveCamera(60, Browser.window.innerWidth / Browser.window.innerHeight, 0.1, 100);
        camera.position.set(0, 2, 8);
        camera.lookAtVector(scene.position);

        // Geometry (shared)
        var geometry = new BoxGeometry(1.5, 1.5, 1.5);

        // Three cubes with different materials
        // Left: MeshBasicMaterial (unlit)
        var basicMaterial = new MeshBasicMaterial({color: 0xff6b6b});
        cubeBasic = new Mesh(geometry, basicMaterial);
        cubeBasic.position.x = -3;
        scene.add(cubeBasic);

        // Center: MeshLambertMaterial (diffuse only)
        var lambertMaterial = new MeshLambertMaterial({color: 0x4ecdc4});
        cubeLambert = new Mesh(geometry, lambertMaterial);
        cubeLambert.position.x = 0;
        scene.add(cubeLambert);

        // Right: MeshPhongMaterial (diffuse + specular)
        var phongMaterial = new MeshPhongMaterial({
            color: 0x95e1d3,
            specular: 0xffffff,
            shininess: 100
        });
        cubePhong = new Mesh(geometry, phongMaterial);
        cubePhong.position.x = 3;
        scene.add(cubePhong);

        // === LIGHTS ===

        // Ambient light - soft global illumination
        var ambientLight = new AmbientLight(0x404040, 0.5);
        scene.add(ambientLight);

        // Directional light - like sunlight from top-right
        var directionalLight = new DirectionalLight(0xffffff, 1.0);
        directionalLight.position.set(5, 5, 5);
        scene.add(directionalLight);

        // Point light - orbiting colored light
        pointLight = new PointLight(0xff9500, 2.0, 15, 2);
        pointLight.position.set(0, 2, 0);
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

        // Rotate all cubes
        cubeBasic.rotation.x = time * 0.5;
        cubeBasic.rotation.y = time * 0.3;

        cubeLambert.rotation.x = time * 0.5;
        cubeLambert.rotation.y = time * 0.3;

        cubePhong.rotation.x = time * 0.5;
        cubePhong.rotation.y = time * 0.3;

        // Orbit the point light around the cubes
        pointLight.position.x = Math.cos(time) * 5;
        pointLight.position.z = Math.sin(time) * 5;
        pointLight.position.y = Math.sin(time * 0.5) * 2 + 2;

        renderer.render(scene, camera);
    }
    #end
}
