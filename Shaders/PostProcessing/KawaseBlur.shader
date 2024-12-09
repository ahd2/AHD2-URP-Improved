Shader "Hidden/Universal Render Pipeline/KawaseBlur"
{
	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
	TEXTURE2D(_MainTex);	SAMPLER(sampler_MainTex);

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
	};
	
	v2f VertGaussianBlurW(a2v v)
	{
		v2f o;
		o.pos = TransformObjectToHClip(v.positionOS.xyz);
		
		o.uv.xy = v.uv;
		
		return o;
	}
	
	float4 FragKawaseBlur(v2f i): SV_Target
	{
		half4 color = float4(0, 0, 0, 0);

		color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + float2(_BlurOffset.z , _BlurOffset.w));
		color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + float2(- _BlurOffset.z , _BlurOffset.w));
		color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + float2(_BlurOffset.z , - _BlurOffset.w));
		color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv + float2(- _BlurOffset.z , - _BlurOffset.w));
		
		return color * 0.25;
	}
	
	ENDHLSL
    SubShader
    {
        //Cull Off ZWrite Off ZTest Always
        Pass
		{
			HLSLPROGRAM
			#pragma vertex VertGaussianBlurW
			#pragma fragment FragKawaseBlur
			ENDHLSL
			
		}
    }
}
