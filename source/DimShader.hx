package;

import flixel.FlxG;
import flixel.math.FlxPoint;

class DimShader extends flixel.system.FlxAssets.FlxShader
{
	/**
	 * the dimness caused by the * dimfactor compunds each tile we add the filter, we need to rewrite this so that it takes several glowing points
	 * that way we make 1 shader pass it the orgin poins and it computes everything, rather than overlaping 12 different shaders and stacking this dim effect.
	 * 
	 * that would also let us stop the lights from combining when they hit
	 */
	@:glFragmentSource('
		#pragma header

uniform sampler2D bgImage;
uniform float uScale;


void main()
{
    vec2 uv=openfl_TextureCoordv;
    
    vec4 bg=texture2D(bgImage,uv);
    vec4 fg=texture2D(bitmap,uv);
        
    gl_FragColor=mix(bg/2,fg,fg.a);
}
	')
	public function new()
	{
		super();
	}
}
