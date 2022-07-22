package;
import flixel.FlxG;
import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
class FPSCounter extends TextField
{
	private var memMax:Float = 0;
	
	public function new(x:Float = 10.0, y:Float = 10.0) 
	{
		super();
		this.x = x;
		this.y = y;
		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 14, FlxColor.WHITE);

		addEventListener(Event.ENTER_FRAME, onEnter);
		autoSize = LEFT;
		multiline = true;
		mouseEnabled = false;
	}

	private function onEnter(_)
	{	
		var mem:Float = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2));
		if (mem > memMax) memMax = mem;
		var memInfo = (FlxG.save.data.mem ? "RAM USAGE: " + mem + "/" + memMax + " MB" : "");
		if (visible)
		{	
			text = 
			"FPS: " + FlxMath.roundDecimal(1 / FlxG.elapsed, 1) + "\n"
			+ memInfo + "\n";
		}
	}
}