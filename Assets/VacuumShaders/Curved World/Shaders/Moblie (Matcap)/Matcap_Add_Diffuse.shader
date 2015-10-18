// VacuumShaders 2015
// https://www.facebook.com/VacuumShaders

Shader "Hidden/VacuumShaders/Curved World/Mobile/Matcap/Addative/Texture"
{
	Properties    
	{                    
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		//Modes
		[CurvedWorldLargeLabel] V_CW_Label_Modes("Modes", float) = 0	
		[CurvedWorldRenderingMode] V_CW_Rendering_Mode("  Rendering", float) = 0	
		[CurvedWorldTextureMixMode] V_CW_Texture_Mix_Mode("  Texture Mix", float) = 0

		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color(" Color", color) = (1, 1, 1, 1)  				
		_MainTex (" Map", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)

		//Matcap
		[CurvedWorldLargeLabel] V_CW_Label_Matcap("Matcap", float) = 0	
		[KeywordEnum(Multiply, Add)] V_CW_MATCAP_BLEND ("  Blend Mode",  Float) = 0
		[NoScaleOffset] _Matcap ("  Matcap (RGB)", 2D) = "Gray" {}			


		
		//Curved World
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Curved World Optionals", float) = 0

		[HideInInspector] _V_CW_Rim_Color("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_Rim_Bias("", Range(-1, 1)) = 0.2
		[HideInInspector] _V_CW_Rim_Power("", Range(0.5, 8.0)) = 3
		
		[HideInInspector] _EmissionMap("", 2D) = "black"{}
		[HideInInspector] _EmissionColor("", color) = (1, 1, 1, 1)	

		[HideInInspector] _BumpMap("", 2D) = ""{}
		[HideInInspector] _BumpStrength("", float) = 1
		[HideInInspector] _BumpMap_UV_Scale("", float) = 1	

		[HideInInspector] _SecondBumpMap("", 2D) = ""{}
		[HideInInspector] _SecondBumpMap_UV_Scale("", float) = 1
	}


	SubShader 
	{
		Tags { "Queue"="Transparent" 
		       "IgnoreProjector"="True" 
			   "RenderType"="Transparent" 
		       "CurvedWorldTag"="Matcap/Addative/Texture" 
			   "CurvedWorldNoneRemoveableKeywords"="V_CW_MATCAP_BLEND_MULTIPLY"
			   "CurvedWorldAvailableOptions"="V_CW_VERTEX_COLOR;_EMISSION;V_CW_RIM;V_CW_FOG;_NORMALMAP;" 
			 }
		LOD 150

		//ColorMask0 
		UsePass "Hidden/VacuumShaders/Curved World/ColorMask0/BASE"

		Blend One OneMinusSrcColor
		Cull Off Lighting Off ZWrite Off


		Pass 
	    { 
			CGPROGRAM 
			#pragma vertex vert
	    	#pragma fragment frag
			 


			#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR 
			#pragma shader_feature _EMISSION_OFF _EMISSION
			#pragma shader_feature V_CW_RIM_OFF V_CW_RIM
			#pragma shader_feature V_CW_MATCAP_BLEND_MULTIPLY V_CW_MATCAP_BLEND_ADD
			#pragma shader_feature _NORMALMAP_OFF _NORMALMAP

			#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif  	
			
			#include "../cginc/CurvedWorld_Matcap.cginc" 


			ENDCG

		} //Pass

	} //SubShader	 
	
	CustomEditor "CurvedWorld_Material_Editor"
} //Shader
