Shader "Distortion" {
	Properties {
		_Refraction  ("Distortion", range (0,128)) = 10
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Power ("Power", Range (1.00, 10.0)) = 1.0
		[Enum(Off,0,Front,1,Back,2)] _Cull ("Face Cull", Int) = 2
		[KeywordEnum(None,Normal,Screen)] _DistortMode ("Distortion Mode", Float) = 0
	}

	Category {
		Tags { "Queue"="Transparent+1"}
		SubShader {
		    LOD 500
			ZWrite Off
			Fog {Mode Off}
			Lighting Off

			GrabPass {}
 		
			Pass {
				Cull [_Cull]

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile _DISTORTMODE_NONE _DISTORTMODE_NORMAL _DISTORTMODE_SCREEN
				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"
				#include "UnityStandardUtils.cginc"
				#include "UnityStandardInput.cginc"
//...............ScreenGrab...............//
				//Tagent-->World
				float3 Vec3TsToWs( float3 vVectorTs, float3 vNormalWs, float3 vTangentUWs, float3 vTangentVWs )
				{
					float3 vVectorWs;
					vVectorWs.xyz = vVectorTs.x * vTangentUWs.xyz;
					vVectorWs.xyz += vVectorTs.y * vTangentVWs.xyz;
					vVectorWs.xyz += vVectorTs.z * vNormalWs.xyz;
					return vVectorWs.xyz; // Return without normalizing
				}

				//Normalize Tagent-->World
				float3 Vec3TsToWsNormalized( float3 vVectorTs, float3 vNormalWs, float3 vTangentUWs, float3 vTangentVWs )
				{
					return normalize( Vec3TsToWs( vVectorTs.xyz, vNormalWs.xyz, vTangentUWs.xyz, vTangentVWs.xyz ) );
				}
//...............ScreenGrab...............//
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
				#ifdef _DISTORTMODE_SCREEN
					float3 vNormal : NORMAL;
					float4 vTangent : TANGENT;
				#endif
				};

				struct v2f {
					float4 vPos : SV_POSITION;
					float4 uvgrab : TEXCOORD0;
					float2 uvbump : TEXCOORD1;
				#ifdef _DISTORTMODE_SCREEN
					float3 vNormalWs : TEXCOORD2;
					float3 vTangentUWs : TEXCOORD3;
					float3 vTangentVWs : TEXCOORD4;
					float2 vTexCoord0 : TEXCOORD5;

				#endif				
				};

				sampler2D _GrabTexture;
				float _Refraction;
				float4 _BumpMap_ST;
				float _Power;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vPos = UnityObjectToClipPos(v.vertex);
					o.uvgrab = ComputeGrabScreenPos(o.vPos);
					o.uvbump = TRANSFORM_TEX(v.texcoord, _BumpMap);
				#ifdef _DISTORTMODE_SCREEN
					// Texture coordinates
					o.vTexCoord0.xy = v.texcoord.xy;
					// World space normal
					o.vNormalWs = UnityObjectToWorldNormal(v.vNormal);
					// Tangent
					o.vTangentUWs.xyz = UnityObjectToWorldDir(v.vTangent.xyz ); // World space tangentU
					o.vTangentVWs.xyz = cross(o.vNormalWs.xyz, o.vTangentUWs.xyz ) * v.vTangent.w;
				#endif				
					return o;
				}

				half4 frag( v2f i ) : COLOR
				{
					half2 bump;
					float2 offset;
			#ifdef _DISTORTMODE_NORMAL
					bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
					offset = bump * _Refraction;
			#elif _DISTORTMODE_SCREEN
					// Tangent space normals
					 float3 vNormalTs = UnpackNormal(tex2D(_BumpMap, i.vTexCoord0.xy));
					// Tangent space -> World space
					float3 vNormalWs = Vec3TsToWsNormalized( vNormalTs.xyz, i.vNormalWs.xyz, i.vTangentUWs.xyz, i.vTangentVWs.xyz );
					// World space -> View space
					float3 vNormalVs = normalize(mul((float3x3)UNITY_MATRIX_V, vNormalWs));
					// Calculate offset
					offset = vNormalVs.xy * _Refraction;
					offset *= pow(length(vNormalVs.xy), _Power);
					// Scale to pixel size
					offset /= float2(_ScreenParams.x, _ScreenParams.y);
					// Scale with screen depth
					offset /=  i.vPos.z;
			#else
					offset = float2(0,0);
			#endif
					float4 col = tex2Dproj(_GrabTexture, i.uvgrab + float4(offset, 0.0, 0.0));
					return col;
				}
				ENDCG
			}
		}
		FallBack "Legacy Shaders/Transparent/Diffuse"
	}
}
