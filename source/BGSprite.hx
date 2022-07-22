package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import Paths;
import Song;
import Conductor;
import Math;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lime.utils.Assets;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;

import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;


#if cpp
import Sys;
import sys.FileSystem;
#end


using StringTools;

class BGSprite extends Sprite
{
	private var idle:String;
	public function new(name:String, x:Float = 0, y:Float = 0, ?scrollFactorX:Float = 1, ?scrollFactorY:Float = 1, ?animArray:Array<String> = null, ?loopAnim:Bool = false)
	{
		super(x, y);
		if(animArray != null)
		{
			frames = Paths.getSparrowAtlas(name);
			for (i in 0 ... animArray.length) 
			{
				var b:String = animArray[i];
				animation.addByPrefix(b, b, 24, loopAnim);
				animation.play(b);
				if(idle == null)
				{
					idle = b;
				}
			}
		}
		else
		{
			loadGraphics(Paths.image(name));
			active = false;
		}
		scrollFactor.set(scrollFactorX, scrollFactorY);
		antialiasing = true;
	}

	public function dance()
	{
		if(idle != null)
		{
			animation.play(idle);
		}
	}
}