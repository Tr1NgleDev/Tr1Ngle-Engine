package;

import flixel.system.FlxAssets.FlxShader;

class GrayScaleShader extends FlxShader
{
	@:glFragmentSource('

		#pragma header

		uniform int turnedOn;

		void main()
		{	
			vec2 uv = openfl_TextureCoordv;

			vec4 col = texture2D(bitmap, uv);
			if(turnedOn >= 1)
			{
				float intensity = (col.r + col.g + col.b) / 3.0;
				gl_FragColor = vec4(intensity, intensity, intensity, col.a);
			}	
			else
				gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}