// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/Dilate" {
Properties {
}
SubShader {
Tags {  }
Pass {
Tags {  }
Cull Off
ZWrite Off
ZTest Always
ZClip On
Offset 0, 0
AlphaToMask Off
Blend One Zero, One Zero
BlendOp Add, Add
ColorMask RGBA
Stencil {
Ref [_Ref]
ReadMask 255
WriteMask 255
Comp [_Comparison]
Pass IncrWrap
Fail Keep
ZFail Keep
}
HLSLPROGRAM
#pragma target 3.5
#pragma only_renderers d3d11 metal
#pragma vertex PortVertex
#pragma fragment PortFragment
#pragma multi_compile_instancing
#pragma multi_compile BASE_QALITY_DILATE HIGH_QUALITY_DILATE ULTRA_QUALITY_DILATE
#pragma multi_compile __ INFO_BUFFER_STAGE
#pragma multi_compile __ USE_INFO_BUFFER
#include "UnityCG.cginc"
float _EffectSize;
float4 _MainTex_TexelSize;
float2 _Shift;
Texture2D<float4> _InfoBuffer;
Texture2D<float4> _MainTex;
SamplerState sampler_InfoBuffer;
SamplerState sampler_MainTex;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    int2 u_xlati6;
    float u_xlat9;
    u_xlat0.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat0.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat0.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat9 = rsqrt(u_xlat9);
    u_xlat0.xyz = ((float3)(u_xlat9)) * u_xlat0.xyz;
    u_xlat1.xy = u_xlat0.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat0.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat0.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat0.xyz;
    u_xlati0.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati6.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati0.xy = (-u_xlati0.xy) + u_xlati6.xy;
    u_xlat0.xy = ((float2)(u_xlati0.xy));
    u_xlat0.xy = u_xlat0.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3 = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3 * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    int u_xlati0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    int2 u_xlati3;
    u_xlati0 = int(0) + 0;
    u_xlati0 = u_xlati0 << 0x3;
    u_xlat1.x = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 0).xyz);
    u_xlat1.y = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 1).xyz);
    u_xlat1.z = dot(input.NORMAL0.xyz, PORT_COLUMN(unity_WorldToObject, 2).xyz);
    u_xlat3.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat3.x = rsqrt(u_xlat3.x);
    u_xlat3.xyz = u_xlat3.xxx * u_xlat1.xyz;
    u_xlat1.xy = u_xlat3.yy * PORT_COLUMN(UNITY_MATRIX_V, 1).xy;
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 0).xy, u_xlat3.xx, u_xlat1.xy);
    u_xlat1.xy = mad(PORT_COLUMN(UNITY_MATRIX_V, 2).xy, u_xlat3.zz, u_xlat1.xy);
    output.TEXCOORD3.xyz = u_xlat3.xyz;
    u_xlati3.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati3.xy = (-u_xlati3.xy) + u_xlati1.xy;
    u_xlat3.xy = ((float2)(u_xlati3.xy));
    u_xlat3.xy = u_xlat3.xy * ((float2)(_EffectSize));
    u_xlat1 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    output.TEXCOORD2.xyz = mad(PORT_COLUMN(unity_ObjectToWorld, 3).xyz, input.POSITION0.www, u_xlat1.xyz);
    u_xlat1 = u_xlat2.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat2.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat2.zzzz, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat2.wwww, u_xlat1);
    u_xlat0.xy = u_xlat3.xy * u_xlat1.ww;
    u_xlat0.xy = u_xlat0.xy / _ScreenParams.xy;
    u_xlat1.xy = u_xlat0.xy + u_xlat1.xy;
    output.mtl_Position = u_xlat1;
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    u_xlat0.xz = u_xlat1.xw * float2(0.5, 0.5);
    u_xlat3.x = u_xlat1.y * _ProjectionParams.x;
    u_xlat0.w = u_xlat3.x * 0.5;
    output.TEXCOORD1.xy = u_xlat0.zz + u_xlat0.xw;
    output.TEXCOORD1.zw = u_xlat1.zw;
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
#if defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    bool u_xlatb1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb0 = u_xlat3.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb0)) ? u_xlat1 : u_xlat3;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat12.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb5 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb5)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat4.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat4 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat2.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat2 : u_xlat0;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    bool u_xlatb1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb0 = u_xlat3.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb0)) ? u_xlat1 : u_xlat3;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat12.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb5 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb5)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat4.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat4 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat2.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat2 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.5, 1.5), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.5, 1.5), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.75, 1.75), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.75, 1.75), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    bool u_xlatb1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb0 = u_xlat3.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb0)) ? u_xlat1 : u_xlat3;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat12.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb5 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb5)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat4.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat4 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat2.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat2 : u_xlat0;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    bool u_xlatb1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb0 = u_xlat3.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb0)) ? u_xlat1 : u_xlat3;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat12.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb5 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb5)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat4.w;
    u_xlat0 = (bool(u_xlatb1)) ? u_xlat4 : u_xlat0;
    u_xlatb1 = u_xlat0.w<u_xlat2.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat2 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.5, 1.5), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.5, 1.5), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.75, 1.75), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && !defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    bool u_xlatb4;
    bool u_xlatb5;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat12.xyxy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat1.zw)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb4 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat3;
    u_xlatb4 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat1 : u_xlat2;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat12.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb5 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat4 : u_xlat1;
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat12.xy);
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2 = mad(u_xlat0.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat12.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlatb4 = u_xlat1.w<u_xlat3.w;
    u_xlat1 = (bool(u_xlatb4)) ? u_xlat3 : u_xlat1;
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlat2.xy = mad(u_xlat0.xy, float2(1.75, 1.75), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlatb3 = u_xlat1.w<u_xlat2.w;
    u_xlat1 = (bool(u_xlatb3)) ? u_xlat2 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    half u_xlat10_1;
    bool u_xlatb1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat7;
    bool u_xlatb7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).x);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat7.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat7.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb7 = u_xlat4.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb7)) ? u_xlat2 : u_xlat4;
    u_xlat7.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlatb5 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat1 : u_xlat2;
    u_xlatb2 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb2)) ? u_xlat4 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    half u_xlat10_1;
    bool u_xlatb1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat7;
    bool u_xlatb7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).x);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat7.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat7.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb7 = u_xlat4.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb7)) ? u_xlat2 : u_xlat4;
    u_xlat7.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlatb5 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat1 : u_xlat2;
    u_xlatb2 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb2)) ? u_xlat4 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.5, 1.5), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.5, 1.5), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat14.xyxy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb22 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat5 : u_xlat2;
    u_xlatb22 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat2;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.75, 1.75), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat14.xyxy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb22 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat5 : u_xlat2;
    u_xlatb22 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat2;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.75, 1.75), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    half u_xlat10_1;
    bool u_xlatb1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat7;
    bool u_xlatb7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).x);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat7.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat7.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb7 = u_xlat4.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb7)) ? u_xlat2 : u_xlat4;
    u_xlat7.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlatb5 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat1 : u_xlat2;
    u_xlatb2 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb2)) ? u_xlat4 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    return output;

}

#elif defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    float4 u_xlat1;
    half u_xlat10_1;
    bool u_xlatb1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    float4 u_xlat4;
    bool u_xlatb5;
    float2 u_xlat7;
    bool u_xlatb7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).x);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat7.xy, float2(-2.0, -2.0), u_xlat12.xy);
    u_xlat7.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat12.xy)));
    u_xlatb7 = u_xlat4.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb7)) ? u_xlat2 : u_xlat4;
    u_xlat7.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat7.xy)));
    u_xlatb5 = u_xlat2.w<u_xlat1.w;
    u_xlat1 = (bool(u_xlatb5)) ? u_xlat1 : u_xlat2;
    u_xlatb2 = u_xlat1.w<u_xlat4.w;
    u_xlat1 = (bool(u_xlatb2)) ? u_xlat4 : u_xlat1;
    u_xlatb2 = u_xlat1.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb2)) ? u_xlat0 : u_xlat1;
    u_xlatb1 = u_xlat0.w<u_xlat3.w;
    output.SV_Target0 = (bool(u_xlatb1)) ? u_xlat3 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.5, 1.5), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.5, -1.5), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.5, -0.5, 0.5, 0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.5, 1.5), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat14.xyxy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb22 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat5 : u_xlat2;
    u_xlatb22 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat2;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.75, 1.75), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
    return output;

}

#elif !defined(BASE_QALITY_DILATE) && !defined(HIGH_QUALITY_DILATE) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(ULTRA_QUALITY_DILATE) && defined(USE_INFO_BUFFER)
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
    float4 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    half u_xlat10_1;
    float4 u_xlat2;
    bool u_xlatb2;
    float4 u_xlat3;
    bool u_xlatb3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float2 u_xlat8;
    float2 u_xlat14;
    bool u_xlatb22;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat14.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat14.xy).x);
    u_xlat8.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat8.xyxy, float4(-2.0, -2.0, -1.75, -1.75), u_xlat14.xyxy);
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.xy)));
    u_xlat2 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat2.zw)));
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlatb22 = u_xlat4.w<u_xlat3.w;
    u_xlat3 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat4;
    u_xlatb22 = u_xlat3.w<u_xlat2.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat2 : u_xlat3;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-1.5, -1.5, -1.25, -1.25), u_xlat14.xyxy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb22 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat5 : u_xlat2;
    u_xlatb22 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb22)) ? u_xlat3 : u_xlat2;
    u_xlat3.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat14.xy);
    u_xlat5 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.75, -0.75, -0.5, -0.5), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(-0.25, -0.25, 0.25, 0.25), u_xlat14.xyxy);
    u_xlat6 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat6.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat6 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(0.5, 0.5, 0.75, 0.75), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat5.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat5 : u_xlat2;
    u_xlat3 = mad(u_xlat8.xyxy, float4(1.25, 1.25, 1.5, 1.5), u_xlat14.xyxy);
    u_xlat4 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.xy)));
    u_xlat3 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat3.zw)));
    u_xlatb0 = u_xlat2.w<u_xlat4.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat4 : u_xlat2;
    u_xlatb0 = u_xlat2.w<u_xlat3.w;
    u_xlat2 = (bool(u_xlatb0)) ? u_xlat3 : u_xlat2;
    u_xlat0.xy = mad(u_xlat8.xy, float2(1.75, 1.75), u_xlat14.xy);
    u_xlat14.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat14.xy);
    u_xlat1 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat14.xy)));
    u_xlat0 = ((float4)(_MainTex.Sample(sampler_MainTex, u_xlat0.xy)));
    u_xlatb3 = u_xlat2.w<u_xlat0.w;
    u_xlat0 = (bool(u_xlatb3)) ? u_xlat0 : u_xlat2;
    u_xlatb2 = u_xlat0.w<u_xlat1.w;
    output.SV_Target0 = (bool(u_xlatb2)) ? u_xlat1 : u_xlat0;
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
