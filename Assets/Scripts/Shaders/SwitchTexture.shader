Shader "Small World/SwitchTexture"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
		// _BumpMap ("Main Bump", 2D) = "bump" {}
		
		_SecondaryTex ("Secondary Texture", 2D) = "white" {}
		// _SecondaryBump ("Secondary Bump", 2D) = "bump" {}
		
        _LerpT ("Lerp t", Range(0.0, 1.0)) = 0.0
    }
	
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		
        Pass
		{
            CGPROGRAM
			//#pragma surface surf Lambert fullforwardshadows
            #pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
            #include "UnityCG.cginc"
 
            // struct Input
			struct v2f
			{
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed val : TEXCOORD1;
            };
			
            float4 _MainTex_ST;
            sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _SecondaryTex;
			sampler2D _SecondaryBump;
			
			half _LerpT;
 
            // void vert(inout appdata_full v, out Input o)
			v2f vert(appdata_base v)
			{
                // UNITY_INITIALIZE_OUTPUT(Input, o);
				v2f o;
				
                float4 worldpos = mul(unity_ObjectToWorld, v.vertex);
				
                o.pos = mul(UNITY_MATRIX_VP, worldpos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
                float3 worldnormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldpos.xyz);
				
                o.val = 1.0f - sin(dot(worldnormal, viewDir));
				
				return o;
            }
			
			/*
			void surf(Input IN, inout SurfaceOutput o)
			{
				float destLerp = saturate(6.28f * (_LerpT * _LerpT) * IN.val);
				
				fixed4 c = (destLerp < 1.0f) ? tex2D(_MainTex, IN.uv) : fixed4(.0f,.0f,.0f,.0f);
				fixed4 alt_c = (destLerp > .0f) ? tex2D(_SecondaryTex, IN.uv) : fixed4(.0f,.0f,.0f,.0f);
				
				c = lerp(c, alt_c, destLerp);
				
				half3 b = (destLerp < 1.0f) ? UnpackNormal(tex2D(_BumpMap, IN.uv.xy)) : half3(.0f,.0f,.0f);
				half3 alt_b = (destLerp > .0f) ? UnpackNormal(tex2D(_SecondaryBump, IN.uv.xy)) : half3(.0f,.0f,.0f);
				
				b = lerp(b, alt_b, destLerp);
				
				o.Albedo = c.rgb;
				o.Normal = b;
			}
			*/
			
            fixed4 frag(v2f i) : SV_Target
			{
				float destLerp = saturate(6.28f * (_LerpT * _LerpT) * i.val);
				
				half3 b = (destLerp < 1.0f)?UnpackNormal(tex2D(_BumpMap, i.uv.xy)):half3(.0f,.0f,.0f);
				half3 alt_b = (destLerp > .0f)?UnpackNormal(tex2D(_SecondaryBump, i.uv.xy)):half3(.0f,.0f,.0f);
				
				b = lerp(b, alt_b, destLerp);
				
                fixed4 c = (destLerp < 1.0f) ? tex2D(_MainTex, i.uv) : fixed4(.0f,.0f,.0f,.0f);
				fixed4 alt_c = (destLerp > .0f) ? tex2D(_SecondaryTex, i.uv) : fixed4(.0f,.0f,.0f,.0f);
				
                c = lerp(c, alt_c, destLerp);
				
                return c;
            }
			
            ENDCG
        }
    }
	Fallback "Diffuse"
}