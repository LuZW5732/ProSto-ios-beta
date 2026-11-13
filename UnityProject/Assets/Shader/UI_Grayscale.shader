// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "UI/Grayscale" {
Properties {
[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
 _Color ("Tint", Color) = (1,1,1,1)
 _GrayscaleAmount ("Grayscale Amount", Range(0, 1)) = 1
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
float _GrayscaleAmount;
float4 _MainTex_ST;
half4 _TextureSampleAdd;
Texture2D<float4> _MainTex;
SamplerState sampler_MainTex;
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
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half u_xlat16_3;
    float3 u_xlat4;
    u_xlat0 = _GrayscaleAmount;
    u_xlat0 = clamp(u_xlat0, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(_TextureSampleAdd));
    u_xlat2 = u_xlat1 * ((float4)(input.COLOR0));
    u_xlat16_3 = dot(u_xlat2.xyz, float3(0.298999995, 0.587000012, 0.114));
    u_xlat4.xyz = mad((-u_xlat1.xyz), ((float3)(input.COLOR0.xyz)), ((float3)(u_xlat16_3)));
    u_xlat2.xyz = mad(((float3)(u_xlat0)), u_xlat4.xyz, u_xlat2.xyz);
    output.SV_Target0 = ((half4)(u_xlat2));
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
    float4 u_xlat0;
    half4 u_xlat16_0;
    float4 u_xlat1;
    half u_xlat16_1;
    bool u_xlatb2;
    half u_xlat16_3;
    float u_xlat12;
    u_xlat16_0 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat0 = ((float4)(u_xlat16_0)) + ((float4)(_TextureSampleAdd));
    u_xlat16_1 = half(mad(u_xlat0.w, float(input.COLOR0.w), -0.00100000005));
    u_xlatb2 = u_xlat16_1<half(0.0);
    if(((int(u_xlatb2) * int(0xffffffffu)))!=0){discard;}
    u_xlat1 = u_xlat0 * ((float4)(input.COLOR0));
    u_xlat16_3 = dot(u_xlat1.xyz, float3(0.298999995, 0.587000012, 0.114));
    u_xlat0.xyz = mad((-u_xlat0.xyz), ((float3)(input.COLOR0.xyz)), ((float3)(u_xlat16_3)));
    u_xlat12 = _GrayscaleAmount;
    u_xlat12 = clamp(u_xlat12, 0.0f, 1.0f);
    u_xlat1.xyz = mad(((float3)(u_xlat12)), u_xlat0.xyz, u_xlat1.xyz);
    output.SV_Target0 = ((half4)(u_xlat1));
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
    float4 u_xlat1;
    half4 u_xlat16_1;
    bool4 u_xlatb1;
    float4 u_xlat2;
    half u_xlat16_3;
    float3 u_xlat4;
    u_xlat0.x = _GrayscaleAmount;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(_TextureSampleAdd));
    u_xlat2 = u_xlat1 * ((float4)(input.COLOR0));
    u_xlat16_3 = dot(u_xlat2.xyz, float3(0.298999995, 0.587000012, 0.114));
    u_xlat4.xyz = mad((-u_xlat1.xyz), ((float3)(input.COLOR0.xyz)), ((float3)(u_xlat16_3)));
    u_xlat0.xyz = mad(u_xlat0.xxx, u_xlat4.xyz, u_xlat2.xyz);
    u_xlatb1.xy = (input.TEXCOORD1.xy>=_ClipRect.xy);
    u_xlatb1.zw = (_ClipRect.zw>=input.TEXCOORD1.xy);
    u_xlat1 = ((((bool4)(u_xlatb1))) ? (float4(1.0, 1.0, 1.0, 1.0)) : (float4(0.0, 0.0, 0.0, 0.0)));
    u_xlat1.xy = u_xlat1.zw * u_xlat1.xy;
    u_xlat1.x = u_xlat1.y * u_xlat1.x;
    u_xlat0.w = u_xlat1.x * u_xlat2.w;
    output.SV_Target0 = ((half4)(u_xlat0));
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
    float4 u_xlat1;
    half4 u_xlat16_1;
    float4 u_xlat2;
    half u_xlat16_3;
    float u_xlat13;
    bool u_xlatb13;
    u_xlatb0.xy = (input.TEXCOORD1.xy>=_ClipRect.xy);
    u_xlatb0.zw = (_ClipRect.zw>=input.TEXCOORD1.xy);
    u_xlat0 = ((((bool4)(u_xlatb0))) ? (float4(1.0, 1.0, 1.0, 1.0)) : (float4(0.0, 0.0, 0.0, 0.0)));
    u_xlat0.xy = u_xlat0.zw * u_xlat0.xy;
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat16_1 = _MainTex.Sample(sampler_MainTex, input.TEXCOORD0.xy);
    u_xlat1 = ((float4)(u_xlat16_1)) + ((float4)(_TextureSampleAdd));
    u_xlat2 = u_xlat1 * ((float4)(input.COLOR0));
    u_xlat16_3 = half(mad(u_xlat2.w, u_xlat0.x, -0.00100000005));
    u_xlat0.w = u_xlat0.x * u_xlat2.w;
    u_xlatb13 = u_xlat16_3<half(0.0);
    if(((int(u_xlatb13) * int(0xffffffffu)))!=0){discard;}
    u_xlat16_3 = dot(u_xlat2.xyz, float3(0.298999995, 0.587000012, 0.114));
    u_xlat1.xyz = mad((-u_xlat1.xyz), ((float3)(input.COLOR0.xyz)), ((float3)(u_xlat16_3)));
    u_xlat13 = _GrayscaleAmount;
    u_xlat13 = clamp(u_xlat13, 0.0f, 1.0f);
    u_xlat0.xyz = mad(((float3)(u_xlat13)), u_xlat1.xyz, u_xlat2.xyz);
    output.SV_Target0 = ((half4)(u_xlat0));
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
