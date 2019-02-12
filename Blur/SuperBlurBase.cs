//模糊效果
//a.通过interpolation和kernel确定模糊半径及采样点
//kernel:迭代次数-> small:offset1, middle:offset2, big:offset3
//interpolation: 半径大小
//iterations: 迭代次数
//Model:Screen:正常Screen，UI：screen+UI，OnlyUI:Screen不渲染,之下u内燃UI
//superFast速度快的原因: https://forum.unity.com/threads/post-process-mobile-performance-alternatives-to-graphics-blit-onrenderimage.414399/
//-->使用OnRenderImage,如果camera没有targetTexture,则使用ReadPixel从GPU抓取像素
using UnityEngine;

namespace FrameWork
{
	[ExecuteInEditMode]
	public class SuperBlurBase : MonoBehaviour
	{
		protected static class Uniforms
		{
			public static readonly int _Radius = Shader.PropertyToID("_Radius");
			public static readonly int _BackgroundTexture = Shader.PropertyToID("_SuperBlurTexture");
		}

		public RenderMode renderMode = RenderMode.Screen;

		public BlurKernelSize kernelSize = BlurKernelSize.Small;

		[Range(0f, 1f)]
		public float interpolation = 1f;

		[Range(0, 4)]
		public int downsample = 1;

		[Range(1, 8)]
		public int iterations = 1;

		public bool gammaCorrection = false;

        public bool screenGray = false;

		public Material blurMaterial;

		public Material UIMaterial;


		protected void Blur (RenderTexture source, RenderTexture destination)
		{
			if (gammaCorrection)
			{
				Shader.EnableKeyword("GAMMA_CORRECTION");
			}
			else
			{
				Shader.DisableKeyword("GAMMA_CORRECTION");
			}

            if(screenGray)
            {
                Shader.EnableKeyword("SCREEN_GRAY");
            }
            else
            {
                Shader.DisableKeyword("SCREEN_GRAY");
            }

            int kernel = 0;

			switch (kernelSize)
			{
			case BlurKernelSize.Small:
				kernel = 0;
				break;
			case BlurKernelSize.Medium:
				kernel = 2;
				break;
			case BlurKernelSize.Big:
				kernel = 4;
				break;
			}

			var rt2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

			for (int i = 0; i < iterations; i++)
			{
				// helps to achieve a larger blur
				float radius = (float)i * interpolation + interpolation;
				blurMaterial.SetFloat(Uniforms._Radius, radius);

				Graphics.Blit(source, rt2, blurMaterial, 1 + kernel);
				source.DiscardContents();

				// is it a last iteration? If so, then blit to destination
				if (i == iterations - 1)
				{
					Graphics.Blit(rt2, destination, blurMaterial, 2 + kernel);
				}
				else
				{
					Graphics.Blit(rt2, source, blurMaterial, 2 + kernel);
					rt2.DiscardContents();
				}
			}

			RenderTexture.ReleaseTemporary(rt2);
		}
			
	}
	
	public enum BlurKernelSize
	{
		Small,
		Medium,
		Big
	}

	public enum RenderMode
	{
		Screen,
		UI,
		OnlyUI
	}

}
