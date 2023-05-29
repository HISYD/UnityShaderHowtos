Shader "ShaderHowtos/Chapter 11/S_Scrolling"
{
    Properties
    {
        _LayerATex ("LayerA", 2D) = "white" {}
        _LayerBTex ("LayerB", 2D) = "white" {}
        _Speed ("Speed", Range(0.0, 100.0)) = 50.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
        
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _LayerATex;
            sampler2D _LayerBTex;
            float4 _LayerATex_ST;
            float4 _LayerBTex_ST;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _LayerATex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _LayerBTex);

                o.uv.x += _Time.y / _Speed;
                o.uv.z += _Time.y / _Speed;
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed4 colorA = tex2D(_LayerATex, f.uv.xy);
                fixed4 colorB = tex2D(_LayerBTex, f.uv.zw);
                fixed4 color = lerp(colorA, colorB, colorB.a);
                return color;
                return fixed4(1,1,1,1);
            }
            
            ENDCG
        }

    }
    FallBack "Diffuse"
}
