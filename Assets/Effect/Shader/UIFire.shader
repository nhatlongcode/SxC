// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UIFire"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_flowmap_with_AChannel("flowmap_with_AChannel", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0.8490566,0.04787254,0,0)
		_Turbulence_215_c("Turbulence_215_c", 2D) = "white" {}
		[HDR]_Color1("Color 1", Color) = (0.7921569,0.2730868,0.09411762,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#endif//ASE Sampling Macros
			

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float4 _Color0;
			uniform float4 _Color1;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Turbulence_215_c);
			SamplerState sampler_Turbulence_215_c;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_flowmap_with_AChannel);
			SamplerState sampler_flowmap_with_AChannel;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_TextureSample0);
			SamplerState sampler_TextureSample0;
			uniform float4 _TextureSample0_ST;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				float2 texCoord8 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner18 = ( 1.0 * _Time.y * float2( 0,-0.1 ) + texCoord8);
				float2 texCoord7 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6 = ( 1.0 * _Time.y * float2( 0,-0.5 ) + texCoord7);
				float temp_output_10_0 = ( SAMPLE_TEXTURE2D( _flowmap_with_AChannel, sampler_flowmap_with_AChannel, panner6 ).r * 0.3 );
				float2 texCoord22 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord29 = IN.texcoord.xy * float2( 1,1.19 ) + float2( 0,0 );
				float clampResult37 = clamp( ( ( pow( SAMPLE_TEXTURE2D( _Turbulence_215_c, sampler_Turbulence_215_c, ( panner18 + temp_output_10_0 ) ).r , 2.08 ) * ( 1.0 - texCoord22.y ) ) + ( 1.0 - ( temp_output_10_0 + texCoord29.y ) ) ) , 0.0 , 1.0 );
				float temp_output_31_0 = pow( clampResult37 , 1.39 );
				float4 lerpResult16 = lerp( _Color0 , _Color1 , temp_output_31_0);
				float2 uv_TextureSample0 = IN.texcoord.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float4 appendResult38 = (float4(lerpResult16.rgb , ( SAMPLE_TEXTURE2D( _TextureSample0, sampler_TextureSample0, uv_TextureSample0 ).a * temp_output_31_0 )));
				
				half4 color = appendResult38;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18400
478;44;1460;971;-1065.948;752.4708;1.306635;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1047.153,217.3838;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;6;-774.7028,225.5763;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-558.2905,194.4899;Inherit;True;Property;_flowmap_with_AChannel;flowmap_with_AChannel;0;0;Create;True;0;0;False;0;False;-1;85b22d4c18b021b49a5ce0a4b11eaa88;85b22d4c18b021b49a5ce0a4b11eaa88;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-433.6317,598.2509;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-920.7488,-224.0604;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;18;-505.0245,-91.7737;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-190.9044,352.1345;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-115.2485,26.83957;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;486.9367,864.9191;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1.19;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;595.105,508.289;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;278.2552,123.9926;Inherit;True;Property;_Turbulence_215_c;Turbulence_215_c;2;0;Create;True;0;0;False;0;False;-1;ff0efd5256f2fb542bba8d37122fc17e;ff0efd5256f2fb542bba8d37122fc17e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;25;942.7925,454.6001;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;859.6996,781.1388;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;671.9842,172.6837;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2.08;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;33;1165.415,757.9702;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1155.043,378.1371;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;1428.142,614.9179;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;1716.923,827.2161;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;1657.269,-84.55589;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;False;0;False;0.8490566,0.04787254,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;31;2044.613,772.3765;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1.39;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;1657.581,137.0602;Inherit;False;Property;_Color1;Color 1;3;1;[HDR];Create;True;0;0;False;0;False;0.7921569,0.2730868,0.09411762,0;0.7921569,0.2730868,0.09411762,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;1901.288,-443.1305;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;16;2186.102,225.0441;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;2503.18,3.230099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;2790.854,313.554;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3127.226,359.3811;Float;False;True;-1;2;ASEMaterialInspector;0;6;UIFire;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;True;0
WireConnection;6;0;7;0
WireConnection;5;1;6;0
WireConnection;18;0;8;0
WireConnection;10;0;5;1
WireConnection;10;1;11;0
WireConnection;9;0;18;0
WireConnection;9;1;10;0
WireConnection;36;1;9;0
WireConnection;25;0;22;2
WireConnection;32;0;10;0
WireConnection;32;1;29;2
WireConnection;19;0;36;1
WireConnection;33;0;32;0
WireConnection;26;0;19;0
WireConnection;26;1;25;0
WireConnection;27;0;26;0
WireConnection;27;1;33;0
WireConnection;37;0;27;0
WireConnection;31;0;37;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;16;2;31;0
WireConnection;42;0;46;4
WireConnection;42;1;31;0
WireConnection;38;0;16;0
WireConnection;38;3;42;0
WireConnection;0;0;38;0
ASEEND*/
//CHKSM=72FBDE26916D90202F4C1647CE503FE5AA345A18