Shader "xcyy/Occluder"
{ 
    SubShader {
        LOD 400
        Pass{
            Tags {"Queue"="AlphaTest"}
            ColorMask 0 ZWrite Off
            Stencil
	        {
		        Ref 4
		        Comp Always
                Pass Replace
	        }
        }
    }
}
