Shader "Custom/Aniamtion/ImageSequenceAnimation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 4 //水平方向关键帧个数
        _VerticalAmount ("Vertical Amount", Float) = 4     //垂直方向关键帧个数
        _Speed ("Speed", Range(1, 100)) = 30 //控制序列帧动播放速度
    }
    SubShader
    {
        //序列帧图一般都带有透明通道，可以当做透明物体渲染
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass
        {
            Tags{ "LightMode"="ForwardBase" }
            //关闭深度写入 开启Alpha混合
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //顶点着色器无需特殊处理
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            fixed4 _Color;

            //顶点着色器无需特殊处理
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            //主要在片元着色器中实现动画效果
            fixed4 frag (v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed); //控制动画播放速度
                float row = floor(time / _HorizontalAmount); //计算当前行数
                float column = time - row * _HorizontalAmount; //计算当前列数

                //索引计算
                //half2 uv = float2(i.uv.x/_HorizontalAmount, i.uv.y/_VerticalAmount);
                //uv.x += column / _HorizontalAmount;
                //uv.y -= row / _VerticalAmount;

                //整合索引计算
                half2 uv = i.uv + half2(column, -row);
                //计算当前帧的UV坐标
                uv.x /= _HorizontalAmount; 
                uv.y /= _VerticalAmount;

                fixed4 col = tex2D(_MainTex, uv); //采样当前帧的颜色
                col.rgb *= _Color.rgb; //颜色乘以颜色调色板
                return col;
            }
            ENDCG
        }
    }

    Fallback "Transparent/VertexLit"
}
