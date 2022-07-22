package;

import flixel.util.FlxTimer;
import haxe.macro.Format;
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
import flixel.tweens.FlxTween;
using StringTools;

class CalibrateOffsetsState extends MusicBeatState
{
    var a:FlxText;
    var dafuk:FlxTypedGroup<Sprite>;
    var started:Bool;
    public var hits:Array<Float> = [];
    var offset:Float = 0;
    public override function create()
    {
        super.create();
        dafuk = new FlxTypedGroup<Sprite>();
        Conductor.changeBPM(60);
        var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.scrollFactor.x = 0;
        menuBG.scrollFactor.y = 0.18;
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

        a = new FlxText(0, 0, 0, "Press Space to start calibrating", 32);
        a.screenCenter();
        add(a);
        var b = new FlxText(10, 10, 0, "Press ESCAPE to cancel.", 32);
        
        add(b);
        curBeat = 0;
        beatHit();
        

    }
    function calcOffset()
    {
        offset = 0;
        for(item in hits)
            offset += item;
        offset /= hits.length;
        offset = FlxMath.roundDecimal(offset, 1);
    }
    var loops:Int = 0; // not loops but yes
    var tryAgain:Bool;
    var endAA:Bool;
    var soundLoops:Int = 0;
    public override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(!started && FlxG.keys.justPressed.SPACE)
        {
            
            started = true;
            remove(a);
            for(i in 0...4)
            {
                var s:Sprite = new Sprite(370 + (i * 180), 285 + (i > 0 ? 25 : 0)).makeGraphics(100 + (i == 0 ? 50 : 0), 100 + (i == 0 ? 50 : 0));
                var sborder:Sprite = new Sprite(370 + (i * 180) - 2, 285 + (i > 0 ? 25 : 0) - 2).makeGraphics(100 + (i == 0 ? 50 : 0) + 4, 100 + (i == 0 ? 50 : 0) + 4, FlxColor.BLACK);
                if(i > 1){
                    s.x -= 50 * (i - 1);
                    sborder.x -= 50 * (i - 1);
                }
                    
                add(sborder);
                dafuk.add(s);
                s.ID = i;
            }
            var daText:FlxText = new FlxText(0, 0, 0, "hit here!", 16);
            daText.borderSize = 1.25;
            daText.borderQuality = 1;
            daText.borderStyle = FlxTextBorderStyle.OUTLINE;
            add(daText);
            daText.x = 370 + 150 / 2 - daText.width / 2;
            daText.y = 285 - 32;
            add(dafuk);
            FlxG.sound.playMusic(Paths.music('calibrating'), 1, true);
            FlxG.sound.music.onComplete = function()
            {
                soundLoops++;
            };
        }
        else if(started && loops <= 8)
        {
            Conductor.songPosition = FlxG.sound.music.time;
            if(FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.ESCAPE)
            {
                loops++;

                
                var offsetVal:Int = Std.int(FlxMath.roundDecimal(Conductor.songPosition + (FlxG.sound.music.length * soundLoops), 2) - ((loops) * 4000));
                
                hits.push(offsetVal);
                
                calcOffset();

                var daText:FlxText = new FlxText(0, 0, 0, offsetVal + "ms", 16);
                daText.borderSize = 1.25;
                daText.borderQuality = 1;
                daText.borderStyle = FlxTextBorderStyle.OUTLINE;
                daText.x = 370 + 150 / 2 - daText.width / 2;
                daText.y = 285 - 64;
                daText.acceleration.y = FlxG.random.int(200, 300);
                daText.velocity.y -= FlxG.random.int(140, 160);
                daText.velocity.x = FlxG.random.float(-5, 5);
                add(daText);
                
                
                FlxTween.tween(daText, {alpha: 0}, 0.2, {
                    onComplete: function(tween:FlxTween)
                    {
                        daText.destroy();
                    },
                    startDelay: Conductor.crochet * 0.002
                });
            }
        }
        if(loops > 8)
        {
            if(!endAA)
            {
                FlxG.sound.music.stop();

                if(offset < -300 || offset > 300)
                {
                    var uhh:FlxText = new FlxText(0, 0, 0, "Your offsets seems to be strange.\nPress ENTER to try again.\n", 16);
                    uhh.borderSize = 1.25;
                    uhh.borderQuality = 1;
                    uhh.borderStyle = FlxTextBorderStyle.OUTLINE;
                    add(uhh);
                    uhh.screenCenter();
                    tryAgain = true;
                }
                else
                {
                    var urOffsets:FlxText = new FlxText(0, 0, 0, "Your offsets:\n" + offset + "ms\nPress ENTER to exit\n", 16);
                    urOffsets.borderSize = 1.25;
                    urOffsets.borderQuality = 1;
                    urOffsets.borderStyle = FlxTextBorderStyle.OUTLINE;
                    add(urOffsets);
                    urOffsets.screenCenter();
                }
                endAA = true;
            }
            if(FlxG.keys.justPressed.ENTER && endAA)
            {
                if(tryAgain)
                {
                    FlxG.resetState();
                }
                else
                {
                    FlxG.save.data.notesOffset = offset;
                    Conductor.offset = offset;
                    trace(Conductor.offset);
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    FlxG.switchState(new OptionsMenu());
                }
            }
        }
        if(started && Conductor.songPosition < Conductor.crochet)
        {
            for(i in dafuk.members)
                if(i.ID == 0)
                    i.color = FlxColor.GREEN;
                else
                    i.color = FlxColor.WHITE;
        }
        if(FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.switchState(new OptionsMenu());
        }

    }
    public override function beatHit() 
    {
        for(i in dafuk.members)
            if(i.ID == curBeat % 4)
                i.color = FlxColor.GREEN;
            else
                i.color = FlxColor.WHITE;
        
    }
}