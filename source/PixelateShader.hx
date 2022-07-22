package;

import flixel.system.FlxAssets.FlxShader;

class PixelateShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float pixelSize;

		void main()
		{	
			
			if(pixelSize >= 1.0)
			{
				vec2 uv = openfl_TextureCoordv;
				uv.x = floor(uv.x * pixelSize) / pixelSize;
				uv.y = floor(uv.y * pixelSize) / pixelSize;
				gl_FragColor = texture2D(bitmap, uv);
			}
			else
			{
				vec2 uv = openfl_TextureCoordv;

				vec4 col = texture2D(bitmap, uv);
				gl_FragColor = col;
			}
				
		}')
	public function new()
	{
		super();
	}
}