using System;
using UnityEngine;

//设置编辑器状态下可用，并限定挂载的组件为摄像机
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    #region 资源检查（已废弃）
    /*新版的Unity已经废弃supportsImageEffects，supportsRenderTextures
     也无需再执行判断是否支持纹理渲染的操作
     */


    //protected void CheckResources()
    //{
    //    bool isSupported = CheckSupport();
    //    if (!isSupported)
    //    {
    //        NotSupported();
    //    }
    //}

    //private void NotSupported()
    //{
    //    enabled = false;
    //}

    //private bool CheckSupport()
    //{
    //    if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
    //    {
    //        Debug.LogWarning("This platform does not support image effects or render textures.");
    //        return false;
    //    }

    //    return true;
    //}
    #endregion

    /// <summary>
    /// 
    /// </summary>
    /// <param name="shader"> 该特效需要使用的shader </param>
    /// <param name="material"> 后期处理的材质 </param>
    /// <returns></returns>
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null) return null;
        if (shader.isSupported && material && material.shader == shader) return material;

        if (!shader.isSupported) return null;

        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        if (material) return material;
        else return null;
    }
        
            
        

}
