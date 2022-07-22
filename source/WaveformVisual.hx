package;

import openfl.display.BitmapData;
import lime.media.AudioBuffer;
import Controls.Action;
import flixel.FlxGame;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.utils.ByteArray;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileReference;
import openfl.net.FileFilter;

using StringTools;

class WaveformVisual extends FlxSprite
{
    public var col:FlxColor;
    public var ab:AudioBuffer;
    public var staticWaveform:Bool;
    public var valueMultiplier:Float;
    public var curSection:Int;
    public override function new(x:Float, y:Float, w:Float, h:Float, col:FlxColor, audioBuffer:AudioBuffer, staticWaveform:Bool = false)
    {
        super(x, y);
        this.col = col;
        this.ab = audioBuffer;
        this.pixels = new BitmapData(Std.int(w), Std.int(h), true, FlxColor.BLACK);
        this.staticWaveform = staticWaveform;
        if(!staticWaveform)
            valueMultiplier = 43.971749999994;
        else
            valueMultiplier = 44.0875;
    }
    function drawLine(x1:Int, y1:Int, x2:Int, y2:Int, color:FlxColor)
    {
        var dx = x2 - x1;
        var dy = y2 - y1;

        for(x in x1...x2){
            var y = y1 + dy * (x - x1) / dx;
            pixels.fillRect(new Rectangle(x, y, 1, 1), color);
        }
    }
    function startTime():Float
    {
        var daBPM:Int = Conductor.bpm;
        var daPos:Float = 0;
        for (i in 0...curSection)
        {
            daPos += 4 * Conductor.crochet;
        }
        return daPos;
    }
    public override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(ab != null && !staticWaveform)
        {
            var index:Int = Std.int((!staticWaveform ? FlxG.sound.music.time : startTime()) * valueMultiplier * (ab.sampleRate / 44100));	
			
			pixels.fillRect(new Rectangle(0, 0, width, height), FlxColor.BLACK);
			var visibleTime:Int = (!staticWaveform ? Std.int(2160 * 2 * (ab.sampleRate / 44100)) : Std.int((Conductor.stepCrochet * 16 * 1.1 * (ab.sampleRate / 44100)) / 16));
            //var points:Array<FlxPoint> = [];
			for(index2 in (!staticWaveform ? index...visibleTime + index : index...index + ab.data.toBytes().length))
			{
				var byte:Int = ab.data.toBytes().getUInt16(index2 * 4);
				if (byte > 65535 / 2)
					byte -= 65535;
				var sample:Float = (byte / 65535);
                if((index2 % visibleTime == 0 && staticWaveform) || !staticWaveform)
                {
                    var aSample:Float = sample + 0.5;
                    var aIndex2:Int = index2 - index;
                    pixels.fillRect(new Rectangle(Std.int( aSample * width ), Std.int( aIndex2 / visibleTime * height ), 2, 1), col);
                    //points.push(new FlxPoint(aSample * width, aIndex2 / visibleTime * height));
                }
				
				//trace(aSample);
			}
            /*for(pointIndex in 1...points.length)
            {
                var pointa:FlxPoint = points[pointIndex - 1];
                var pointb:FlxPoint = points[pointIndex];
                drawLine(Std.int(pointa.x), Std.int(pointa.y), Std.int(pointb.x), Std.int(pointb.y), col);
            }*/
        }
    }
    public function updateWaveform()
    {
        var index:Int = Std.int((!staticWaveform ? FlxG.sound.music.time : startTime()) * valueMultiplier * (ab.sampleRate / 44100));	
			
		pixels.fillRect(new Rectangle(0, 0, width, height), FlxColor.BLACK);
		var visibleTime:Int = (!staticWaveform ? Std.int(2160 * 2 * (ab.sampleRate / 44100)) : Std.int((Conductor.stepCrochet * 16 * 1.1 * (ab.sampleRate / 44100)) / 16));
		var index3:Int = 0;
        //var points:Array<FlxPoint> = [];
        for(index2 in (!staticWaveform ? index...visibleTime + index : index...index + ab.data.toBytes().length))
		{
			var byte:Int = ab.data.toBytes().getUInt16(index2 * 4);
			if (byte > 65535 / 2)
				byte -= 65535;
			var sample:Float = (byte / 65535);
            if(((index2 % visibleTime) == 0 && staticWaveform) || !staticWaveform)
            {
                var aSample:Float = sample + 0.5;
                pixels.fillRect(new Rectangle(Std.int( aSample * width ), index3, 2, 1), col);
                //points.push(new FlxPoint(aSample * width, index3));
                index3++;
			    if(index3 > height) break;
            }
            
            
			//trace(aSample);
		}
        /*for(pointIndex in 1...points.length)
        {
            var pointa:FlxPoint = points[pointIndex - 1];
            var pointb:FlxPoint = points[pointIndex];
            drawLine(Std.int(pointa.x), Std.int(pointa.y), Std.int(pointb.x), Std.int(pointb.y), col);
        }*/
    }
    public function dispose()
    {
        ab.dispose();
    }
}