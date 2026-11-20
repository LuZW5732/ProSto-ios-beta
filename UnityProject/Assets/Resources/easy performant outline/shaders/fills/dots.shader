// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/EPO/Fill/Basic/Dots" {
Properties {
 _PublicColor ("Color", Vector) = (1,0,0,1)
 _PublicHorizontalSize ("Horizontal size", Float) = 1
 _PublicVerticalSize ("Vertical size", Float) = 1
 _PublicHorizontalGapSize ("Horizontal gap size", Range(-1, 1)) = 0.5
 _PublicVerticalGapSize ("Vertical gap size", Range(-1, 1)) = 0.5
 _PublicHorizontalSoftness ("Horizontal softness", Range(0, 1)) = 0.2
 _PublicVerticalSoftness ("Vertical softness", Range(0, 1)) = 0.2
 _PublicHorizontalSpeed ("Horizontal speed", Float) = 1
 _PublicVerticalSpeed ("Vertical speed", Float) = 1
 _PublicAngle ("Angle", Range(0, 360)) = 0
 _PublicSecondaryAlpha ("Secondary alpha", Range(0, 1)) = 0.2
}
SubShader {
Tags {  }
Pass {
Tags {  }
Cull [_Cull]
ZWrite Off
ZTest Always
ZClip On
Offset 0, 0
AlphaToMask Off
Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
BlendOp Add, Add
ColorMask RGBA
Stencil {
Ref [_FillRef]
ReadMask 255
WriteMask 255
Comp Equal
Pass Zero
Fail Keep
ZFail Keep
}
HLSLPROGRAM
#pragma target 3.5
#pragma only_renderers d3d11 metal
#pragma vertex PortVertex
#pragma fragment PortFragment
#pragma multi_compile __ BACK_MASKING_RENDERING BACK_OBSTACLE_RENDERING
#pragma multi_compile __ TEXARRAY_CUTOUT
#pragma multi_compile __ USE_CUTOUT
#include "UnityCG.cginc"
float4 _CutoutMask;
float4 _CutoutTexture_ST;
float _CutoutThreshold;
float _PublicAngle;
float4 _PublicColor;
float _PublicHorizontalGapSize;
float _PublicHorizontalSize;
float _PublicHorizontalSoftness;
float _PublicHorizontalSpeed;
float _PublicSecondaryAlpha;
float _PublicVerticalGapSize;
float _PublicVerticalSize;
float _PublicVerticalSoftness;
float _PublicVerticalSpeed;
float _TextureIndex;
#if defined(TEXARRAY_CUTOUT)
Texture2DArray<float4> _CutoutTexture;
#else
Texture2D<float4> _CutoutTexture;
#endif
Texture2D<float4> _InfoBuffer;
SamplerState sampler_CutoutTexture;
SamplerState sampler_InfoBuffer;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float3 NORMAL0 : NORMAL0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float3 TEXCOORD2 : TEXCOORD2;
    float3 TEXCOORD3 : TEXCOORD3;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat0.xyz);
    u_xlat0 = u_xlat1.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat1.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat1.zzzz, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat1.wwww, u_xlat0);
    output.mtl_Position = u_xlat0;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.y = u_xlat0.y * _ProjectionParams.x;
    u_xlat1.xzw = u_xlat0.xwy * float3(0.5, 0.5, 0.5);
    output.TEXCOORD1.zw = u_xlat0.zw;
    output.TEXCOORD1.xy = u_xlat1.zz + u_xlat1.xw;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    output.TEXCOORD3.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
#if !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.100000001;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.5;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.100000001;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.5;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.100000001;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float2 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.5;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.100000001;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_0;
    bool u_xlatb0;
    float3 u_xlat1;
    float2 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    half u_xlat10_8;
    bool u_xlatb8;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_8 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat8.x = (-float(u_xlat10_8)) + 0.5;
    u_xlatb8 = u_xlat8.x<0.0;
    if(((int(u_xlatb8) * int(0xffffffffu)))!=0){discard;}
    u_xlat8.x = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin((-u_xlat8.x));
    u_xlat2.x = sin(u_xlat8.x);
    u_xlat3 = cos(u_xlat8.x);
    u_xlat1.y = u_xlat3;
    u_xlat1.z = u_xlat2.x;
    u_xlat2.y = dot(u_xlat1.zy, u_xlat0.xy);
    u_xlat2.x = dot(u_xlat1.yx, u_xlat0.xy);
    u_xlat0.xy = max(abs(float2(_PublicHorizontalSize, _PublicVerticalSize)), float2(0.00100000005, 0.00100000005));
    u_xlat0.xy = u_xlat2.xy / u_xlat0.xy;
    u_xlat0.xy = mad(_Time.yy, float2(_PublicHorizontalSpeed, _PublicVerticalSpeed), u_xlat0.xy);
    u_xlat0.xy = frac(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(-0.5, -0.5);
    u_xlat8.xy = max(float2(_PublicHorizontalSoftness, _PublicVerticalSoftness), float2(0.00100000005, 0.00100000005));
    u_xlat1.xy = float2(_PublicHorizontalGapSize, _PublicVerticalGapSize);
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.xy = (-u_xlat1.xy) + float2(1.0, 1.0);
    u_xlat8.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat1.xy = (-u_xlat8.xy) + u_xlat1.xy;
    u_xlat0.xy = mad(abs(u_xlat0.xy), float2(2.0, 2.0), (-u_xlat8.xy));
    u_xlat8.xy = float2(1.0, 1.0) / u_xlat1.xy;
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat8.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), float2(3.0, 3.0));
    u_xlat0.xy = u_xlat0.xy * u_xlat0.xy;
    u_xlat0.xy = mad((-u_xlat8.xy), u_xlat0.xy, float2(1.0, 1.0));
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat4 = (-_PublicSecondaryAlpha) + 1.0;
    u_xlat0.x = mad(u_xlat0.x, u_xlat4, _PublicSecondaryAlpha);
    output.SV_Target0.w = u_xlat0.x * _PublicColor.w;
    output.SV_Target0.xyz = _PublicColor.xyz;
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
ENDHLSL
}
}
Fallback Off
}
