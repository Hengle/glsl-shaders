/* Filename: chromaticity 

   Copyright (C) 2023 W. M. Martinez
   splitted and adjusted by DariusG

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. 
   */
 
#pragma parameter Readme "READ GLSL FILE FOR VARIOUS COEFFS" 0.0 0.0 1.0 1.0 
#pragma parameter CHROMA_A_X "Chromaticity R x" 0.670 0.0 1.0 0.001
#pragma parameter CHROMA_A_Y "Chromaticity R y" 0.330 0.0 1.0 0.001
#pragma parameter CHROMA_B_X "Chromaticity G x" 0.210 0.0 1.0 0.001
#pragma parameter CHROMA_B_Y "Chromaticity G y" 0.710 0.0 1.0 0.001
#pragma parameter CHROMA_C_X "Chromaticity B x" 0.140 0.0 1.0 0.001
#pragma parameter CHROMA_C_Y "Chromaticity B y" 0.080 0.0 1.0 0.001
#pragma parameter CHROMA_A_WEIGHT "Chromaticity R luminance weight" 0.299 0.0 1.0 0.01
#pragma parameter CHROMA_B_WEIGHT "Chromaticity G luminance weight" 0.587 0.0 1.0 0.01
#pragma parameter CHROMA_C_WEIGHT "Chromaticity B luminance weight" 0.114 0.0 1.0 0.01
#pragma parameter CRT_TR0 "Transfer Function" 0.018 0.0 0.2 0.001
#pragma parameter CRT_TR "Transfer Function" 0.099 0.0 0.2 0.001
#pragma parameter CRT_TR2 "Transfer Function" 4.5 3.0 5.0 0.05
#pragma parameter SCALE_W "Scale white point" 1.0 0.0 1.0 1.0
#pragma parameter GAMMAIN "Gamma In" 2.4 1.0 4.0 0.05
#pragma parameter GAMMAOUT "Gamma Out" 2.2 1.0 4.0 0.05


/* 
SMPTE-C/170M used by NTSC and PAL and by SDTV in general.
REC709       used by HDTV in general.
SRGB         used by most webcams and computer graphics. ***NOTE***: Gamma 2.4
BT2020       used by Ultra-high definition television (UHDTV) and wide color gamut.
SMPTE240     used during the early days of HDTV (1988-1998).
NTSC1953     used by NTSC at 1953. 
EBU          used by PAL/SECAM in 1975. Identical to REC601.
*/


//			  RX   RY      GX     GY     BX      BY      RL    GL    BL     TR0    TR   TR2
// SMPTE C 	0.630 0.340 / 0.310 0.595 / 0.155	0.070 / 0.299 0.587 0.114 / 0.018 0.099 4.5
// REC709  	0.640 0.330 / 0.300 0.600 / 0.150	0.060 / 0.212 0.715 0.072 / 0.018 0.099 4.5
// SRGB  	0.640 0.330 / 0.300 0.600 / 0.150	0.060 / 0.299 0.587 0.114 / 0.040 0.055 12.92
// BT2020   0.708 0.292 / 0.170 0.797 / 0.131   0.046 / 0.262 0.678 0.059 / 0.059 0.099 4.5
// SMPTE240 0.630 0.340 / 0.310 0.595 / 0.155   0.070 / 0.212 0.701 0.086 / 0.091 0.111 4.0
// NTSC1953 0.670 0.330 / 0.210 0.710 / 0.140   0.080 / 0.299 0.587 0.114 / 0.081 0.099 4.5
// EBU      0.640 0.330 / 0.290 0.600 / 0.150   0.060 / 0.299 0.587 0.114 / 0.081 0.099 4.5


const vec3 WHITE = vec3(1.0, 1.0, 1.0);

#ifdef GL_ES
#define COMPAT_PRECISION mediump
precision mediump float;
#else
#define COMPAT_PRECISION
#endif


uniform vec2 TextureSize;
varying vec2 TEX0;

#if defined(VERTEX)
uniform mat4 MVPMatrix;
attribute vec4 VertexCoord;
attribute vec2 TexCoord;
uniform vec2 InputSize;
uniform vec2 OutputSize;

void main()
{
	TEX0 = TexCoord;                    
	gl_Position = MVPMatrix * VertexCoord;     
}

#elif defined(FRAGMENT)

uniform sampler2D Texture;
uniform vec2 OutputSize;

#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define FragColor gl_FragColor
#define Source Texture


#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION	float CHROMA_A_X;
uniform COMPAT_PRECISION	float CHROMA_A_Y;
uniform COMPAT_PRECISION	float CHROMA_B_X;
uniform COMPAT_PRECISION	float CHROMA_B_Y;
uniform COMPAT_PRECISION	float CHROMA_C_X;
uniform COMPAT_PRECISION	float CHROMA_C_Y;
uniform COMPAT_PRECISION	float CHROMA_A_WEIGHT;
uniform COMPAT_PRECISION	float CHROMA_B_WEIGHT;
uniform COMPAT_PRECISION	float CHROMA_C_WEIGHT;
uniform COMPAT_PRECISION	float SCALE_W;
uniform COMPAT_PRECISION	float CRT_TR0;
uniform COMPAT_PRECISION	float CRT_TR;
uniform COMPAT_PRECISION	float CRT_TR2;
uniform COMPAT_PRECISION	float GAMMAIN;
uniform COMPAT_PRECISION	float GAMMAOUT;

#else

#define CS 0.0
#define  CHROMA_A_X 0.63
#define  CHROMA_A_Y 0.34 
#define  CHROMA_B_X 0.31
#define  CHROMA_B_Y 0.595
#define  CHROMA_C_X 0.155
#define  CHROMA_C_Y 0.07
#define  CHROMA_A_WEIGHT 0.2124
#define  CHROMA_B_WEIGHT 0.7011
#define  CHROMA_C_WEIGHT 0.0866
#define  SCALE_W 1.0
#define  CRT_TR0 0.018
#define  CRT_TR 0.099
#define  CRT_TR2 4.5
#define  GAMMAIN 2.4
#define  GAMMAOUT 2.25
#endif



mat3 XYZ_TO_sRGB = mat3(
	 3.2406255, -0.9689307,  0.0557101,
	-1.5372080,  1.8758561, -0.2040211,
	-0.4986286,  0.0415175,  1.0569959);

mat3 colorspace_rgb()
{
	return XYZ_TO_sRGB;
}


vec3 xyY_to_XYZ(const vec3 xyY)
{
	float x = xyY.x;
	float y = xyY.y;
	float Y = xyY.z;
	float z = 1.0 - x - y;

	return vec3(Y * x / y, Y, Y * z / y);
}



vec3 Yrgb_to_RGB(mat3 toRGB, vec3 W, vec3 Yrgb)
{
	mat3 xyYrgb = mat3(CHROMA_A_X, CHROMA_A_Y, Yrgb.r,
	                   CHROMA_B_X, CHROMA_B_Y, Yrgb.g,
	                   CHROMA_C_X, CHROMA_C_Y, Yrgb.b);
	mat3 XYZrgb = mat3(xyY_to_XYZ(xyYrgb[0]),
	                   xyY_to_XYZ(xyYrgb[1]),
	                   xyY_to_XYZ(xyYrgb[2]));
	mat3 RGBrgb = mat3(toRGB * XYZrgb[0],
	                   toRGB * XYZrgb[1],
	                   toRGB * XYZrgb[2]);
	return vec3(dot(W, vec3(RGBrgb[0].r, RGBrgb[1].r, RGBrgb[2].r)),
	            dot(W, vec3(RGBrgb[0].g, RGBrgb[1].g, RGBrgb[2].g)),
	            dot(W, vec3(RGBrgb[0].b, RGBrgb[1].b, RGBrgb[2].b)));
}


float sdr_linear(const float x)
{
	return x < CRT_TR0 ? x / CRT_TR2 : pow((x + CRT_TR) / (1.0+ CRT_TR), GAMMAIN);
}

vec3 sdr_linear(const vec3 x)
{
	return vec3(sdr_linear(x.r), sdr_linear(x.g), sdr_linear(x.b));
}

float srgb_gamma(const float x)
{
	return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / GAMMAOUT) - 0.055;
}

vec3 srgb_gamma(const vec3 x)
{
	return vec3(srgb_gamma(x.r), srgb_gamma(x.g), srgb_gamma(x.b));
}

void main()
{
	mat3 toRGB = colorspace_rgb();
	vec3 Yrgb = texture2D(Source, vTexCoord).rgb;
	Yrgb = sdr_linear(Yrgb);
	vec3 W = vec3(CHROMA_A_WEIGHT, CHROMA_B_WEIGHT, CHROMA_C_WEIGHT);
	vec3 RGB = Yrgb_to_RGB(toRGB, W, Yrgb);
	if (SCALE_W > 0.0) {
		vec3 white = Yrgb_to_RGB(toRGB, W, WHITE);
		float G = 1.0 / max(max(white.r, white.g), white.b);

		RGB *= G;
	}
	RGB = clamp(RGB, 0.0, 1.0);
	RGB = srgb_gamma(RGB);
	FragColor = vec4(RGB, 1.0);
}




#endif
