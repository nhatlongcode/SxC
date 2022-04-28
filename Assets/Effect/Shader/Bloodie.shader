// Custom Inputs are X = Pan Offset, Y = UV Warp Strength, Z = Gravity
// Specular Alpha is used like a metalness control. High values are more like dielectrics, low are more like metals
// Subshader at the bottom is for Shader Model 2.0 and OpenGL ES 2.0 devices

Shader "Particles/Bloodie"
{
	Properties
	{
		[Header(Color Controls)]
		[HDR] _BaseColor("Base Color Mult", Color) = (1,1,1,1)
		_LightStr("Lighting Strength", float) = 1.0
		_AlphaMin("Alpha Clip Min", Range(-0.01, 1.01)) = 0.1
		_AlphaSoft("Alpha Clip Softness", Range(0,1)) = 0.1
		_EdgeDarken("Edge Darkening", float) = 1.0
		_ProcMask("Procedural Mask Strength", float) = 1.0

		[Header(Mask Controls)]
		_MainTex("Mask Texture", 2D) = "white" {}
		_MaskStr("Mask Strength", float) = 0.7
		_Columns("Flipbook Columns", Int) = 1
		_Rows("Flipbook Rows", Int) = 1
		_ChannelMask("Channel Mask", Vector) = (1,1,1,0)
		[Toggle] _FlipU("Flip U Randomly", float) = 0
		[Toggle] _FlipV("Flip V Randomly", float) = 0

		[Header(Noise Controls)]
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseAlphaStr("Noise Strength", float) = 1.0
		_ChannelMask2("Channel Mask",Vector) = (1,1,1,0)
		_Randomize("Randomize Noise", float) = 1.0

		[Header(UV Warp Controls)]
		_WarpTex("Warp Texture", 2D) = "gray" {}
		_WarpStr("Warp Strength", float) = 0.2

		[Header(Vertex Physics)]
		_FallOffset("Gravity Offset", range(-1,0)) = -0.5
		_FallRandomness("Gravity Randomness", float) = 0.25

		//specular stuff//
		[HDR] _SpecularColor("Reflection Color Mult", Color) = (1,1,1,0.5)
		_ReflectionTex("Reflection Texture", 2D) = "black" {}
		_ReflectionSat("Reflection Saturation", float) = 0.5
		[NoScaleOffset][Normal] _Normal("Reflection Normalmap", 2D) = "bump" {}
		_FlattenNormal("Flatten Reflection Normal", float) = 2.0

	}

		SubShader
			{
				Tags
				{
					"RenderPipeline" = "UniversalPipeline"
					"Queue" = "Transparent"
					"RenderType" = "Transparent"
					"CanUseSpriteAtlas" = "True"
				}

				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off

				Pass
				{
				HLSLPROGRAM
					#pragma vertex vert
					#pragma fragment frag

				// Required to compile gles 2.0 with standard srp library
				#pragma prefer_hlslcc gles
				#pragma exclude_renderers d3d11_9x
				#pragma target 2.0			

				#pragma multi_compile _ SPECULAR_REFLECTION_ON SPECULAR_REFLECTION_OFF

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

				/// Properties ///
					/// Color Controls ///
					half4 _BaseColor;
					half4 _SpecularColor;
					half _LightStr;
					half _AlphaMin;
					half _AlphaSoft;
					half _EdgeDarken;
					half _ProcMask;

					/// Mask Controls ///
					sampler2D _MainTex; float4 _MainTex_ST;
					half _MaskStr;
					half _Columns;
					half _Rows;
					half4 _ChannelMask;
					half _FlipU;
					half _FlipV;

					sampler2D _ReflectionTex; float4 _ReflectionTex_ST;
					half _ReflectionSat;

					/// Noise Controls ///
					sampler2D _NoiseTex; float4 _NoiseTex_ST;
					half _NoiseAlphaStr;
					half _NoiseColorStr;
					half4 _ChannelMask2;
					#ifdef SPECULAR_REFLECTION_ON
					sampler2D _Normal;
					half _FlattenNormal;
					#endif
					half _Randomize;

					/// UV Warp Controls ///
					sampler2D _WarpTex; float4 _WarpTex_ST;
					half _WarpStr;

					/// Vertex Physics ///
					half _FallOffset;
					half _FallRandomness;

				struct appdata_t
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord0 : TEXCOORD0; // Z is Random, W is Lifetime
					float3 texcoord1 : TEXCOORD1; // X is Pan Offset, Y is UV Warp Strength, Z is Gravity


					float4 color : COLOR;
					#ifdef SPECULAR_REFLECTION_ON
					half4 tangent : TANGENT;
					#endif
				};

				struct v2f
				{
					float4 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 color : Color;

					////// Stuff I constructed //////
	#ifdef SPECULAR_REFLECTION_ON
					float3 viewDir : TEXCOORD1;
	#endif

					float4 vertLight : TEXCOORD3;
					float3 customData : TEXCOORD4; //XY is custom ((panDistanceOffset & warpStrength)), Z is stable random

					// UNITY_FOG_COORDS(5)
					float fogFactor : FOGFACTOR;

					////// Normal Map Transform Stuff /////
					half3 normal : NORMAL;
					float3x3 tangentToWorld : TEXCOORD6;
				};

				v2f vert(appdata_t IN)
				{
					v2f OUT;

					float lifetime = IN.texcoord0.w;
					lifetime = lifetime * lifetime + (_FallOffset + ((IN.texcoord0.z - 0.5) * _FallRandomness)) * lifetime;
					float4 fallPos = lifetime * float4(0, IN.texcoord1.z, 0, 0);

					float2 UVflip = round(frac(float2(IN.texcoord0.z * 13, IN.texcoord0.z * 8))); 	//random 0 or 1 in x and y
					UVflip = UVflip * 2 - 1; 														//random -1 or 1 in x and y
					UVflip = lerp(1, UVflip, float2(_FlipU, _FlipV));

	#ifdef SHADER_API_GLES3
					fallPos *= -1.0;
	#endif

					VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.vertex.xyz);
					OUT.vertex = vertexInput.positionCS + fallPos;

					OUT.color = IN.color;
					OUT.color.a *= OUT.color.a;
					OUT.color.a += _AlphaMin;
					OUT.normal = TransformObjectToWorldNormal(IN.normal);
					OUT.customData = float3(IN.texcoord1.xy, IN.texcoord0.z);

					// UNITY_TRANSFER_FOG(OUT, OUT.vertex);
					OUT.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);


					// OUT.uv.xy is original UVs, OUT.uv.zw is randomized and panned //
					OUT.uv.xy = TRANSFORM_TEX(IN.texcoord0.xy * UVflip, _MainTex);
					OUT.uv.zw = OUT.uv.xy * half2(_Columns, _Rows) + IN.texcoord0.z * half2(3, 8) * _Randomize;

	#ifdef SPECULAR_REFLECTION_ON
					// get all the vectors and matricies I need to handle normalmapped reflections //
					float3 binormal = cross(IN.normal, IN.tangent.xyz) * IN.tangent.w;
					float3x3 rotation = float3x3(IN.tangent.xyz, binormal, IN.normal);
					OUT.tangentToWorld = mul((float3x3)unity_ObjectToWorld, transpose(rotation));
					float3 worldViewDir = normalize(TransformWorldToView(vertexInput.positionWS));
					OUT.viewDir = worldViewDir;
	#endif

					// Do vertex lighting
					// float3 shade = SampleSHVertex(OUT.normal);
					// shade = max(shade, (unity_AmbientSky + unity_AmbientGround + unity_AmbientEquator) * 0.15);		//Don't go to 0 even if there's no significant lighting data
					// OUT.vertLight.xyz = lerp(1, shade, _LightStr);
					OUT.vertLight.xyz = _LightStr;

					return OUT;
				}

				half4 frag(v2f IN) : SV_Target
				{
					////// Sample The UV Offset //////
					float4 uvWarp = tex2D(_WarpTex, IN.uv.zw * _WarpTex_ST.xy + _WarpTex_ST.zw * (IN.customData.x + 1) + (float2(5,8) * IN.customData.z));
					float2 warp = (uvWarp.xy * 2) - 1;
					warp *= _WarpStr * IN.customData.y;

					////// Sample The Mask //////
					half4 mask = tex2D(_MainTex, IN.uv.xy * _MainTex_ST.xy + warp);
					mask = saturate(lerp(1, mask, _MaskStr));

					////// Make And Edge Mask So Nothing Spills Off The Quad //////
					half2 tempUV = frac(IN.uv.xy * half2(_Columns, _Rows)) - 0.5;
					tempUV *= tempUV * 4;
					half edgeMask = saturate(tempUV.x + tempUV.y);
					edgeMask *= edgeMask;
					edgeMask = 1 - edgeMask;
					edgeMask = lerp(1.0, edgeMask, _ProcMask);

					mask *= edgeMask;
					half4 col = max(0.001, IN.color);
					col.a = saturate(dot(mask, _ChannelMask));



					////// Sample The Noise //////
					half4 noise4 = tex2D(_NoiseTex, IN.uv.zw * _NoiseTex_ST.xy + _NoiseTex_ST.zw * IN.customData.x + warp);
					half noise = dot(noise4, _ChannelMask2);
					noise = saturate(lerp(1,noise,_NoiseAlphaStr));

					////// Alpha Clip //////
					col.a *= noise;
					half preClipAlpha = col.a;
					half clippedAlpha = saturate((preClipAlpha * IN.color.a - _AlphaMin) / (_AlphaSoft));
					col.a = clippedAlpha;

					////// Bring In Base Lighting //////
					float3 baseLighting = max(0.01,(IN.vertLight + 0.2 * dot(IN.vertLight, half3(1,1,1))));
					baseLighting = IN.vertLight.xyz;

					#ifdef SPECULAR_REFLECTION_ON
					////// Sample The Normals //////
					half3 normalTex = UnpackNormal(tex2D(_Normal, IN.uv.zw * _NoiseTex_ST.xy + _NoiseTex_ST.zw * IN.customData.x + warp));

					////// Make Normals Steep Near Alpha Edge //////
					normalTex.z = _FlattenNormal * (preClipAlpha + preClipAlpha + col.a - 1) * 0.5;
					normalTex.z = _FlattenNormal * (saturate((preClipAlpha * IN.color.a - _AlphaMin) / (_AlphaSoft + 0.2)) - 0.1) * 1.2;
					normalTex = normalize(normalTex);

					////// Transform Normals To World Space //////
					normalTex.xyz = mul(IN.tangentToWorld, normalTex.xyz);
					float3 combinedNormals = normalize(IN.normal + normalTex);
					float3 viewDir = (combinedNormals + half3(0,1,0)) * 0.5;

					////// Calculate Reflection UVs ///////
					float3 reflectionVector = reflect(-IN.viewDir, combinedNormals);
					reflectionVector.x = atan2(reflectionVector.x, reflectionVector.z) * 0.31831;
					reflectionVector = reflectionVector * 0.5;
					float2 reflectionUVs = reflectionVector.xy * _ReflectionTex_ST.xy;
					reflectionUVs += _ReflectionTex_ST.zw * (_Time + IN.customData.z);
					float3 reflectionTex = tex2D(_ReflectionTex, reflectionUVs);

					////// Generate Specular Reflection//////
					float desatReflection = dot(reflectionTex, float3(1,1,1)) * 0.333;
					float3 spec = lerp(desatReflection, reflectionTex, _ReflectionSat);
					float3 spec0 = spec;
					float3 spec1 = spec0 * spec0 * spec0 * spec0;
					spec = clamp(lerp(spec0, spec1, _SpecularColor.w * preClipAlpha),0,10);


					float fresnel = 1 - dot(IN.viewDir, combinedNormals) * _SpecularColor.w;
					spec *= clamp(fresnel, 0.2,1);
					#endif


					////// Find Edge //////
					half edge = 1 - saturate(preClipAlpha * clippedAlpha);
					edge *= edge;
					edge = 1 - edge;
					edge = edge + lerp(0, noise - 0.5, _NoiseColorStr);

					////// Edge Darken //////
					edge = saturate(lerp(0.71, edge * edge, _EdgeDarken));

					////// Edge Alpha //////
					col.a *= saturate(lerp(1.25, _BaseColor.a , edge));

					#ifdef SPECULAR_REFLECTION_OFF
						edge *= 2;
					#endif 

					col.xyz *= lerp(min(col.xyz * col.xyz * col.xyz * 0.3, 1.0), 0.71, edge);  /// Make sure this doesn't end up wAAAAAAY over one


					////// Tint And Combine Lighting //////

					col.xyz *= max(0,baseLighting * _BaseColor.xyz);

					#ifdef SPECULAR_REFLECTION_ON
					col.xyz += baseLighting * spec * _SpecularColor.xyz;
					#endif					

					///// Apply Fog //////
					// UNITY_APPLY_FOG(IN.fogCoord, col);

					// Mix the pixel color with fogColor. You can optionaly use MixFogColor to override the fogColor
					// with a custom one.
					col.xyz = MixFog(col.xyz, IN.fogFactor);

					return col;
				}
				ENDHLSL
				}
			}
			CustomEditor "SpecularToggleEditor"
}
