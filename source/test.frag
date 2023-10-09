#ifdef GL_ES
#endif

//head manual mport
varying vec4 openfl_ColorMultiplierv;
varying vec4 openfl_ColorOffsetv;
varying vec2 openfl_TextureCoordv;

uniform bool openfl_HasColorTransform;
uniform sampler2D openfl_Texture;
uniform vec2 openfl_TextureSize;

//header manual import end

uniform sampler2D bgImage;
uniform vec2 uOrigin;
uniform float uScale;
uniform float uGlowRadius;

// I added this! adjust as needed to change dim setting, will apply to both FG and BG -- zurtar
const float dimFactor=.8;

vec2 scalePos(vec2 p,float scale)
{
    vec2 origin=uOrigin;// / openfl_TextureSize;
    return origin+(p-origin)/scale;
}

float getShadow(vec2 p)
{
    // Not an effecient way to do this, but just scaling up the texture and put shadow if any part of it is "blocked"
    float shadowAmount=0.;
    
    for(float scale=1.;scale<2.;scale+=.02)
    {
        shadowAmount = max(shadowAmount,texture2D(bitmap,scalePos(p,scale)).a);
    }
    return shadowAmount;
}

float getGlow(vec2 p)
{
    vec2 res=openfl_TextureSize;
    p=p-uOrigin;
    p.y*=res.y/res.x;
    return 1.-smoothstep(uGlowRadius*.5,uGlowRadius,length(p));
}

const vec4 fgGlow=vec4(.7412,.251,.0235,.5);

vec4 applyFgGlow(vec4 fg,float glowAmount)
{
    vec3 glowRgb=fgGlow.rgb*fgGlow.a*glowAmount;
    vec3 mult=fg.rgb*glowRgb;
    vec3 add=fg.rgb+glowRgb;
    
    return vec4((mult+add)*dimFactor,fg.a);
}

void main()
{
    vec2 uv=openfl_TextureCoordv;
    
    vec4 bg=texture2D(bgImage,uv);
    vec4 fg=texture2D(bitmap,uv);
    float shadowAmount=getShadow(uv);
    float glowAmount=getGlow(uv);
    
    // I just dont call bgGlow because I dont want to affect our static background. its brightness should be constant.
    gl_FragColor=mix(vec4(0,0,0,0),applyFgGlow(fg,glowAmount),fg.a);
    
}