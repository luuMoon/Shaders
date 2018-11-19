Shader "xcyy/Terrain/Standard" {
    Properties {
        // set by terrain engine
         _Control ("Control (RGBA)", 2D) = "red" {}
        _Splat3 ("Layer 3 (A)", 2D) = "white" {}
         _Splat2 ("Layer 2 (B)", 2D) = "white" {}
         _Splat1 ("Layer 1 (G)", 2D) = "white" {}
         _Splat0 ("Layer 0 (R)", 2D) = "white" {}
         _Normal3 ("Normal 3 (A)", 2D) = "bump" {}
         _Normal2 ("Normal 2 (B)", 2D) = "bump" {}
         _Normal1 ("Normal 1 (G)", 2D) = "bump" {}
         _Normal0 ("Normal 0 (R)", 2D) = "bump" {}
         [Gamma] _Metallic0 ("Metallic 0", Range(0.0, 1.0)) = 0.0
         [Gamma] _Metallic1 ("Metallic 1", Range(0.0, 1.0)) = 0.0
         [Gamma] _Metallic2 ("Metallic 2", Range(0.0, 1.0)) = 0.0
         [Gamma] _Metallic3 ("Metallic 3", Range(0.0, 1.0)) = 0.0
         _Smoothness0 ("Smoothness 0", Range(0.0, 1.0)) = 1.0
         _Smoothness1 ("Smoothness 1", Range(0.0, 1.0)) = 1.0
         _Smoothness2 ("Smoothness 2", Range(0.0, 1.0)) = 1.0
         _Smoothness3 ("Smoothness 3", Range(0.0, 1.0)) = 1.0

        // used in fallback on old cards & base map
        [HideInInspector]_MainTex ("BaseMap (RGB)", 2D) = "white" {}
        [HideInInspector]_Color ("Emission Color", Color) = (1,1,1,1)
        _HSVRangeMin ("HSV Affect Range Min", Range(0, 1)) = 0
        _HSVRangeMax ("HSV Affect Range Max", Range(0, 1)) = 1
        _HSVAAdjust ("HSVA Adjust", Vector) = (0, 0, 0, 0)
    }

    SubShader {
        LOD 400
        Tags {
            "Queue" = "Geometry-100"
            "RenderType" = "Opaque"
        }

        CGPROGRAM
        #pragma surface surf Standard vertex:SplatmapVert finalcolor:SplatmapFinalColor finalgbuffer:SplatmapFinalGBuffer fullforwardshadows noinstancing
        #pragma multi_compile_fog
        #pragma target 3.0
        // needs more than 8 texcoords
        #pragma exclude_renderers gles psp2
        #include "UnityPBSLighting.cginc"

        #define _TERRAIN_NORMAL_MAP
        #define TERRAIN_STANDARD_SHADER
        #define TERRAIN_SURFACE_OUTPUT SurfaceOutputStandard
        #include "TerrainSplatmapCommon.cginc"

        #include "../CgIncludes/HsvCompute.cginc"

        half _Metallic0;
        half _Metallic1;
        half _Metallic2;
        half _Metallic3;

        half _Smoothness0;
        half _Smoothness1;
        half _Smoothness2;
        half _Smoothness3;

        uniform float4 _Color;
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            half4 splat_control;
            half weight;
            fixed4 mixedDiffuse;
            half4 defaultSmoothness = half4(_Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3);
            SplatmapMix(IN, defaultSmoothness, splat_control, weight, mixedDiffuse, o.Normal);
            float3 hsv = rgb2hsv(mixedDiffuse.rgb);
            float affectMult = step(_HSVRangeMin, hsv.r) * step(hsv.r, _HSVRangeMax);
            float3 hsvColor = hsv2rgb(hsv + _HSVAAdjust.xyz * affectMult);
            o.Albedo = hsvColor;
            o.Alpha = weight;
            o.Smoothness = mixedDiffuse.a;
            o.Metallic = dot(splat_control, half4(_Metallic0, _Metallic1, _Metallic2, _Metallic3));
        }
        ENDCG
        
    }

SubShader {
        Tags {
            "Queue" = "Geometry-100"
            "RenderType" = "Opaque"
        }

    CGPROGRAM
        #pragma surface surf Lambert vertex:SplatmapVert finalcolor:SplatmapFinalColor finalprepass:SplatmapFinalPrepass finalgbuffer:SplatmapFinalGBuffer noinstancing
        #pragma multi_compile_fog
        #include "TerrainSplatmapCommon.cginc"
        #include "../CgIncludes/HsvCompute.cginc"

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 splat_control;
            half weight;
            fixed4 mixedDiffuse;
            SplatmapMix(IN, splat_control, weight, mixedDiffuse, o.Normal);
            float3 hsv = rgb2hsv(mixedDiffuse.rgb);
            float affectMult = step(_HSVRangeMin, hsv.r) * step(hsv.r, _HSVRangeMax);
            float3 hsvColor = hsv2rgb(hsv + _HSVAAdjust.xyz * affectMult);
            o.Albedo = mixedDiffuse.rgb;
            o.Alpha = weight;
        }
    ENDCG
    }

    Dependency "AddPassShader" = "Hidden/TerrainEngine/Splatmap/Standard-AddPass"
    Dependency "BaseMapShader" = "Hidden/TerrainEngine/Splatmap/Standard-Base"

    Fallback "Nature/Terrain/Diffuse"
}
