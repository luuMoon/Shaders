
Shader "Custom/Flow" {
 
	Properties
	{
		_MainTex("底图 (RGB)", 2D) = "white" {}
		_FlowTex("流光图 (A)", 2D) = "white" {}
		_ScrollXSpeed("横向速度", Range(0, 10)) = 2
		_ScrollYSpeed("竖向速度", Range(0, 10)) = 0
	}
 
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
 
		CGPROGRAM
		#pragma surface surf Lambert  
 
		sampler2D _MainTex;
		sampler2D _FlowTex;
		float _ScrollXSpeed;
 	    float _ScrollYSpeed;

		struct Input {
			float2 uv_MainTex;
			float2 uv_FlowTex;
		};
 
		void surf(Input IN, inout SurfaceOutput o) {
			//改变流光图的uv
			fixed2 scrolledUV = IN.uv_FlowTex;
			scrolledUV += fixed2( _ScrollXSpeed * _Time.y, _ScrollYSpeed * _Time.y);
			
			//颜色混合；
			half4 c = tex2D(_FlowTex, scrolledUV);
			half4 d = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb + d.rgb;
			o.Alpha = d.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
	}