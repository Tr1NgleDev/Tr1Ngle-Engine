package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:Sprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:Sprite;

	var curWacky:Array<String> = [];

	var wackyImage:Sprite;

	override public function create():Void
	{
	  #if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		
		FlxG.fullscreen = FlxG.save.data.fullscreen;
		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();
<<<<<<< HEAD
		
=======


		FlxG.sound.volume = 0.3;
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618

		FlxG.save.bind('funkin', 'ninjamuffin99');

    Save.initSave();

		Highscore.load();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end

		if(FlxG.save.data.framerateDraw != null){
			FlxG.updateFramerate = FlxG.save.data.framerateDraw;
			FlxG.drawFramerate = FlxG.save.data.framerateDraw;
		}
			
	}

	var logoBl:Sprite;
	var logoTE:Sprite;
	var gfDance:Sprite;
	var danceLeft:Bool = false;
	var titleText:Sprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:Sprite = new Sprite().makeGraphics(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new Sprite(-100, 1150); // -100 -50
		logoBl.frames = Paths.getSparrowAtlas('FNF_Logo');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'FNF Logo', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		logoTE = new Sprite(2000, 450);// 620 450
		logoTE.frames = Paths.getSparrowAtlas('Logo_TE');
		logoTE.antialiasing = true;
		logoTE.animation.addByPrefix('bump', 'Logo TE', 24);
		logoTE.animation.play('bump');
		logoTE.updateHitbox();

		gfDance = new Sprite(700, 1150); // 600 0
		gfDance.frames = Paths.getSparrowAtlas('gf_starting_screen');
		gfDance.animation.addByIndices('danceLeft', 'gf starting screen', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gf starting screen', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(logoBl);
		add(gfDance);
		add(logoTE);
		

		titleText = new Sprite(100, 1150); // 100 FlxG.height * 0.8
		titleText.frames = Paths.getSparrowAtlas('press_enter_to_begin');
		titleText.animation.addByPrefix('idle', "Press enter to begin 20", 24, true);
		titleText.animation.addByPrefix('press', "Press enter to begin 2 pressed0", 24, true);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		logoBl.setGraphicSize(Std.int(logoBl.width * 1.05));
		logoTE.setGraphicSize(Std.int(logoTE.width * 1.1));
		gfDance.setGraphicSize(Std.int(gfDance.width * 0.65));
		logoBl.updateHitbox();
		logoTE.updateHitbox();
		gfDance.updateHitbox();
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new Sprite().makeGraphics(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new Sprite(0, FlxG.height * 0.52).loadGraphics(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{

		if(FlxG.fullscreen != FlxG.save.data.fullscreen){
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
			FlxG.save.data.fullscreen = FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
<<<<<<< HEAD
			// If it's Friday according to da clock

=======
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();
			FlxTween.cancelTweensOf(logoBl);
			FlxTween.cancelTweensOf(logoTE);
			FlxTween.cancelTweensOf(gfDance);
			FlxTween.tween(logoBl, {y: 2000}, 0.8, {ease: FlxEase.quadInOut});
			FlxTween.tween(logoTE, {y: 2000}, 0.8, {ease: FlxEase.quadInOut, startDelay: 0.4});
			FlxTween.tween(gfDance, {y: 2000}, 0.8, {ease: FlxEase.quadInOut, startDelay: 0.425});
			FlxTween.tween(titleText, {y: 2000}, 0.8, {ease: FlxEase.quadInOut, startDelay: 0.45});
			
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
					FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		logoTE.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
			FlxTween.tween(logoBl, {y: -50}, 0.8, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(logoTE, {x: 580}, 0.5, {ease: FlxEase.quadInOut});
					FlxTween.tween(gfDance, {y: 100}, 0.5, {ease: FlxEase.quadInOut});
					FlxTween.tween(titleText, {y: FlxG.height * 0.725}, 0.5, {ease: FlxEase.quadInOut, onComplete: function(twn2:FlxTween)
					{
						FlxTween.tween(logoBl, {y: -50 + 50}, 2.5, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 1.2});
						FlxTween.tween(gfDance, {y: -30 + 100}, 2.5, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 1.2});
						FlxTween.tween(logoTE, {y: 450 - 30}, 2.5, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 1.2});
						
					}});
				}});
				
		}
	}
}
