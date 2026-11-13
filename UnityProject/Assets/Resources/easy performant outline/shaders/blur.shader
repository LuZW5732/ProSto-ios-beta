// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/Blur" {
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
#pragma multi_compile ANISOTROPIC_BLUR BOX_BLUR GAUSSIAN13X13 GAUSSIAN5X5 GAUSSIAN9X9
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

#if defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
#if defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_1)));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_1)));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_3));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_3));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat8.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat8.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat2.xy = mad(u_xlat8.xy, float2(-2.0, -2.0), u_xlat0.xy);
    u_xlat8.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_2));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat8.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat8.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat2.xy = mad(u_xlat8.xy, float2(-2.0, -2.0), u_xlat0.xy);
    u_xlat8.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_2));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(4.0, 4.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(4.0, 4.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat8.xyxy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(6.0, 6.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat8.xyxy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(6.0, 6.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_1)));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_1)));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_3));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1.xy = mad(u_xlat0.xy, float2(-2.0, -2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_3));
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_2));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat8.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat8.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat2.xy = mad(u_xlat8.xy, float2(-2.0, -2.0), u_xlat0.xy);
    u_xlat8.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_2));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat8.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat8.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat2.xy = mad(u_xlat8.xy, float2(-2.0, -2.0), u_xlat0.xy);
    u_xlat8.xy = mad(u_xlat8.xy, float2(2.0, 2.0), u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat0.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_2));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(4.0, 4.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(4.0, 4.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat8.xyxy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(6.0, 6.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && !defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float2 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat8;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat8.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat1 = mad(u_xlat0.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat8.xyxy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat1.zw);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat8.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat3.xy = mad((-_Shift.xxxy.zw), abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat8.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_3));
    u_xlat3.xy = mad(_Shift.xxxy.zw, abs(_MainTex_TexelSize.xy), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat1);
    u_xlat3.xy = mad(u_xlat0.xy, float2(2.0, 2.0), u_xlat8.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat1);
    u_xlat2 = mad(u_xlat0.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat8.xyxy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(6.0, 6.0), u_xlat8.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat1);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_2)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_2)));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_4)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_2)));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_4)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_2));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_4));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_2));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_4));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float2 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat1.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_4));
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float2 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat1.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_4));
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat12.xy = mad(u_xlat7.xy, float2(4.0, 4.0), u_xlat12.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1 = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / ((float3)(u_xlat1));
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat12.xy = mad(u_xlat7.xy, float2(4.0, 4.0), u_xlat12.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1 = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / ((float3)(u_xlat1));
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat12.xyxy);
    u_xlat0.xy = mad(u_xlat7.xy, float2(6.0, 6.0), u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && !defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat12.xyxy);
    u_xlat0.xy = mad(u_xlat7.xy, float2(6.0, 6.0), u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_2)));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_4)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(2.0, 2.0, 2.0, 2.0), ((float4)(u_xlat16_2)));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_4)), float4(3.0, 3.0, 3.0, 3.0), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(2.0, 2.0, 2.0, 2.0), u_xlat1);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.111111112;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_2));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_4));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float2 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat6.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(u_xlat16_2));
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat1 = u_xlat1 + ((float4)(u_xlat16_4));
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = ((float4)(u_xlat16_0)) + u_xlat1;
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_3));
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.200000003;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float2 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat1.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_4));
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float2 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    half4 u_xlat16_3;
    half4 u_xlat16_4;
    float2 u_xlat6;
    float2 u_xlat10;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat10.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat10.xy).y);
    u_xlat6.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat6.xy);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = ((float4)(u_xlat16_2)) * float4(0.606530666, 0.606530666, 0.606530666, 0.606530666);
    u_xlat6.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat10.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat0.xy = mad(u_xlat6.xy, float2(-2.0, -2.0), u_xlat10.xy);
    u_xlat1.xy = mad(u_xlat6.xy, float2(2.0, 2.0), u_xlat10.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat10.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat1.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat2);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat0 = u_xlat0 + ((float4)(u_xlat16_4));
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.402619958;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat12.xy = mad(u_xlat7.xy, float2(4.0, 4.0), u_xlat12.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1 = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / ((float3)(u_xlat1));
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && !defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.324652463, 0.324652463, 0.324652463, 0.324652463);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.882496893, 0.882496893, 0.882496893, 0.882496893), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat12.xy = mad(u_xlat7.xy, float2(4.0, 4.0), u_xlat12.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_3)), float4(0.324652463, 0.324652463, 0.324652463, 0.324652463), u_xlat0);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_1)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat0);
    u_xlat1 = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / ((float3)(u_xlat1));
    output.SV_Target0.w = u_xlat0.w * 0.204163685;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && !defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat12.xyxy);
    u_xlat0.xy = mad(u_xlat7.xy, float2(6.0, 6.0), u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
    return output;

}

#elif !defined(ANISOTROPIC_BLUR) && !defined(BOX_BLUR) && defined(GAUSSIAN13X13) && !defined(GAUSSIAN5X5) && !defined(GAUSSIAN9X9) && defined(INFO_BUFFER_STAGE) && defined(INSTANCING_ON) && defined(USE_INFO_BUFFER)
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
    half4 u_xlat16_0;
    float4 u_xlat1;
    half4 u_xlat16_1;
    half u_xlat10_1;
    float4 u_xlat2;
    half4 u_xlat16_2;
    float4 u_xlat3;
    half4 u_xlat16_3;
    float2 u_xlat4;
    half4 u_xlat16_4;
    half4 u_xlat16_5;
    float2 u_xlat7;
    float2 u_xlat12;
    u_xlat0.xy = _Shift.xxxy.zw * abs(_MainTex_TexelSize.xy);
    u_xlat12.xy = input.TEXCOORD1.xy / input.TEXCOORD1.ww;
    u_xlat10_1 = half(_InfoBuffer.Sample(sampler_InfoBuffer, u_xlat12.xy).y);
    u_xlat7.xy = u_xlat0.xy * ((float2)(u_xlat10_1));
    u_xlat2 = mad(u_xlat7.xyxy, float4(-6.0, -6.0, -5.0, -5.0), u_xlat12.xyxy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat2.zw);
    u_xlat16_2 = _MainTex.Sample(sampler_MainTex, u_xlat2.xy);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat3 = ((float4)(u_xlat16_3)) * float4(0.249352247, 0.249352247, 0.249352247, 0.249352247);
    u_xlat16_2.xyz = u_xlat16_2.www * u_xlat16_2.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_2)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat3);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-4.0, -4.0, -3.0, -3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(-2.0, -2.0, 3.0, 3.0), u_xlat12.xyxy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat4.xy = mad((-u_xlat0.xy), ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat0.xy = mad(u_xlat0.xy, ((float2)(u_xlat10_1)), u_xlat12.xy);
    u_xlat16_5 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat4.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat12.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = u_xlat2 + ((float4)(u_xlat16_4));
    u_xlat16_5.xyz = u_xlat16_5.www * u_xlat16_5.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_5)), float4(0.945959449, 0.945959449, 0.945959449, 0.945959449), u_xlat2);
    u_xlat0.xy = mad(u_xlat7.xy, float2(2.0, 2.0), u_xlat12.xy);
    u_xlat16_4 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_4.xyz = u_xlat16_4.www * u_xlat16_4.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_4)), float4(0.800737381, 0.800737381, 0.800737381, 0.800737381), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat2 = mad(((float4)(u_xlat16_3)), float4(0.606530666, 0.606530666, 0.606530666, 0.606530666), u_xlat2);
    u_xlat3 = mad(u_xlat7.xyxy, float4(4.0, 4.0, 5.0, 5.0), u_xlat12.xyxy);
    u_xlat0.xy = mad(u_xlat7.xy, float2(6.0, 6.0), u_xlat12.xy);
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, u_xlat0.xy);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, u_xlat3.xy);
    u_xlat16_3 = _MainTex.Sample(sampler_MainTex, u_xlat3.zw);
    u_xlat16_1.xyz = u_xlat16_1.www * u_xlat16_1.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_1)), float4(0.411112279, 0.411112279, 0.411112279, 0.411112279), u_xlat2);
    u_xlat16_3.xyz = u_xlat16_3.www * u_xlat16_3.xyz;
    u_xlat1 = mad(((float4)(u_xlat16_3)), float4(0.249352247, 0.249352247, 0.249352247, 0.249352247), u_xlat1);
    u_xlat16_0.xyz = u_xlat16_0.www * u_xlat16_0.xyz;
    u_xlat0 = mad(((float4)(u_xlat16_0)), float4(0.135335281, 0.135335281, 0.135335281, 0.135335281), u_xlat1);
    u_xlat1.x = max(u_xlat0.w, 9.99999975e-06);
    output.SV_Target0.xyz = u_xlat0.xyz / u_xlat1.xxx;
    output.SV_Target0.w = u_xlat0.w * 0.137022808;
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
