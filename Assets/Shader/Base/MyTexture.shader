Shader "Custom/MyTextureShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Pass{
        CGPROGRAM
        
        #pragma vertex my_vert
        #pragma fragment my_frag
        //定义sampler2D保存贴图
        sampler2D _MainTex;
        //定义结构体appdata，输入到顶点着色器
        struct appdata{
            float4 vertex:POSITION;
            float2 uv:TEXCOORD0;
        };
        //定义结构体appdata，输入到片元着色器
        struct v2f{
            float2 uv:TEXCOORD0;
            float4 vertex:SV_POSITION;
        };
        //顶点着色器获取顶点信息和贴图信息
        v2f my_vert(appdata v){
            v2f _v2f;
            _v2f.vertex = UnityObjectToClipPos(v.vertex);
            //引入#include "UnityCG.cginc"时可以这样写 _v2f.uv = TRANSFORM_TEX(v.uv, _MainTex); 但是注意，需要定义参数float4 _MainTex_ST,否则报错
            _v2f.uv = v.uv; 
            return _v2f;
        }
        //数据传递到这里，用tex2D进行采样
        fixed4 my_frag(v2f _v2f):SV_Target{
            fixed4 _color = tex2D(_MainTex,_v2f.uv);
            return _color;
        }

        ENDCG
       
        }
    }
    FallBack "Diffuse"
}
