// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/EPO/Fill/Utils/Empty fill" {
Properties {
}
SubShader {
Tags {  }
Pass {
Tags {  }
Cull [_Cull]
ZWrite Off
ZTest [_ZTest]
ZClip On
Offset 0, 0
AlphaToMask Off
Blend One Zero, One Zero
BlendOp Add, Add
ColorMask 0
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
float _TextureIndex;
#if defined(TEXARRAY_CUTOUT)
Texture2DArray<float4> _CutoutTexture;
#else
Texture2D<float4> _CutoutTexture;
#endif
SamplerState sampler_CutoutTexture;
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
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && !defined(USE_CUTOUT)
struct Mtl_FragmentOut
{
    float4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment()
{
    Mtl_FragmentOut output;
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && !defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, u_xlat0.xy);
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif !defined(BACK_MASKING_RENDERING) && defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
    return output;

}

#elif defined(BACK_MASKING_RENDERING) && !defined(BACK_OBSTACLE_RENDERING) && defined(TEXARRAY_CUTOUT) && defined(USE_CUTOUT)
struct Mtl_FragmentIn
{
    float2 TEXCOORD0 : TEXCOORD0;
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
    u_xlat0.xy = mad(input.TEXCOORD0.xy, _CutoutTexture_ST.xy, _CutoutTexture_ST.zw);
    u_xlat0.z = _TextureIndex;
    u_xlat16_0 = _CutoutTexture.Sample(sampler_CutoutTexture, float3(u_xlat0.xy, round(u_xlat0.z)));
    u_xlat0.x = dot(((float4)(u_xlat16_0)), _CutoutMask);
    u_xlat0.x = u_xlat0.x + (-_CutoutThreshold);
    u_xlatb0 = u_xlat0.x<0.0;
    if(((int(u_xlatb0) * int(0xffffffffu)))!=0){discard;}
    output.SV_Target0 = float4(0.0, 0.0, 0.0, 0.0);
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
