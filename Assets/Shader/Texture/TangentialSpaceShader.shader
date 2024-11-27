Shader "Custom/TangentialSpaceShader"
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
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
                //保存两个纹理坐标
                o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                //从世界坐标切换到切线空间，可直接用内置宏，内部实现如下
                //float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
                //float3x3 rotation = float3x3(v.tangent.xyz,binormak,v.normal);
                //内置宏
                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                fixed3 tangentNormal;

                //如果Unity没有设置该纹理为Normal map，就需要手动处理：
                //tangentNormal.xy = (packedNormal.xy *2-1) * _BumpScale
                //tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                //我们已经设置好了法线贴图，所以可以直接用内置函数反映射
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                //计算光照
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);

                return fixed4(ambient + diffuse + specular,1.0);

            }
            ENDCG
        }
    }
    Fallback "Specular"
}
