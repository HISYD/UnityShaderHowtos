Shader "ShaderHowtos/Diffuse Frag"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Glow ("Glow", Range(8.0, 200)) = 20.0
        _MainTex ("Main Text", 2D) = "white"{}
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
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldNormal : NORMAL;
            };

            fixed4 _Diffuse;
            float _Glow;
            sampler2D _MainTex; 
            float4 _MainTex_ST;
            
            v2f vert(a2v i)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);

                o.uv = i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(i.texcoord, _MainTex); // built-in 写法，与上面一致

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz); // calculate by hand
                fixed3 worldLight = normalize(WorldSpaceLightDir(i.worldPos)); //built-in function
                
                fixed3 albedo, cDiffuse;
                albedo = tex2D(_MainTex, i.uv);
                // cDiffuse = albedo * _Diffuse.xyz * saturate(dot(worldLight, worldNormal)); // Lambert
                cDiffuse = albedo * _Diffuse.xyz * (0.5 * dot(worldLight, worldNormal) + 0.5); // Half-Lambert

                
                fixed3 cSpecular;
                // fixed3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                fixed3 eyeDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); // built-in function
                fixed3 halfDir = normalize(eyeDir + worldLight);
                cSpecular = _LightColor0 * pow(saturate(dot(halfDir, worldNormal)), _Glow);
                
                fixed3 cAmbient;
                cAmbient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                return fixed4(cAmbient + cDiffuse + cSpecular, 1.0);
                // return fixed4(i.worldNormal, 1.0);
            }
            
            

            
            ENDCG
        }   
        
        
    }
    FallBack "Diffuse"
}
