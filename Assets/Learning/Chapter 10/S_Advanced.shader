Shader "ShaderHowtos/Chapter 10/S_Advanced"
{
    Properties
    {
        _Gloss ("Gloss", Range(8.0, 255.0)) = 20.0
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        
        _ReflCube ("ReflCube", Cube) = "_Skybox"{}
        _ReflColor ("ReflColor", Color) = (1,1,1,1)
        _ReflAmount ("ReflAmount", Range(0.0, 1.0)) = 0.2 
        
        _FresnelScale ("FresnelScale", Range(0.0, 1.0)) = 0.5
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
            
            samplerCUBE _ReflCube;
            fixed4 _ReflColor;
            float _ReflAmount;

            fixed _FresnelScale;

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

                fixed3 worldViewDir : TEXCOORD3;
                fixed3 worldRefl : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                TRANSFER_SHADOW(o);

                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
                
                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed3 worldNormal = normalize(f.worldNormal);
                fixed3 viewDir = normalize(f.worldViewDir);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                
                UNITY_LIGHT_ATTENUATION(atten, f, f.worldPos)
                atten = lerp(atten, 1, 0.2);
                
                fixed3 reflection = texCUBE(_ReflCube, f.worldRefl).rgb * _ReflColor.rgb;
                
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(viewDir, worldNormal), 5);
                
                //
                fixed3 color;
                // color = ambient + atten * lerp((diffuse + specular), reflection, _ReflAmount);
                color = ambient + lerp(diffuse + specular, reflection, saturate(fresnel)) * atten;

                    
                return fixed4(color, 1.0);
                // return fixed4(ambient + atten * shadow * lerp((diffuse + specular), reflection, _ReflAmount), 1.0);
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
                
                return fixed4(atten * (diffuse + specular), 1.0);
            }

            ENDCG
        }
//        

        
            
    }
    
    Fallback "Specular"   
}