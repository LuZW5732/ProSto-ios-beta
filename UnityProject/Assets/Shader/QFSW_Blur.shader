// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "QFSW/Blur" {
Properties {
 _Color ("Main Color", Color) = (1,1,1,1)
 _OverlayColor ("Overlay Color", Color) = (1,1,1,1)
 _MainTex ("Tint Color (RGB)", 2D) = "white" {}
 _Radius ("Radius", Range(0, 20)) = 1
 _StencilComp ("Stencil Comparison", Float) = 8
 _Stencil ("Stencil ID", Float) = 0
 _StencilOp ("Stencil Operation", Float) = 0
 _StencilWriteMask ("Stencil Write Mask", Float) = 255
 _StencilReadMask ("Stencil Read Mask", Float) = 255
 _ColorMask ("Color Mask", Float) = 15
}
SubShader {
Tags { "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
GrabPass { "_PortBlurBackground" }
Pass {
Tags {  }
Cull Off
ZWrite Off
ZTest [unity_GUIZTestMode]
ZClip On
Offset 0, 0
AlphaToMask Off
Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
BlendOp Add, Add
ColorMask [_ColorMask]
Stencil {
Ref [_Stencil]
ReadMask [_StencilReadMask]
WriteMask [_StencilWriteMask]
Comp [_StencilComp]
Pass [_StencilOp]
Fail Keep
ZFail Keep
}
HLSLPROGRAM
#pragma target 3.5
#pragma only_renderers d3d11 metal
#pragma vertex PortVertex
#pragma fragment PortFragment
#pragma multi_compile __ UNITY_UI_CLIP_RECT
#include "UnityCG.cginc"
float4 _ClipRect;
half4 _Color;
float4 _MainTex_ST;
half4 _OverlayColor;
float4 _PortBlurBackground_TexelSize;
float _Radius;
Texture2D<float4> _MainTex;
Texture2D<float4> _PortBlurBackground;
SamplerState sampler_MainTex;
SamplerState sampler_PortBlurBackground;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if !defined(UNITY_UI_CLIP_RECT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float4 TEXCOORD2 : TEXCOORD2;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    output.mtl_Position = u_xlat0;
    output.COLOR0 = input.COLOR0 * _Color;
    output.TEXCOORD0.xy = mad(input.TEXCOORD0.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.TEXCOORD1 = input.POSITION0;
    u_xlat1.xyz = u_xlat0.xwy * float3(0.5, 0.5, -0.5);
    output.TEXCOORD2.zw = u_xlat0.zw;
    output.TEXCOORD2.xy = u_xlat1.yy + u_xlat1.xz;
    return output;

}

#elif defined(UNITY_UI_CLIP_RECT)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float4 TEXCOORD2 : TEXCOORD2;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0 = input.POSITION0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    output.mtl_Position = u_xlat0;
    output.COLOR0 = input.COLOR0 * _Color;
    output.TEXCOORD0.xy = mad(input.TEXCOORD0.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.TEXCOORD1 = input.POSITION0;
    u_xlat1.xyz = u_xlat0.xwy * float3(0.5, 0.5, -0.5);
    output.TEXCOORD2.zw = u_xlat0.zw;
    output.TEXCOORD2.xy = u_xlat1.yy + u_xlat1.xz;
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
#if !defined(UNITY_UI_CLIP_RECT)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD2 : TEXCOORD2;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float4 u_xlat0;
    half4 u_xlat16_0;
    half3 u_xlat10_0;
    float3 u_xlat1;
    half3 u_xlat10_1;
    float4 u_xlat2;
    half3 u_xlat10_2;
    float3 u_xlat3;
    half3 u_xlat10_3;
    float4 u_xlat4;
    half3 u_xlat10_4;
    half3 u_xlat10_5;
    half3 u_xlat10_6;
    half3 u_xlat16_7;
    half3 u_xlat16_8;
    float2 u_xlat18;
    float2 u_xlat19;
    u_xlat0.z = 0.0;
    u_xlat0.xy = abs(_PortBlurBackground_TexelSize.xy) * ((float2)(_Radius));
    u_xlat1.xy = input.TEXCOORD2.xy / input.TEXCOORD2.ww;
    u_xlat2 = u_xlat0.xzzy + u_xlat1.xyxy;
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat2.xy).xyz));
    u_xlat10_2.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat2.zw).xyz));
    u_xlat4 = (-u_xlat0.xzxy) + u_xlat1.xyxy;
    u_xlat19.xy = (-u_xlat0.zy) + u_xlat1.xy;
    u_xlat10_5.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat19.xy).xyz));
    u_xlat10_6.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat4.xy).xyz));
    u_xlat10_4.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat4.zw).xyz));
    u_xlat3.xyz = ((float3)(u_xlat10_3.xyz)) + ((float3)(u_xlat10_6.xyz));
    u_xlat2.xyz = ((float3)(u_xlat10_2.xyz)) + u_xlat3.xyz;
    u_xlat2.xyz = ((float3)(u_xlat10_5.xyz)) + u_xlat2.xyz;
    u_xlat2.xyz = u_xlat2.xyz + u_xlat2.xyz;
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat1.xy).xyz));
    u_xlat2.xyz = mad(((float3)(u_xlat10_3.xyz)), float3(4.0, 4.0, 4.0), u_xlat2.xyz);
    u_xlat0.w = (-u_xlat0.y);
    u_xlat18.xy = u_xlat0.xw + u_xlat1.xy;
    u_xlat0.xy = mad(u_xlat0.xy, float2(-1.0, 1.0), u_xlat1.xy);
    u_xlat1.xy = mad(abs(_PortBlurBackground_TexelSize.xy), ((float2)(_Radius)), u_xlat1.xy);
    u_xlat10_1.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat1.xy).xyz));
    u_xlat1.xyz = ((float3)(u_xlat10_4.xyz)) + ((float3)(u_xlat10_1.xyz));
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat0.xy).xyz));
    u_xlat10_0.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat18.xy).xyz));
    u_xlat0.xyz = ((float3)(u_xlat10_0.xyz)) + u_xlat1.xyz;
    u_xlat0.xyz = ((float3)(u_xlat10_3.xyz)) + u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz + u_xlat2.xyz;
    u_xlat16_7.xyz = ((half3)(u_xlat0.xyz * float3(0.0625, 0.0625, 0.0625)));
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat0 = ((float4)(u_xlat16_0)) * ((float4)(input.COLOR0));
    u_xlat16_8.xyz = ((half3)(u_xlat0.xyz * ((float3)(u_xlat16_7.xyz))));
    u_xlat16_7.xyz = ((half3)(mad((-((float3)(u_xlat16_7.xyz))), u_xlat0.xyz, ((float3)(_OverlayColor.xyz)))));
    output.SV_Target0.w = half(u_xlat0.w);
    output.SV_Target0.xyz = mad(_OverlayColor.www, u_xlat16_7.xyz, u_xlat16_8.xyz);
    return output;

}

#elif defined(UNITY_UI_CLIP_RECT)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
    float4 TEXCOORD2 : TEXCOORD2;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float4 u_xlat0;
    half4 u_xlat16_0;
    half3 u_xlat10_0;
    bool2 u_xlatb0;
    float3 u_xlat1;
    half3 u_xlat10_1;
    bool2 u_xlatb1;
    float4 u_xlat2;
    half3 u_xlat10_2;
    float3 u_xlat3;
    half3 u_xlat10_3;
    float4 u_xlat4;
    half3 u_xlat10_4;
    half3 u_xlat10_5;
    half3 u_xlat10_6;
    half3 u_xlat16_7;
    half3 u_xlat16_8;
    float2 u_xlat18;
    float2 u_xlat19;
    u_xlat0.z = 0.0;
    u_xlat0.xy = abs(_PortBlurBackground_TexelSize.xy) * ((float2)(_Radius));
    u_xlat1.xy = input.TEXCOORD2.xy / input.TEXCOORD2.ww;
    u_xlat2 = u_xlat0.xzzy + u_xlat1.xyxy;
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat2.xy).xyz));
    u_xlat10_2.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat2.zw).xyz));
    u_xlat4 = (-u_xlat0.xzxy) + u_xlat1.xyxy;
    u_xlat19.xy = (-u_xlat0.zy) + u_xlat1.xy;
    u_xlat10_5.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat19.xy).xyz));
    u_xlat10_6.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat4.xy).xyz));
    u_xlat10_4.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat4.zw).xyz));
    u_xlat3.xyz = ((float3)(u_xlat10_3.xyz)) + ((float3)(u_xlat10_6.xyz));
    u_xlat2.xyz = ((float3)(u_xlat10_2.xyz)) + u_xlat3.xyz;
    u_xlat2.xyz = ((float3)(u_xlat10_5.xyz)) + u_xlat2.xyz;
    u_xlat2.xyz = u_xlat2.xyz + u_xlat2.xyz;
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat1.xy).xyz));
    u_xlat2.xyz = mad(((float3)(u_xlat10_3.xyz)), float3(4.0, 4.0, 4.0), u_xlat2.xyz);
    u_xlat0.w = (-u_xlat0.y);
    u_xlat18.xy = u_xlat0.xw + u_xlat1.xy;
    u_xlat0.xy = mad(u_xlat0.xy, float2(-1.0, 1.0), u_xlat1.xy);
    u_xlat1.xy = mad(abs(_PortBlurBackground_TexelSize.xy), ((float2)(_Radius)), u_xlat1.xy);
    u_xlat10_1.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat1.xy).xyz));
    u_xlat1.xyz = ((float3)(u_xlat10_4.xyz)) + ((float3)(u_xlat10_1.xyz));
    u_xlat10_3.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat0.xy).xyz));
    u_xlat10_0.xyz = ((half3)(_PortBlurBackground.Sample(sampler_PortBlurBackground, u_xlat18.xy).xyz));
    u_xlat0.xyz = ((float3)(u_xlat10_0.xyz)) + u_xlat1.xyz;
    u_xlat0.xyz = ((float3)(u_xlat10_3.xyz)) + u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz + u_xlat2.xyz;
    u_xlat16_7.xyz = ((half3)(u_xlat0.xyz * float3(0.0625, 0.0625, 0.0625)));
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat0 = ((float4)(u_xlat16_0)) * ((float4)(input.COLOR0));
    u_xlat16_8.xyz = ((half3)(u_xlat0.xyz * ((float3)(u_xlat16_7.xyz))));
    u_xlat16_7.xyz = ((half3)(mad((-((float3)(u_xlat16_7.xyz))), u_xlat0.xyz, ((float3)(_OverlayColor.xyz)))));
    output.SV_Target0.xyz = mad(_OverlayColor.www, u_xlat16_7.xyz, u_xlat16_8.xyz);
    u_xlatb0.xy = (input.TEXCOORD1.xy>=_ClipRect.xy);
    u_xlat0.xy = ((((bool2)(u_xlatb0.xy))) ? (float2(1.0, 1.0)) : (float2(0.0, 0.0)));
    u_xlatb1.xy = (_ClipRect.zw>=input.TEXCOORD1.xy);
    u_xlat1.xy = ((((bool2)(u_xlatb1.xy))) ? (float2(1.0, 1.0)) : (float2(0.0, 0.0)));
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat0.x = u_xlat0.x * u_xlat0.w;
    output.SV_Target0.w = half(u_xlat0.x);
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
