// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Sprites/SolidBlend" {
Properties {
[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
 _Color ("Tint", Color) = (1,1,1,1)
 _SolidColor ("Solid Color", Color) = (0,0,0,1)
 _SolidBlend ("Solid Blend", Range(0, 1)) = 0
[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
[HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
[HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
[PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
}
SubShader {
Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
Pass {
Tags {  }
Cull Off
ZWrite Off
ZTest LEqual
ZClip On
Offset 0, 0
AlphaToMask Off
Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
BlendOp Add, Add
ColorMask RGBA
Stencil {
Ref 0
ReadMask 255
WriteMask 255
Comp Always
Pass Keep
Fail Keep
ZFail Keep
}
HLSLPROGRAM
#pragma target 3.5
#pragma only_renderers d3d11 metal
#pragma vertex PortVertex
#pragma fragment PortFragment
#pragma multi_compile __ ETC1_EXTERNAL_ALPHA
#pragma multi_compile __ PIXELSNAP_ON
#include "UnityCG.cginc"
half4 _Color;
float _EnableExternalAlpha;
half2 _Flip;
half4 _RendererColor;
float _SolidBlend;
half4 _SolidColor;
Texture2D<float4> _AlphaTex;
Texture2D<float4> _MainTex;
SamplerState sampler_AlphaTex;
SamplerState sampler_MainTex;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if !defined(ETC1_EXTERNAL_ALPHA) && !defined(PIXELSNAP_ON)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.POSITION0.xy * ((float2)(_Flip.xyxx.xy));
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    output.mtl_Position = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    u_xlat0 = input.COLOR0 * ((float4)(_Color));
    u_xlat0 = u_xlat0 * ((float4)(_RendererColor));
    output.COLOR0 = ((half4)(u_xlat0));
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    return output;

}

#elif defined(ETC1_EXTERNAL_ALPHA) && !defined(PIXELSNAP_ON)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.POSITION0.xy * ((float2)(_Flip.xyxx.xy));
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    output.mtl_Position = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    u_xlat0 = input.COLOR0 * ((float4)(_Color));
    u_xlat0 = u_xlat0 * ((float4)(_RendererColor));
    output.COLOR0 = ((half4)(u_xlat0));
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    return output;

}

#elif !defined(ETC1_EXTERNAL_ALPHA) && defined(PIXELSNAP_ON)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.POSITION0.xy * ((float2)(_Flip.xyxx.xy));
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.mtl_Position.xy = u_xlat0.ww * u_xlat0.xy;
    output.mtl_Position.zw = u_xlat0.zw;
    u_xlat0 = input.COLOR0 * ((float4)(_Color));
    u_xlat0 = u_xlat0 * ((float4)(_RendererColor));
    output.COLOR0 = ((half4)(u_xlat0));
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    return output;

}

#elif defined(ETC1_EXTERNAL_ALPHA) && defined(PIXELSNAP_ON)
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    float4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.POSITION0.xy * ((float2)(_Flip.xyxx.xy));
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(unity_ObjectToWorld, 2), input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.mtl_Position.xy = u_xlat0.ww * u_xlat0.xy;
    output.mtl_Position.zw = u_xlat0.zw;
    u_xlat0 = input.COLOR0 * ((float4)(_Color));
    u_xlat0 = u_xlat0 * ((float4)(_RendererColor));
    output.COLOR0 = ((half4)(u_xlat0));
    output.TEXCOORD0.xy = input.TEXCOORD0.xy;
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
#if !defined(ETC1_EXTERNAL_ALPHA) && !defined(PIXELSNAP_ON)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_1;
    float3 u_xlat2;
    u_xlat0.x = _SolidBlend;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat2.xyz = mad((-((float3)(u_xlat16_1.xyz))), ((float3)(input.COLOR0.xyz)), ((float3)(_SolidColor.xyz)));
    u_xlat16_1 = u_xlat16_1 * input.COLOR0;
    u_xlat0.xyz = mad(u_xlat0.xxx, u_xlat2.xyz, ((float3)(u_xlat16_1.xyz)));
    output.SV_Target0.xyz = ((half3)(((float3)(u_xlat16_1.www)) * u_xlat0.xyz));
    output.SV_Target0.w = u_xlat16_1.w;
    return output;

}

#elif defined(ETC1_EXTERNAL_ALPHA) && !defined(PIXELSNAP_ON)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    float3 u_xlat3;
    half u_xlat16_3;
    u_xlat0.x = _SolidBlend;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat16_3 = _AlphaTex.Sample(sampler_AlphaTex, input.TEXCOORD0.xy).x;
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat3.x = float(u_xlat16_3) + (-float(u_xlat16_1.w));
    u_xlat16_1.w = half(mad(_EnableExternalAlpha, u_xlat3.x, float(u_xlat16_1.w)));
    u_xlat16_2 = u_xlat16_1 * input.COLOR0;
    u_xlat3.xyz = mad((-((float3)(u_xlat16_1.xyz))), ((float3)(input.COLOR0.xyz)), ((float3)(_SolidColor.xyz)));
    u_xlat0.xyz = mad(u_xlat0.xxx, u_xlat3.xyz, ((float3)(u_xlat16_2.xyz)));
    output.SV_Target0.xyz = ((half3)(((float3)(u_xlat16_2.www)) * u_xlat0.xyz));
    output.SV_Target0.w = u_xlat16_2.w;
    return output;

}

#elif !defined(ETC1_EXTERNAL_ALPHA) && defined(PIXELSNAP_ON)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_1;
    float3 u_xlat2;
    u_xlat0.x = _SolidBlend;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat2.xyz = mad((-((float3)(u_xlat16_1.xyz))), ((float3)(input.COLOR0.xyz)), ((float3)(_SolidColor.xyz)));
    u_xlat16_1 = u_xlat16_1 * input.COLOR0;
    u_xlat0.xyz = mad(u_xlat0.xxx, u_xlat2.xyz, ((float3)(u_xlat16_1.xyz)));
    output.SV_Target0.xyz = ((half3)(((float3)(u_xlat16_1.www)) * u_xlat0.xyz));
    output.SV_Target0.w = u_xlat16_1.w;
    return output;

}

#elif defined(ETC1_EXTERNAL_ALPHA) && defined(PIXELSNAP_ON)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float3 u_xlat0;
    half4 u_xlat16_1;
    half4 u_xlat16_2;
    float3 u_xlat3;
    half u_xlat16_3;
    u_xlat0.x = _SolidBlend;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat16_3 = _AlphaTex.Sample(sampler_AlphaTex, input.TEXCOORD0.xy).x;
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat3.x = float(u_xlat16_3) + (-float(u_xlat16_1.w));
    u_xlat16_1.w = half(mad(_EnableExternalAlpha, u_xlat3.x, float(u_xlat16_1.w)));
    u_xlat16_2 = u_xlat16_1 * input.COLOR0;
    u_xlat3.xyz = mad((-((float3)(u_xlat16_1.xyz))), ((float3)(input.COLOR0.xyz)), ((float3)(_SolidColor.xyz)));
    u_xlat0.xyz = mad(u_xlat0.xxx, u_xlat3.xyz, ((float3)(u_xlat16_2.xyz)));
    output.SV_Target0.xyz = ((half3)(((float3)(u_xlat16_2.www)) * u_xlat0.xyz));
    output.SV_Target0.w = u_xlat16_2.w;
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
