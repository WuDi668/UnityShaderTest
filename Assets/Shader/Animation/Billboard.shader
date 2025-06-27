// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Aniamtion/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        //调整是固定法线还是固定指向上（up）的方向 即约束垂直方向的程度 1表示法线方向固定 0表示向上方向固定位（0,1,0）
        _VerticalBillboarding ("Vertical Billboarding", Range(0,1)) = 1 
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching" = "True" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            //关闭深度写入  开启设置混合 关闭剔除
            //这是为了让广告牌的每个面都能显示
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _VerticalBillboarding;

            v2f vert (appdata v)
            {
                v2f o;
                //将模型空间的原点作为锚点，并获取模型空间下的视角位置
                float3 center = float3(0,0,0);
                float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

                //计算三个正交矢量
                float3 normalDir = viewer - center; //法线方向
                normalDir.y = normalDir.y * _VerticalBillboarding; //约束垂直方向的程度
                normalDir = normalize(normalDir); //归一化得到单位矢量

                //计算右矢量和上矢量
                //这只是一个粗略方向，而且要防止与法线方向平行（否则叉积错误），因此还要判断一下得到还是得方向
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0); 
                //归一化得到右矢量
                float3 rightDir = normalize(cross(upDir, normalDir)); 
                //此时的上矢量仍然是不准确的，通过准确的法线方向和右矢量计算出准确的上矢量
                upDir = normalize(cross(normalDir, rightDir)); 

                //完成三个正交矢量的计算后，根据原始位置相对于锚点的偏移量和3个正交矢量计算新的顶点位置
                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
                //记得模型空间的定点位置要变换到裁剪空间中
                o.vertex = UnityObjectToClipPos(float4(localPos,1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
