// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "UI/ScratchReveal" {
Properties {
[PerRendererData] _MainTex ("Prize", 2D) = "white" {}
 _CoverTex ("Cover", 2D) = "white" {}
 _MaskTex ("Mask", 2D) = "black" {}
 _Color ("Tint", Color) = (1,1,1,1)
 _StencilComp ("Stencil Comparison", Float) = 8
 _Stencil ("Stencil ID", Float) = 0
 _StencilOp ("Stencil Operation", Float) = 0
 _StencilWriteMask ("Stencil Write Mask", Float) = 255
 _StencilReadMask ("Stencil Read Mask", Float) = 255
 _ColorMask ("Color Mask", Float) = 15
[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
}
SubShader {
Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
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
#pragma multi_compile __ UNITY_UI_ALPHACLIP
#pragma multi_compile __ UNITY_UI_CLIP_RECT
#include "UnityCG.cginc"
float4 _ClipRect;
half4 _Color;
float4 _MainTex_ST;
Texture2D<float4> _CoverTex;
Texture2D<float4> _MainTex;
Texture2D<float4> _MaskTex;
SamplerState sampler_CoverTex;
SamplerState sampler_MainTex;
SamplerState sampler_MaskTex;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if !defined(UNITY_UI_ALPHACLIP) && !defined(UNITY_UI_CLIP_RECT)
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

#elif defined(UNITY_UI_ALPHACLIP) && !defined(UNITY_UI_CLIP_RECT)
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

#elif !defined(UNITY_UI_ALPHACLIP) && defined(UNITY_UI_CLIP_RECT)
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

#elif defined(UNITY_UI_ALPHACLIP) && defined(UNITY_UI_CLIP_RECT)
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
#if !defined(UNITY_UI_ALPHACLIP) && !defined(UNITY_UI_CLIP_RECT)
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
    float u_xlat0;
    half4 u_xlat16_0;
    half u_xlat10_0;
    half4 u_xlat16_1;
    half4 u_xlat10_2;
    u_xlat10_0 = half(_MaskTex.Sample(sampler_MaskTex, input.TEXCOORD0.xy).x);
    u_xlat0 = float(float(u_xlat10_0));
    u_xlat0 = clamp(u_xlat0, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat10_2 = ((half4)(_CoverTex.Sample(sampler_CoverTex, input.TEXCOORD0.xy)));
    u_xlat16_1 = ((half4)(((float4)(u_xlat16_1)) + (-((float4)(u_xlat10_2)))));
    u_xlat16_0 = ((half4)(mad(((float4)(u_xlat0)), ((float4)(u_xlat16_1)), ((float4)(u_xlat10_2)))));
    output.SV_Target0 = u_xlat16_0 * input.COLOR0;
    return output;

}

#elif defined(UNITY_UI_ALPHACLIP) && !defined(UNITY_UI_CLIP_RECT)
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
    float u_xlat0;
    half4 u_xlat16_0;
    half u_xlat10_0;
    half4 u_xlat16_1;
    half4 u_xlat10_2;
    bool u_xlatb2;
    half u_xlat16_3;
    u_xlat10_0 = half(_MaskTex.Sample(sampler_MaskTex, input.TEXCOORD0.xy).x);
    u_xlat0 = float(float(u_xlat10_0));
    u_xlat0 = clamp(u_xlat0, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat10_2 = ((half4)(_CoverTex.Sample(sampler_CoverTex, input.TEXCOORD0.xy)));
    u_xlat16_1 = ((half4)(((float4)(u_xlat16_1)) + (-((float4)(u_xlat10_2)))));
    u_xlat16_0 = ((half4)(mad(((float4)(u_xlat0)), ((float4)(u_xlat16_1)), ((float4)(u_xlat10_2)))));
    u_xlat16_3 = mad(u_xlat16_0.w, input.COLOR0.w, half(-0.00100000005));
    u_xlat16_0 = u_xlat16_0 * input.COLOR0;
    output.SV_Target0 = u_xlat16_0;
    u_xlatb2 = u_xlat16_3<half(0.0);
    if(((int(u_xlatb2) * int(0xffffffffu)))!=0){discard;}
    return output;

}

#elif !defined(UNITY_UI_ALPHACLIP) && defined(UNITY_UI_CLIP_RECT)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float4 u_xlat0;
    bool4 u_xlatb0;
    half4 u_xlat16_1;
    half4 u_xlat10_2;
    float u_xlat3;
    half u_xlat10_3;
    u_xlatb0.xy = (input.TEXCOORD1.xy>=_ClipRect.xy);
    u_xlatb0.zw = (_ClipRect.zw>=input.TEXCOORD1.xy);
    u_xlat0 = ((((bool4)(u_xlatb0))) ? (float4(1.0, 1.0, 1.0, 1.0)) : (float4(0.0, 0.0, 0.0, 0.0)));
    u_xlat0.xy = u_xlat0.zw * u_xlat0.xy;
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat10_3 = half(_MaskTex.Sample(sampler_MaskTex, input.TEXCOORD0.xy).x);
    u_xlat3 = float(float(u_xlat10_3));
    u_xlat3 = clamp(u_xlat3, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat10_2 = ((half4)(_CoverTex.Sample(sampler_CoverTex, input.TEXCOORD0.xy)));
    u_xlat16_1 = ((half4)(((float4)(u_xlat16_1)) + (-((float4)(u_xlat10_2)))));
    u_xlat16_1 = ((half4)(mad(((float4)(u_xlat3)), ((float4)(u_xlat16_1)), ((float4)(u_xlat10_2)))));
    u_xlat16_1 = u_xlat16_1 * input.COLOR0;
    u_xlat0.x = u_xlat0.x * float(u_xlat16_1.w);
    output.SV_Target0.xyz = u_xlat16_1.xyz;
    output.SV_Target0.w = half(u_xlat0.x);
    return output;

}

#elif defined(UNITY_UI_ALPHACLIP) && defined(UNITY_UI_CLIP_RECT)
struct Mtl_FragmentIn
{
    half4 COLOR0 : COLOR0;
    float2 TEXCOORD0 : TEXCOORD0;
    float4 TEXCOORD1 : TEXCOORD1;
};
struct Mtl_FragmentOut
{
    half4 SV_Target0 : SV_Target0;
};
Mtl_FragmentOut PortFragment(Mtl_FragmentIn input)
{
    Mtl_FragmentOut output;
    float4 u_xlat0;
    bool4 u_xlatb0;
    half4 u_xlat16_1;
    half4 u_xlat10_2;
    half u_xlat16_3;
    float u_xlat4;
    half u_xlat10_4;
    u_xlatb0.xy = (input.TEXCOORD1.xy>=_ClipRect.xy);
    u_xlatb0.zw = (_ClipRect.zw>=input.TEXCOORD1.xy);
    u_xlat0 = ((((bool4)(u_xlatb0))) ? (float4(1.0, 1.0, 1.0, 1.0)) : (float4(0.0, 0.0, 0.0, 0.0)));
    u_xlat0.xy = u_xlat0.zw * u_xlat0.xy;
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat10_4 = half(_MaskTex.Sample(sampler_MaskTex, input.TEXCOORD0.xy).x);
    u_xlat4 = float(float(u_xlat10_4));
    u_xlat4 = clamp(u_xlat4, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat10_2 = ((half4)(_CoverTex.Sample(sampler_CoverTex, input.TEXCOORD0.xy)));
    u_xlat16_1 = ((half4)(((float4)(u_xlat16_1)) + (-((float4)(u_xlat10_2)))));
    u_xlat16_1 = ((half4)(mad(((float4)(u_xlat4)), ((float4)(u_xlat16_1)), ((float4)(u_xlat10_2)))));
    u_xlat16_1 = u_xlat16_1 * input.COLOR0;
    u_xlat16_3 = half(mad(float(u_xlat16_1.w), u_xlat0.x, -0.00100000005));
    u_xlat0.x = u_xlat0.x * float(u_xlat16_1.w);
    output.SV_Target0.xyz = u_xlat16_1.xyz;
    output.SV_Target0.w = half(u_xlat0.x);
    u_xlatb0.x = u_xlat16_3<half(0.0);
    if(((int(u_xlatb0.x) * int(0xffffffffu)))!=0){discard;}
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
