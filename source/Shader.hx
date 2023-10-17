package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import haxe.Log;
import openfl.display.ShaderParameter;

class Shader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header

	uniform sampler2D bgImage;	
	uniform float uScale;

	const vec3 unshadedRgb = vec3(0.6, 0.6, 1.0);
	const vec4 shadeColor = vec4(0.0, 0.0, 0.4, 0.6);
	const vec4 bgGlow = vec4(1.0, 0.125, 0.0, 0.25);
	vec4 applyBgGlow(vec4 bg, float shadeAmount, float glowAmount)
	{
			vec3 shadeRgb = mix(unshadedRgb, shadeColor.rgb, shadeColor.a * shadeAmount);
			vec3 glowRgb = bgGlow.rgb * bgGlow.a * glowAmount;
			vec3 mult = (bg.rgb + glowRgb ) * (glowRgb + shadeRgb);
			return vec4(mult, bg.a);
	}
		
		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			
			vec4 bg = texture2D(bgImage, uv);
			vec4 fg = texture2D(bitmap, uv);

			gl_FragColor = mix(bg, fg, fg.a *.8);
		}
	')
	public function new()
	{
		super();
	}
}
/**
 * https://www.youtube.com/watch?v=sMbW4sptVnE
 * 
 * ^ gsl music, it helps
 * 
 * https://www.youtube.com/watch?v=EUtA0AbYNic
 * 
 *  ^ crash and burn
 * 
 * https://www.youtube.com/watch?v=EUtA0AbYNic
 * 
 *  !!!!!!!!!! slaughter beach dog 
 */
