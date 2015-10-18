#ifndef VACUUM_CURVEDWORLD_FORWARDBASE_CGINC
#define VACUUM_CURVEDWORLD_FORWARDBASE_CGINC

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "../cginc/CurvedWorld_Base.cginc"
#include "../cginc/CurvedWorld_Functions.cginc"

//Defines/////////////////////////////////////////////////////////////
#ifdef _NORMALMAP
	#define V_CW_LIGHTDIR i.lightDir
#else
	#define V_CW_LIGHTDIR _WorldSpaceLightPos0.xyz
#endif

#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || (defined(V_CW_SPECULAR) && !defined(_NORMALMAP))
	#define V_CW_V_NEED_VIEWDIR_WS
#endif
#if defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_RIM) || (defined(V_CW_SPECULAR) && defined(_NORMALMAP))
	#define V_CW_V_NEED_VIEWDIR_OS
#endif


//FUCK YOU -> d3d11_9x
#ifdef SHADER_API_D3D11_9X
	#ifndef LIGHTMAP_ON
			
		#if (defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)) && defined(V_CW_FOG) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
			#ifdef V_CW_SPECULAR
			#undef V_CW_SPECULAR
			#endif
		#endif
		#if (defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)) && defined(_NORMALMAP) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
			#ifdef V_CW_SPECULAR
			#undef V_CW_SPECULAR
			#endif
		#endif
		#if defined(_EMISSION) && defined(V_CW_FOG) && defined(V_CW_IBL) && defined(V_CW_RIM) && defined(_NORMALMAP) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
			#ifdef V_CW_SPECULAR
			#undef V_CW_SPECULAR
			#endif
		#endif

	#endif
#endif

//Variables/////////////////////////////////////////////////////////////
fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;

#ifdef _NORMALMAP
	sampler2D _BumpMap;
	half _BumpMap_UV_Scale;
	half _BumpStrength;
#endif

#ifdef V_CW_SPECULAR
	fixed _V_CW_Specular_Intensity;
	fixed _V_CW_SpecularOffset;
	sampler2D _V_CW_Specular_Lookup;
#endif

#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
	samplerCUBE _Cube;
	fixed4 _ReflectColor;
	fixed _ReflectStrengthAlphaOffset;

	#ifdef V_CW_REFLECTIVE_FRESNEL
		half _V_CW_Fresnel_Bias;
	#endif
#endif


#ifdef _NORMALMAP
	#if defined(V_CW_DECAL) || defined(V_CW_DETAIL) || defined(V_CW_BLEND_BY_VERTEX)
		sampler2D _SecondBumpMap;
		half _SecondBumpMap_UV_Scale;
	#endif
#endif

#ifdef V_CW_DECAL
	sampler2D _DecalTex;
	half4 _DecalTex_ST;
	fixed2 _V_CW_DecalTex_Scroll;
#endif

#ifdef V_CW_DETAIL
	sampler2D _Detail;
	half4 _Detail_ST;
	fixed2 _V_CW_Detail_Scroll;
#endif

#ifdef V_CW_BLEND_BY_VERTEX
	fixed _VertexBlend;
	sampler2D _BlendTex;
	half4 _BlendTex_ST;
	fixed2 _V_CW_BlendTex_Scroll;
#endif

#ifdef V_CW_CUTOUT
	half _Cutoff;
#endif

#ifdef _EMISSION
	sampler2D _EmissionMap;
	half4 _EmissionColor;
#endif

#ifdef V_CW_RIM
	fixed4 _V_CW_Rim_Color;
	fixed  _V_CW_Rim_Bias;
#endif

#if defined(V_CW_MOBILE_TERRAIN)
	sampler2D _V_CW_Control;

	sampler2D _V_CW_Splat1; half _V_CW_Splat1_uvScale;
	sampler2D _V_CW_Splat2; half _V_CW_Splat2_uvScale;

	#ifdef V_CW_TERRAIN_3TEX 
		sampler2D _V_CW_Splat3; 
		half _V_CW_Splat3_uvScale;
	#endif

	#ifdef V_CW_TERRAIN_4TEX 
		sampler2D _V_CW_Splat4; 
		half _V_CW_Splat4_uvScale;
	#endif
#endif

#ifdef V_CW_IBL
	half _V_CW_IBL_Intensity;
	half _V_CW_IBL_Contrast;
	samplerCUBE _V_CW_IBL_Cube;	
#endif

//Structs///////////////////////////////////////////////////////////////
struct vInput
{
	float4 vertex : POSITION;   

	float4 texcoord : TEXCOORD0;

	#ifndef LIGHTMAP_OFF
		float4 texcoord1 : TEXCOORD1;
	#endif

	float3 normal : NORMAL;

	float4 tangent : TANGENT;

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR0;
	#endif
};

struct vOutput
{
	float4 pos : SV_POSITION;
	half4 texcoord : TEXCOORD0;

	half4 normal : TEXCOORD1; //xyz - normal, w - rim

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		half4 refl : TEXCOORD2;	//xyz - refl, w - fresnel
	#endif


	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		float4 color : COLOR0;
	#endif

	
	#ifdef V_CW_FOG
		UNITY_FOG_COORDS(3)
	#endif


	#ifndef LIGHTMAP_OFF
		half2 lm : TEXCOORD4;
	#else
		half4 vLight : TEXCOORD4;

		#ifdef V_CW_SPECULAR
			half4 viewDir : TEXCOORD5;	//xyz - viewdir, w - specular(nh)
		#endif

		#ifdef _NORMALMAP
			half3 lightDir : TEXCOORD6;
		#endif	

		SHADOW_COORDS(7)
	#endif
};

//Vertex////////////////////////////////////////////////////////////////
vOutput vert(vInput v)
{ 
	vOutput o;
	UNITY_INITIALIZE_OUTPUT(vOutput,o); 

		
	#ifndef LIGHTMAP_OFF
		#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
			V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);	
		#else
			V_CW_TransformPoint(v.vertex);	
		#endif
	#else
		V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);	
	#endif
	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);


	#ifdef V_CW_MOBILE_TERRAIN
		o.texcoord.xy = v.texcoord.xy;
	#else
		o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		o.texcoord.xy += _V_CW_MainTex_Scroll.xy * _Time.x;
	#endif


	#ifdef V_CW_DECAL
		o.texcoord.zw = v.texcoord.xy * _DecalTex_ST.xy + _DecalTex_ST.zw;
		o.texcoord.zw += _V_CW_DecalTex_Scroll.xy * _Time.x;
	#elif defined(V_CW_DETAIL)
		o.texcoord.zw = v.texcoord.xy * _Detail_ST.xy + _Detail_ST.zw;
		o.texcoord.zw += _V_CW_Detail_Scroll.xy * _Time.x;
	#elif defined(V_CW_BLEND_BY_VERTEX)
		o.texcoord.zw = v.texcoord.xy * _BlendTex_ST.xy + _BlendTex_ST.zw;
		o.texcoord.zw += _V_CW_BlendTex_Scroll.xy * _Time.x;
	#endif
	


	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		o.color = v.color;
	#endif
	

	float3 normal_WS = UnityObjectToWorldNormal(v.normal);
	
	#ifdef V_CW_V_NEED_VIEWDIR_WS
		float3 viewDir_WS = WorldSpaceViewDir(v.vertex);
	#endif
	#ifdef V_CW_V_NEED_VIEWDIR_OS
		float3 viewDir_OS = normalize(ObjSpaceViewDir(v.vertex));
	#endif

	
	#ifndef LIGHTMAP_OFF
		o.lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#else
		#if defined(VERTEXLIGHT_ON) && defined(V_CW_MOBILE_INCLUDE_VERTEX_POINTLIGHTS)	
			float3 pos_WS = mul(_Object2World, v.vertex).xyz;
			
			o.vLight.rgb = Shade4PointLights ( unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
						 					   unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
											   unity_4LightAtten0, pos_WS, normal_WS );
		#endif


		#ifdef V_CW_MOBILE_LIGHT_CALC_PER_PIXEL
			#ifdef _NORMALMAP
				TANGENT_SPACE_ROTATION;

				o.lightDir = normalize(mul (rotation, ObjSpaceLightDir(v.vertex)));

				#ifdef V_CW_SPECULAR
					o.viewDir.xyz = mul (rotation, viewDir_OS);
				#endif
			#else
				#ifdef V_CW_SPECULAR
					o.viewDir.xyz = viewDir_WS;
				#endif
			#endif
		#else
			o.vLight.a = max(0, dot (normal_WS, _WorldSpaceLightPos0.xyz));	
			 
			#ifdef V_CW_SPECULAR
				o.viewDir.w = max (0, dot(normal_WS, normalize(_WorldSpaceLightPos0.xyz + normalize(viewDir_WS))));
				o.viewDir.w = clamp(o.viewDir.w + _V_CW_SpecularOffset, 0, 1);
			#endif
		#endif
	#endif
		

	o.normal.xyz = normal_WS;


	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)		
		o.refl.xyz = normalize(reflect(-viewDir_WS, normal_WS));

		#ifdef V_CW_REFLECTIVE_FRESNEL
			half fresnel = 1 - saturate(dot (v.normal, viewDir_OS) + _V_CW_Fresnel_Bias);
			o.refl.w = fresnel * fresnel;
		#endif
	#endif

	#ifdef V_CW_RIM
		half rim = saturate(dot (normalize(v.normal), viewDir_OS) + _V_CW_Rim_Bias);
		o.normal.w = rim * rim;
	#endif	
	
	#ifdef LIGHTMAP_OFF
		TRANSFER_SHADOW(o);
	#endif
	#ifdef V_CW_FOG
		UNITY_TRANSFER_FOG(o,o.pos); 
	#endif

	return o;
} 
 

//Fragment//////////////////////////////////////////////////////////////
fixed4 frag (vOutput i) : SV_Target
{
	#ifdef V_CW_MOBILE_TERRAIN
		#ifdef V_CW_TERRAINBLEND_VERTEXCOLOR
			half4 splat_control = i.color;
		#else
			half4 splat_control = tex2D (_V_CW_Control, i.texcoord.xy);
		#endif

		//Normalise controll texture
		#if defined(V_CW_TERRAIN_4TEX)
			splat_control /= (splat_control.r + splat_control.g + splat_control.b + splat_control.a);
		#elif defined(V_CW_TERRAIN_3TEX)
			splat_control.rgb /= (splat_control.r + splat_control.g + splat_control.b);
		#else
			splat_control.rg /= (splat_control.r + splat_control.g);
		#endif

		
		fixed4 mainTex  = splat_control.r * tex2D (_V_CW_Splat1, i.texcoord.xy * _V_CW_Splat1_uvScale);
		mainTex += splat_control.g * tex2D (_V_CW_Splat2, i.texcoord.xy * _V_CW_Splat2_uvScale);

		#ifdef V_CW_TERRAIN_3TEX
			mainTex += splat_control.b * tex2D (_V_CW_Splat3, i.texcoord.xy * _V_CW_Splat3_uvScale);
		#endif

		#ifdef V_CW_TERRAIN_4TEX
			mainTex += splat_control.a * tex2D (_V_CW_Splat4, i.texcoord.xy * _V_CW_Splat4_uvScale);
		#endif
		
		fixed4 retColor = mainTex;
	#else
		half4 mainTex = tex2D(_MainTex, i.texcoord.xy);

		#ifdef V_CW_DECAL
			fixed4 decal = tex2D(_DecalTex, i.texcoord.zw);
			fixed4 retColor = fixed4(lerp(mainTex.rgb, decal.rgb, decal.a), mainTex.a);
		#elif defined(V_CW_DETAIL)
			fixed4 retColor = mainTex;
			retColor.rgb *= tex2D(_Detail, i.texcoord.zw).rgb * 2;
		#elif defined(V_CW_BLEND_BY_VERTEX)
			fixed vBlend = clamp(_VertexBlend + i.color.a, 0, 1);
			fixed4 retColor = lerp(mainTex, tex2D(_BlendTex, i.texcoord.zw), vBlend);
		#else
			fixed4 retColor = mainTex;
		#endif
	#endif

	retColor *= _Color;

	#ifdef V_CW_VERTEX_COLOR
		retColor *= i.color;
	#endif 
	 

	#if defined(V_CW_CUTOUT)
		clip(retColor.a - _Cutoff);	
	#elif defined(V_CW_COUTOUT_SOFTEDGE)
		clip(-(retColor.a - _Cutoff));		
	#endif

	
	#ifdef _NORMALMAP
		fixed4 normalMap = tex2D(_BumpMap, i.texcoord.xy * _BumpMap_UV_Scale);				

		#ifdef V_CW_DECAL
			fixed4 secondN =  tex2D(_SecondBumpMap, i.texcoord.zw *_SecondBumpMap_UV_Scale);
			normalMap = lerp(normalMap, secondN, decal.a);		
		#elif defined(V_CW_DETAIL)
			fixed4 secondN =  tex2D(_SecondBumpMap, i.texcoord.zw *_SecondBumpMap_UV_Scale);
			normalMap = (normalMap + secondN) * 0.5;	
		#elif defined(V_CW_BLEND_BY_VERTEX)
			fixed4 secondN =  tex2D(_SecondBumpMap, i.texcoord.zw *_SecondBumpMap_UV_Scale);
			normalMap = lerp(normalMap, secondN, vBlend);		
		#endif

		fixed3 bumpNormal = UnpackNormal(normalMap);
		bumpNormal =  normalize(fixed3(bumpNormal.x * _BumpStrength, bumpNormal.y * _BumpStrength, bumpNormal.z));
	#endif
	

	
	#ifndef LIGHTMAP_OFF
		fixed3 diff = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm));
	#else
		fixed atten = LIGHT_ATTENUATION(i);

		#ifdef V_CW_MOBILE_LIGHT_CALC_PER_PIXEL			
			#ifdef _NORMALMAP
				half3 normal = bumpNormal;				
			#else
				half3 normal = normalize(i.normal.xyz);
			#endif
		
			fixed3 diff = _LightColor0.rgb * max(0, dot(normal, V_CW_LIGHTDIR)) * atten + UNITY_LIGHTMODEL_AMBIENT.xyz;
							
			#ifdef V_CW_SPECULAR  
				half nh = max (0, dot (normal, normalize (V_CW_LIGHTDIR + normalize(i.viewDir.xyz))));
				fixed3 specular = tex2D(_V_CW_Specular_Lookup, half2(clamp(nh + _V_CW_SpecularOffset, 0, 1), 0.5)).rgb * retColor.a * _LightColor0.rgb * atten * _V_CW_Specular_Intensity;
			#endif

		#else
			fixed3 diff = _LightColor0.rgb * i.vLight.a * atten + UNITY_LIGHTMODEL_AMBIENT.xyz;

			#ifdef V_CW_SPECULAR
				fixed3 specular = tex2D(_V_CW_Specular_Lookup, half2(i.viewDir.w, 0.5)).rgb * retColor.a * _LightColor0.rgb * atten * _V_CW_Specular_Intensity;
			#endif								
		#endif	
		
		#ifdef V_CW_MOBILE_INCLUDE_VERTEX_POINTLIGHTS
			diff += i.vLight.rgb;
		#endif	
	#endif
		

	#ifdef V_CW_IBL
		diff += V_UNPACK_IBL(i.normal.xyz);									
	#endif	
				
	retColor.rgb = diff * retColor.rgb;		


	#ifndef LIGHTMAP_OFF
	#else
		#if defined(V_CW_SPECULAR)
			retColor.rgb += specular;
		#endif
	#endif

	
	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		#ifdef _NORMALMAP
			fixed4 reflTex = texCUBE( _Cube, i.refl.xyz + bumpNormal) * _ReflectColor;
		#else
			fixed4 reflTex = texCUBE( _Cube, i.refl.xyz ) * _ReflectColor;
		#endif

		#ifdef V_CW_REFLECTIVE_FRESNEL
			retColor.rgb += reflTex.rgb * i.refl.w * clamp(retColor.a + _ReflectStrengthAlphaOffset, 0, 1);
		#else
			retColor.rgb += reflTex.rgb * clamp(retColor.a + _ReflectStrengthAlphaOffset, 0, 1);
		#endif
	#endif
	
	#ifdef _EMISSION
		retColor.rgb += tex2D(_EmissionMap, i.texcoord.xy).rgb * _EmissionColor.rgb;
	#endif

	#ifdef V_CW_RIM
		retColor.rgb = lerp(_V_CW_Rim_Color.rgb, retColor.rgb, i.normal.w);
	#endif
	


	#ifdef V_CW_FOG
		UNITY_APPLY_FOG(i.fogCoord, retColor); 
	#endif


	#if defined(V_CW_TRANSPARENT) || defined(V_CW_CUTOUT)
		//Empty
	#else
		UNITY_OPAQUE_ALPHA(retColor.a);
	#endif

	return retColor;
}


#endif