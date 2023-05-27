Shader "ShaderHowtos/Chapter 9/S_Shadow"
{
    Properties
    {
        _Gloss ("Gloss", Range(8.0, 255.0)) = 20.0
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            
            CGPROGRAM
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            float _Gloss;
            fixed4 _Diffuse;
            fixed4 _Specular;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                float shadow = SHADOW_ATTENUATION(f);

                UNITY_LIGHT_ATTENUATION(atten, f, f.worldPos)
                return fixed4(ambient + atten * shadow * (diffuse + specular), 1.0);
            }

            ENDCG
        }  
    
        Pass
        {
            Tags {"LightMode"="ForwardAdd"}
            Blend One One
            
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag

            

            float _Gloss;
            fixed4 _Diffuse;
            fixed4 _Specular;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldPos));

                fixed3 lightDir;
                #ifdef USING_DIRECTIONAL_LIGHT
                    lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - f.worldPos);
                #endif

                
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);


                UNITY_LIGHT_ATTENUATION(atten, f, f.worldPos)
                // float atten;
                // #ifdef USING_DIRECTIONAL_LIGHT
                //     atten = 1.0;
                // #else
                //     #if defined(POINT)
                //         float3 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1)).xyz;
                //         atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL; 
                //     #elif defined(SPOT)
                //         float4 lightCoord = mul(unity_WorldToLight, float4(f.worldPos, 1));
                //         atten =
                //             (lightCoord.z > 0)
                //             * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w
                //             * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                //     #endif
                // #endif


                
                return fixed4(atten * (diffuse + specular), 1.0);
            }

            ENDCG
        }
        

        
            
    }
    
    Fallback "Specular"   
}