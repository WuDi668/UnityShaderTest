Shader "Custom/MoreLight/ShadowShader"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse",Color) = (1,1,1,1) //漫反射颜色
        _Specular("Specular",Color) = (1,1,1,1) //高光反射颜色
        _Gloss("Gloss",Range(8.0,256)) = 20 //光泽度 范围8~256 默认值20 控制高光区域大小
    }
    SubShader {
		Tags { "RenderType"="Opaque" }
		//Base Pass
		Pass {
			
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			
			#pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc" //处理阴影用
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				//阴影内置宏
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//阴影处理函数
				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
			 	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	fixed3 halfDir = normalize(worldLightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				//手动计算阴影值和光照衰减
				//fixed atten = 1.0;
				// fixed shadow = SHADOW_ATTENUATION(i);
				// return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);

				//统一计算光照衰减和阴影
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
	    // Addtional Pass
		Pass {
			Tags { "LightMode"="ForwardAdd" }
			
			Blend One One
		
			CGPROGRAM
			
			// Apparently need to add this declaration
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				//阴影内置宏
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				//阴影处理函数
				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				//手动计算阴影值和光照衰减
				// #ifdef USING_DIRECTIONAL_LIGHT
				// 	fixed atten = 1.0;
				// #else
				// 	#if defined (POINT)
				//         float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				//         fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				//     #elif defined (SPOT)
				//         float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				//         fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				//     #else
				//         fixed atten = 1.0;
				//     #endif
				// #endif

				//计算阴影值
				// fixed shadow = SHADOW_ATTENUATION(i);
				// return fixed4((diffuse + specular) * atten * shadow, 1.0);

				//统一计算光照衰减和阴影
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				return fixed4((diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
    }
	Fallback "Specular"
}
