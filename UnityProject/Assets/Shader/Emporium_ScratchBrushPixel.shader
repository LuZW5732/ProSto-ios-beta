// Recovered from source-bearing Metal programs in the supplied IPA.
// Candidate translation: Unity/Metal and visual validation are still required.
Shader "Emporium/ScratchBrushPixel" {
Properties {
 _Coord ("Coord", Vector) = (0,0,0,0)
 _Radius ("Radius", Float) = 10
 _TexSize ("TexSize", Vector) = (56,56,0,0)
 _EdgeSoftness ("Edge Softness", Float) = 2
 _BrushTex ("Brush Texture (optional)", 2D) = "white" {}
 _UseTexture ("Use Texture", Float) = 0
 _ScratchCount ("Number of Scratches", Float) = 3
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
Blend One One, One One
BlendOp Max, Max
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
#include "UnityCG.cginc"
float4 _Coord;
float _EdgeSoftness;
float _Radius;
float _ScratchCount;
float4 _TexSize;
float _UseTexture;
Texture2D<float4> _BrushTex;
SamplerState sampler_BrushTex;
#define PORT_COLUMN(m,i) float4(m[0][i],m[1][i],m[2][i],m[3][i])

#if 1
struct Mtl_VertexIn
{
    float4 POSITION0 : POSITION0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Mtl_VertexOut
{
    float4 mtl_Position : SV_POSITION;
    float2 TEXCOORD0 : TEXCOORD0;
};
Mtl_VertexOut PortVertex(Mtl_VertexIn input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.POSITION0.xy + input.POSITION0.xy;
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(unity_ObjectToWorld, 1);
    u_xlat1 = mad(PORT_COLUMN(unity_ObjectToWorld, 0), u_xlat0.xxxx, u_xlat1);
    output.TEXCOORD0.xy = u_xlat0.xy;
    u_xlat0 = u_xlat1 + PORT_COLUMN(unity_ObjectToWorld, 3);
    u_xlat1 = u_xlat0.yyyy * PORT_COLUMN(UNITY_MATRIX_VP, 1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 0), u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(PORT_COLUMN(UNITY_MATRIX_VP, 2), u_xlat0.zzzz, u_xlat1);
    output.mtl_Position = mad(PORT_COLUMN(UNITY_MATRIX_VP, 3), u_xlat0.wwww, u_xlat1);
    return output;

}

#else
#error No recovered Metal variant matches these keywords
#endif
#if 1
struct Mtl_FragmentIn
{
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
    half u_xlat16_0;
    float3 u_xlat1;
    float u_xlat2;
    bool u_xlatb2;
    float2 u_xlat4;
    float u_xlat6;
    u_xlat0.xy = mad(input.TEXCOORD0.xy, float2(1.0, -1.0), float2(0.0, 1.0));
    u_xlat0.xy = u_xlat0.xy * _TexSize.xy;
    u_xlat0.xy = floor(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy + float2(0.5, 0.5);
    u_xlat4.xy = _Coord.xy + float2(0.5, 0.5);
    u_xlat0.xy = (-u_xlat4.xy) + u_xlat0.xy;
    u_xlat4.x = dot(u_xlat0.xy, u_xlat0.xy);
    u_xlat4.x = sqrt(u_xlat4.x);
    u_xlat1.xyz = max(float3(_Radius, _EdgeSoftness, _ScratchCount), float3(0.00999999978, 0.00999999978, 1.0));
    u_xlat4.x = (-u_xlat4.x) + u_xlat1.x;
    u_xlat4.x = u_xlat4.x / u_xlat1.y;
    u_xlat4.x = clamp(u_xlat4.x, 0.0f, 1.0f);
    u_xlat6 = u_xlat1.x + u_xlat1.x;
    u_xlat0.xy = u_xlat0.xy / ((float2)(u_xlat6));
    u_xlat0.xy = u_xlat0.xy + float2(0.5, 0.5);
    u_xlat6 = u_xlat1.z * u_xlat0.x;
    u_xlat16_0 = _BrushTex.Sample(sampler_BrushTex, u_xlat0.xy).x;
    u_xlat0.x = float(u_xlat16_0) + -1.0;
    u_xlat2 = frac(u_xlat6);
    u_xlatb2 = u_xlat2>=0.25;
    u_xlat2 = (u_xlatb2) ? 1.0 : 0.699999988;
    u_xlat2 = u_xlat2 * u_xlat4.x;
    u_xlat4.x = _UseTexture;
    u_xlat4.x = clamp(u_xlat4.x, 0.0f, 1.0f);
    u_xlat0.x = mad(u_xlat4.x, u_xlat0.x, 1.0);
    u_xlat0 = u_xlat0.xxxx * ((float4)(u_xlat2));
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
