using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode] //该标记允许脚本在编辑状态下也可使用
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    #region 材质属性
    [SerializeField,SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get
        {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;
    public float blurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_texture = null;

    private void Start()
    {
        if(material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null)
            {
                return;
            }
            //材质为空时获取该脚本物体上的材质
            material = renderer.sharedMaterial;
        }
        UpdateMaterial();
    }

    private void UpdateMaterial()
    {
        if (material != null)
        {
            m_texture = GenerateProceduralTexture();
            material.SetTexture("_MainTex", m_texture);
        }
    }

    //颜色混合
    private Color MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    //绘制三行，每行三个圆形图像
    private Texture2D GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        //间距 半径 模糊系数
        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blurFactor;

        for(int w = 0; w < textureWidth; w++)
        {
            for(int h = 0; h < textureWidth; h++)
            {
                //初始化颜色
                Color pixel = backgroundColor;
                //绘制圆
                for(int i = 0; i < 3; i++)
                {
                    for (int j = 0;j < 3; j++) {
                        //计算圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        //计算圆心距离
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        //模糊圆的边界
                        Color color = MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        //颜色混合
                        pixel = MixColor(pixel, color, color.a);
                    }
                    proceduralTexture.SetPixel(w, h, pixel);
                }
            }
        }
        proceduralTexture.Apply();

        return proceduralTexture;
    }
}
