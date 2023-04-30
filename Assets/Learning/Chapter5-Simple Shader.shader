Shader "Custom/Chapter5-Simple Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            struct a2v
            {
                float4 pos : POSITION;
            };

            float4 vert(a2v i) : SV_POSITION
            {
                return UnityObjectToClipPos(i.pos);
            }

            float4 frag() : SV_Target
            {
                return float4(1.0, 1.0, 1.0, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
