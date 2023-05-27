Shader "ShaderHowtos/Chapter 10/S_Mirror"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "White"{}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
            
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 texcoord : TEXCOORD0;
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
                o.uv  = v.texcoord;
                o.uv.x = 1 - o.uv.x;

                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                f.uv = f.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                fixed3 color = tex2D(_MainTex, f.uv);

                return fixed4(color, 1.0);
            }
            
            ENDCG
        }
    }
    FallBack Off
}
