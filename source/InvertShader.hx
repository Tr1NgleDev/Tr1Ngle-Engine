package;

import flixel.system.FlxAssets.FlxShader;

class InvertShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform int turnedOn;

		void main()
		{	
			vec2 uv = openfl_TextureCoordv;

			vec4 col = texture2D(bitmap, uv);
			if(turnedOn >= 1)
				gl_FragColor = vec4(1.0 - col.rgb, col.a);
			else
				gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}