Shader "Custom/UnlitShaderTest"
{
    Properties
    {
        // 纹理 Texture 他们的值是black，white，gray等纹理名称
        _Tex2D ("Texture2D", 2D) = "white" {}
        _Tex3D ("Texture3D", 3D) = "black" {}
        _TexCube("TextureCube", Cube) = "" {}
        //Number 类型
        _Int("Int",Int) = 1
        _Float("Float",Float) = 2.5
        _Range("Range",Range(0.0,5.0)) = 3.0
        //四维向量
        _Vector("Vector",Vector) = (1,1,1,1)
        _Color("Color",Color) = (2,3,6,1)


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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
