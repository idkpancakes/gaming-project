		#pragma header

	uniform sampler2D bgImage;	
    uniform int pointCount;
	uniform vec2 uOrigin;
	uniform mat4 myOrigins;
	uniform float uScale;
	uniform float uGlowRadius;

		// I added this! adjust as needed to change dim setting, will apply to both FG and BG -- ethan
		//const float dimFactor = .8;

	vec2 scalePos(vec2 p, vec2 gPoint, float scale)
	{
    	vec2 origin=gPoint;
    	return origin+(p-origin)/scale;
	}

float getShadow(vec2 p, vec2 gPoint)
{
    // Not an effecient way to do this, but just scaling up the texture and put shadow if any part of it is "blocked"
    float shadowAmount=0.0;
    
    for(float scale=1.;scale<2.;scale+=.02)
    {
        shadowAmount=max(shadowAmount,texture2D(bitmap,scalePos(p, gPoint, scale)).a);
    }
    return shadowAmount;
}

float getGlow(vec2 p, vec2 gPoint)
{
    vec2 res=openfl_TextureSize;
    p=p-gPoint;
    p.y*=res.y/res.x;
    return 1.-smoothstep(uGlowRadius*.25,uGlowRadius,length(p));
}


const vec4 fgGlow = vec4(.7412,.251,.0235,.5);

vec4 applyFgGlow(vec4 fg,float glowAmount)
{
    vec3 glowRgb=fgGlow.rgb*fgGlow.a*glowAmount;
    vec3 mult=fg.rgb*glowRgb;
    vec3 add=fg.rgb+glowRgb;
        
    return vec4((mult+add),fg.a);
}

		const vec3 unshadedRgb = vec3(0.6, 0.6, 1.0);
		const vec4 shadeColor = vec4(0.0, 0.0, 0.4, 0.6);
		const vec4 bgGlow = vec4(1.0, 0.125, 0.0, 0.25);

vec4 applyBgGlow(vec4 bg,float shadeAmount,float glowAmount)
{
	vec3 shadeRgb = mix(unshadedRgb, shadeColor.rgb, shadeColor.a * shadeAmount);
	vec3 glowRgb = bgGlow.rgb * bgGlow.a * glowAmount;
	vec3 mult = (bg.rgb + glowRgb) * (glowRgb + shadeRgb);
	return vec4(mult, bg.a);
    }

void main()
{
    vec2 uv=openfl_TextureCoordv;
    
    vec4 bg=texture2D(bgImage,uv);

    float array[16] = float[16](myOrigins[0][0],myOrigins[1][0],myOrigins[2][0],myOrigins[3][0],myOrigins[0][1],myOrigins[1][1],myOrigins[2][1],myOrigins[3][1],myOrigins[0][2],myOrigins[1][2],myOrigins[2][2],myOrigins[3][2],myOrigins[3][3],myOrigins[1][3],myOrigins[2][3],myOrigins[3][3]);

	vec4 fg=texture2D(bitmap,uv);

	float finalShadow = 0.;
	float finalGlow = 0.;

	for (int i=0; i < pointCount; i++) {
		vec2 glowPoint = vec2(array[i], array[i+1]);

    	float glowAmount = getGlow(uv, glowPoint);
		float shadowAmount = getShadow(uv, glowPoint);

		// if(glowAmount > finalGlow) {
			finalGlow = glowAmount;
			finalShadow = shadowAmount;
		// }
	}

	 // change 0. to finalShadow to reintroduce shadows
   	 gl_FragColor = mix(applyBgGlow(bg,0.,finalGlow), applyFgGlow(fg,finalGlow),fg.a);
}