Shader "Custom/WorldSpaceNormalShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1) //高光反射颜色
        _Gloss("Gloss",Range(8.0,256)) = 20 //光泽度 范围8~256 默认值20 控制高光区域大小
        _BumpMap("Bump Map",2D) = "bump"{} //凹凸贴图
        _BumpScale("Bump Scale",Float) = 1.0 //凹凸程度 0表示不会对光照产生任何影响
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
                float4 uv : TEXCOORD0;
                float3 normal :NORMAL;
                float4 tangent :TANGENT; //切线变量
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //用于保存变换矩阵的三个变量
                float4 TtoW0:TEXCOORD1;
                float4 TtoW1:TEXCOORD2;
                float4 TtoW2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _BumpMap;
            float _BumpScale;
            //凹凸贴图也需要获得纹理属性
            float4 _BumpMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                //获取世界坐标下的顶点坐标 法线 切线 副切线
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
                //将变换矩阵的每一行分别保存到TtoW0 TtoW1 TtoW2
                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
                //将法线变换到世界空间下
                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                 //计算光照
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump,lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump,halfDir)),_Gloss);

                return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
