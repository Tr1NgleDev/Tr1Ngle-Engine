package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<Sprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:Sprite;
	var camFollow:FlxObject;

	override function create()
	{
		Bind.keyCheck();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing || FlxG.sound.music.volume == 0)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:Sprite = new Sprite(-80).loadGraphics(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.17;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new Sprite(-80).loadGraphics(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.17;
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<Sprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:Sprite = new Sprite(0, -440 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.alpha = 0;
			/*variants of tween (don't forget to change the coordinates of the menuItem)

			FlxTween.tween(menuItem, {alpha: 1, y: menuItem.y - 500}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2 + i / 4});	coords of the menuItem = 0, 560 + (i * 160)
			FlxTween.tween(menuItem, {alpha: 1, y: menuItem.y + 500}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2 + i / 4});	coords of the menuItem = 0, -440 + (i * 160)
			


			FlxTween.tween(menuItem, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2 + i / 4});		coords of the menuItem = 0, 60 + (i * 160)

			*/
			FlxTween.tween(menuItem, {alpha: 1, y: menuItem.y + 500}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2 + i / 4});
			
		}

		

		var versionShit:FlxText = new FlxText(5, FlxG.height - 36, 0, "Game version:" + Application.current.meta.get('version') , 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var engineVersionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Tr1NgleEngine version:" + Main.engineVersion, 12);
		engineVersionShit.scrollFactor.set();
		engineVersionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(engineVersionShit);
		
		FlxG.camera.follow(camFollow, null, 0.06);
		

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

    #if android
  	addVirtualPad(FULL, A_B);
    #end
 
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
<<<<<<< HEAD
			if (controls.UP_P)
=======
			if (controls.UP_PUI)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1, false);
				changeItem(-1);
			}

<<<<<<< HEAD
			if (controls.DOWN_P)
=======
			if (controls.DOWN_PUI)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1, false);
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:Sprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());
										trace("Freeplay Menu Selected");
									case 'options':
										FlxG.switchState(new OptionsMenu());
										trace("Options Menu Selected");
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:Sprite)
		{
			spr.screenCenter(X);
			if (spr.ID == curSelected)
			{
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
		});
		
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:Sprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
		
	}
}
