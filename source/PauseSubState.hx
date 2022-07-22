package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var difficultyChoices:Array<String> = ["Easy", "Normal", "Hard", "Back"];
	var modifiersChoices:Array<String> = ["Insta Fail", "No Fail", "Random Notes", "Back"];
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Modifiers', 'Exit to menu'/*, 'Exit to chart editor'*/];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Modifiers', 'Exit to menu'];
	var curSelected:Int = 0;

	var canCountdown:Bool = true;

	var pauseMusic:FlxSound;

	public function new()
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeathCounter:FlxText = new FlxText(20,79,0,"",32);
		levelDeathCounter.text += "Blue balled: " + PlayState.deathCounter;
		levelDeathCounter.scrollFactor.set();
		levelDeathCounter.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeathCounter.updateHitbox();
		add(levelDeathCounter);

		var levelModifier1:FlxText = new FlxText(20,79 + 32,0,"",32);
		levelModifier1.text += "Insta. Fail = " + (!PlayState.instaFail ? "false" : "true");
		levelModifier1.scrollFactor.set();
		levelModifier1.setFormat(Paths.font('vcr.ttf'), 32);
		levelModifier1.updateHitbox();
		add(levelModifier1);

		var levelModifier2:FlxText = new FlxText(20,79 + 64,0,"",32);
		levelModifier2.text += "No Fail = " + (!PlayState.noFail ? "false" : "true");
		levelModifier2.scrollFactor.set();
		levelModifier2.setFormat(Paths.font('vcr.ttf'), 32);
		levelModifier2.updateHitbox();
		add(levelModifier2);

		var levelModifier4:FlxText = new FlxText(20,79 + 96,0,"",32);
		levelModifier4.text += "Random Notes = " + (!PlayState.randomNotes ? "false" : "true");
		levelModifier4.scrollFactor.set();
		levelModifier4.setFormat(Paths.font('vcr.ttf'), 32);
		levelModifier4.updateHitbox();
		add(levelModifier4);

		

		

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeathCounter.alpha = 0;
		levelModifier1.alpha = 0;
		levelModifier2.alpha = 0;
		levelModifier4.alpha = 0;
		

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeathCounter.x = FlxG.width - (levelDeathCounter.width + 20);
		levelModifier1.x = FlxG.width - (levelModifier1.width + 20);
		levelModifier2.x = FlxG.width - (levelModifier2.width + 20);
		levelModifier4.x = FlxG.width - (levelModifier4.width + 20);
	
		

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeathCounter, {alpha: 1, y: levelDeathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(levelModifier1, {alpha: 1, y: levelModifier1.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(levelModifier2, {alpha: 1, y: levelModifier2.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(levelModifier4, {alpha: 1, y: levelModifier4.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		
		

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	
	#if android
	addVirtualPad(FULL, A_B);
  #end
	}
	function regenMenu() 
	{
        
        grpMenuShit.clear();
        
            
        for (a in 0 ... menuItems.length) {
         	var songText:Alphabet = new Alphabet(0, (70 * a) + 30, menuItems[a], true, false);
			songText.isMenuItem = true;
			songText.targetY = a;
			grpMenuShit.add(songText);
         } 
            
        
        curSelected = 0;
        changeSelection();
    }
    var startTimer:FlxTimer;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if(canCountdown)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					closePauseMenu();

				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
                case "Easy":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-easy", PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 0;
                    
					FlxG.switchState(new PlayState());
					
				case "Normal":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase(), PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 1;
                    
					FlxG.switchState(new PlayState());
					
				case "Hard":
                	PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + "-hard", PlayState.SONG.song.toLowerCase());
                    PlayState.storyDifficulty = 2;
                    
					FlxG.switchState(new PlayState());
					
				case "Back":
                	menuItems = menuItemsOG;
                	regenMenu();

                case "Insta Fail": //done
                	
                    PlayState.instaFail = !PlayState.instaFail;
                    PlayState.noFail = false;
                    
					FlxG.switchState(new PlayState());

				case "No Fail": //done
                	
                    PlayState.noFail = !PlayState.noFail;
                    PlayState.instaFail = false;
                    
					FlxG.switchState(new PlayState());

				case "Random Notes": //done
                	
                    PlayState.randomNotes = !PlayState.randomNotes;
                    
					FlxG.switchState(new PlayState());
				
				case "Modifiers":
					menuItems = modifiersChoices;
					regenMenu();
			}
		}

	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	public function closePauseMenu()
	{

		if(FlxG.save.data.pauseCountdown)
		{
			if(canCountdown)
			{
				canCountdown = false;
				var swagCounter:Int = 0;
				var three:FlxText = new FlxText(0, 0, 400, "3", 100);
				three.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				three.borderSize = 2.5;

				var two:FlxText = new FlxText(0, 0, 400, "2", 100);
				two.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				two.borderSize = 2.5;

				var one:FlxText = new FlxText(0, 0, 400, "1", 100);
				one.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				one.borderSize = 2.5;

				var go:FlxText = new FlxText(0, 0, 400, "GO", 100);
				go.setFormat(Paths.font("vcr.ttf"), 100, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				go.borderSize = 2.5;
				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					switch (swagCounter) 
					{
						case 0:
							three.screenCenter();
							three.acceleration.y = 600;
							three.velocity.y -= FlxG.random.int(190, 205);
							three.velocity.x -= FlxG.random.int(0, 50);
							three.updateHitbox();
							add(three);
							FlxTween.tween(three, {alpha: 0}, Conductor.crochet / 1002, {
								startDelay: Conductor.crochet * 0.001,
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									three.destroy();
								}
							});

						case 1:
							two.screenCenter();
							two.acceleration.y = 600;
							two.velocity.y -= FlxG.random.int(190, 205);
							two.velocity.x -= FlxG.random.int(0, 50);
							two.updateHitbox();
							add(two);
							FlxTween.tween(two, {alpha: 0}, Conductor.crochet / 1002, {
								startDelay: Conductor.crochet * 0.001,
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									two.destroy();
								}
							});

						case 2:
							one.screenCenter();
							one.acceleration.y = 600;
							one.velocity.y -= FlxG.random.int(190, 205);
							one.velocity.x -= FlxG.random.int(0, 50);
							one.updateHitbox();
							add(one);
							FlxTween.tween(one, {alpha: 0}, Conductor.crochet / 1002, {
								startDelay: Conductor.crochet * 0.001,
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									one.destroy();
								}
							});

						case 3:
							go.screenCenter();
							go.acceleration.y = 600;
							go.velocity.y -= FlxG.random.int(190, 205);
							go.velocity.x -= FlxG.random.int(0, 50);
							go.updateHitbox();
							add(go);
							FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1002, {
								startDelay: Conductor.crochet * 0.001,
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});

						case 4:
							close();
					}
					swagCounter += 1;
				}, 5);
			}
			
		}
		else
		{
			close();
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
