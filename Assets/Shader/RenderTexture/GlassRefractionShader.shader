Shader "Custom/RenderTexture/GlassRefraction"
{
    //Properties
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}  //玻璃材质纹理
        _Cubemap ("EM", Cube) = "_Skybox" {}
        _BumpMap ("Bump Map", 2D) = "bump" {}  //玻璃法线纹理
        //control the distortion of refraction
        _Distortion ("Distortion", range(0, 1000)) = 10
        _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
    }
    
    SubShader {
        // 渲染队列必须是透明层，这样才能在所有不透明几何体之后绘制自己
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }
 
        /*
        GrabPass是一种特殊的通道，
        他把即将绘制对象时的屏幕内容抓取到纹理中，
        后续通道就可以使用此纹理了，在玻璃效果中，
        他可以用于扭曲纹理模拟折射，从而模拟透过玻璃看物体的效果
        */
        GrabPass {"_RefractionTex"}
 
        Pass {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
 
            //Properties
            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _Cubemap;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _Distortion;
            fixed _RefractAmount;
            //定义GrabPass函数指定的变量
            sampler2D _RefractionTex;
            //该变量可获取纹素的大小
            float4 _RefractionTex_TexelSize; 
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            };
 
            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                float4 srcPos : TEXCOORD4;
            };
 
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
 
                //抓取屏幕图像的采样坐标
                o.srcPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
 
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                float3 worldTangent = UnityObjectToWorldNormal(v.tangent).xyz;
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
 
                //计算切线空间 -> 世界空间的矩阵，只需要3x3
                //按列摆放
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
 
                return o;
            }
 
            fixed4 frag(v2f i) :SV_Target {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                //计算光照需要参数：
                fixed3 worldlightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldviewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                //对纹理采样+解码，得到法线方向
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                
                //由于这里需要模拟的是玻璃的折射效果，因此不能是这种常规的法线纹理的偏移：
                //bump.xy *= _BumpScale;
                //bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
 
                //开始实现折射效果
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.srcPos.xy = offset + i.srcPos.xy;
                //采样得到“折射”颜色:
                fixed3 refractColor = tex2D(_RefractionTex, i.srcPos.xy/i.srcPos.w).rgb;
 
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
 
                //开始环境映射：
                fixed3 reflectDir = reflect(-worldviewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflectColor = texCUBE(_Cubemap, reflectDir).rgb * texColor.rgb;
 
                fixed3 finalColor = reflectColor * (1 - _RefractAmount) + refractColor * _RefractAmount;
                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack  "Diffuse"
}