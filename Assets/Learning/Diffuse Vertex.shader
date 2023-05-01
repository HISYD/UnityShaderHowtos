Shader "ShaderHowtos/Diffuse Vertex"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION; 
                float3 normal : NORMAL;

            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            fixed4 _Diffuse;

            
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuseResult = _Diffuse.xyz * saturate(dot(worldLight, worldNormal));
                o.color = ambient + diffuseResult;


                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            

            
            ENDCG
        }   
        
        
    }
    FallBack "Diffuse"
}
