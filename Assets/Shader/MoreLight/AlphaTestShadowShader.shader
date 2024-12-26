Shader "Custom/MoreLight/AlphaTestShadowShader"
{
    Properties
    {
        _Color("Main Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff("Alpha Cutoff",Range(0,1)) = 0.5 //调用clip进行透明度测试时的判断条件，范围为[0,1]
    }
    SubShader
    {
        //将该Shader归入TransparentCutout组 忽略投影器的影响 渲染队列为AlphaTest
        Tags { "RenderType"="TransparentCutout" "IgnoreProjector" = "True" "Queue" = "AlphaTest"}
        LOD 100

        Pass
        {
            //Pass内部标签
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
            fixed _Cutoff;

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

                //透明度测试函数
                clip(texColor.a - _Cutoff);
                //内部实现
                /* if((texColor.a - _Cutoff) < 0.0){
                    discard;
                } */

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));

                return fixed4(ambient + diffuse,1.0);

            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}
