Shader "PPE/VoronoiDistort"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Offset ("Offset", Range(0,2)) = .1
		_SpeedZ ("Speed Z", Float) = .0
		
		_Blend ("Blend", Range(0,1)) = 1.0
		
		/* voronoise settings */
		_Shape ("Shape", Range(0, 1)) = 1.0
		_Blur ("Blur", Range(0, 1)) = 1.0
		
		/* generation seed */
		_Seed0 ("Seed [0]", Float) = 127.1
		_Seed1 ("Seed [1]", Float) = 322.7
		_Seed2 ("Seed [2]", Float) = 261.7
		_Seed3 ("Seed [3]", Float) = 269.5
		_Seed4 ("Seed [4]", Float) = 183.3
		_Seed5 ("Seed [5]", Float) = 457.7
		_Seed6 ("Seed [6]", Float) = 419.2
		_Seed7 ("Seed [7]", Float) = 371.9
		_Seed8 ("Seed [8]", Float) = 435.3
		
		/* parameter modifiers */
		_ScaleX ("Scale x", Float) = 1.0
		_ScaleY ("Scale y", Float) = 1.0
		_OffsetX ("Offset x", Float) = .0
		_OffsetY ("Offset y", Float) = .0
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

			/* noise adaptation */
			float _Seed0, _Seed1, _Seed2,
				_Seed3, _Seed4, _Seed5,
				_Seed6, _Seed7, _Seed8;
			/* used for cos convertion */
			static float pi = 3.14159f;
			
			float3 hash3(float3 p)
			{
				float3 q = float3(
					dot(p, float3(_Seed0, _Seed1, _Seed2)), 
					dot(p, float3(_Seed3, _Seed4, _Seed5)), 
					dot(p, float3(_Seed6, _Seed7, _Seed8)));
				return frac(sin(q) * 43758.5453f);
			}
			
			float noise(in float3 x, float u, float v)
			{
				float3 p = floor(x);
				float3 f = frac(x);
				
				float k = 1.0f + 63.0f * pow(1.0f - v, 4.0f);
				
				float va = .0f;
				float wt = .0f;
				
				for(int n = -2; n <= 2; n ++)
					for(int j = -2; j <= 2; j ++)
						for(int i = -2; i <= 2; i ++)
						{
							float3 g = float3(float(i), float(j), float(n));
							float3 o = hash3(p + g) * float3(u, u, 1.0f);
							float3 r = g - f + o.xyz;
							float d = dot(r, r);
							float ww = pow(1.0f - smoothstep(.0f, 1.414f, sqrt(d)), k);
							va += o.z * ww;
							wt += ww;
						}
				
				return saturate((va / wt) * 2.0f - .5f);
			}
			/* noise adaptation end */
			
		
			sampler2D _MainTex;
			half _Offset;
			half _Blend;
			half _SpeedZ;
			
			half _Shape;
			half _Blur;
			
			float _ScaleX; float _ScaleY;
			float _OffsetX; float _OffsetY;

			fixed4 frag (v2f_img i) : COLOR
			{
				float3 noisePos = float3(i.uv.x * _ScaleX + _OffsetX,
					i.uv.y * _ScaleY + _OffsetY, .0f);
				noisePos.z += _Time * _SpeedZ;
				
				float noiseVal = 1.0f - noise(noisePos, _Shape, _Blur) * _Blend;
				
				half offset = _Offset * (pow(_Blend, 8));
				
				half2 dir = i.uv - half2(.5f, .5f);
				
				i.uv = saturate(i.uv + dir * ((-.5f) * offset + noiseVal * offset * _Blend));
				fixed4 c = tex2D(_MainTex, i.uv);
				
				return c;
			}
			ENDCG
		}
	}
}
