Shader "Hidden/Universal Render Pipeline/GaussianBlur"
{
	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
	TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
	float4 _BlurOffset;

	struct a2v
	{
	    float4 positionOS : POSITION;
		float2 uv : TEXCOORD0;
	};
	
	struct v2f
	{
		float4 pos: SV_POSITION;
		float2 uv: TEXCOORD0;	
		float4 uv01: TEXCOORD1;
		float4 uv23: TEXCOORD2;
		float4 uv45: TEXCOORD3;
	};
	
	v2f VertGaussianBlurW(a2v v)
	{
		v2f o;
		o.pos = TransformObjectToHClip(v.positionOS.xyz);
		
		o.uv.xy = v.uv;
		
		#if UNITY_UV_STARTS_AT_TOP
			o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
		#endif
		
		o.uv01 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0);
		o.uv23 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0) * 2.0;
		o.uv45 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0) * 6.0;
		
		return o;
	}

	v2f VertGaussianBlurH(a2v v)
	{
		v2f o;
		o.pos = TransformObjectToHClip(v.positionOS.xyz);
		
		o.uv.xy = v.uv;
		
		#if UNITY_UV_STARTS_AT_TOP
			o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
		#endif
		
		o.uv01 = o.uv.xyxy + _BlurOffset.y * float4(0, 1, 0, -1);
		o.uv23 = o.uv.xyxy + _BlurOffset.y * float4(0, 1, 0, -1) * 2.0;
		o.uv45 = o.uv.xyxy + _BlurOffset.y * float4(0, 1, 0, -1) * 6.0;
		
		return o;
	}
	
	float4 FragGaussianBlur(v2f i): SV_Target
	{
		half4 color = float4(0, 0, 0, 0);
		
		color += 0.40 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
		color += 0.15 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv01.xy);
		color += 0.15 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv01.zw);
		color += 0.10 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv23.xy);
		color += 0.10 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv23.zw);
		color += 0.05 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv45.xy);
		color += 0.05 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv45.zw);
		
		return color;
	}
	
	float4 FragCombine(Varyings i): SV_Target
	{
		return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * 0.9;
	}
	ENDHLSL
    SubShader
    {
        //Cull Off ZWrite Off ZTest Always
        Pass
		{
			HLSLPROGRAM
			#pragma vertex VertGaussianBlurW
			#pragma fragment FragGaussianBlur
			ENDHLSL
			
		}

		Pass
		{
			HLSLPROGRAM
			#pragma vertex VertGaussianBlurH
			#pragma fragment FragGaussianBlur
			ENDHLSL
			
		}
		
		Pass
		{
			HLSLPROGRAM
			#pragma vertex FullscreenVert
			#pragma fragment FragCombine
			ENDHLSL
			
		}
    }
}
