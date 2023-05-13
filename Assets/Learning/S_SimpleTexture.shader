Shader "ShaderHowtos/S_SimpleTexture"
{
    Properties
    {
        _ColorTint ( "ColorTint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("MainTex", 2D) = "White"{}
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8.0, 256.0)) = 20.0
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
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float3 normal : NORMAL;
                float4 vert : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;

                //
                float3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vert);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));

                // fixed3 diffuse = saturate(dot(worldLightDir, worldNormal));
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * (dot(worldLightDir, worldNormal) + 0.5) / 2;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;// * albedo;

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);


                
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}