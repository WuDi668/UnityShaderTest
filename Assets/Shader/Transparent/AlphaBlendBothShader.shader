Shader "Custom/Transparent/AlphaBlendBothShader"
{
     Properties
    {
        _Color("Main Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale",Range(0,1)) = 1 //透明度 1表示不透明 0表示完全透明
    }
    SubShader
    {
        //将该Shader归入TransparentCutout组 忽略投影器的影响 渲染队列为Transparent
        Tags { "RenderType"="TransparentCutout" "IgnoreProjector" = "True" "Queue" = "Transparent"}
        LOD 100

        Pass
        {
            //Pass内部标签
            Tags { "LightMode" = "ForwardBase"}

            //关闭深度写入
            ZWrite Off
            //开启颜色混合
            Blend SrcAlpha OneMinusSrcAlpha
            //第一个Pass只渲染背面 剔除正面
            Cull Front

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
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

               fixed4 texColor = tex2D(_MainTex,i.uv);

               fixed3 albedo = texColor.rgb * _Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
               fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

               return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }
            ENDCG
        }

        Pass
        {
            //Pass内部标签
            Tags { "LightMode" = "ForwardBase"}

            //关闭深度写入
            ZWrite Off
            //开启颜色混合
            Blend SrcAlpha OneMinusSrcAlpha
            //第二个Pass只渲染正面 剔除背面
            Cull Back

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
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

               fixed4 texColor = tex2D(_MainTex,i.uv);

               fixed3 albedo = texColor.rgb * _Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
               fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

               return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}
