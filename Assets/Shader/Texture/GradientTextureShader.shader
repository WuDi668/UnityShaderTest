Shader "Custom/GradientTextureShader"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _RampTex ("Texture", 2D) = "white" {}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _RampTex;
            float4 _RampTex_ST;

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            { 
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

               //半兰伯特模型处理纹理
               fixed halfLambert = saturate(dot(worldNormal,worldLightDir) * 0.5 + 0.5);
               fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;

               fixed diffuse = _LightColor0.rgb * diffuseColor;

               fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
               fixed3 halfDir = normalize(worldLightDir + viewDir);
               fixed specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

               return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
