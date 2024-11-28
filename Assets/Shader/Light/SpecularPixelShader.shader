// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Light/SpecularPixelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse",Color) = (1,1,1,1) //漫反射颜色
        _Specular("Specular",Color) = (1,1,1,1) //高光反射颜色
        _Gloss("Gloss",Range(8.0,256)) = 20 //光泽度 范围8~256 默认值20 控制高光区域大小
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               //环境光
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
               //获取世界坐标下法线
               fixed3 worldNormal = normalize(i.worldNormal);
               //获取光源方向
               fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

               //先计算漫反射
               fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

               //计算高光反射
               //计算反射方向，reflect为CG自带函数，顾名思义计算两向量的反射方向
               //这里计算的是入射光线关于表面法线的反射方向
               fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
               //模型空间位置转换到世界空间 与摄像机位置相减得到视角方向
               fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
               //高光反射光照模型计算
               fixed specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

               return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
