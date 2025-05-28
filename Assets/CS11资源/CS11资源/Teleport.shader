// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Teleport"
{
	Properties
	{
		_BaseMap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_CampMask("CampMask", 2D) = "white" {}
		_MetallicAdjust("MetallicAdjust", Range( -1 , 1)) = 0
		_SmoothnessAdjust("SmoothnessAdjust", Range( -1 , 1)) = 0
		_DissolveAmount("DissolveAmount", Range( 0 , 5)) = 0
		_DissolveOffset("DissolveOffset", Float) = 0
		_DissolveSpread("DissolveSpread", Float) = 1
		[HDR]_RimColor("RimColor", Color) = (0.3830188,0.4014236,1,0)
		_RimControl("RimControl", Range( 0 , 1)) = 1
		_RimIntensity("RimIntensity", Float) = 1
		_RimScale("RimScale", Float) = 1
		_RimPow("RimPow", Float) = 1.3
		_RimBias("RimBias", Float) = 0
		_VertEffectOffset("VertEffectOffset", Float) = 0
		_VertEffectSpread("VertEffectSpread", Float) = 1
		_VertOffsetIntensity("VertOffsetIntensity", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (100,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_EdgeEmissColor("EdgeEmissColor", Color) = (0,0.9886398,2,0)
		_DissolveEdgeOffset("DissolveEdgeOffset", Float) = 0
		_EdgePower("EdgePower", Float) = 2
		_Min("Min", Float) = 0
		_Max("Max", Float) = 1
		_VertNoiseScale("VertNoiseScale", Vector) = (10,10,10,0)
		_EmissTex("EmissTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
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

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _DissolveAmount;
		uniform float _VertEffectOffset;
		uniform float _VertEffectSpread;
		uniform float _VertOffsetIntensity;
		uniform float3 _VertNoiseScale;
		uniform float _DissolveOffset;
		uniform float _DissolveSpread;
		uniform float3 _NoiseScale;
		uniform float4 _RimColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimControl;
		uniform sampler2D _EmissTex;
		uniform float4 _EmissTex_ST;
		uniform float _RimPow;
		uniform float _RimScale;
		uniform float _RimBias;
		uniform float _RimIntensity;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform float _MetallicAdjust;
		uniform sampler2D _CampMask;
		uniform float4 _CampMask_ST;
		uniform float _SmoothnessAdjust;
		uniform float _Min;
		uniform float _Max;
		uniform float _DissolveEdgeOffset;
		uniform float _EdgePower;
		uniform float4 _EdgeEmissColor;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld19 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_22_0 = ( ase_worldPos.y - objToWorld19.y );
			float simplePerlin3D90 = snoise( ( ase_worldPos * _VertNoiseScale ) );
			simplePerlin3D90 = simplePerlin3D90*0.5 + 0.5;
			float3 worldToObj85 = mul( unity_WorldToObject, float4( ( ( max( ( ( ( temp_output_22_0 + _DissolveAmount ) - _VertEffectOffset ) / _VertEffectSpread ) , 0.0 ) * float3(0,1,0) * _VertOffsetIntensity * simplePerlin3D90 ) + ase_worldPos ), 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 FinnalVertOffset88 = ( worldToObj85 - ase_vertex3Pos );
			v.vertex.xyz += FinnalVertOffset88;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld19 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_22_0 = ( ase_worldPos.y - objToWorld19.y );
			float temp_output_29_0 = ( ( ( ( 1.0 - temp_output_22_0 ) - _DissolveAmount ) - _DissolveOffset ) / _DissolveSpread );
			float smoothstepResult70 = smoothstep( 0.8 , 1.0 , temp_output_29_0);
			float simplePerlin3D33 = snoise( ( ase_worldPos * _NoiseScale ) );
			simplePerlin3D33 = simplePerlin3D33*0.5 + 0.5;
			float NoiseMap60 = simplePerlin3D33;
			float clampResult37 = clamp( ( smoothstepResult70 + ( temp_output_29_0 - NoiseMap60 ) ) , 0.0 , 1.0 );
			float DissolveMaskg65 = clampResult37;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode4 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float3 NormalMap123 = tex2DNode4;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult97 = dot( (WorldNormalVector( i , NormalMap123 )) , ase_worldViewDir );
			float clampResult101 = clamp( ( ( 1.0 - (dotResult97*0.5 + 0.5) ) - (_RimControl*2.0 + -1.0) ) , 0.0 , 1.0 );
			float2 uv_EmissTex = i.uv_texcoord * _EmissTex_ST.xy + _EmissTex_ST.zw;
			float4 saferPower107 = abs( ( clampResult101 + ( clampResult101 * tex2D( _EmissTex, uv_EmissTex ) ) ) );
			float4 temp_cast_0 = (_RimPow).xxxx;
			float4 RimEmiss110 = ( _RimColor * ( ( pow( saferPower107 , temp_cast_0 ) * _RimScale ) + _RimBias ) * _RimIntensity );
			SurfaceOutputStandard s2 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float3 gammaToLinear13 = GammaToLinearSpace( tex2D( _BaseMap, uv_BaseMap ).rgb );
			s2.Albedo = gammaToLinear13;
			s2.Normal = normalize( WorldNormalVector( i , tex2DNode4 ) );
			s2.Emission = float3( 0,0,0 );
			float2 uv_CampMask = i.uv_texcoord * _CampMask_ST.xy + _CampMask_ST.zw;
			float4 tex2DNode5 = tex2D( _CampMask, uv_CampMask );
			float clampResult8 = clamp( ( _MetallicAdjust + tex2DNode5.r ) , 0.0 , 1.0 );
			s2.Metallic = clampResult8;
			float clampResult12 = clamp( ( ( 1.0 - tex2DNode5.g ) + _SmoothnessAdjust ) , 0.0 , 1.0 );
			s2.Smoothness = clampResult12;
			s2.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi2 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g2 = UnityGlossyEnvironmentSetup( s2.Smoothness, data.worldViewDir, s2.Normal, float3(0,0,0));
			gi2 = UnityGlobalIllumination( data, s2.Occlusion, s2.Normal, g2 );
			#endif

			float3 surfResult2 = LightingStandard ( s2, viewDir, gi2 ).rgb;
			surfResult2 += s2.Emission;

			#ifdef UNITY_PASS_FORWARDADD//2
			surfResult2 -= s2.Emission;
			#endif//2
			float3 linearToGamma14 = LinearToGammaSpace( surfResult2 );
			float RimControl121 = _RimControl;
			float3 PBRLighting16 = ( linearToGamma14 * RimControl121 );
			float DissolveEdge125 = temp_output_29_0;
			float saferPower56 = abs( ( 1.0 - distance( DissolveEdge125 , _DissolveEdgeOffset ) ) );
			float smoothstepResult57 = smoothstep( _Min , _Max , ( pow( saferPower56 , _EdgePower ) - NoiseMap60 ));
			float4 DissolveEdgeColor49 = ( smoothstepResult57 * _EdgeEmissColor );
			c.rgb = ( RimEmiss110 + float4( PBRLighting16 , 0.0 ) + DissolveEdgeColor49 ).rgb;
			c.a = 1;
			clip( DissolveMaskg65 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
Node;AmplifyShaderEditor.CommentaryNode;113;-3239.263,1861.209;Inherit;False;2455.189;637.5819;Comment;24;98;124;121;114;119;101;115;100;118;120;111;110;103;102;109;106;108;105;107;104;116;99;97;95;RimColor;0.1566037,0.2969854,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-3280.644,1029.495;Inherit;False;2254.171;703.8639;Comment;19;72;73;77;75;79;81;80;76;83;85;86;87;88;84;90;91;92;93;82;VertOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-926.9728,1119.434;Inherit;False;1829.76;430.6531;Comment;14;47;57;48;58;59;63;56;64;45;43;41;42;49;126;DissolveColor;0,0.3384843,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-3286.87,566.7659;Inherit;False;2139.295;452.4181;Comment;16;125;29;65;37;71;34;61;19;22;18;27;25;23;26;70;31;DissolveMask;0.4490565,0.4490565,0.4490565,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-727.2392,1584.19;Inherit;False;1152.726;430.2088;Comment;6;33;60;38;40;39;35;Noise;1,0.435849,0.9328313,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;15;-3300.799,-353.1396;Inherit;False;1791.499;813.0666;Comment;17;2;13;4;3;6;9;8;7;5;14;12;11;10;16;117;122;123;PBRLighting;1,0.9018673,0.2849057,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3240.838,306.2842;Inherit;False;Property;_SmoothnessAdjust;SmoothnessAdjust;4;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-2779.236,279.8841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;12;-2628.835,279.8841;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-3250.799,88.54057;Inherit;True;Property;_CampMask;CampMask;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-2947.598,88.54066;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;8;-2823.301,88.50486;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-2943.237,221.4838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-3244.4,-6.659406;Inherit;False;Property;_MetallicAdjust;MetallicAdjust;3;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2835.517,-303.1396;Inherit;True;Property;_BaseMap;BaseMap;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-2833.118,-114.3394;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GammaToLinearNode;13;-2542.941,-302.295;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-677.2393,1733.23;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-470.4103,1635.835;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-238.1875,1634.354;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;191.3689,1634.927;Inherit;False;NoiseMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-2824.682,795.3642;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;452.5481,1268.508;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;25.55557,1358.369;Inherit;False;Property;_Max;Max;23;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;25.55557,1284.769;Inherit;False;Property;_Min;Min;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-128.0589,1169.434;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;56;-300.1215,1170.37;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;628.784,1271.545;Inherit;False;DissolveEdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-619.6078,1274.025;Inherit;False;Property;_EdgePower;EdgePower;21;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;41;-614.4868,1170.472;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;33;-66.9191,1634.19;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-450.1995,766.308;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;70;-2063.332,648.0751;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-2434.002,794.3886;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-2631.717,794.7093;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2630.976,893.2583;Inherit;False;Property;_DissolveOffset;DissolveOffset;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2431.645,891.4133;Inherit;False;Property;_DissolveSpread;DissolveSpread;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-458.1579,1169.989;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-255.3512,494.4831;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;18;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-2336.604,1082.373;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-2512.899,1082.031;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2697.854,1079.495;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2709.873,1180.901;Inherit;False;Property;_VertEffectOffset;VertEffectOffset;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;79;-2167.883,1082.513;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;81;-2233.145,1177.37;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2005.147,1155.771;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2510.542,1179.056;Inherit;False;Property;_VertEffectSpread;VertEffectSpread;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-1796.132,1156.629;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;85;-1665.356,1155.786;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-1420.501,1150.121;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;87;-1664.501,1315.722;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1268.471,1151.415;Inherit;False;FinnalVertOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;84;-2002.212,1298.069;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;90;-2267.021,1393.159;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;91;-2678.221,1397.958;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2428.622,1469.158;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-553.4215,927.8237;Inherit;False;88;FinnalVertOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;95;-3028.395,1931.827;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;97;-2826.172,2072.448;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;99;-2701.117,2072.825;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;2;-2307.403,-302.0502;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;14;-2093.47,-300.7223;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1868.118,-302.1691;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;116;-2695.506,2258.023;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1911.154,2185.255;Inherit;False;Property;_RimPow;RimPow;12;0;Create;True;0;0;0;False;0;False;1.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;107;-1742.79,2064.128;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1744.753,2189.257;Inherit;False;Property;_RimScale;RimScale;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1570.788,2063.327;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1570.351,2180.458;Inherit;False;Property;_RimBias;RimBias;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1401.988,2065.728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1205.004,2063.953;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1384.909,2173.015;Inherit;False;Property;_RimIntensity;RimIntensity;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-982.7127,2054.264;Inherit;False;RimEmiss;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;111;-1442.394,1887.866;Inherit;False;Property;_RimColor;RimColor;8;1;[HDR];Create;True;0;0;0;False;0;False;0.3830188,0.4014236,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-1916.099,2074.475;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-2067.315,2227.115;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;100;-2496.996,2072.929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-2359.476,2074.086;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;101;-2217.452,2073.33;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;-2397.431,2251.205;Inherit;True;Property;_EmissTex;EmissTex;25;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;114;-3067.869,2258.699;Inherit;False;Property;_RimControl;RimControl;9;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-2702.767,2393.581;Inherit;False;RimControl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2062.345,-213.3183;Inherit;False;121;RimControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1709.741,-302.9254;Inherit;False;PBRLighting;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-2303.514,-114.2348;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-3217.016,1929.014;Inherit;False;123;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;98;-3026.51,2094.339;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;61;-2252.759,929.3139;Inherit;False;60;NoiseMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;-2061.054,905.544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1501.535,769.6788;Inherit;False;DissolveMaskg;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-1751.771,768.9791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;-1641.766,768.9628;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-867.3738,1251.448;Inherit;False;Property;_DissolveEdgeOffset;DissolveEdgeOffset;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-2982.064,794.2255;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-2257.707,794.7305;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-2062.27,794.8757;Inherit;False;DissolveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-812.1356,714.717;Inherit;False;110;RimEmiss;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-812.1565,791.3007;Inherit;False;16;PBRLighting;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-810.7598,870.468;Inherit;False;49;DissolveEdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-523.8137,712.2513;Inherit;False;65;DissolveMaskg;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3254.334,1100.139;Inherit;False;Property;_DissolveAmount;DissolveAmount;5;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;38;-471.9303,1784.875;Inherit;False;Property;_NoiseScale;NoiseScale;17;0;Create;True;0;0;0;False;0;False;100,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;18;-3216.606,623.2122;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;19;-3246.904,773.975;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;126;-861.7779,1171.44;Inherit;False;125;DissolveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-350.6183,1339.992;Inherit;False;60;NoiseMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;57;249.0311,1168.776;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;218.0616,1333.568;Inherit;False;Property;_EdgeEmissColor;EdgeEmissColor;19;1;[HDR];Create;True;0;0;0;False;0;False;0,0.9886398,2,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-2287.552,1329.45;Inherit;False;Property;_VertOffsetIntensity;VertOffsetIntensity;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;93;-2716.622,1549.159;Inherit;False;Property;_VertNoiseScale;VertNoiseScale;24;0;Create;True;0;0;0;False;0;False;10,10,10;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;7;0;6;0
WireConnection;7;1;5;1
WireConnection;8;0;7;0
WireConnection;9;0;5;2
WireConnection;13;0;3;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;60;0;33;0
WireConnection;31;0;22;0
WireConnection;47;0;57;0
WireConnection;47;1;48;0
WireConnection;63;0;56;0
WireConnection;63;1;64;0
WireConnection;56;0;43;0
WireConnection;56;1;45;0
WireConnection;49;0;47;0
WireConnection;41;0;126;0
WireConnection;41;1;42;0
WireConnection;33;0;40;0
WireConnection;50;0;112;0
WireConnection;50;1;17;0
WireConnection;50;2;51;0
WireConnection;70;0;29;0
WireConnection;26;0;23;0
WireConnection;26;1;25;0
WireConnection;23;0;31;0
WireConnection;23;1;24;0
WireConnection;43;0;41;0
WireConnection;0;10;66;0
WireConnection;0;13;50;0
WireConnection;0;11;89;0
WireConnection;72;0;73;0
WireConnection;72;1;76;0
WireConnection;73;0;77;0
WireConnection;73;1;75;0
WireConnection;77;0;22;0
WireConnection;77;1;24;0
WireConnection;79;0;72;0
WireConnection;80;0;79;0
WireConnection;80;1;81;0
WireConnection;80;2;82;0
WireConnection;80;3;90;0
WireConnection;83;0;80;0
WireConnection;83;1;84;0
WireConnection;85;0;83;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;88;0;86;0
WireConnection;90;0;92;0
WireConnection;92;0;91;0
WireConnection;92;1;93;0
WireConnection;95;0;124;0
WireConnection;97;0;95;0
WireConnection;97;1;98;0
WireConnection;99;0;97;0
WireConnection;2;0;13;0
WireConnection;2;1;4;0
WireConnection;2;3;8;0
WireConnection;2;4;12;0
WireConnection;14;0;2;0
WireConnection;117;0;14;0
WireConnection;117;1;122;0
WireConnection;116;0;114;0
WireConnection;107;0;120;0
WireConnection;107;1;104;0
WireConnection;108;0;107;0
WireConnection;108;1;105;0
WireConnection;109;0;108;0
WireConnection;109;1;106;0
WireConnection;102;0;111;0
WireConnection;102;1;109;0
WireConnection;102;2;103;0
WireConnection;110;0;102;0
WireConnection;120;0;101;0
WireConnection;120;1;118;0
WireConnection;118;0;101;0
WireConnection;118;1;119;0
WireConnection;100;0;99;0
WireConnection;115;0;100;0
WireConnection;115;1;116;0
WireConnection;101;0;115;0
WireConnection;121;0;114;0
WireConnection;16;0;117;0
WireConnection;123;0;4;0
WireConnection;34;0;29;0
WireConnection;34;1;61;0
WireConnection;65;0;37;0
WireConnection;71;0;70;0
WireConnection;71;1;34;0
WireConnection;37;0;71;0
WireConnection;22;0;18;2
WireConnection;22;1;19;2
WireConnection;29;0;26;0
WireConnection;29;1;27;0
WireConnection;125;0;29;0
WireConnection;57;0;63;0
WireConnection;57;1;59;0
WireConnection;57;2;58;0
ASEEND*/
//CHKSM=DD8016DF16E2CF2D77AEE7FD6093E8C59D1B8E79