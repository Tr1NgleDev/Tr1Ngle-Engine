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

class NoteSplash extends Sprite
{
	

    public function new(X:Float, Y:Float, noteData:Int)
    {
    	super(X, Y);
    	frames = (Paths.getSparrowAtlas("noteSplashes" + (PlayState.storyWeek == 6 ? "Pixel" : "")));
		var addPixel:String = (PlayState.storyWeek == 6 ? " pixel" : "");
    	//impact 1
    	animation.addByPrefix("note1-0", "note impact 1 blue" + addPixel, 24, false);
    	animation.addByPrefix("note2-0", "note impact 1 green" + addPixel, 24, false);
    	animation.addByPrefix("note0-0", "note impact 1 purple" + addPixel, 24, false);
    	animation.addByPrefix("note3-0", "note impact 1 red" + addPixel, 24, false);
    	//impact 2
    	animation.addByPrefix("note1-1", "note impact 2 blue" + addPixel, 24, false);
    	animation.addByPrefix("note2-1", "note impact 2 green" + addPixel, 24, false);
    	animation.addByPrefix("note0-1", "note impact 2 purple" + addPixel, 24, false);
    	animation.addByPrefix("note3-1", "note impact 2 red" + addPixel, 24, false);
		if(PlayState.storyWeek == 6)
			{
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			}
        setupNoteSplash(X, Y, noteData);
    }

    public function setupNoteSplash(x:Float, y:Float, note:Int)
    {
		this.x = x;
		this.y = y;
    	alpha = 0.65;
    	animation.play("note" + note + "-" + FlxG.random.int(0, 1), true);
    	
		
    	animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
    	updateHitbox();
		if(PlayState.storyWeek != 6)
		{
    		offset.set(0.3 * width, 0.3 * height);
		}
		else
		{
			offset.set(-16, 0);
		}
    }

    override public function update(elapsed:Float)
    {
    	
    	if(animation.curAnim.finished)
    	{
    		kill();
    	}
    	super.update(elapsed);
    }
}