package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
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

class Sprite extends FlxSprite
{
	public function loadGraphics(name:String, ?animated:Bool = false, ?width:Int = 100, ?height:Int = 100):Sprite
    {
        if(OpenFlAssets.cache.hasBitmapData(name))
            loadGraphic(OpenFlAssets.getBitmapData(name), animated, width, height);
        else
            loadGraphic(name, animated, width, height);
        return this;
    }
    public function makeGraphics(width:Int, height:Int, ?color:FlxColor = FlxColor.WHITE):Sprite
        {
            makeGraphic(width, height, color);
            return this;
        }
}