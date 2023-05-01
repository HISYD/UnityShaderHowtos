Shader "Custom/Chapter5-Simple Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _VizSwitcher ("VizType", int) = 1
    }
    SubShader
    {
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            int _VizSwitcher;

            // struct a2v
            // {
            //     float3 normal : NORMAL;
            //     float4 vertex : POSITION;
            //     fixed4 color : COLOR0;
            // };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR0;
            };
            
            
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                switch (_VizSwitcher)
                {
                case 0:
                    o.color = fixed4(1, 1,1,1);
                    break;
                case 1:
                    o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                    break;
                case 2:
                    fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                    o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                    break;
                case 3:
                    o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
                    break;
                }
                

                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
                // return fixed4(1.0,1.0,1.0,1.0);
            }


            ENDCG
        }
    }
    FallBack "Diffuse"
}
