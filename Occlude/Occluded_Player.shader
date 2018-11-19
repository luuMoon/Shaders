Shader "xcyy/Occluded_Player"
{  
    Properties  
    {  
        _MainTex("Base 2D", 2D) = "white"{}
        _Color ("Main Color", Color) = (1,1,1,1)
        _OccludeColor("Occluded Color", Color) = (1,1,1,1)
    }  
  
    SubShader  
    {  
        LOD 400
        Tags{ "Queue" = "AlphaTest+1" "RenderType" = "Opaque" }  
          
        Pass  
        {  
            Name "OCCLUDED"
            
            Stencil
			{
				Ref 4
				Comp Equal
			}

            Blend SrcAlpha One  
            ZWrite Off  
            ZTest Greater  
            
            CGPROGRAM  
            #include "Lighting.cginc"  
            #pragma vertex vert  
            #pragma fragment frag 

            fixed4 _OccludeColor;

            struct v2f  
            {  
                float4 pos : SV_POSITION;  
            };  
  
            v2f vert (appdata_base v)  
            {  
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                return o;  
            }  
  
            fixed4 frag(v2f i) : SV_Target  
            {  
                return _OccludeColor;
            }  

            ENDCG  
        }  
    }
}  