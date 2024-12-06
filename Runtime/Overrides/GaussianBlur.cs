using System;

namespace UnityEngine.Rendering.Universal
{
    //决定Volume菜单里面显示的名字，类名则是
    [Serializable, VolumeComponentMenuForRenderPipeline("Post-processing/Gaussian Blur", typeof(UniversalRenderPipeline))]
    public sealed class GaussianBlur : VolumeComponent, IPostProcessComponent
    {
        [Header("高斯模糊")]
        [Tooltip("模糊迭代次数(勾选后模糊才生效)")]
        //overrideState设置为true，才可以实现这个组件初始化的时候就是被勾选状态的效果。
        public ClampedIntParameter iterations = new ClampedIntParameter(0, 1, 16, true);

        public bool IsActive() => iterations.value > 0f;

        public bool IsTileCompatible() => false;
    }
}
