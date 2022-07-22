package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end
	#if (haxe >= "4.0.0")
	public static var songAcc:Map<String, Float> = new Map();
	#else
	public static var songAcc:Map<String, Float> = new Map<String, Float>();
	#end
	#if (haxe >= "4.0.0")
	public static var songCombo:Map<String, Int> = new Map();
	#else
	public static var songCombo:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?accuracy:Float = 0, ?combo:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

<<<<<<< HEAD

=======
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);

		if (songAcc.exists(daSong))
		{
			if (songAcc.get(daSong) < accuracy)
				setAcc(daSong, accuracy);
		}
		else
			setAcc(daSong, accuracy);

		if (songCombo.exists(daSong))
		{
			if (songCombo.get(daSong) < combo)
				setCombo(daSong, combo);
		}
		else
			setCombo(daSong, combo);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
<<<<<<< HEAD


=======
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		var daWeek:String = formatSong('week' + week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setAcc(song:String, accuracy:Float = 0):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		
		songAcc.set(song, accuracy);
		FlxG.save.data.songAcc = songAcc;
		FlxG.save.flush();
	}
	static function setCombo(song:String, combo:Int = 0):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		
		songCombo.set(song, combo);
		FlxG.save.data.songCombo = songCombo;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';
		else if (diff == 3)
			daSong += '-funky';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getAcc(song:String, diff:Int):Float
	{
		if (!songAcc.exists(formatSong(song, diff)))
			setAcc(formatSong(song, diff), 0);

		return songAcc.get(formatSong(song, diff));
	}

	public static function getCombo(song:String, diff:Int):Int
	{
		if (!songCombo.exists(formatSong(song, diff)))
			setCombo(formatSong(song, diff), 0);

		return songCombo.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songAcc != null)
		{
			songAcc = FlxG.save.data.songAcc;
		}
		if (FlxG.save.data.songCombo != null)
		{
			songCombo = FlxG.save.data.songCombo;
		}
	}
}
