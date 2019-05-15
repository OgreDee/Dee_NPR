Shader "Unlit/Chinese Painting"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeThreshold("EdgeThreshold", Range(0, 1)) = 0.
		_Tooniness("Tooniness ", Range(2, 20)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _EdgeThreshold;
			fixed _Tooniness;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal.xyz);
				o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				//float3 worldPos = normalize(i.worldPos);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float rota = dot(worldNormal, viewDir);
				//rota = pow(rota, 1);
				rota = step(_EdgeThreshold, rota);
				//return fixed4(rota,rota,rota,1);
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) ;

				col.rgb = floor(col.rgb * _Tooniness) / _Tooniness;

				return col;
			}
			ENDCG
		}
	}
}
