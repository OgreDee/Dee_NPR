Shader "Dee/DeeHair"
{
	Properties
	{
		_MainTex ("Albedo(RGB) Alpha(A)", 2D) = "white" {}
		_SpecMaskTex ("SpecMaskTex Spec(R) Shift(G) SecondarySpecMask(B)", 2D) = "white" {}
		diffuseColor ("diffuseColor", Color) = (1,1,1,1)
		primarySpecColor ("primarySpecColor", Color) = (1,1,1,1)
		secondarySpecColor ("secondarySpecColor", Color) = (1,1,1,1)
		primarySpecPower("primarySpecPower", Range(0, 256)) = 8
		secondarySpecPower("secondarySpecPower", Range(0, 256)) = 8
		primaryShift("primaryShift", Range(-2, 2)) = 0
		secondaryShift("secondaryShift", Range(-2, 2)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
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
				float4 color : COLOR;
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldTangent : TEXCOORD3;
				float3 worldPos : TEXCOORD4;
				float3 worldBinormal : TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float3 diffuseColor;

			float3 primarySpecColor;
			float primarySpecPower;
			float primaryShift;

			float3 secondarySpecColor;
			float secondarySpecPower;
			float secondaryShift;

			sampler2D _SpecMaskTex;


			inline float3 ShiftTangent(float3 T, float3 N, float shift)
			{
				float3 shiftT = T + shift * N;

				return normalize(shiftT);
			}

			inline float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
			{
				float3 H = normalize(L + V);
				float dotTH = dot(T, H);
				float sinTH = sqrt(1.0 - dotTH *dotTH);
				float dirAtten = smoothstep(-1.0, 0.0, dotTH);
				
				return dirAtten * pow(sinTH, exponent);
			}

			//Schenermann漫反射: lerp(0.25, 1, dot(n,l))
			inline half3 ScheuermannDiffuseTerm(float3 normal, float3 lightVec)
			{
				return  lerp(0.25, 1.0, saturate(dot(normal, lightVec)));
			}

			//Scheuermann高光选项
			inline half3 ScheuermannSpecularTerm(float3 T, float3 normal, float3 lightVec, float3 viewVec, float2 uv)
			{
				//shift tangent
				float4 specMask = tex2D(_SpecMaskTex, uv);

				float shiftTex = specMask.g - 0.5;
				float3 t1 = ShiftTangent(T, normal, primaryShift + shiftTex);
				float3 t2 = ShiftTangent(T, normal, secondaryShift + shiftTex);

				//specular lighting
				half3 primarySpec = primarySpecColor * StrandSpecular(t1, viewVec, lightVec, primarySpecPower) * specMask.r;
				half3 secondarySpec = specMask.b * secondarySpecColor * StrandSpecular(t2, viewVec, lightVec, secondarySpecPower)  * specMask.r;

				return primarySpec + secondarySpec;

			}


			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal.xyz);
				o.worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldTangent = normalize(i.worldTangent);
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldBinormal = normalize(i.worldBinormal);

				float3 worldLitDir = UnityWorldSpaceLightDir(i.worldPos);
				float3 worldViewDir = UnityWorldSpaceViewDir(i.worldPos);

				half3 diffuse = diffuseColor;
				diffuse *= ScheuermannDiffuseTerm(worldNormal, worldLitDir);

				half3 specular = ScheuermannSpecularTerm(worldBinormal, worldNormal, worldLitDir, worldViewDir, i.uv);

				//final color assembly
				float4 finalColor = (float4)0;
				finalColor.rgb = diffuse + specular;

				finalColor.rgb *= tex2D(_MainTex, i.uv);

				return finalColor;
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 diffuseColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 diffuse = tex2D(_MainTex, i.uv).rgb * diffuseColor;
				return float4(diffuse,1);
			}
			ENDCG
		}
	}
}
