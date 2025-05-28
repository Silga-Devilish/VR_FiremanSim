// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HoloGram"
{
	Properties
	{
		[Toggle]_ZWriteMode("ZWriteMode", Float) = 0
		[HDR]_MainColor("MainColor", Color) = (0.1566037,0.4771748,1,0)
		_Alpha("Alpha", Range( 0 , 1)) = 1
		_HFTilling("HFTilling", Float) = 100
		_NormalMap("NormalMap", 2D) = "bump" {}
		_ShinningControl("ShinningControl", Range( 0 , 1)) = 0.5
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_RimBais("RimBais", Float) = 0
		_WireFrame("WireFrame", 2D) = "white" {}
		_WireFrameIntensity("WireFrameIntensity", Float) = 1
		_ScanLine1Tex("ScanLine 1 Tex", 2D) = "white" {}
		[HDR]_Scan1Color("Scan 1 Color", Color) = (0.2471698,0.4384021,1,0)
		_Line1Alpha("Line 1 Alpha", Range( 0 , 1)) = 1
		_Line1Speed("Line 1 Speed", Float) = 1
		_Line1Freq("Line 1 Freq", Float) = 3
		_Line1Width("Line 1 Width", Float) = 0
		_Line1Hardness("Line 1 Hardness", Float) = 1
		_ScanLine2Tex("ScanLine 2 Tex", 2D) = "white" {}
		_Line2Alpha("Line 2 Alpha", Range( 0 , 1)) = 1
		_Line2Speed("Line 2 Speed", Float) = 1
		_Line2Freq("Line 2 Freq", Float) = 50
		_Line2Width("Line 2 Width", Float) = 0
		_Line2Hardness("Line 2 Hardness", Float) = 1
		_GlitchVertexOffset("GlitchVertexOffset", Vector) = (0,1,0,0)
		_GlitchTilling("GlitchTilling", Float) = 10
		_GlitchHFTilling("GlitchHFTilling", Float) = 100
		_ScanOffsetTex("ScanOffset Tex", 2D) = "white" {}
		_ScanLineVertexOffset("ScanLineVertexOffset", Vector) = (0,1,0,0)
		_ScanOffsetSpeed("ScanOffset Speed", Float) = 1
		_ScanOffsetFreq("ScanOffset Freq", Float) = 3
		_ScanOffsetWidth("ScanOffset Width", Float) = 0
		_ScanOffsetHardness("ScanOffset Hardness", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite [_ZWriteMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float _ZWriteMode;
		uniform float3 _GlitchVertexOffset;
		uniform float _GlitchTilling;
		uniform float _GlitchHFTilling;
		uniform float3 _ScanLineVertexOffset;
		uniform sampler2D _ScanOffsetTex;
		uniform float _ScanOffsetFreq;
		uniform float _ScanOffsetSpeed;
		uniform float _ScanOffsetWidth;
		uniform float _ScanOffsetHardness;
		uniform float _HFTilling;
		uniform float _ShinningControl;
		uniform float4 _MainColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBais;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _Scan1Color;
		uniform sampler2D _ScanLine1Tex;
		uniform float _Line1Freq;
		uniform float _Line1Speed;
		uniform float _Line1Width;
		uniform float _Line1Hardness;
		uniform sampler2D _ScanLine2Tex;
		uniform float _Line2Freq;
		uniform float _Line2Speed;
		uniform float _Line2Width;
		uniform float _Line2Hardness;
		uniform float _Line1Alpha;
		uniform float _Line2Alpha;
		uniform sampler2D _WireFrame;
		uniform float4 _WireFrame_ST;
		uniform float _WireFrameIntensity;
		uniform float _Alpha;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 viewToObjDir122 = mul( UNITY_MATRIX_T_MV, float4( _GlitchVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime111 = _Time.y * 0.5;
			float mulTime113 = _Time.y * -2.0;
			float2 appendResult112 = (float2((ase_worldPos.y*_GlitchTilling + mulTime111) , mulTime113));
			float simplePerlin2D114 = snoise( appendResult112 );
			simplePerlin2D114 = simplePerlin2D114*0.5 + 0.5;
			float3 objToWorld123 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime125 = _Time.y * -1.0;
			float mulTime129 = _Time.y * 0.1;
			float2 appendResult126 = (float2((( objToWorld123.x + objToWorld123.y + objToWorld123.z )*_GlitchHFTilling + mulTime125) , mulTime129));
			float simplePerlin2D127 = snoise( appendResult126 );
			simplePerlin2D127 = simplePerlin2D127*0.5 + 0.5;
			float clampResult132 = clamp( (simplePerlin2D127*2.0 + -1.0) , 0.0 , 1.0 );
			float temp_output_133_0 = ( (simplePerlin2D114*2.0 + -1.0) * clampResult132 );
			float2 break134 = appendResult112;
			float2 appendResult137 = (float2(( 200.0 * break134.x ) , break134.y));
			float simplePerlin2D138 = snoise( appendResult137 );
			simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
			float clampResult140 = clamp( (simplePerlin2D138*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchOffset120 = ( ( viewToObjDir122 * 0.01 ) * ( temp_output_133_0 + ( temp_output_133_0 * clampResult140 ) ) );
			float3 viewToObjDir152 = mul( UNITY_MATRIX_T_MV, float4( _ScanLineVertexOffset, 0 ) ).xyz;
			float3 objToWorld2_g6 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g6 = _Time.y * _ScanOffsetSpeed;
			float2 appendResult9_g6 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g6.y )*_ScanOffsetFreq + mulTime7_g6)));
			float clampResult23_g6 = clamp( ( ( tex2Dlod( _ScanOffsetTex, float4( appendResult9_g6, 0, 0.0) ).r - _ScanOffsetWidth ) * _ScanOffsetHardness ) , 0.0 , 1.0 );
			float3 ScaneLineOffset155 = ( ( viewToObjDir152 * 0.01 ) * clampResult23_g6 );
			v.vertex.xyz += ( GlitchOffset120 + ScaneLineOffset155 );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 objToWorld10 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime9 = _Time.y * 5.0;
			float mulTime15 = _Time.y * 0.5;
			float2 appendResult14 = (float2((( objToWorld10.x + objToWorld10.y + objToWorld10.z )*_HFTilling + mulTime9) , mulTime15));
			float simplePerlin2D16 = snoise( appendResult14 );
			simplePerlin2D16 = simplePerlin2D16*0.5 + 0.5;
			float clampResult24 = clamp( (-0.5 + (simplePerlin2D16 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult51 = lerp( 1.0 , clampResult24 , _ShinningControl);
			float Shining19 = lerpResult51;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV27 = dot( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )), ase_worldViewDir );
			float fresnelNode27 = ( _RimBais + _RimScale * pow( max( 1.0 - fresnelNdotV27 , 0.0001 ), _RimPower ) );
			float FresnelFactor34 = max( fresnelNode27 , 0.0 );
			float3 objToWorld2_g5 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g5 = _Time.y * _Line1Speed;
			float2 appendResult9_g5 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g5.y )*_Line1Freq + mulTime7_g5)));
			float clampResult23_g5 = clamp( ( ( tex2D( _ScanLine1Tex, appendResult9_g5 ).r - _Line1Width ) * _Line1Hardness ) , 0.0 , 1.0 );
			float temp_output_77_0 = clampResult23_g5;
			float3 objToWorld2_g4 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g4 = _Time.y * _Line2Speed;
			float2 appendResult9_g4 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g4.y )*_Line2Freq + mulTime7_g4)));
			float clampResult23_g4 = clamp( ( ( tex2D( _ScanLine2Tex, appendResult9_g4 ).r - _Line2Width ) * _Line2Hardness ) , 0.0 , 1.0 );
			float temp_output_100_0 = clampResult23_g4;
			float4 ScanLine_1_Color66 = ( _Scan1Color * ( temp_output_77_0 * temp_output_100_0 ) );
			o.Emission = ( Shining19 * ( _MainColor + ( _MainColor * FresnelFactor34 ) + max( ScanLine_1_Color66 , float4( 0,0,0,0 ) ) ) ).rgb;
			float temp_output_101_0 = ( temp_output_100_0 * _Line2Alpha );
			float ScanLine_1_Alpha87 = ( ( ( temp_output_77_0 * _Line1Alpha ) * temp_output_101_0 ) + temp_output_101_0 );
			float clampResult48 = clamp( ( _MainColor.a + FresnelFactor34 + ScanLine_1_Alpha87 ) , 0.0 , 1.0 );
			float2 uv_WireFrame = i.uv_texcoord * _WireFrame_ST.xy + _WireFrame_ST.zw;
			float4 WireFrame41 = ( tex2D( _WireFrame, uv_WireFrame ) * _WireFrameIntensity );
			o.Alpha = ( clampResult48 * WireFrame41 * _Alpha ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;157;-631.8483,914.276;Inherit;False;1586.268;712.8833;Comment;12;149;150;151;152;153;155;154;145;146;147;144;148;ScanGlitch;0.390566,0.4411743,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;143;-2963.063,1728.153;Inherit;False;3347.543;1151.705;Comment;34;106;108;111;107;113;115;112;114;123;124;126;127;128;130;125;129;131;132;135;137;136;134;138;139;117;116;118;122;119;120;142;141;133;140;GlitchOffset;1,0.3935618,0.3150943,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;76;-2949.091,575.7719;Inherit;False;2154.945;1057.349;Comment;23;85;86;105;104;87;103;83;84;66;102;96;95;94;93;98;101;100;77;78;82;81;80;79;anline;1,0.9079556,0.481132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-1601.486,7.448876;Inherit;False;864.3441;488.0142;Comment;4;36;37;39;41;WireFrame;0.2638162,0.3432626,0.781132,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-2964.106,0.3722632;Inherit;False;1327.056;496.9482;Comment;8;29;32;27;34;33;31;30;28;Fresnel;0.4207547,0.7471927,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-480.5811,-300.1572;Inherit;False;260;162.8;ProPerties;1;25;ProPerties;0.1822836,0.9698113,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-2976.553,-537.9385;Inherit;False;1933.939;484.174;Comment;13;19;51;52;24;22;15;12;16;14;9;13;11;10;Shinning;0.5849056,0.5849056,0.5849056,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-430.5811,-250.1572;Inherit;False;Property;_ZWriteMode;ZWriteMode;1;1;[Toggle];Create;True;0;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;28;-2560.658,50.37229;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;30;-2528.65,191.7252;Inherit;False;Property;_RimBais;RimBais;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2531.049,338.9252;Inherit;False;Property;_RimPower;RimPower;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;33;-1996.65,50.92502;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1879.049,67.72508;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;27;-2312.938,49.61238;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2528.649,265.3252;Inherit;False;Property;_RimScale;RimScale;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-2918.251,50.92504;Inherit;True;Property;_NormalMap;NormalMap;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-177.2293,229.12;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-1910.897,-494.7322;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;-1643.322,-495.8662;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1694.002,-281.875;Inherit;False;Property;_ShinningControl;ShinningControl;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;-1402.8,-329.0749;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1261.618,-328.4594;Inherit;False;Shining;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-73.65472,349.5791;Inherit;False;41;WireFrame;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-167.8779,417.9418;Inherit;False;Property;_Alpha;Alpha;3;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-1589.886,58.24897;Inherit;True;Property;_WireFrame;WireFrame;10;0;Create;True;0;0;0;False;0;False;-1;92f284b27dea88e41885444624ec2963;92f284b27dea88e41885444624ec2963;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1581.675,263.5168;Inherit;False;Property;_WireFrameIntensity;WireFrameIntensity;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1281.638,238.4631;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1061.542,242.8501;Inherit;False;WireFrame;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;161.5451,324.7791;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;48;-40.8548,228.7791;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-720.0449,-150.8222;Inherit;False;Property;_MainColor;MainColor;2;1;[HDR];Create;True;0;0;0;False;0;False;0.1566037,0.4771748,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;-600.5086,196.3002;Inherit;False;34;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-602.5938,265.3229;Inherit;False;87;ScanLine 1 Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;653.5838,135.5699;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;HoloGram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;_ZWriteMode;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;100.8464,-149.0765;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;248.8976,-284.4136;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-198.0821,-91.24628;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-0.9159586,-283.1533;Inherit;False;19;Shining;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-448.7333,-68.31116;Inherit;False;34;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;92;-32.69482,1.029572;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-262.0491,2.120438;Inherit;False;66;ScanLine 1 Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;100;-2355.628,1198.994;Inherit;False;Scanline;-1;;4;c86830a66645d204f992376eb49bbd3b;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;98;-2914.016,1195.384;Inherit;True;Property;_ScanLine2Tex;ScanLine 2 Tex;19;0;Create;True;0;0;0;False;0;False;4bbf045a9f687084ea4bc84d53c39623;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;93;-2709.761,1274.7;Inherit;False;Property;_Line2Freq;Line 2 Freq;22;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2706.14,1353.606;Inherit;False;Property;_Line2Speed;Line 2 Speed;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2708.541,1424.006;Inherit;False;Property;_Line2Width;Line 2 Width;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2706.14,1500.006;Inherit;False;Property;_Line2Hardness;Line 2 Hardness;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1348.24,769.1876;Inherit;False;ScanLine 1 Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1993.074,786.9503;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1522.317,1166.872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-1171.155,1240.833;Inherit;False;ScanLine 1 Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;10;-2926.553,-487.9385;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-2684.154,-463.9384;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;9;-2746.76,-283.4863;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-2287.356,-495.1385;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;16;-2140.68,-494.0046;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;12;-2562.554,-367.9385;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-2510.555,-229.5386;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2713.754,-347.1386;Inherit;False;Property;_HFTilling;HFTilling;4;0;Create;True;0;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;106;-2913.063,1929.121;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;82;-2695.905,1088.546;Inherit;False;Property;_Line1Hardness;Line 1 Hardness;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2699.526,863.2404;Inherit;False;Property;_Line1Freq;Line 1 Freq;16;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2695.905,942.1456;Inherit;False;Property;_Line1Speed;Line 1 Speed;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-2698.305,1012.546;Inherit;False;Property;_Line1Width;Line 1 Width;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;78;-2903.781,783.9237;Inherit;True;Property;_ScanLine1Tex;ScanLine 1 Tex;12;0;Create;True;0;0;0;False;0;False;afb16754b93daf04187b10b438f7a250;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;77;-2345.394,787.5336;Inherit;False;Scanline;-1;;5;c86830a66645d204f992376eb49bbd3b;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;149;85.06805,1211.507;Inherit;False;Scanline;-1;;6;c86830a66645d204f992376eb49bbd3b;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;14.15149,968.6729;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-465.8485,1123.073;Inherit;False;Constant;_Float2;Float 0;27;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;152;-300.3999,974.318;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;472.9337,967.519;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;712.4201,964.276;Inherit;False;ScaneLineOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;154;-581.8483,975.0731;Inherit;False;Property;_ScanLineVertexOffset;ScanLineVertexOffset;29;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;145;-269.0638,1287.214;Inherit;False;Property;_ScanOffsetFreq;ScanOffset Freq;31;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-265.4431,1366.119;Inherit;False;Property;_ScanOffsetSpeed;ScanOffset Speed;30;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-267.8429,1436.52;Inherit;False;Property;_ScanOffsetWidth;ScanOffset Width;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-275.7631,1514.359;Inherit;False;Property;_ScanOffsetHardness;ScanOffset Hardness;33;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;148;-473.3188,1207.897;Inherit;True;Property;_ScanOffsetTex;ScanOffset Tex;28;0;Create;True;0;0;0;False;0;False;4bbf045a9f687084ea4bc84d53c39623;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1754.601,1016.894;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-1376.93,1245.519;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;-1829.685,662.503;Inherit;False;Property;_Scan1Color;Scan 1 Color;13;1;[HDR];Create;True;0;0;0;False;0;False;0.2471698,0.4384021,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1573.686,765.3033;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2056.999,1301.17;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;20;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2060.362,1176.734;Inherit;False;Property;_Line1Alpha;Line 1 Alpha;14;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-1753.798,1229.602;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;112;-2468.779,2008.203;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;113;-2690.945,2161.041;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;123;-2290.247,2237.786;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-2033.281,2566.041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;-1850.736,2590.381;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2189.055,2553.872;Inherit;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;134;-2302.878,2591.136;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;138;-1695.775,2592.003;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;114;-2277.784,2024.948;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;122;-2049.251,1792.301;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;118;-2272.726,1941.057;Inherit;False;Constant;_Float0;Float 0;27;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1747.5,1875.457;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;115;-2026.301,2025.654;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;125;-2289.449,2441.068;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-2087.831,2261.786;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;129;-1975.605,2496.186;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;128;-1977.66,2364.895;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;126;-1759.592,2468.349;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;131;-1743.443,2090.753;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;132;-1537.643,2089.407;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1293.637,2016.649;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-1106.963,2210.814;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-890.2251,2023.08;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;139;-1470.187,2588.655;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;140;-1261.736,2586.407;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;127;-1589.394,2355.949;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-683.9603,1909.229;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-689.6261,2274.57;Inherit;False;GlitchOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;107;-2698.839,2006.975;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-2911.21,2076.575;Inherit;False;Property;_GlitchTilling;GlitchTilling;26;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;111;-2909.609,2145.375;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;311.8405,477.8735;Inherit;False;155;ScaneLineOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;310.1698,397.7599;Inherit;False;120;GlitchOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;535.1938,398.0939;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-2289.151,2380.805;Inherit;False;Property;_GlitchHFTilling;GlitchHFTilling;27;0;Create;True;0;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;116;-2265.099,1790.656;Inherit;False;Property;_GlitchVertexOffset;GlitchVertexOffset;25;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;28;0;29;0
WireConnection;33;0;27;0
WireConnection;34;0;33;0
WireConnection;27;0;28;0
WireConnection;27;1;30;0
WireConnection;27;2;32;0
WireConnection;27;3;31;0
WireConnection;47;0;2;4
WireConnection;47;1;89;0
WireConnection;47;2;88;0
WireConnection;22;0;16;0
WireConnection;24;0;22;0
WireConnection;51;1;24;0
WireConnection;51;2;52;0
WireConnection;19;0;51;0
WireConnection;37;0;36;0
WireConnection;37;1;39;0
WireConnection;41;0;37;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;49;2;53;0
WireConnection;48;0;47;0
WireConnection;0;2;4;0
WireConnection;0;9;49;0
WireConnection;0;11;158;0
WireConnection;46;0;2;0
WireConnection;46;1;44;0
WireConnection;46;2;92;0
WireConnection;4;0;20;0
WireConnection;4;1;46;0
WireConnection;44;0;2;0
WireConnection;44;1;45;0
WireConnection;92;0;90;0
WireConnection;100;20;98;0
WireConnection;100;18;93;0
WireConnection;100;19;94;0
WireConnection;100;21;95;0
WireConnection;100;22;96;0
WireConnection;66;0;84;0
WireConnection;103;0;77;0
WireConnection;103;1;100;0
WireConnection;105;0;86;0
WireConnection;105;1;101;0
WireConnection;87;0;104;0
WireConnection;11;0;10;1
WireConnection;11;1;10;2
WireConnection;11;2;10;3
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;16;0;14;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;12;2;9;0
WireConnection;77;20;78;0
WireConnection;77;18;79;0
WireConnection;77;19;80;0
WireConnection;77;21;81;0
WireConnection;77;22;82;0
WireConnection;149;20;148;0
WireConnection;149;18;145;0
WireConnection;149;19;146;0
WireConnection;149;21;147;0
WireConnection;149;22;144;0
WireConnection;150;0;152;0
WireConnection;150;1;151;0
WireConnection;152;0;154;0
WireConnection;153;0;150;0
WireConnection;153;1;149;0
WireConnection;155;0;153;0
WireConnection;86;0;77;0
WireConnection;86;1;85;0
WireConnection;104;0;105;0
WireConnection;104;1;101;0
WireConnection;84;0;83;0
WireConnection;84;1;103;0
WireConnection;101;0;100;0
WireConnection;101;1;102;0
WireConnection;112;0;107;0
WireConnection;112;1;113;0
WireConnection;135;0;136;0
WireConnection;135;1;134;0
WireConnection;137;0;135;0
WireConnection;137;1;134;1
WireConnection;134;0;112;0
WireConnection;138;0;137;0
WireConnection;114;0;112;0
WireConnection;122;0;116;0
WireConnection;117;0;122;0
WireConnection;117;1;118;0
WireConnection;115;0;114;0
WireConnection;124;0;123;1
WireConnection;124;1;123;2
WireConnection;124;2;123;3
WireConnection;128;0;124;0
WireConnection;128;1;130;0
WireConnection;128;2;125;0
WireConnection;126;0;128;0
WireConnection;126;1;129;0
WireConnection;131;0;127;0
WireConnection;132;0;131;0
WireConnection;133;0;115;0
WireConnection;133;1;132;0
WireConnection;141;0;133;0
WireConnection;141;1;140;0
WireConnection;142;0;133;0
WireConnection;142;1;141;0
WireConnection;139;0;138;0
WireConnection;140;0;139;0
WireConnection;127;0;126;0
WireConnection;119;0;117;0
WireConnection;119;1;142;0
WireConnection;120;0;119;0
WireConnection;107;0;106;2
WireConnection;107;1;108;0
WireConnection;107;2;111;0
WireConnection;158;0;121;0
WireConnection;158;1;156;0
ASEEND*/
//CHKSM=0AC6B2382CA736B4F5533CD180125E17248DAA09