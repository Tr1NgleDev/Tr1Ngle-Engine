package;

import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.FlxG;

class Shaders
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var vignette:ShaderFilter = new ShaderFilter(new VignetteShader());
	public static var invert:ShaderFilter = new ShaderFilter(new InvertShader());
	public static var grayScale:ShaderFilter = new ShaderFilter(new GrayScaleShader());
	public static var pixelate:ShaderFilter = new ShaderFilter(new PixelateShader());
	private static var aaa:Float = 0;
	private static var aaaaaa:Float = 0;
	public static function setChrome(?chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	public static function setVignette(?radius:Float):Void
	{
		vignette.shader.data.radius.value = [radius];
		if(vignette.shader.data.radius.value == null)
			vignette.shader.data.radius.value = [0];
		aaaaaa = CoolUtil.coolLerp(aaaaaa, radius, 0.075);
		if (Math.abs(aaaaaa - radius) <= 0.01)
			aaaaaa = radius;
		vignette.shader.data.radius.value = [aaaaaa];
	}

	public static function setInvertColor(?turnedOn:Int):Void
	{
		invert.shader.data.turnedOn.value = [turnedOn];
	}

	public static function setGrayScale(?turnedOn:Int):Void
	{
		grayScale.shader.data.turnedOn.value = [turnedOn];
	}

	public static function setPixelation(?pixelSize:Float = 80):Void
	{
		if(pixelate.shader.data.pixelSize.value == null)
			pixelate.shader.data.pixelSize.value = [0];
		if(pixelSize == 0)
			aaa = 200;
		aaa = CoolUtil.coolLerp(aaa, pixelSize, 0.075);
		if (Math.abs(aaa - pixelSize) <= 10)
			aaa = pixelSize;
		pixelate.shader.data.pixelSize.value = [pixelSize != 0 ? aaa : 0];
	}

}