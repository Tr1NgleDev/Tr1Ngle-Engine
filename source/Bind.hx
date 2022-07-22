package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class Bind
{

    public static function resetBinds():Void{

        FlxG.save.data.upBind = "W";
        FlxG.save.data.downBind = "S";
        FlxG.save.data.leftBind = "A";
        FlxG.save.data.rightBind = "D";
        FlxG.save.data.killBind = "R";

        FlxG.save.data.upBindUI = "W";
        FlxG.save.data.downBindUI = "S";
        FlxG.save.data.leftBindUI = "A";
        FlxG.save.data.rightBindUI = "D";

		FlxG.save.data.pauseBindUI = "P";
		FlxG.save.data.acceptBindUI = "Z";
		FlxG.save.data.backBindUI = "X";
        
        PlayerSettings.player1.controls.loadKeyBinds();

	}

    public static function keyCheck():Void
    {
        if(FlxG.save.data.upBind == null){
            FlxG.save.data.upBind = "W";
            trace("No UP");
        }
        if(FlxG.save.data.downBind == null){
            FlxG.save.data.downBind = "S";
            trace("No DOWN");
        }
        if(FlxG.save.data.leftBind == null){
            FlxG.save.data.leftBind = "A";
            trace("No LEFT");
        }
        if(FlxG.save.data.rightBind == null){
            FlxG.save.data.rightBind = "D";
            trace("No RIGHT");
        }
        if(FlxG.save.data.upBindUI == null){
            FlxG.save.data.upBindUI = "W";
            trace("No UP UI");
        }
        if(FlxG.save.data.downBindUI == null){
            FlxG.save.data.downBindUI = "S";
            trace("No DOWN UI");
        }
        if(FlxG.save.data.leftBindUI == null){
            FlxG.save.data.leftBindUI = "A";
            trace("No LEFT UI");
        }
        if(FlxG.save.data.rightBindUI == null){
            FlxG.save.data.rightBindUI = "D";
            trace("No RIGHT UI");
        }
        if(FlxG.save.data.pauseBindUI == null)
			FlxG.save.data.pauseBindUI = "P";
		if(FlxG.save.data.acceptBindUI == null)
			FlxG.save.data.acceptBindUI = "Z";
		if(FlxG.save.data.backBindUI == null)
			FlxG.save.data.backBindUI = "X";
        if(FlxG.save.data.killBind == null){
            FlxG.save.data.killBind = "R";
            trace("No KILL");
        }
        PlayerSettings.player1.controls.loadKeyBinds();
    }

}