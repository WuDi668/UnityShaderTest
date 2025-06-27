using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    [SerializeField]
    private Shader briSatConShader;
    private Material briSatConMaterial;

    [SerializeField,Range(0.0f, 3.0f)]
    private float brightness = 1.0f;

    [SerializeField,Range(0.0f, 3.0f)]
    private float saturation = 1.0f;

    [SerializeField,Range(0.0f, 3.0f)]
    private float contrast = 1.0f;

    public Material BriSatConMaterial
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (BriSatConMaterial != null)
        {
            BriSatConMaterial.SetFloat("_Brightness", brightness);
            BriSatConMaterial.SetFloat("_Saturation", saturation);
            BriSatConMaterial.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, BriSatConMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
