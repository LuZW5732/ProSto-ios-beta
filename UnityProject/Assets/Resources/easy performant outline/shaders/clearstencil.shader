// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Hidden/ClearStencil" {
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
ColorMask 0
Stencil {
Ref 0
ReadMask 255
WriteMask 255
Comp Always
Pass Zero
Fail Keep
ZFail Keep
}
HLSLPROGRAM
#pragma target 3.5
#pragma only_renderers d3d11 metal
#pragma vertex PortVertex
#pragma fragment PortFragment
#pragma multi_compile_instancing
#include "UnityCG.cginc"
float _EffectSize;

#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if !defined(INSTANCING_ON)
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

#elif defined(INSTANCING_ON)
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
#if !defined(INSTANCING_ON)
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

#elif defined(INSTANCING_ON)
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

#else
#error No recovered Metal variant matches these keywords
#endif
ENDHLSL
}
}
Fallback Off
}
