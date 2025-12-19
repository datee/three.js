package three;

/**
 * Three.js constants ported to Haxe
 */

// Side
enum abstract Side(Int) to Int
{
    var FrontSide = 0;
    var BackSide = 1;
    var DoubleSide = 2;
}

// Blending
enum abstract Blending(Int) to Int
{
    var NoBlending = 0;
    var NormalBlending = 1;
    var AdditiveBlending = 2;
    var SubtractiveBlending = 3;
    var MultiplyBlending = 4;
    var CustomBlending = 5;
}

// Blending equations
enum abstract BlendingEquation(Int) to Int
{
    var AddEquation = 100;
    var SubtractEquation = 101;
    var ReverseSubtractEquation = 102;
    var MinEquation = 103;
    var MaxEquation = 104;
}

// Blending factors
enum abstract BlendingFactor(Int) to Int
{
    var ZeroFactor = 200;
    var OneFactor = 201;
    var SrcColorFactor = 202;
    var OneMinusSrcColorFactor = 203;
    var SrcAlphaFactor = 204;
    var OneMinusSrcAlphaFactor = 205;
    var DstAlphaFactor = 206;
    var OneMinusDstAlphaFactor = 207;
    var DstColorFactor = 208;
    var OneMinusDstColorFactor = 209;
    var SrcAlphaSaturateFactor = 210;
}

// Depth functions
enum abstract DepthFunc(Int) to Int
{
    var NeverDepth = 0;
    var AlwaysDepth = 1;
    var LessDepth = 2;
    var LessEqualDepth = 3;
    var EqualDepth = 4;
    var GreaterEqualDepth = 5;
    var GreaterDepth = 6;
    var NotEqualDepth = 7;
}

// Texture mapping
enum abstract TextureMapping(Int) to Int
{
    var UVMapping = 300;
    var CubeReflectionMapping = 301;
    var CubeRefractionMapping = 302;
    var EquirectangularReflectionMapping = 303;
    var EquirectangularRefractionMapping = 304;
    var CubeUVReflectionMapping = 306;
}

// Texture wrapping
enum abstract TextureWrapping(Int) to Int
{
    var RepeatWrapping = 1000;
    var ClampToEdgeWrapping = 1001;
    var MirroredRepeatWrapping = 1002;
}

// Texture filters
enum abstract TextureFilter(Int) to Int
{
    var NearestFilter = 1003;
    var NearestMipmapNearestFilter = 1004;
    var NearestMipmapLinearFilter = 1005;
    var LinearFilter = 1006;
    var LinearMipmapNearestFilter = 1007;
    var LinearMipmapLinearFilter = 1008;
}

// Texture data types
enum abstract TextureDataType(Int) to Int
{
    var UnsignedByteType = 1009;
    var ByteType = 1010;
    var ShortType = 1011;
    var UnsignedShortType = 1012;
    var IntType = 1013;
    var UnsignedIntType = 1014;
    var FloatType = 1015;
    var HalfFloatType = 1016;
}

// Texture formats
enum abstract TextureFormat(Int) to Int
{
    var AlphaFormat = 1021;
    var RGBFormat = 1022;
    var RGBAFormat = 1023;
    var DepthFormat = 1026;
    var DepthStencilFormat = 1027;
    var RedFormat = 1028;
    var RGFormat = 1030;
}

// Combine operations
enum abstract CombineOperation(Int) to Int
{
    var MultiplyOperation = 0;
    var MixOperation = 1;
    var AddOperation = 2;
}

// Tone mapping
enum abstract ToneMapping(Int) to Int
{
    var NoToneMapping = 0;
    var LinearToneMapping = 1;
    var ReinhardToneMapping = 2;
    var CineonToneMapping = 3;
    var ACESFilmicToneMapping = 4;
    var CustomToneMapping = 5;
    var AgXToneMapping = 6;
    var NeutralToneMapping = 7;
}

// Draw modes
enum abstract DrawMode(Int) to Int
{
    var TrianglesDrawMode = 0;
    var TriangleStripDrawMode = 1;
    var TriangleFanDrawMode = 2;
}

// Color spaces
enum abstract ColorSpace(String) to String
{
    var NoColorSpace = "";
    var SRGBColorSpace = "srgb";
    var LinearSRGBColorSpace = "srgb-linear";
}

// GL usage
enum abstract BufferUsage(Int) to Int
{
    var StaticDrawUsage = 35044;
    var DynamicDrawUsage = 35048;
    var StreamDrawUsage = 35040;
}

// Cull face
enum abstract CullFace(Int) to Int
{
    var CullFaceNone = 0;
    var CullFaceBack = 1;
    var CullFaceFront = 2;
    var CullFaceFrontBack = 3;
}

// Shadow map types
enum abstract ShadowMapType(Int) to Int
{
    var BasicShadowMap = 0;
    var PCFShadowMap = 1;
    var PCFSoftShadowMap = 2;
    var VSMShadowMap = 3;
}

// Stencil operations
enum abstract StencilOp(Int) to Int
{
    var ZeroStencilOp = 0;
    var KeepStencilOp = 7680;
    var ReplaceStencilOp = 7681;
    var IncrementStencilOp = 7682;
    var DecrementStencilOp = 7683;
    var IncrementWrapStencilOp = 34055;
    var DecrementWrapStencilOp = 34056;
    var InvertStencilOp = 5386;
}

// Stencil functions
enum abstract StencilFunc(Int) to Int
{
    var NeverStencilFunc = 512;
    var LessStencilFunc = 513;
    var EqualStencilFunc = 514;
    var LessEqualStencilFunc = 515;
    var GreaterStencilFunc = 516;
    var NotEqualStencilFunc = 517;
    var GreaterEqualStencilFunc = 518;
    var AlwaysStencilFunc = 519;
}

// WebGL coordinate system
enum abstract CoordinateSystem(Int) to Int
{
    var WebGLCoordinateSystem = 2000;
    var WebGPUCoordinateSystem = 2001;
}
