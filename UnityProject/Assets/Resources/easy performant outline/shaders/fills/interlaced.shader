// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/EPO/Fill/Basic/Interlaced" {
Properties {
 _PublicColor ("Color", Vector) = (1,0,0,1)
 _PublicGapColor ("Gap color", Vector) = (1,0,0,0.2)
 _PublicSize ("Size", Float) = 1
 _PublicGapSize ("Gap size", Range(-1, 1)) = 0.2
 _PublicSoftness ("Softness", Range(0, 3)) = 0.75
 _PublicSpeed ("Speed", Float) = 1
 _PublicAngle ("Angle", Range(0, 360)) = 0
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
float4 _PublicGapColor;
float _PublicGapSize;
float _PublicSize;
float _PublicSoftness;
float _PublicSpeed;
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.100000001;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.5;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.100000001;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.5;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.100000001;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.5;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
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
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.100000001;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat3;
    float u_xlat6;
    half u_xlat10_6;
    bool u_xlatb6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_6 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat0.xy).z);
    u_xlat0.xy = u_xlat0.xy * _ScreenParams.xy;
    u_xlat0.xy = u_xlat0.xy * float2(0.03125, 0.03125);
    u_xlat6 = (-float(u_xlat10_6)) + 0.5;
    u_xlatb6 = u_xlat6<0.0;
    if(((int(u_xlatb6) * int(0xffffffffu)))!=0){discard;}
    u_xlat6 = _PublicAngle * 0.0174532924;
    u_xlat1.x = sin(u_xlat6);
    u_xlat2 = cos(u_xlat6);
    u_xlat1.y = u_xlat2;
    u_xlat0.x = dot(u_xlat1.xy, u_xlat0.xy);
    u_xlat3 = max(abs(_PublicSize), 0.00100000005);
    u_xlat0.x = u_xlat0.x / u_xlat3;
    u_xlat0.x = mad(_Time.y, _PublicSpeed, u_xlat0.x);
    u_xlat0.x = frac(u_xlat0.x);
    u_xlat0.x = u_xlat0.x + -0.5;
    u_xlat3 = _PublicSoftness * 0.25;
    u_xlat3 = max(u_xlat3, 0.00100000005);
    u_xlat6 = _PublicGapSize;
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = (-u_xlat6) + 1.0;
    u_xlat3 = (-u_xlat3) + u_xlat6;
    u_xlat6 = (-u_xlat3) + u_xlat6;
    u_xlat0.x = mad(abs(u_xlat0.x), 2.0, (-u_xlat3));
    u_xlat3 = float(1.0) / u_xlat6;
    u_xlat0.x = u_xlat3 * u_xlat0.x;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat3 = mad(u_xlat0.x, -2.0, 3.0);
    u_xlat0.x = u_xlat0.x * u_xlat0.x;
    u_xlat0.x = mad((-u_xlat3), u_xlat0.x, 1.0);
    u_xlat1 = _PublicColor + (-_PublicGapColor);
    output.SV_Target0 = mad(u_xlat0.xxxx, u_xlat1, _PublicGapColor);
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
