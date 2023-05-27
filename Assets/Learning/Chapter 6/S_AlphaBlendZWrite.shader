Shader "ShaderHowtos/S_AlphaBlendZWrite"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "White"{}
        _AlphaClamp("AlphaClamp", Range(0.0, 1.0)) = 1.0
        _AlphaScaler("AlphaScaler", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        
        Pass
        {
            ZWrite On
            ColorMask 0
            }
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaClamp;
            float _AlphaScaler;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, f.uv);
                
                float3 lightDir = normalize(UnityWorldSpaceLightDir(f.pos));
                fixed3 diffuse = texColor.rgb * saturate(dot(f.normal, lightDir) * 0.5 + 0.5);

                // return fixed4(1.0, 1.0, 1.0, texColor.a * _AlphaScaler);
                return fixed4(diffuse, texColor.a * _AlphaScaler);
            }


            ENDCG
        }
    }
    FallBack "Transparent/VertexList"
}
