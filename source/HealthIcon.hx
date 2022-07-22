package;

import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class HealthIcon extends Sprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var isPlayer:Bool;
	public var isOldIcon:Bool;
	public var character:String;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = this.isOldIcon = false;
		this.character = "";
		this.isPlayer = isPlayer;
		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		this.isOldIcon = !this.isOldIcon;
		this.isOldIcon ? changeIcon("bf-old") : changeIcon("bf");
	}

	public function changeIcon(char:String)
	{
		if("bf-pixel" != char && "bf-old" != char && "senpai-angry" != char && "senpai-pissed" != char)
		{
			char = char.split("-")[0];
		} 
		if(char != this.character)
		{
			#if desktop
			if(FileSystem.exists(Paths.image("icons/icon-" + char)))
			{
				if(loadGraphics((Paths.image("icons/icon-" + char))).width >= 450)
				{
					loadGraphics((Paths.image("icons/icon-" + char)), true, 150, 150);
					animation.add(char, [0, 1, 2], 0, false, this.isPlayer);
				}
				else if (loadGraphics((Paths.image("icons/icon-" + char))).width <= 300)
				{
					loadGraphics((Paths.image("icons/icon-" + char)), true, 150, 150);
					animation.add(char, [0, 1], 0, false, this.isPlayer);
				}
				animation.play(char);
				this.character = char;
			}
			else
			{
				changeIcon("face");
			}
			#else
			if(Assets.exists(Paths.image("icons/icon-" + char)))
			{
				if(loadGraphics((Paths.image("icons/icon-" + char))).width >= 450)
				{
					loadGraphics((Paths.image("icons/icon-" + char)), true, 150, 150);
					animation.add(char, [0, 1, 2], 0, false, this.isPlayer);
				}
				else if (loadGraphics((Paths.image("icons/icon-" + char))).width <= 300)
				{
					loadGraphics((Paths.image("icons/icon-" + char)), true, 150, 150);
					animation.add(char, [0, 1], 0, false, this.isPlayer);
				}
				animation.play(char);
				this.character = char;
			}
			else
			{
				changeIcon("face");
			}
			#end
			
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
