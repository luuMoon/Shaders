// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UICustom/ImageFlashEffect2"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        _LightTex ("Light Texture", 2D) = "white" {}

        _LightColor("Light Color",Color) = (1,1,1,1)

        _LightPower("Light Power",Range(0,5)) = 1

        //每次持续时间，受Angle和Scale影响
        _LightDuration("Light Duration",Range(0,10)) = 1
        //时间间隔，受Angle和Scale影响
        _LightInterval("Light Interval",Range(0,20)) = 3
    }

    SubShader
    {
        Tags 
        {
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        Offset -1, -1
        Blend SrcAlpha OneMinusSrcAlpha 
        AlphaTest Greater 0.1

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 lightuv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _LightTex ;
            float4  _LightTex_ST;

            float _LightInterval;
            float _LightDuration;

            half4 _LightColor;
            float _LightPower;

            float _LightOffSetX ;
            float _LightOffSetY ;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed currentTimePassed = fmod(_Time.y,_LightInterval);//0～_LightInterval
                fixed offsetX = currentTimePassed/_LightDuration;
                fixed offsetY = currentTimePassed/_LightDuration;
                fixed2 offset = fixed2(offsetX - 1.8f,offsetY - 0.5f);
                o.lightuv = v.uv  + offset;
                o.uv=TRANSFORM_TEX(v.uv, _MainTex);
                o.lightuv=TRANSFORM_TEX(o.lightuv, _LightTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainCol   = tex2D(_MainTex, i.uv);
                fixed4 lightCol  = tex2D(_LightTex, i.lightuv);
                lightCol *= _LightColor ;

                //need blend
                //lightCol.rgb *= mainCol.rgb ;
                fixed4 fininalCol ;
                fininalCol.rgb   = mainCol.rgb +  lightCol.rgb * _LightPower;
                fininalCol.a =  mainCol.a * lightCol.a ;
                return fininalCol ;
            }
            ENDCG
        }
    }
}