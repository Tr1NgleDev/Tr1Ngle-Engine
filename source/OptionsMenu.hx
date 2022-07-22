package;

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

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCatagory> = [
		new OptionCatagory("Preferences", [
			new HitsoundsOption(),
			new PauseCountdownOption(),
			new InstantRespawnOption(),
			new OffsetsOption(),
			new CalibrateOffsetsOption(),
			new BotOption(),
			new FramerateOption(),
			new FPSOption(),
			new MemoryCounterOption(),
			new FullscreenOption(),
			new ShadersOption(),
<<<<<<< HEAD
			//new OptimizationOption()
			
		]),
		new OptionCatagory("Mobile Controls",[]),
		new OptionCatagory("Keyboard Controls",[]),
		new OptionCatagory("Hitbox Selection",[]),
=======
			new PreloadImagesOption(),
			new SkillIssueOption()
		]),
		new OptionCatagory("Appearance",[]),
		new OptionCatagory("Controls",[]),
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		new OptionCatagory("Exit",[]),
	];
	
	private var grpControls:FlxTypedGroup<Alphabet>;
	
	private var checkBoxesArray:Array<CheckboxThingie> = [];

	var currentSelectedCat:OptionCatagory;

	var camFollow:FlxObject;

	override function create()
	{
		
		var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.scrollFactor.x = 0;
        menuBG.scrollFactor.y = 0.18;
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter(X);
		add(camFollow);

		

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (100 * i) + 105, options[i].getName(), true, false);
			grpControls.add(controlLabel);

			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		changeSelection(0);
		

    #if android
	  addVirtualPad(FULL, A_B_C);
    #end
 
		super.create();
	}

	var isCat:Bool = false;

	
	
	public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.offset = FlxG.save.data.notesOffset;
		FlxG.fullscreen = FlxG.save.data.fullscreen;
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if(!isCat)
		{
			grpControls.forEach(function(controlLabel:Alphabet)
			{
				controlLabel.screenCenter(X);
			
			});
		}
		else
		{
			grpControls.forEach(function(controlLabel:Alphabet)
			{
				controlLabel.x = 120;
			});
		}

			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0 ... checkBoxesArray.length) 
				{
			        
					remove(checkBoxesArray[i]);
					checkBoxesArray[i].destroy();
					
				    
				}
				
				checkBoxesArray = [];

				for (i in 0...options.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (100 * i) + 105, options[i].getName(), true, false);
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				curSelected = 0;
				changeSelection(0);
			}
<<<<<<< HEAD
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
=======
			if (controls.UP_PUI)
				changeSelection(-1);
			if (controls.DOWN_PUI)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT #if android || _virtualpad.buttonC.justPressed #end)
						{
<<<<<<< HEAD
							if (controls.RIGHT_P)
								currentSelectedCat.getOptions()[curSelected].right();
							if (controls.LEFT_P)
=======
							if (controls.RIGHTUI)
								currentSelectedCat.getOptions()[curSelected].right();
							if (controls.LEFTUI)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
<<<<<<< HEAD
						if (controls.RIGHT_P)
							currentSelectedCat.getOptions()[curSelected].right();
						if (controls.LEFT_P)
=======
						if (controls.RIGHTUI)
							currentSelectedCat.getOptions()[curSelected].right();
						if (controls.LEFTUI)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				
			}
			
		

			

			if (controls.ACCEPT)
			{
				
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press(true))
					{
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
						grpControls.add(ctrl);
						ctrl.isMenuItem = true;
						checkBoxesArray[curSelected].sprTracker = grpControls.members[curSelected];
						checkBoxesArray[curSelected].set_daValue(currentSelectedCat.getOptions()[curSelected].getAccept());
						//updateCheckboxes();
					}
				}
				else
				{
					
                        if(options[curSelected].getName() == "Keyboard Controls")
						{
							FlxG.switchState(new BindMenu());
						}
<<<<<<< HEAD
						else if(options[curSelected].getName() == "Mobile Controls")
						{
							FlxG.switchState(new android.AndroidControlsMenu());
						}
						else if(options[curSelected].getName() == "Hitbox Selection")
						{
							FlxG.switchState(new HitboxSkinState());
=======
						else if(options[curSelected].getName() == "Appearance")
						{
							FlxG.switchState(new AppearanceMenu());
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
						}
						else if(options[curSelected].getName() == "Exit")
						{
							FlxG.switchState(new MainMenuState());
						}
						else
						{
							currentSelectedCat = options[curSelected];
							isCat = true;
							grpControls.clear();
							for (i in 0...currentSelectedCat.getOptions().length)
								{
									var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), currentSelectedCat.getOptions()[i].boldDisplay, false);
									controlLabel.isMenuItem = true;
									controlLabel.targetY = i;
									grpControls.add(controlLabel);
									// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
									/*var checkbox:CheckboxThingie = new CheckboxThingie(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getAccept());
									checkbox.sprTracker = controlLabel;

									// using a FlxGroup is too much fuss!
									checkBoxesArray.push(checkbox);
									add(checkbox);*/
								}
							curSelected = 0;
							updateCheckboxes();
						}
                    
					
					
				}
			}
			else if(controls.LEFT_PUI && isCat)
			{
				if(currentSelectedCat.getOptions()[curSelected].left())
				{
					grpControls.remove(grpControls.members[curSelected]);
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
					grpControls.add(ctrl);
					ctrl.isMenuItem = true;
				}
			}else if (controls.RIGHT_PUI && isCat)
			{
				if(currentSelectedCat.getOptions()[curSelected].right())
				{
					grpControls.remove(grpControls.members[curSelected]);
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), currentSelectedCat.getOptions()[curSelected].boldDisplay, false);
					grpControls.add(ctrl);
					ctrl.isMenuItem = true;
				}
			}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function updateCheckboxes()
	{
		for (i in 0 ... checkBoxesArray.length)
		{
			checkBoxesArray[i].destroy();
			remove(checkBoxesArray[i]);
		}
		checkBoxesArray = [];
		for (i in 0...currentSelectedCat.getOptions().length)
		{
			currentSelectedCat.getOptions()[i].press(false);
			var checkbox:CheckboxThingie = new CheckboxThingie(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getAccept());
			checkbox.sprTracker = grpControls.members[i];
			// using a FlxGroup is too much fuss!
			checkBoxesArray.push(checkbox);
			if(!currentSelectedCat.getOptions()[i].withoutCheckboxes)
				add(checkbox);
			
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4, false);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		camFollow.screenCenter();

		

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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
