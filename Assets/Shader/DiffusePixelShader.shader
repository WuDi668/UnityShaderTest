Shader "Unlit/DiffusePixelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse",Color) = (1,1,1,1) //光照参数
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
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
                float2 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);

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
                //漫反射光照模型计算
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                fixed3 color = ambient + diffuse;

                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}
