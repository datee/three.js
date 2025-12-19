package three.materials;

import three.core.EventDispatcher;
import three.math.Color;
import three.math.MathUtils;
import three.Constants;

/**
 * Abstract base class for materials.
 */
class Material extends EventDispatcher
{
    private static var _materialId:Int = 0;

    public var id(default, null):Int;
    public var uuid:String;
    public var name:String;
    public var type:String;

    public var blending:Int;
    public var side:Int;
    public var vertexColors:Bool;

    public var opacity:Float;
    public var transparent:Bool;

    public var blendSrc:Int;
    public var blendDst:Int;
    public var blendEquation:Int;
    public var blendSrcAlpha:Null<Int>;
    public var blendDstAlpha:Null<Int>;
    public var blendEquationAlpha:Null<Int>;
    public var blendColor:Color;
    public var blendAlpha:Float;

    public var depthFunc:Int;
    public var depthTest:Bool;
    public var depthWrite:Bool;

    public var stencilWriteMask:Int;
    public var stencilFunc:Int;
    public var stencilRef:Int;
    public var stencilFuncMask:Int;
    public var stencilFail:Int;
    public var stencilZFail:Int;
    public var stencilZPass:Int;
    public var stencilWrite:Bool;

    public var clippingPlanes:Array<Dynamic>;
    public var clipIntersection:Bool;
    public var clipShadows:Bool;

    public var shadowSide:Null<Int>;

    public var colorWrite:Bool;

    public var precision:Null<String>;

    public var polygonOffset:Bool;
    public var polygonOffsetFactor:Float;
    public var polygonOffsetUnits:Float;

    public var dithering:Bool;

    public var alphaToCoverage:Bool;
    public var premultipliedAlpha:Bool;
    public var forceSinglePass:Bool;

    public var visible:Bool;
    public var toneMapped:Bool;

    public var userData:Dynamic;

    public var version:Int;

    private var _alphaTest:Float;

    public var isMaterial(default, never):Bool = true;

    public function new()
    {
        super();

        id = _materialId++;
        uuid = MathUtils.generateUUID();
        name = "";
        type = "Material";

        blending = 1; // NormalBlending
        side = 0; // FrontSide
        vertexColors = false;

        opacity = 1;
        transparent = false;

        blendSrc = 204; // SrcAlphaFactor
        blendDst = 205; // OneMinusSrcAlphaFactor
        blendEquation = 100; // AddEquation
        blendSrcAlpha = null;
        blendDstAlpha = null;
        blendEquationAlpha = null;
        blendColor = new Color(0, 0, 0);
        blendAlpha = 0;

        depthFunc = 3; // LessEqualDepth
        depthTest = true;
        depthWrite = true;

        stencilWriteMask = 0xff;
        stencilFunc = 519; // AlwaysStencilFunc
        stencilRef = 0;
        stencilFuncMask = 0xff;
        stencilFail = 7680; // KeepStencilOp
        stencilZFail = 7680;
        stencilZPass = 7680;
        stencilWrite = false;

        clippingPlanes = null;
        clipIntersection = false;
        clipShadows = false;

        shadowSide = null;

        colorWrite = true;

        precision = null;

        polygonOffset = false;
        polygonOffsetFactor = 0;
        polygonOffsetUnits = 0;

        dithering = false;

        alphaToCoverage = false;
        premultipliedAlpha = false;
        forceSinglePass = false;

        visible = true;
        toneMapped = true;

        userData = {};

        version = 0;

        _alphaTest = 0;
    }

    public var alphaTest(get, set):Float;

    private function get_alphaTest():Float
    {
        return _alphaTest;
    }

    private function set_alphaTest(value:Float):Float
    {
        if ((_alphaTest > 0) != (value > 0))
        {
            version++;
        }
        _alphaTest = value;
        return value;
    }

    public function setValues(values:Dynamic):Void
    {
        if (values == null) return;

        var fields = Reflect.fields(values);
        for (key in fields)
        {
            var newValue = Reflect.field(values, key);

            if (newValue == null)
            {
                trace('Material: parameter "' + key + '" has value of null.');
                continue;
            }

            var currentValue = Reflect.field(this, key);

            if (currentValue == null)
            {
                trace('Material: "' + key + '" is not a property of ' + type);
                continue;
            }

            if (Std.isOfType(currentValue, Color))
            {
                cast(currentValue, Color).set(newValue);
            }
            else
            {
                Reflect.setField(this, key, newValue);
            }
        }
    }

    public function clone():Material
    {
        return new Material().copy(this);
    }

    public function copy(source:Material):Material
    {
        name = source.name;

        blending = source.blending;
        side = source.side;
        vertexColors = source.vertexColors;

        opacity = source.opacity;
        transparent = source.transparent;

        blendSrc = source.blendSrc;
        blendDst = source.blendDst;
        blendEquation = source.blendEquation;
        blendSrcAlpha = source.blendSrcAlpha;
        blendDstAlpha = source.blendDstAlpha;
        blendEquationAlpha = source.blendEquationAlpha;
        blendColor.copy(source.blendColor);
        blendAlpha = source.blendAlpha;

        depthFunc = source.depthFunc;
        depthTest = source.depthTest;
        depthWrite = source.depthWrite;

        stencilWriteMask = source.stencilWriteMask;
        stencilFunc = source.stencilFunc;
        stencilRef = source.stencilRef;
        stencilFuncMask = source.stencilFuncMask;
        stencilFail = source.stencilFail;
        stencilZFail = source.stencilZFail;
        stencilZPass = source.stencilZPass;
        stencilWrite = source.stencilWrite;

        if (source.clippingPlanes != null)
        {
            clippingPlanes = source.clippingPlanes.copy();
        }
        else
        {
            clippingPlanes = null;
        }

        clipIntersection = source.clipIntersection;
        clipShadows = source.clipShadows;

        shadowSide = source.shadowSide;

        colorWrite = source.colorWrite;

        precision = source.precision;

        polygonOffset = source.polygonOffset;
        polygonOffsetFactor = source.polygonOffsetFactor;
        polygonOffsetUnits = source.polygonOffsetUnits;

        dithering = source.dithering;

        alphaTest = source.alphaTest;
        alphaToCoverage = source.alphaToCoverage;
        premultipliedAlpha = source.premultipliedAlpha;
        forceSinglePass = source.forceSinglePass;

        visible = source.visible;

        toneMapped = source.toneMapped;

        userData = source.userData;

        return this;
    }

    public function dispose():Void
    {
        dispatchEvent({type: "dispose"});
    }

    public var needsUpdate(null, set):Bool;

    private function set_needsUpdate(value:Bool):Bool
    {
        if (value) version++;
        return value;
    }
}
