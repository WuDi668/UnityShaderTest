Shader "Custom/WaterUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1) //增加一个颜色参数

        _Amplitude("Amplitude",float) = 0 //幅度参数，主要进行波峰控制
        _WaveLength("WaveLength",float) = 0 //影响正弦函数的周期，控制水波的宽度，相当于角速度
        _WaveSpeed("WaveSpeed",float) = 0 //波浪速度
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //自定义颜色变量，名称与上面属性表一致时获取外部属性值
            fixed4 _Color;
            //波浪相关变量
            float _Amplitude;
            float _WaveLength;
            float _WaveSpeed;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                //正弦波模拟波浪
                float3 p = v.vertex;
                //sin的周期通常是2π 这样处理实现_WaveLength越大，水波宽度越大，即周期越小
                float k = UNITY_PI * 2 / _WaveLength; 
                p.y = _Amplitude * sin(k * (p.x + _WaveSpeed * _Time.y));
                o.vertex = UnityObjectToClipPos(p);
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex); 雾化效果去掉
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //将自定义颜色赋值给给颜色，这样外部修改时才有效果 这里使用= + * 会有不同的效果
                //颜色混合的常用算法是 “+” 和 “*”，“+”对应灯光类发光物体，“*”对应油墨类，不发光物体。
                col = _Color;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);雾化效果去掉
                return col;
            }
            ENDCG
        }
    }
}
