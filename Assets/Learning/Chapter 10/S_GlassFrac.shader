Shader "ShaderHowtos/Chapter 10/S_GlassFrac"
{
    Properties
    {   
        _BumpTex ("BumpTex", 2D) = "white" {}
        _DiffuseTex ("DiffuseTex", 2D) = "White" {}
        _ReflCubeMap("ReflTex", Cube) = "White"{}
        
        _Distortion ("Distortion", Range(0, 512)) = 20.0
        _ReFracWeight ("ReFracWeight", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }
        GrabPass{"_ReFracTex"}
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _BumpTex;
            sampler2D _DiffuseTex;
            sampler2D _ReFracTex;
            samplerCUBE _ReflCubeMap;
            float4 _BumpTex_ST;
            float4 _DiffuseTex_ST;
            float2 _ReFracTex_TexelSize;

            float _Distortion;
            float _ReFracWeight;

            //
            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                
                float2 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;

                float4 srcPos : TEXCOORD1;

                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
                float4 TtoW3 : TEXCOORD5;
            };


            //
            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _BumpTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DiffuseTex);

                o.srcPos = ComputeGrabScreenPos(o.pos);

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                fixed3 albedo = tex2D(_DiffuseTex, f.uv.zw).xyz;
                
                fixed3 bump = UnpackNormal(tex2D(_BumpTex, f.uv.xy));
                bump = half3(dot(f.TtoW0.xyz, bump), dot(f.TtoW1.xyz, bump), dot(f.TtoW2.xyz, bump));
                bump = normalize(bump);

                fixed2 RefracSampleOffset = f.srcPos + bump.xy * _Distortion * _ReFracTex_TexelSize.xy;
                f.srcPos.xy = RefracSampleOffset * f.srcPos.z + f.srcPos.xy;
                fixed3 RefracColor = tex2D(_ReFracTex, f.srcPos.xy / f.srcPos.w).rgb;

                fixed3 worldPos = fixed3(f.TtoW0.w, f.TtoW1.w, f.TtoW2.w);
                fixed3 worldNormal = fixed3(f.TtoW0.z, f.TtoW1.z, f.TtoW2.z);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                fixed3 ReflDir = reflect(-worldViewDir, bump);
                fixed3 ReflColor = texCUBE(_ReflCubeMap, ReflDir).rgb * albedo;


                fixed3 color;
                color = lerp(ReflColor, RefracColor, _ReFracWeight);
                
                return fixed4(color, 1);
            }


            
            ENDCG
        }
    }
    FallBack "Transparent"
}
