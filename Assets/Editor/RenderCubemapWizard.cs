using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform renderFromPosition;
    public Cubemap cubemap;

    void OnWizardUpdate()
    {
        helpString = "选择要渲染的位置和cubemap";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }

    private void OnWizardCreate()
    {
        //需要临时动态创建一个摄像机以调用相关函数
        GameObject go = new GameObject("CubemapCamera");
        go.AddComponent<Camera>();
        go.transform.position = renderFromPosition.position;
        //RenderToCubemap可以把任意位置观察到的场景图像保存到6张图像中以创建对应的立方体纹理
        go.GetComponent<Camera>().RenderToCubemap(cubemap);
        Debug.Log("Cubemap渲染完成");
        //完成后销毁
        DestroyImmediate(go);
    }

    [MenuItem("GameObject/渲染Cubemap")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>(
            "Render cubemap", "Render!");
    }
}
