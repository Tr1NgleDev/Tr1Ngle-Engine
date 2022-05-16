import openfl.Lib;
import flixel.FlxG;

class Save
{
    public static function initSave()
    {
		if (FlxG.save.data.hitbox == null)
			FlxG.save.data.hitbox = 'default';
	  }
}