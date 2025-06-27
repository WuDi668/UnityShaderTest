Shader "Custom/Aniamtion/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Magnitude("Distortion Magnitude",Float) = 1 //水流波动幅度
        _Frequency("Distortion Frequency",Float) = 1 //波动频率
        _InvWaveLength("Distortion Inverse Wave Length",Float) = 10 //波长倒数，该值越大，波动幅度越小
        _Speed("Speed",Float) = 0.5
    }
    SubShader
    {
        
        //DisableBatching禁止对该SubShader进行批处理
        //批处理会合并相关模型，导致各自的模型空间丢失，该示例需要模型空间下对顶点位置的偏移
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching" = "True" }
        LOD 100

        Pass
        {
         
            Tags{"LightMode" = "ForwardBase"}

            //关闭深度写入  开启设置混合 关闭剔除
            //这是为了让水流的每个面都能显示
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
            float4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;

                float4 offset;
                offset.yzw = float3(0.0,0.0,0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength+ v.vertex.z * _InvWaveLength)*_Magnitude;

                o.vertex = UnityObjectToClipPos(v.vertex + offset); //记得加上偏移量
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv += float2(0.0,_Time.y * _Speed);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
