Shader "Hidden/Universal Render Pipeline/GaussianBlur"
{
	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
	TEXTURE2D(_MainTex);
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
		
		// #if UNITY_UV_STARTS_AT_TOP
		// 	o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
		// #endif

		//范围从0-1变成0-宽度/高度
		o.uv.x *= _BlurOffset.z;
		o.uv.y *= _BlurOffset.w;
		
		o.uv01 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0);
		
		o.uv23 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0) * 2.0;
		
		o.uv45 = o.uv.xyxy + _BlurOffset.x * float4(1, 0, -1, 0) * 3.0;
		
		
		return o;
	}

	v2f VertGaussianBlurH(a2v v)
	{
		v2f o;
		o.pos = TransformObjectToHClip(v.positionOS.xyz);
		
		o.uv.xy = v.uv;
		
		// #if UNITY_UV_STARTS_AT_TOP
		// 	o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
		// #endif

		//范围从0-1变成0-宽度/高度
		o.uv.x *= _BlurOffset.z;
		o.uv.y *= _BlurOffset.w;
		
		o.uv01 = o.uv.xyxy + _BlurOffset.x * float4(0, 1, 0, -1);
		
		o.uv23 = o.uv.xyxy + _BlurOffset.x * float4(0, 1, 0, -1) * 2.0;
		
		o.uv45 = o.uv.xyxy + _BlurOffset.x * float4(0, 1, 0, -1) * 3.0;
		
		return o;
	}
	
	float4 FragGaussianBlurW(v2f i): SV_Target
	{
		half4 color = float4(0, 0, 0, 0);
		i.uv01.x = min(i.uv01.x, _BlurOffset.z - 1);//防止超出右
		i.uv23.x = min(i.uv23.x, _BlurOffset.z - 1);//防止超出右
		i.uv45.x = min(i.uv45.x, _BlurOffset.z - 1);//防止超出右
		i.uv01.z = max(i.uv01.z, 0);//防止超出左
		i.uv23.z = max(i.uv23.z, 0);//防止超出左
		i.uv45.z = max(i.uv45.z, 0);//防止超出左
		
		color += 0.40 * LOAD_TEXTURE2D(_MainTex, i.uv);
		color += 0.15 * LOAD_TEXTURE2D(_MainTex, i.uv01.xy);
		color += 0.15 * LOAD_TEXTURE2D(_MainTex, i.uv01.zw);
		color += 0.10 * LOAD_TEXTURE2D(_MainTex, i.uv23.xy);
		color += 0.10 * LOAD_TEXTURE2D(_MainTex, i.uv23.zw);
		color += 0.05 * LOAD_TEXTURE2D(_MainTex, i.uv45.xy);
		color += 0.05 * LOAD_TEXTURE2D(_MainTex, i.uv45.zw);
		
		return color;
	}

	float4 FragGaussianBlurH(v2f i): SV_Target
	{
		half4 color = float4(0, 0, 0, 0);
		//必须在片元着色器做钳制，不然顶点着色器做钳制后插值，效果就是错误的。
		i.uv01.y = min(i.uv01.y, _BlurOffset.w - 1);//防止超出右
		i.uv23.y = min(i.uv23.y, _BlurOffset.w - 1);//防止超出右
		i.uv45.y = min(i.uv45.y, _BlurOffset.w - 1);//防止超出右
		i.uv01.w = max(i.uv01.w, 0);//防止超出左
		i.uv23.w = max(i.uv23.w, 0);//防止超出左
		i.uv45.w = max(i.uv45.w, 0);//防止超出左
		
		color += 0.40 * LOAD_TEXTURE2D(_MainTex, i.uv);
		color += 0.15 * LOAD_TEXTURE2D(_MainTex, i.uv01.xy);
		color += 0.15 * LOAD_TEXTURE2D(_MainTex, i.uv01.zw);
		color += 0.10 * LOAD_TEXTURE2D(_MainTex, i.uv23.xy);
		color += 0.10 * LOAD_TEXTURE2D(_MainTex, i.uv23.zw);
		color += 0.05 * LOAD_TEXTURE2D(_MainTex, i.uv45.xy);
		color += 0.05 * LOAD_TEXTURE2D(_MainTex, i.uv45.zw);
		
		return color;
	}
	
	// float4 FragCombine(Varyings i): SV_Target
	// {
	// 	return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
	// }
	ENDHLSL
    SubShader
    {
        //Cull Off ZWrite Off ZTest Always
        Pass
		{
			HLSLPROGRAM
			#pragma vertex VertGaussianBlurW
			#pragma fragment FragGaussianBlurW
			ENDHLSL
			
		}

		Pass
		{
			HLSLPROGRAM
			#pragma vertex VertGaussianBlurH
			#pragma fragment FragGaussianBlurH
			ENDHLSL
			
		}
		
//		Pass
//		{
//			HLSLPROGRAM
//			#pragma vertex FullscreenVert
//			#pragma fragment FragCombine
//			ENDHLSL
//			
//		}
    }
}
