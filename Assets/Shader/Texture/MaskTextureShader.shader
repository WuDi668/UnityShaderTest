Shader "Custom/Texture/MaskTextureShader"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        _BumpMap("Normal Map",2D) = "bump" {}
        _BumpScale("Bump Scale",Float) = 1.0

        _SpecularMask("Specular Mask",2D) = "white" {}//遮罩纹理
        _SpecularScale("Specular Scale",Float) = 1.0
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
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 lightDir: TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                //高光反射遮罩采样
                fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
