uniform sampler2D bgImage;
uniform float uScale;


void main()
{
    vec2 uv=openfl_TextureCoordv;
    
    vec4 bg=texture2D(bgImage,uv);
    vec4 fg=texture2D(bitmap,uv);
        
    gl_FragColor=mix(bg/2,fg,fg.a);
}