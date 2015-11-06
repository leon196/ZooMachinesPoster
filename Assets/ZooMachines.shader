Shader "Unlit/ZooMachines"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PerlinTex ("Texture", 2D) = "white" {}
		_TitleTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
   		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
		    Cull off
	    	Blend SrcAlpha OneMinusSrcAlpha     
		    ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#define PI 3.1416
			#define POSTERIZE_THRESHOLD 2.0
			#define NOISE_LENGTH 0.5

			float2 pixelate ( float2 pixel, float2 details ) { return floor(pixel * details) / details; }
			float3 posterize ( float3 color, float details ) { return floor(color * details) / details; }
			float luminance ( float3 color ) { return (color.r + color.g + color.b) / 3.0; }

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 screenUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _PerlinTex;
			sampler2D _TitleTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.screenUV = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.screenUV.xy / i.screenUV.w;
				float2 screenUV = uv;
				float2 uvTitle = uv;
				uvTitle.y /= 1.0 / 3.0;

				float2 pixelResolution = float2(pow(2.0, 7.0), pow(2.0, 7.0));

				// Center & Scale UV
				uv.x -= 0.5;
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				uv.x += 0.5;
				uv.x = 1.0 - uv.x;

				// Pixelate
				pixelResolution.x *= _ScreenParams.x / _ScreenParams.y;
				uv = pixelate(uv, _ScreenParams.xy / 4.0);

				// Maths infos about the current pixel position
				float2 center = uv - float2(0.5, 0.5);
				float angle = atan2(center.y, center.x);
				float radius = length(center);
				float ratioAngle = (angle / PI) * 0.5 + 0.5;

				// Displacement from noise
				float2 angleUV = fmod(abs(float2(0, angle / PI)), 1.0);
				//angleUV = pixelate(angleUV, float2(64.0));
				float offset = tex2D(_PerlinTex, angleUV).r * NOISE_LENGTH;

				// Displaced pixel color
				float2 p = float2(cos(angle), sin(angle)) * offset + float2(0.5, 0.5);

				// Apply displacement
				uv = lerp(uv, p, step(offset, radius));

				// Get color from texture
				float3 color = tex2D(_MainTex, uv).rgb;

				// Retro effect
				//color = posterize(color, POSTERIZE_THRESHOLD);

				// Just Yellow and Red
				float lum = luminance(color);
				float3 black = float3(0.0, 0.0, 0.0);
				float3 red = float3(1.0, 0.0, 0.0);
				float3 yellow = float3(1.0, 1.0, 0.0);
				//color = lerp(black, red, smoothstep(0.0, 0.5, lum));
				color = lerp(float3(0, 0, 0), float3(1,0,0), step(0.45, lum));
				color = lerp(color, float3(1,1,0), step(0.65, lum));
				color = lerp(color, float3(1,1,1), step(0.85, lum));


				float4 webcam = tex2D(_TitleTex, uvTitle);

				float3 col = lerp(color, webcam.rgb, webcam.a * step(2.0 / 3.0, 1.0 - screenUV.y));
				return float4(col, 1.0);
			}
			ENDCG
		}
	}
}
