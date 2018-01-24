Shader "PPE/Blur"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Radius ("Radius", Range(.0, 1.0)) = .0
	}
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
	 
			sampler2D _MainTex;
			half _Radius;
	 
			fixed4 frag (v2f_img i) : COLOR
			{
				_Radius *= .005f;
				fixed4 col = tex2D(_MainTex, i.uv) * .25f;
				
				if(_Radius > .0f)
				{
					col += tex2D(_MainTex, i.uv + float2(_Radius, _Radius)) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(- _Radius, _Radius)) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(_Radius, - _Radius)) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(- _Radius, - _Radius)) * .09375f;
					
					col += tex2D(_MainTex, i.uv + float2(_Radius * sqrt(2), .0)) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(- _Radius * sqrt(2), .0)) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(.0, _Radius * sqrt(2))) * .09375f;
					col += tex2D(_MainTex, i.uv + float2(.0, -_Radius * sqrt(2))) * .09375f;
				}
				else
					col *= 4.0f;
				
				return col;
			}
			ENDCG
		}
	}
}