Shader "ShaderHowtos/S_TangentBumpTexture"
{
    Properties
    {
        _ColorTint ( "ColorTint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("MainTex", 2D) = "White"{}
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8.0, 256.0)) = 20.0
        
        _BumpTex ("BumpTex", 2D) = "White"{}
        _BumpScale ("BumpScale", Range(0.0, 1.0)) = 1.0
    }
    
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _ColorTint;
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;

            
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float3 normal : NORMAL;
                float4 vert : POSITION;

                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;

                float3 tLightDir : TEXCOORD1;
                float3 tViewDir : TEXCOORD2;

            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex); //v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);
                

                // o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float4 worldPos = mul(unity_ObjectToWorld, v.vert);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                float3x3 WtoT= float3x3(worldTangent, worldBinormal, worldNormal);
                o.tLightDir = mul(WtoT, WorldSpaceLightDir(worldPos));
                o.tViewDir  = mul(WtoT, WorldSpaceViewDir(worldPos));
                
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 tLightDir = normalize(i.tLightDir);
                float3 tViewDir = normalize(i.tViewDir);

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
                
                fixed3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                bump *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
                
                fixed3 diffuse = _LightColor0.rgb * albedo * (dot(tLightDir, bump) + 0.5) / 2;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;// * albedo;

                
                fixed3 halfDir = normalize(tViewDir + tLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, bump)), _Gloss);


                
                return fixed4(ambient + diffuse + specular, 1.0);
                // return fixed4(bump, 0.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}