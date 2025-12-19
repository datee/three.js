package three;

/**
 * Three.hx - Haxe port of Three.js
 * A minimal port targeting JavaScript for basic 3D rendering.
 */

// Re-export all public classes
import three.math.Vector3;
import three.math.Matrix4;
import three.math.Quaternion;
import three.math.Euler;
import three.math.Color;
import three.math.MathUtils;

import three.core.EventDispatcher;
import three.core.Object3D;
import three.core.BufferGeometry;
import three.core.BufferAttribute;

import three.scenes.Scene;

import three.cameras.Camera;
import three.cameras.PerspectiveCamera;

import three.materials.Material;
import three.materials.MeshBasicMaterial;

import three.objects.Mesh;

import three.geometries.BoxGeometry;

import three.renderers.WebGLRenderer;

class Three
{
    public static inline var REVISION:String = "183dev-haxe";
}
