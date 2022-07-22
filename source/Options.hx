package;

import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
#if windows
import sys.io.Process;
#end
import flixel.math.FlxMath;
using StringTools;

class OptionCatagory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}
	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Catagory";
	
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var display:String;
	private var acceptValues:Bool = false;
	public var withoutCheckboxes:Bool = false;
	public var boldDisplay:Bool = true;
	public var HitboxOption:Int = 1;
	public final function getDisplay():String
	{
	  switch(FlxG.save.data.hitbox)
	{
	  case 1:
	    HitboxOption = 1;
	  case 2:
	    HitboxOption = 2;
	  case 3:
	    HitboxOption = 3;
	}

		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}
	
	// Returns whether the label is to be updated.
	public function press(changeData:Bool):Bool { return false; }
	private function updateDisplay():String { return ""; }
	public function left():Bool { return false; }
	public function right():Bool { return false; }
}


class DownscrollOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		acceptValues = FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Downscroll "/* + (!FlxG.save.data.downscroll ? "off" : "on")*/;
	}
}

<<<<<<< HEAD
class OptimizationOption extends Option
=======
class SkillIssueOption extends Option
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
{
	public function new()
	{
		super();
	}
<<<<<<< HEAD

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.optimode = !FlxG.save.data.optimode;
		acceptValues = FlxG.save.data.optimode;
=======
	public override function press(changeData:Bool):Bool
	{
		if(changeData)
		{
			FlxG.save.data.skillIssue = !FlxG.save.data.skillIssue;
			if(FlxG.save.data.skillIssue)
			{
				#if windows
				// should open skillIssue message box but idfk how :skull:
				#end
			}
		}
			
		acceptValues = FlxG.save.data.skillIssue;
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
<<<<<<< HEAD
		return "Optimization Mode "/* + (!FlxG.save.data.downscroll ? "off" : "on")*/;
	}
}
=======
		return "Ghost Tapping";
	}
}

>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
class BGForNotesOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.bgNotes = !FlxG.save.data.bgNotes;
		acceptValues = FlxG.save.data.bgNotes;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "BG For Notes "/* + (!FlxG.save.data.downscroll ? "off" : "on")*/;
	}
}

class HitsoundsOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.hitSounds = !FlxG.save.data.hitSounds;
		acceptValues = FlxG.save.data.hitSounds;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Hitsounds ";
	}
}



class MiddlescrollOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
		acceptValues = FlxG.save.data.middlescroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middlescroll "/* + (!FlxG.save.data.middlescroll ? "off" : "on")*/;
	}
}


class PauseCountdownOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.pauseCountdown = !FlxG.save.data.pauseCountdown;
		acceptValues = FlxG.save.data.pauseCountdown;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Pause Countdown "/* + (!FlxG.save.data.pauseCountdown ? "off" : "on")*/;
	}
}

class InstantRespawnOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.instRespawn = !FlxG.save.data.instRespawn;
		acceptValues = FlxG.save.data.instRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Instant Respawn "/* + (!FlxG.save.data.instRespawn ? "off" : "on")*/;
	}
}

class PreloadImagesOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		
		if(changeData)
			FlxG.save.data.preloadCharacters = !FlxG.save.data.preloadCharacters;
		FlxGraphic.defaultPersist = FlxG.save.data.preloadCharacters;
		acceptValues = FlxG.save.data.preloadCharacters;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Preload Images"/* + (!FlxG.save.data.instRespawn ? "off" : "on")*/;
	}
}

class BotOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.botAutoPlay = !FlxG.save.data.botAutoPlay;
		acceptValues = FlxG.save.data.botAutoPlay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Bot Auto Play "/* + (!FlxG.save.data.botAutoPlay ? "off" : "on")*/;
	}
}

class FPSOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
		{
			FlxG.save.data.fps = !FlxG.save.data.fps;
			(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		}
			
		acceptValues = FlxG.save.data.fps;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter "/* + (!FlxG.save.data.fps ? "off" : "on")*/;
	}
}

class FramerateOption extends Option
{
	public function new()
	{
		withoutCheckboxes = true;
		boldDisplay = false;
		super();
	}
	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		boldDisplay = false;
		return true;
	}
	public override function left():Bool
	{
		if(FlxG.drawFramerate > 60)
			FlxG.drawFramerate -= 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.framerateDraw = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool
	{
		if(FlxG.drawFramerate < 360)
			FlxG.drawFramerate += 1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		FlxG.save.data.framerateDraw = FlxG.drawFramerate;
		FlxG.updateFramerate = FlxG.drawFramerate;
		display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String
	{
		boldDisplay = false;
		return "Framerate: " + FlxG.drawFramerate/* + (!FlxG.save.data.fps ? "off" : "on")*/;
	}
}

<<<<<<< HEAD
=======
class OffsetsOption extends Option
{
	public function new()
	{
		withoutCheckboxes = true;
		boldDisplay = false;
		super();
		display = updateDisplay();
	}
	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		boldDisplay = false;
		display = updateDisplay();
		return true;
	}
	public override function left():Bool
	{
		if(FlxG.save.data.notesOffset > -300)
			FlxG.save.data.notesOffset -= 0.1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		if(FlxG.save.data.notesOffset < -300)
			FlxG.save.data.notesOffset = -300;
		FlxG.save.data.notesOffset = FlxMath.roundDecimal(FlxG.save.data.notesOffset, 1);
		Conductor.offset = FlxG.save.data.notesOffset;
		
		display = updateDisplay();
		return true;
	}
	public override function right():Bool
	{
		if(FlxG.save.data.notesOffset < 300)
			FlxG.save.data.notesOffset += 0.1 * (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.CONTROL ? 10 : 1);
		if(FlxG.save.data.notesOffset > 300)
			FlxG.save.data.notesOffset = 300;
		FlxG.save.data.notesOffset = FlxMath.roundDecimal(FlxG.save.data.notesOffset, 1);
		Conductor.offset = FlxG.save.data.notesOffset;
		display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String
	{
		Conductor.offset = FlxG.save.data.notesOffset;
		boldDisplay = false;
		return "Offset: " + Conductor.offset;
	}
}
class CalibrateOffsetsOption extends Option
{
	public function new()
	{
		withoutCheckboxes = true;
		boldDisplay = true;
		super();
	}
	public override function press(changeData:Bool):Bool
	{
		withoutCheckboxes = true;
		boldDisplay = true;
		if(changeData){
			FlxG.sound.music.stop();
			FlxG.switchState(new CalibrateOffsetsState());
		}
		

		return true;
	}
	private override function updateDisplay():String
	{
		boldDisplay = true;
		return "Calibrate Offsets";
	}
}
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
class ShadersOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.shadersOn = !FlxG.save.data.shadersOn;
		acceptValues = FlxG.save.data.shadersOn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Shaders "/* + (!FlxG.save.data.shadersOn ? "off" : "on")*/;
	}
}

class MemoryCounterOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
		{
			FlxG.save.data.mem = !FlxG.save.data.mem;
		}
		
		acceptValues = FlxG.save.data.mem;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Memory Counter "/* + (!FlxG.save.data.fps ? "off" : "on")*/;
	}
}

class FullscreenOption extends Option
{
	public function new()
	{
		super();
	}

	public override function press(changeData:Bool):Bool
	{
		if(changeData)
			FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen;
		acceptValues = FlxG.save.data.fullscreen;
		FlxG.fullscreen = FlxG.save.data.fullscreen;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Fullscreen "/* + (!FlxG.save.data.fullscreen ? "off" : "on")*/;
	}
}
