package;

import lime.utils.Assets;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function txtOffsets(key:String, ?library:String)
	{
		return getPath('images/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	static public function voices(song:String):Array<String>
	{
		if(Assets.exists('songs:assets/songs/${song.toLowerCase()}/Player1Voices.$SOUND_EXT') && Assets.exists('songs:assets/songs/${song.toLowerCase()}/Player2Voices.$SOUND_EXT'))
			return ['songs:assets/songs/${song.toLowerCase()}/Player1Voices.$SOUND_EXT', 'songs:assets/songs/${song.toLowerCase()}/Player2Voices.$SOUND_EXT'];
		else
			return ['songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT', ""];
	}
	static public function voicesFunky(song:String):Array<String>
	{
		if(Assets.exists('songs:assets/songs/${song.toLowerCase()}/Player1VoicesFunky.$SOUND_EXT') && Assets.exists('songs:assets/songs/${song.toLowerCase()}/Player2VoicesFunky.$SOUND_EXT'))
			return ['songs:assets/songs/${song.toLowerCase()}/Player1VoicesFunky.$SOUND_EXT', 'songs:assets/songs/${song.toLowerCase()}/Player2VoicesFunky.$SOUND_EXT'];
		else
			return ['songs:assets/songs/${song.toLowerCase()}/VoicesFunky.$SOUND_EXT', ""];
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}
	inline static public function instFunky(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/InstFunky.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		if(OpenFlAssets.cache.hasBitmapData(image(key, library)))
		{
			return FlxAtlasFrames.fromSparrow(OpenFlAssets.getBitmapData(image(key, library)), file('images/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	static public function getPackerAtlas(key:String, ?library:String)
	{
		if(OpenFlAssets.cache.hasBitmapData(image(key, library)))
			{
				return FlxAtlasFrames.fromSpriteSheetPacker(OpenFlAssets.getBitmapData(image(key, library)), file('images/$key.txt', library));
			}
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}