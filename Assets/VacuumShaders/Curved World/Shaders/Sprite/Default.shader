Shader "VacuumShaders/Curved World/Sprites/Default"
{
	Properties
	{
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0



		//Curved World
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Curved World Optionals", float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
			"CurvedWorldTag"="Sprites/Default" 
			"CurvedWorldNoneRemoveableKeywords"="" 
			"CurvedWorldAvailableOptions"=""
		} 

		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"


			#include "../cginc/CurvedWorld_Base.cginc" 
			  
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			}; 
			 
			struct v2f
			{
				float4 pos   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			}; 
			
			fixed4 _Color;  

			v2f vert(appdata_t IN) 
			{  
				v2f o; 
				UNITY_INITIALIZE_OUTPUT(v2f,o); 


				V_CW_TransformPoint(IN.vertex); 
				

				o.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				o.texcoord = IN.texcoord;
				o.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
					o.pos = UnityPixelSnap (o.pos);
				#endif 

				return o;  
			}  
			 
			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord) * IN.color;

				c.rgb *= c.a;
				return c;
			}
			ENDCG
		}
	}

	CustomEditor "CurvedWorld_Material_Editor"
}
