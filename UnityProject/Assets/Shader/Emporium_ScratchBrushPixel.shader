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
	//DummyShaderTextExporter
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 unity_ObjectToWorld;
			float4x4 unity_MatrixVP;

			struct Vertex_Stage_Input
			{
				float4 pos : POSITION;
			};

			struct Vertex_Stage_Output
			{
				float4 pos : SV_POSITION;
			};

			Vertex_Stage_Output vert(Vertex_Stage_Input input)
			{
				Vertex_Stage_Output output;
				output.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, input.pos));
				return output;
			}

			float4 frag(Vertex_Stage_Output input) : SV_TARGET
			{
				return float4(1.0, 1.0, 1.0, 1.0); // RGBA
			}

			ENDHLSL
		}
	}
}