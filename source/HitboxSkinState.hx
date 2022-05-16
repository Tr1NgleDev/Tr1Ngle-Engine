package;

import flixel.*;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.*;
import flixel.graphics.FlxGraphic;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;

class HitboxSkinState extends MusicBeatState {
    var daName:FlxText;
    var arrow1:FlxSprite;
    var arrow2:FlxSprite;
    var hitbox:FlxSprite;
    var hitbox_hint:FlxSprite;
    var menuItems:Array<String> = ['default','saw','neon','stock','retrostyle','thedumbass'];
    var curSelected:Int = 0;
    var exitButton:FlxUIButton;
    var exitNSaveButton:FlxUIButton;
    override function create()
    {
        super.create();
        curSelected = getthing();

        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF2b2e94;
        bg.updateHitbox();
        add(bg);
        
        hitbox_hint = new FlxSprite(0, 0).loadGraphic(Paths.image('androidcontrols/' + FlxG.save.data.hitbox + '_hint'));
		    hitbox_hint.alpha = 0.75;
		    add(hitbox_hint);
		    
		    hitbox = new FlxSprite(0, 0).loadGraphic(Paths.image('androidcontrols/' + FlxG.save.data.hitbox));
		    add(hitbox);

        arrow1 = new FlxSprite(5, 5);
        arrow1.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        arrow1.animation.addByPrefix('idle', 'arrow left', 24, false);
        arrow1.animation.addByPrefix('pressed', 'arrow push left', 24, false);
        arrow1.animation.play('idle', false);
        add(arrow1);

        daName = new FlxText(arrow1.x + 55, arrow1.y, 0, menuItems[curSelected], 55);
        if (menuItems[curSelected] == 'DEFAULT')
            daName.text = 'DEFAULT';
        else
            daName.text = menuItems[curSelected];
        add(daName); //this line crashes the game wtf // nvm :)))

        arrow2 = new FlxSprite(arrow1.x + 55 + daName.width, arrow1.y);
        arrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        arrow2.animation.addByPrefix('idle', 'arrow right', 0, false);
        arrow2.animation.addByPrefix('pressed', 'arrow push right', 24, false);
        arrow2.animation.play('idle', false);
        add(arrow2);

        exitNSaveButton = new FlxUIButton(895, 5, "Exit and save", exitThing);
        exitNSaveButton.resize(195,50);
        exitNSaveButton.setLabelFormat(16,FlxColor.BLACK,"center");
        add(exitNSaveButton);

        exitButton = new FlxUIButton(exitNSaveButton.x - exitNSaveButton.width - 35, 5, "Exit", exitThingTwo);
        exitButton.resize(125,50);
        exitButton.setLabelFormat(24,FlxColor.BLACK,"center");
        add(exitButton);
    } // bruh this is so little code why'd it take me so long to fuckin code

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (touch in FlxG.touches.list)
        {
            if (touch.overlaps(arrow1) && touch.justPressed)
            {
                remove(hitbox_hint);
                remove(hitbox);
                changeThing(-1);
                add(hitbox_hint);
                add(hitbox);
                arrow1.animation.play('pressed');
                new FlxTimer().start(0.5, function(tmr:FlxTimer){
                    arrow1.animation.play('idle');
                }); // anim shit :spooky:
            }
            else if (touch.overlaps(arrow2) && touch.justPressed)
            {
                remove(hitbox_hint);
                remove(hitbox);
                changeThing(1);
                add(hitbox_hint);
                add(hitbox);
                arrow2.animation.play('pressed');
                new FlxTimer().start(0.5, function(tmr:FlxTimer){
                    arrow2.animation.play('idle');
                }); // anim shit :spooky:
            }
        }

        if (controls.LEFT_P)
        {
            remove(hitbox_hint);
                remove(hitbox);
                changeThing(-1);
                add(hitbox_hint);
                add(hitbox);
            arrow1.animation.play('pressed');
            new FlxTimer().start(0.5, function(tmr:FlxTimer){
                arrow1.animation.play('idle');
            }); // anim shit :spooky:
        }
        else if (controls.RIGHT_P)
        {
            remove(hitbox_hint);
                remove(hitbox);
                changeThing(1);
                add(hitbox_hint);
                add(hitbox);
            arrow2.animation.play('pressed');
            new FlxTimer().start(0.5, function(tmr:FlxTimer){
                arrow2.animation.play('idle');
            }); // anim shit :spooky:
        }

    }
    function changeThing(howMuchThing:Int):Void
    {
        curSelected += howMuchThing;

        if (curSelected > menuItems.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuItems.length - 1;
        trace("length of menu items: "+menuItems.length+" currently selected:"+curSelected);

        if (menuItems[curSelected] == 'default')
            daName.text = 'luckydog7';
        else if (menuItems[curSelected] == 'thedumbass')
            daName.text = 'The Dumbass';
        else
            daName.text = menuItems[curSelected];

        arrow2.x = daName.width + 65;
        arrow2.updateHitbox();

        // simple ass code but its long enought that it needs a fucktion
    }
    function exitThing():Void {
        FlxG.save.data.hitbox = menuItems[curSelected];
        FlxG.switchState(new OptionsMenu());
    }

    function exitThingTwo():Void {
        FlxG.switchState(new OptionsMenu());
    }
    function getthing():Int {
        switch (FlxG.save.data.hitbox)
        {
            case 'default':
                return 0;
            case 'saw':
                return 1;
            case 'neon':
                return 2;
            case 'stock':
                return 3;
            case 'retrostyle':
                return 4;
            case 'thedumbass':
                return 5;
        }
        return 0;
    }
}