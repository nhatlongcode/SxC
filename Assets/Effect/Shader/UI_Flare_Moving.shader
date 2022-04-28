// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UI_Flare_Moving"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0.8679245,0.05322181,0.05322181,0)
		_MovingFlare("Moving Flare", Vector) = (0,0,0,0)
		_TopWhite("Top White", Float) = 1.02
		_BotWhite("Bot White", Float) = 0
		_ColorStrength("Color Strength", Float) = 1

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One One
		
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			

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
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float4 _Color0;
			uniform float2 _MovingFlare;
			uniform float _TopWhite;
			uniform float _BotWhite;
			uniform float _ColorStrength;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float2 uv023 = IN.texcoord.xy * float2( 1,1 ) + _MovingFlare;
				float4 appendResult46 = (float4(0.5 , _TopWhite , 0.0 , 0.0));
				float cos33 = cos( ( 7.2 * 0.1 ) );
				float sin33 = sin( ( 7.2 * 0.1 ) );
				float2 rotator33 = mul( uv023 - appendResult46.xy , float2x2( cos33 , -sin33 , sin33 , cos33 )) + appendResult46.xy;
				float temp_output_34_0 = (rotator33).x;
				float4 appendResult48 = (float4(0.51 , _BotWhite , 0.0 , 0.0));
				float cos38 = cos( ( -24.5 * 0.1 ) );
				float sin38 = sin( ( -24.5 * 0.1 ) );
				float2 rotator38 = mul( uv023 - appendResult48.xy , float2x2( cos38 , -sin38 , sin38 , cos38 )) + appendResult48.xy;
				float temp_output_40_0 = (rotator38).x;
				float temp_output_42_0 = ( temp_output_34_0 * temp_output_40_0 );
				float4 appendResult54 = (float4(( _Color0 * temp_output_42_0 * _ColorStrength ).rgb , ( 1.0 - (( 0.41 * 0.1 ) + (temp_output_42_0 - ( 0.39 * 0.1 )) * (( 1.13 * 0.1 ) - ( 0.41 * 0.1 )) / (( 1.7 * 0.1 ) - ( 0.39 * 0.1 ))) )));
				
				fixed4 c = appendResult54;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18100
164;161.6;1668;928;-1279.239;-2388.647;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;35;148.8474,2225.914;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;7.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;145.7052,2089.765;Inherit;False;Property;_TopWhite;Top White;2;0;Create;True;0;0;False;0;False;1.02;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-99.12566,2532.269;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;False;0;False;-24.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;241.4169,2464.798;Inherit;False;Property;_BotWhite;Bot White;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;44;-118.5746,1882.438;Inherit;False;Property;_MovingFlare;Moving Flare;1;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;184.751,1803.245;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;46;390.9247,2076.111;Inherit;False;FLOAT4;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;481.6778,2272.264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;417.3669,2644.455;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;481.0891,2445.733;Inherit;False;FLOAT4;4;0;FLOAT;0.51;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotatorNode;38;874.7622,2385.857;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.1;False;2;FLOAT;0.65;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;33;840.248,1961.202;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,1.06;False;2;FLOAT;0.65;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;58;1858.896,2897.891;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;False;0.39;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;1137.438,2090.524;Inherit;True;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;1166.882,2430.968;Inherit;True;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;1815.896,3075.891;Inherit;False;Constant;_Float1;Float 1;5;0;Create;True;0;0;False;0;False;1.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;1862.896,3232.891;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;0.41;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;1920.896,3411.891;Inherit;False;Constant;_Float5;Float 5;5;0;Create;True;0;0;False;0;False;1.13;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1881.135,2570.449;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;2126.896,3350.891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;2085.896,3176.891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;2099.896,3079.891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;2105.896,2975.891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;1530.316,2040.341;Inherit;False;Property;_Color0;Color 0;0;1;[HDR];Create;True;0;0;False;0;False;0.8679245,0.05322181,0.05322181,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;1968.129,2253.39;Inherit;False;Property;_ColorStrength;Color Strength;4;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;57;2360.896,2889.891;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;2228.521,2107.042;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;50;2569.309,2586.64;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;2382.896,3285.891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;2767.02,1991.297;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;53;1525.292,2226.142;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.09;False;3;FLOAT;0.32;False;4;FLOAT;0.62;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;51;1536.323,2637.083;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.09;False;3;FLOAT;0.32;False;4;FLOAT;0.62;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;3060.518,1357.351;Float;False;True;-1;2;ASEMaterialInspector;0;8;UI_Flare_Moving;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;23;1;44;0
WireConnection;46;1;47;0
WireConnection;36;0;35;0
WireConnection;39;0;41;0
WireConnection;48;1;49;0
WireConnection;38;0;23;0
WireConnection;38;1;48;0
WireConnection;38;2;39;0
WireConnection;33;0;23;0
WireConnection;33;1;46;0
WireConnection;33;2;36;0
WireConnection;34;0;33;0
WireConnection;40;0;38;0
WireConnection;42;0;34;0
WireConnection;42;1;40;0
WireConnection;64;0;66;0
WireConnection;63;0;65;0
WireConnection;62;0;59;0
WireConnection;60;0;58;0
WireConnection;57;0;42;0
WireConnection;57;1;60;0
WireConnection;57;2;62;0
WireConnection;57;3;63;0
WireConnection;57;4;64;0
WireConnection;43;0;14;0
WireConnection;43;1;42;0
WireConnection;43;2;55;0
WireConnection;50;0;57;0
WireConnection;54;0;43;0
WireConnection;54;3;50;0
WireConnection;53;0;34;0
WireConnection;51;0;40;0
WireConnection;4;0;54;0
ASEEND*/
//CHKSM=872D511F5EE5EE72374BB79B4EE04AC778264E64