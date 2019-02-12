using System;
using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;
using Object = UnityEngine.Object;
#if UNITY_EDITOR
using System.Reflection;
#endif

namespace FrameWork
{
	public class ApplyShader : MonoBehaviour
	{
		// Use this for initialization
		public void Start ()
		{
			ResetShader(gameObject);
		}

		public static ApplyShader CheckShader(Object o)
		{
			GameObject go = o as GameObject;
			if(null!=go)
			{
                ApplyShader comp = go.GetComponent<ApplyShader>();
                if (comp == null)
                    comp = go.AddComponent<ApplyShader>();
                return comp;
			}
            return null;
		}

		public static void CheckShader(Material m)
		{
			if(null!=m &&null!=m.shader)
				m.shader = Shader.Find(m.shader.name);
		}

		private void ResetShader(GameObject go)
		{
			List<Renderer> renders = null;
            Utils.GetComponent(go, ref renders);
            Dictionary<Material, string> materialShaders = new Dictionary<Material, string>();
            for (int i = 0; i < renders.Count; ++i)
            {
                Material[] materials = renders[i].sharedMaterials;
                if (materials == null)
                    continue;
                for (int j = 0; j < materials.Length; ++j)
                {
                    Material m = materials[j];
                    if (null != m && !materialShaders.ContainsKey(m))
                        materialShaders.Add(m, m.shader.name);
                }
            }
            List<Graphic> graphics = null;
            Utils.GetComponent(go, ref graphics);
            for (int i = 0; i < graphics.Count; ++i)
            {
                Material m = graphics[i].material;
                if (null != m && !materialShaders.ContainsKey(m))
                    materialShaders.Add(m, m.shader.name);
            }
			
			foreach(KeyValuePair<Material,string> element in materialShaders)
			{
#if UNITY_EDITOR
				int rawRQ = GetMaterialRawRQFromShader(element.Key);
#endif
				element.Key.shader = Shader.Find(element.Value);
#if UNITY_EDITOR
				if (rawRQ != -1)
					element.Key.renderQueue = rawRQ;
#endif
			}

		}

		#if UNITY_EDITOR
		private static MethodInfo getMaterialRawRQMethod;
		private static MethodInfo getGetMaterailRawRQMethod()
		{
			if (null == getMaterialRawRQMethod)
			{
				Assembly asm = Assembly.GetAssembly(typeof(UnityEditor.Editor));
				Type type = asm.GetType("UnityEditor.ShaderUtil");
				getMaterialRawRQMethod = type.GetMethod("GetMaterialRawRenderQueue", BindingFlags.Static | BindingFlags.NonPublic);
			}

			return getMaterialRawRQMethod;
		}

		private static int GetMaterialRawRQFromShader(Material m)
		{
			MethodInfo methodInfo = getGetMaterailRawRQMethod(); 
			System.Object result = methodInfo.Invoke(null, new[] {m});
			return (int) result;
		}
		#endif
	}
}

