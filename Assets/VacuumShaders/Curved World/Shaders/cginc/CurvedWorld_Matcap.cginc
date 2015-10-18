#ifndef VACUUM_CURVEDWORLD_MATCAP_CGINC
#define VACUUM_CURVEDWORLD_MATCAP_CGINC

#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"

//Variables/////////////////////////////////////////////////////////////
fixed4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;

sampler2D _Matcap;

#ifdef _NORMALMAP
	sampler2D _BumpMap;
	half _BumpMap_UV_Scale;
	half _BumpStrength;
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

//Structs///////////////////////////////////////////////////////////////
struct vInput
{
	float4 vertex : POSITION;
    
	float4 texcoord : TEXCOORD0;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR;
	#endif
};

struct vOutput
{
	float4 pos : SV_POSITION;

	half4 texcoord : TEXCOORD0;
	half2 matcap : TEXCOORD1;
				
	#ifdef V_CW_RIM
		half rim : TEXCOORD2;
	#endif

	#ifdef _NORMALMAP
		float3 r1 : TEXCOORD3; 
		float3 r2 : TEXCOORD4; 
		float3 r3 : TEXCOORD5;
	#endif

	UNITY_FOG_COORDS(6)

 	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR;
	#endif
};

//Vertex////////////////////////////////////////////////////////////////
vOutput vert(vInput v)
{ 
	vOutput o;
	UNITY_INITIALIZE_OUTPUT(vOutput,o); 
	
		
	V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);		
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


	#ifdef _NORMALMAP
		fixed3 normal_WS = UnityObjectToWorldNormal(v.normal);
		fixed3 tangent_WS = UnityObjectToWorldDir(v.tangent.xyz);
		fixed3 binormal_WS = cross(normal_WS, tangent_WS) * v.tangent.w;
		
		o.r1 = fixed3(tangent_WS.x, binormal_WS.x, normal_WS.x);
		o.r2 = fixed3(tangent_WS.y, binormal_WS.y, normal_WS.y);
		o.r3 = fixed3(tangent_WS.z, binormal_WS.z, normal_WS.z);
	#else
		float3 normal_OS = normalize(_World2Object[0].xyz * v.normal.x + _World2Object[1].xyz * v.normal.y + _World2Object[2].xyz * v.normal.z);
		o.matcap.xy = mul((float3x3)UNITY_MATRIX_V, normal_OS) * 0.5 + 0.5;
	#endif
		

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		o.color = v.color;
	#endif	

	#ifdef V_CW_RIM
		half rim = saturate(dot (v.normal, normalize(ObjSpaceViewDir(v.vertex))) + _V_CW_Rim_Bias);
		o.rim = rim * rim;
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


	#ifdef V_CW_CUTOUT
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

		fixed3 normals = UnpackNormal(normalMap);
		normals = normalize(fixed3(normals.x * _BumpStrength, normals.y * _BumpStrength, normals.z));



		float3 matcapN = float3(dot(i.r1, normals), dot(i.r2, normals), dot(i.r3, normals));
		matcapN = mul((float3x3)UNITY_MATRIX_V, matcapN);
		fixed4 matColor = tex2D(_Matcap, matcapN.xy * 0.5 + 0.5) * 2;
	#else
		fixed4 matColor = tex2D(_Matcap, i.matcap) * 2;
	#endif
	

	#ifdef V_CW_MATCAP_BLEND_ADD					
		retColor.rgb += matColor.rgb;
	#else
		retColor.rgb *= matColor.rgb;
	#endif

	 
	
	#ifdef _EMISSION
		retColor.rgb += tex2D(_EmissionMap, i.texcoord.xy).rgb * _EmissionColor.rgb;
	#endif

	#ifdef V_CW_RIM
		retColor.rgb = lerp(_V_CW_Rim_Color.rgb, retColor.rgb, i.rim);
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