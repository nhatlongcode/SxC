Shader "Unlit/Unlit_shader_water_Sand"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _ColorDeep("_Color Deep", Color) = (1,1,1,1)
        _ColorOut("_Color Out", Color) = (1,1,1,1)
        _ColorDeep_Out("_Color Deep Out", Color) = (1,1,1,1)
        _SandColor("_SandColor", Color) = (1,1,1,1)
        [PerRendererData]_MainTex("MainTex", 2D) = "white"{}
        _Noise("Noise", 2D) = "white" {}
        _Noise2("Noise2", 2D) = "white" {}
        [NoScaleOffset] _FlowMap("Flow Map (RG, A noise)", 2D) = "white" {}
        _DerivHeightMap("Deriv (AG) Height (B)", 2D) = "black" {}
        _UJump("U jump per phase", Range(-.25, .25)) = .25
        _VJump("V jump per phase", Range(-.25, .25)) = .25
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Tiling("Tiling", float) = 1
        _Speed("Speed", float) = 1
        _FlowStrength("Flow Strength", float) = 1
        _FlowOffset("Flow Offset", float) = 0
        _HeightScaleConstant("Height Scale, Constant", float) = 1
        _HeightScaleModulated("Height Scale, Modulate", float) = 1
        _LightPosition ("LightPosition", float) = (0, 1 , 0 , 1)
        _Smoothness("Smoothness", Range(0,1)) = .5
        _LightColor("LightColor", Color) = (1,1,1,1)
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        _Alpha("Alpha", Range(0, 10)) = .5
        _TillingOffsetNoise("TillingOffsetNoise", float) = (1,1,1,1)
        _WaveColor1("Wave Color 1", Color) = (1,1,1,1)
        _WaveColor2("Wave Color 2", Color) = (1,1,1,1)
        _WaveMap("Wave Map", 2D) = "gray" {}
        _TillingWaveSmall("Tilling Wave Small", float) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True" }
        LOD 100
            Cull Off
            Lighting Off
            ZWrite Off
            ZTest[unity_GUIZTestMode]
            Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "Flow.cginc"
            #include "UnityStandardUtils.cginc"

            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };
            fixed3 UnpackDerivativeHeight(fixed4 textureData) {
                fixed3 dh = textureData.agb;
                dh.xy = dh.xy * 2 - 1;
                return dh;
            }
            struct v2f
            {
                fixed2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                fixed4 vertex : SV_POSITION;
                fixed3 Normal : NORMAL;
                fixed3 worldPos : TEXCOORD1;
            };
            sampler2D _MainTex, _FlowMap, _DerivHeightMap, _Noise, _Noise2, _WaveMap;
            fixed4 _MainTex_ST, _LightColor, _SpecularColor, _Noise_ST, _TillingOffsetNoise, _WaveColor1, _WaveColor2, _Noise2_ST, _TillingWaveSmall;
            fixed3 _LightPosition;
            half _Glossiness;
            fixed4 _Color, _ColorDeep, _ColorOut, _ColorDeep_Out, _SandColor;
            fixed _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset, _HeightScaleConstant, _HeightScaleModulated, _Smoothness, _Alpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 flow = tex2D(_FlowMap, i.uv).rgb;
                flow.xy = flow.xy * 2 - 1;
                flow *= _FlowStrength/1000;
                fixed3 viewDir = normalize(float3(0, 0, 1) - i.worldPos);
                fixed noise = tex2D(_FlowMap, i.uv).a;
                fixed time = _Time.y * _Speed + noise;
                fixed2 jump = float2(_UJump, _VJump);
                fixed3 uvw_A = FlowUVW(i.uv, flow, jump, _FlowOffset, _Tiling, time, true);
                fixed3 uvw_B = FlowUVW(i.uv, flow, jump, _FlowOffset, _Tiling, time, false);
                fixed3 uvw_C = FlowUVW(i.uv, flow, jump, _FlowOffset, _Tiling, time * .2, true);
                fixed3 uvw_D = FlowUVW(i.uv, flow, jump, _FlowOffset, _Tiling, time * .2, false);
                fixed finalHeighScale = flow.z * _HeightScaleModulated + _HeightScaleConstant;
                fixed3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvw_A.xy)) * (uvw_A.z * finalHeighScale);
                fixed3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvw_B.xy)) * (uvw_B.z * finalHeighScale);
                fixed3 dhC = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvw_C.xy));
                fixed3 dhD = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvw_D.xy));
                fixed4 loadingFakeNormal_A = saturate(dot(_LightPosition.xyz, dhA.rgb));
                fixed4 loadingFakeNormal_B = saturate(dot(_LightPosition.xyz, dhB.rgb));
                fixed3 reflectionDir_A = reflect(float3(0, 0, -1), dhA);
                fixed3 reflectionDir_B = reflect(float3(0, 0, -1), dhB);
                fixed3 albedo_A = tex2D(_Noise, uvw_A.xy) * uvw_A.z;
                fixed3 albedo_B = tex2D(_Noise, uvw_B.xy) * uvw_B.z;
                fixed3 tex_A = albedo_A * loadingFakeNormal_A * _LightColor.rgb;
                fixed3 tex_B = albedo_B * loadingFakeNormal_B * _LightColor.rgb;
                float4 specular_A = (1 - _SpecularColor) * _LightColor * pow(saturate(dot(normalize(_LightPosition + viewDir), loadingFakeNormal_A)), _Smoothness * 100);
                float4 specular_B = (1 - _SpecularColor) * _LightColor * pow(saturate(dot(normalize(_LightPosition + viewDir), loadingFakeNormal_B)), _Smoothness * 100);
                fixed4 c = (((tex_A + tex_B).r * _Color + specular_A) + ((1 - (tex_A + tex_B).r) * _ColorDeep) + specular_B);
                fixed4 c_out = (((tex_A + tex_B).r * _ColorOut + specular_A) + ((1 - (tex_A + tex_B).r) * _ColorDeep_Out) + specular_B);
                fixed4 mainSand = fixed4(tex2D(_MainTex, i.uv).rgb, (tex2D(_MainTex, i.uv).a * _Alpha)) * max(0, 1 - pow(tex2D(_Noise, i.uv).r, 3));
                fixed2 uv_noiseAlpha = i.uv * _TillingOffsetNoise.xy + _TillingOffsetNoise.wz;
                fixed4 waving = lerp(c_out, c, (tex2D(_MainTex, i.uv).g));

                float4 waveFar = (1 - tex2D(_MainTex, i.uv).r) * waving + tex2D(_MainTex, i.uv).r * _SandColor *lerp(c_out, c, (tex2D(_MainTex, i.uv).r)) ;
                float4 waveNear = float4(lerp(_WaveColor1, _WaveColor2, tex2D(_MainTex,i.uv).b).rgb, tex2D(_MainTex,i.uv).b);
                return lerp(waveFar, waveNear * (tex2D(_Noise2, dhC).r + tex2D(_Noise2, dhD).r) + waveFar , tex2D(_MainTex,i.uv).b);
                //return lerp(waveFar, waveNear + waveFar, tex2D(_MainTex,i.uv).b);
                //return waveNear;
            }
            ENDCG
        }
    }
}
