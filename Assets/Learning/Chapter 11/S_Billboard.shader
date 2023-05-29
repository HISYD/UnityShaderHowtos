Shader "ShaderHowtos/Chapter 11/S_Billboard"
{
    Properties
    {
        _MainTex ("BaseLayer", 2D) = "white" {}
        _Ratio ("Ratio", Range(0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Pass
        {
        
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Ratio;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
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


                float3 centerPos = float3(0,0,0);
                float4 objViewPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                float3 targetNormal = objViewPos - centerPos;
                targetNormal.y = targetNormal.y * _Ratio;
                targetNormal = normalize(targetNormal);

                float3 up = targetNormal.y > 0.99 ? float3(0,0,1) : float3(0,1,0);
                float3 right = normalize(cross(up, targetNormal));
                up = cross(targetNormal, right);

                float3 centerOffsets = v.vertex.xyz - centerPos;
                float3 newPos =
                    centerPos +
                    right * centerOffsets.x +
                    up * centerOffsets.y +
                    targetNormal * centerOffsets.z;
                
                

                
                o.pos = UnityObjectToClipPos(float4(newPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, f.uv);
                return color;                
            }
            
            ENDCG
        }

    }
    FallBack "Diffuse"
}
