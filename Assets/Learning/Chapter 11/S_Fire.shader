Shader "ShaderHowtos/Chapter 11/S_Fire"
{
    Properties
    {
        _MainTex ("BaseLayer", 2D) = "white" {}
        _VerticalNum ("VerticalNum", float) = 12.0
        _HorizontalNum ("HorizontalNum", float) = 6.0
        _Speed ("Speed", Range(0, 100.0)) = 100
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
        
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _VerticalNum;
            float _HorizontalNum;
            int _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                float frameCount = _HorizontalNum * _VerticalNum;
                float frame = floor(_Time.y * _Speed);
                
                //scale
                f.uv.x /= _HorizontalNum;
                f.uv.y /= _VerticalNum;

                f.uv.x += frac(frame / _HorizontalNum);
                f.uv.y += floor(frame / _HorizontalNum) / _VerticalNum;
                
                fixed4 color = tex2D(_MainTex, f.uv);
                
                // color = fixed4(f.uv, 0, 1);
                return color;                
            }
            
            ENDCG
        }

    }
    FallBack "Diffuse"
}
