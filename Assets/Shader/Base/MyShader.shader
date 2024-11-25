
Shader "Custom/MyShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Pass{
            CGPROGRAM

            #pragma vertex my_vert //顶点着色
            //语义绑定 POSITION获取上一个输入的坐标，并将这里的结果传给下一个
            float4 my_vert(float4 pos:POSITION):POSITION{
                return UnityObjectToClipPos(pos);
            }

            #pragma fragment my_frag //片元着色
            //单色着色 Color
            fixed4 my_frag():COLOR{
                return fixed4(1.0,0.0,0.0,1.0); 
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
