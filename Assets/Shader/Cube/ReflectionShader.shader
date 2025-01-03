Shader "Custom/Cube/ReflectionShader"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _ReflectColor("Reflection Color",Color) = (1,1,1,1) //控制反射颜色
        _ReflectAmount("Reflect Amount",Range(0,1)) = 1 //反射程度
        _Cubemap("Reflection Cubemap",Cube) = "_Skybox"{} //环境映射纹理
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
               float4 pos : SV_POSITION;
			   float3 worldPos : TEXCOORD0;
			   fixed3 worldNormal : TEXCOORD1;
			   fixed3 worldViewDir : TEXCOORD2;
			   fixed3 worldRefl : TEXCOORD3;
			   SHADOW_COORDS(4)
            };

            fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _ReflectAmount;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos =  mul(unity_ObjectToWorld,v.vertex).xyz;

                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                //通过reflect函数计算该顶点处的反射方向，物体反射到摄像机的光线方向
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //常规计算各个方向
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));		
				fixed3 worldViewDir = normalize(i.worldViewDir);		
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				
				//使用texCUBE函数进行采样，i.worldRefl没有进行归一化操作，因为这里仅仅是作为方向变量传递给函数的
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;
				
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				//_ReflectAmount混合漫反射颜色和反射颜色
				fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
				
				return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
