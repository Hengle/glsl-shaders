#version 110

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float WHATEVER;
#else
#define WHATEVER 0.0
#endif

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    TEX0.xy = TexCoord.xy*1.0001;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

// compatibility #defines
#define vTexCoord TEX0.xy
#define Source Texture
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float ph_mode;
uniform COMPAT_PRECISION float d_crawl;
uniform COMPAT_PRECISION float mini_hue1;
uniform COMPAT_PRECISION float mini_hue2;
uniform COMPAT_PRECISION float h_deg;
uniform COMPAT_PRECISION float v_deg;
uniform COMPAT_PRECISION float modulo;
uniform COMPAT_PRECISION float rf_audio;

#else
#define ph_mode 0.0
#define d_crawl 0.0
#define mini_hue2 0.0
#define mini_hue1 0.0
#define rf_audio 0.0

#endif

#define iTimer (float(FrameCount) / 60.0)

#define onedeg 0.017453
#define PI   3.14159265358979323846
#define TAU  6.28318530717958647693
const mat3 RGBYUV = mat3(0.299, 0.587, 0.114,
                        -0.299, -0.587, 0.886, 
                         0.701, -0.587, -0.114);

float noise(vec2 co)
{
return fract(sin(iTimer * dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


void main() {

vec3 res = vec3(0.0);

// snes loosely based on internet videos and blargg

float h_ph, v_ph, mod0 = 0.0;
if      (ph_mode == 0.0) {h_ph =  90.0*onedeg; v_ph = PI;        mod0 = 2.0;}
else if (ph_mode == 1.0) {h_ph = 120.0*onedeg; v_ph = PI;        mod0 = 2.0;}
else if (ph_mode == 2.0) {h_ph = 48.0*onedeg; v_ph = 0.0;        mod0 = 2.0;}
else if (ph_mode == 3.0) {h_ph = 120.0*onedeg; v_ph = PI*0.6667; mod0 = 3.0;}
else if (ph_mode == 4.0) {h_ph =  45.0*onedeg; v_ph = 0.0; mod0 = 2.0;}
else                     {h_ph =  h_deg*onedeg; v_ph = v_deg*onedeg; mod0 = modulo;}

float phase = floor(vTexCoord.x*SourceSize.x)*h_ph + floor(vTexCoord.y*SourceSize.y)*v_ph+ noise(vTexCoord)*rf_audio*PI;
phase += d_crawl *(mod(float(FrameCount),3.0))*PI*0.6667;

res = COMPAT_TEXTURE(Source,vTexCoord).rgb*RGBYUV;
res.gb *=0.5*vec2(cos(phase+mini_hue1),sin(phase+mini_hue2));

float signal = dot(vec3(1.0),res);
signal *= 1.0 ;

FragColor.rgb = vec3(signal);
}
#endif
