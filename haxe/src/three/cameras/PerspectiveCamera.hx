package three.cameras;

import three.cameras.Camera;
import three.core.Object3D;
import three.math.MathUtils;

/**
 * Camera that uses perspective projection.
 */
class PerspectiveCamera extends Camera
{
    public var fov:Float;
    public var zoom:Float;
    public var near:Float;
    public var far:Float;
    public var focus:Float;
    public var aspect:Float;
    public var view:Dynamic;
    public var filmGauge:Float;
    public var filmOffset:Float;

    public var isPerspectiveCamera(default, never):Bool = true;

    public function new(fov:Float = 50, aspect:Float = 1, near:Float = 0.1, far:Float = 2000)
    {
        super();

        type = "PerspectiveCamera";

        this.fov = fov;
        this.zoom = 1;
        this.near = near;
        this.far = far;
        this.focus = 10;
        this.aspect = aspect;
        this.view = null;
        this.filmGauge = 35; // width of the film (default in millimeters)
        this.filmOffset = 0; // horizontal film offset (same unit as gauge)

        updateProjectionMatrix();
    }

    public function setFocalLength(focalLength:Float):Void
    {
        // see http://www.bobatkins.com/photography/technical/field_of_view.html
        var vExtentSlope = 0.5 * getFilmHeight() / focalLength;
        fov = MathUtils.RAD2DEG * 2 * Math.atan(vExtentSlope);
        updateProjectionMatrix();
    }

    public function getFocalLength():Float
    {
        var vExtentSlope = Math.tan(MathUtils.DEG2RAD * 0.5 * fov);
        return 0.5 * getFilmHeight() / vExtentSlope;
    }

    public function getEffectiveFOV():Float
    {
        return MathUtils.RAD2DEG * 2 * Math.atan(Math.tan(MathUtils.DEG2RAD * 0.5 * fov) / zoom);
    }

    public function getFilmWidth():Float
    {
        return filmGauge * Math.min(aspect, 1);
    }

    public function getFilmHeight():Float
    {
        return filmGauge / Math.max(aspect, 1);
    }

    /**
     * Sets an offset in a larger frustum. This is useful for multi-window or
     * multi-monitor/multi-machine setups.
     */
    public function setViewOffset(fullWidth:Float, fullHeight:Float, x:Float, y:Float, width:Float, height:Float):Void
    {
        aspect = fullWidth / fullHeight;

        view = {
            enabled: true,
            fullWidth: fullWidth,
            fullHeight: fullHeight,
            offsetX: x,
            offsetY: y,
            width: width,
            height: height
        };

        updateProjectionMatrix();
    }

    public function clearViewOffset():Void
    {
        if (view != null)
        {
            view.enabled = false;
        }

        updateProjectionMatrix();
    }

    public function updateProjectionMatrix():Void
    {
        var near = this.near;
        var top = near * Math.tan(MathUtils.DEG2RAD * 0.5 * fov) / zoom;
        var height = 2 * top;
        var width = aspect * height;
        var left = -0.5 * width;

        if (view != null && view.enabled)
        {
            var fullWidth:Float = view.fullWidth;
            var fullHeight:Float = view.fullHeight;

            left += view.offsetX * width / fullWidth;
            top -= view.offsetY * height / fullHeight;
            width *= view.width / fullWidth;
            height *= view.height / fullHeight;
        }

        var skew = filmOffset;
        if (skew != 0) left += near * skew / getFilmWidth();

        projectionMatrix.makePerspective(left, left + width, top, top - height, near, far);

        projectionMatrixInverse.copy(projectionMatrix).invert();
    }

    public function copyPerspective(source:PerspectiveCamera, recursive:Bool = true):PerspectiveCamera
    {
        super.copyCamera(source, recursive);

        fov = source.fov;
        zoom = source.zoom;
        near = source.near;
        far = source.far;
        focus = source.focus;
        aspect = source.aspect;
        view = source.view;
        filmGauge = source.filmGauge;
        filmOffset = source.filmOffset;

        return this;
    }

    override public function clone(recursive:Bool = true):Object3D
    {
        return new PerspectiveCamera().copyPerspective(this, recursive);
    }
}
