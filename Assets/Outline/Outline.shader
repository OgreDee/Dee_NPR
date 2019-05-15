Shader "Dee/Outline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutlineSize("Outline Size", Range(0, 10)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull back
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		Pass
		{
			Cull front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			half _OutlineSize;

			v2f vert(a2v v)
			{
				v2f o = (v2f)0;

				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float4 viewNormal = mul(UNITY_MATRIX_MV, v.normal);
				viewPos.xyz = viewPos.xyz + normalize(viewNormal.xyz) * _OutlineSize/ 1000;

				o.vertex = mul(UNITY_MATRIX_P, viewPos);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return half4(0,0,0,1);
			}

			ENDCG
		}
	}
}
