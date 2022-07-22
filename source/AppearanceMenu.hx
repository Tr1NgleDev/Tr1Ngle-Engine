package;

import haxe.macro.Expr.Case;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class AppearanceMenu extends MusicBeatState
{
    private var grpControls:FlxTypedGroup<Alphabet>;
    var camFollow:FlxObject;
    var names:Array<String> = ["VANILLA UI", "TE UI"];
    var uiNewValue:Int = 2;
    var curSelected:Int = 0;
    var rightArrow:Sprite;
	var leftArrow:Sprite;
    public override function create() 
    {
        super.create();
        uiNewValue = FlxG.save.data.uiOption;
        var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.scrollFactor.x = 0;
        menuBG.scrollFactor.y = 0.1;
		menuBG.screenCenter();
		menuBG.antialiasing = true;
        add(menuBG);

        grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

        leftArrow = new Sprite(305, 0);
		leftArrow.frames = Paths.getSparrowAtlas('arrowsMENU');
		leftArrow.animation.addByIndices('idle', "arrowsMENU arrow left", [0], "", 24, true);
		leftArrow.animation.addByIndices('pressed', "arrowsMENU arrow left pressed", [0], "", 24, true);
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new Sprite(934, 0);
		rightArrow.frames = Paths.getSparrowAtlas('arrowsMENU');
		rightArrow.animation.addByIndices('idle', "arrowsMENU arrow right", [0], "", 24, true);
		rightArrow.animation.addByIndices('pressed', "arrowsMENU arrow right pressed", [0], "", 24, true);
		rightArrow.animation.play('idle');
		add(rightArrow);

        rightArrow.scrollFactor.y = 0;
        leftArrow.scrollFactor.y = 0;

        camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		add(camFollow);
        FlxG.camera.follow(camFollow, null, 0.06);

        var optionUI1:Alphabet = new Alphabet(0, (100) + 105, names[uiNewValue - 1], true, false);
		grpControls.add(optionUI1);
        optionUI1.screenCenter(X);
        optionUI1.ID = 0;

        var optionUI2:Alphabet = new Alphabet(0, (100 * 2) + 105, (FlxG.save.data.downscroll ? "DOWNSCROLL" : "UPSCROLL"), true, false);
		grpControls.add(optionUI2);
        optionUI2.screenCenter(X);
        optionUI2.ID = 1;

        var optionUI3:Alphabet = new Alphabet(0, (100 * 3) + 105, (FlxG.save.data.middlescroll ? "MIDDLESCROLL" : "NO MIDDLESCROLL"), true, false);
		grpControls.add(optionUI3);
        optionUI3.screenCenter(X);
        optionUI3.ID = 2;

        var optionUI4:Alphabet = new Alphabet(0, (100 * 4) + 105, (FlxG.save.data.bgNotes ? "Notes BG" : "No Notes BG"), true, false);
		grpControls.add(optionUI4);
        optionUI4.screenCenter(X);
        optionUI4.ID = 3;

        var optionUI5:Alphabet = new Alphabet(0, (100 * 5) + 105, (FlxG.save.data.judgementBar ? "Judgement Bar" : "No Judgement Bar"), true, false);
		grpControls.add(optionUI5);
        optionUI5.screenCenter(X);
        optionUI5.ID = 4;

        var optionUI6:Alphabet = new Alphabet(0, (100 * 6) + 105, (FlxG.save.data.showEnemyNotes ? "Show Enemy Notes" : "Hide Enemy Notes"), true, false);
		grpControls.add(optionUI6);
        optionUI6.screenCenter(X);
        optionUI6.ID = 5;
        
        textUpdate();
		changeItem(0);
    }
    public function textUpdate()
    {
        grpControls.remove(grpControls.members[curSelected]);
        switch (curSelected)
        {
            case 0:
                var ctrl:Alphabet = new Alphabet(0, (100) + 105, names[uiNewValue - 1], true, false);
                ctrl.ID = 0;
                ctrl.screenCenter(X);
                grpControls.add(ctrl);
                leftArrow.x = 305 + 30;
                rightArrow.x = 934 - 30;
            case 1:
                var ctrl:Alphabet = new Alphabet(0, (100 * 2) + 105, (FlxG.save.data.downscroll ? "DOWNSCROLL" : "UPSCROLL"), true, false);
                ctrl.ID = 1;
                ctrl.screenCenter(X);
                grpControls.add(ctrl);
                leftArrow.x = 305;
                rightArrow.x = 934;
            case 2:
                var ctrl:Alphabet = new Alphabet(0, (100 * 3) + 105, (FlxG.save.data.middlescroll ? "MIDDLESCROLL" : "NO MIDDLESCROLL"), true, false);
                ctrl.ID = 2;
                ctrl.screenCenter(X);
                grpControls.add(ctrl);
                leftArrow.x = 305 - 90;
                rightArrow.x = 934 + 90;
            case 3:
                var ctrl:Alphabet = new Alphabet(0, (100 * 4) + 105, (FlxG.save.data.bgNotes ? "Notes BG" : "No Notes BG"), true, false);
                ctrl.ID = 3;
                ctrl.screenCenter(X);
                grpControls.add(ctrl);
                leftArrow.x = 305 + 20;
                rightArrow.x = 934 - 20;
            case 4:
                var ctrl:Alphabet = new Alphabet(0, (100 * 5) + 105, (FlxG.save.data.judgementBar ? "Judgement Bar" : "No Judgement Bar"), true, false);
                ctrl.ID = 4;
                ctrl.screenCenter(X);
                grpControls.add(ctrl);
                leftArrow.x = 305 - 90;
                rightArrow.x = 934 + 90;
            case 5:
                leftArrow.x = 305 - 90;
                rightArrow.x = 934 + 90;

        }
        if(FlxG.save.data.middlescroll)
        {
            grpControls.remove(grpControls.members[5]);
            var ctrl:Alphabet = new Alphabet(0, (100 * 6) + 105, (FlxG.save.data.showEnemyNotes ? "Show Enemy Notes" : "Hide Enemy Notes"), true, false);
            ctrl.ID = 5;
            ctrl.screenCenter(X);
            grpControls.add(ctrl);
        }
        else
            if(grpControls.length == 6)
                grpControls.remove(grpControls.members[5], true);
    }
    public override function update(elapsed:Float)
    {
        super.update(elapsed);
        FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);
        rightArrow.screenCenter(Y);
        leftArrow.screenCenter(Y);
        leftArrow.y -= 40;
        rightArrow.y -= 40;
        if(controls.UP_PUI)
        {
            changeItem(-1);
        }
        if(controls.DOWN_PUI)
        {
            changeItem(1);
        }
        if(controls.LEFTUI)
		{
			leftArrow.animation.play("pressed");
		}
		else
		{
			leftArrow.animation.play("idle");
		}
		if(controls.RIGHTUI)
		{
			rightArrow.animation.play("pressed");
		}
		else
		{
			rightArrow.animation.play("idle");
		}

        if(controls.RIGHT_PUI)
        {
            changeCurOptionValue(1);
        }
        if(controls.LEFT_PUI)
        {
            changeCurOptionValue(-1);
        }

        if (controls.BACK)
        {
            FlxG.save.data.uiOption = uiNewValue;
            FlxG.save.flush();
            FlxG.switchState(new OptionsMenu());
        }
            
    }
    public function changeCurOptionValue(amount:Int = 0)
    {
        switch (curSelected)
        {
            case 0: // UI Option
                uiNewValue += amount;
                if (uiNewValue < 1)
                    uiNewValue = 2;
                if (uiNewValue > 2)
                    uiNewValue = 1;
            case 1:
                FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
            case 2:
                FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
            case 3:
                FlxG.save.data.bgNotes = !FlxG.save.data.bgNotes;
            case 4:
                FlxG.save.data.judgementBar = !FlxG.save.data.judgementBar;
            case 5:
                FlxG.save.data.showEnemyNotes = !FlxG.save.data.showEnemyNotes;
        }
        textUpdate();
    }
    public function changeItem(_amount:Int = 0)
    {
        FlxG.sound.play(Paths.sound("scrollMenu"), 0.4, false);

        curSelected += _amount;

        if (curSelected < 0)
            curSelected = grpControls.length - 1;
        if (curSelected >= grpControls.length)
            curSelected = 0;

        var bullShit:Int = 0;

        
        camFollow.y = grpControls.members[curSelected].getGraphicMidpoint().y + 70;
        
        

        for (item in grpControls.members)
        {
            if(item.ID != curSelected)
                item.alpha = 0.6;
            if(item.ID == curSelected)
                item.alpha = 1;
        }
        textUpdate();
    }
}