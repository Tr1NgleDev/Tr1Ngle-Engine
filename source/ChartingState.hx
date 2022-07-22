package;

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

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals1:FlxSound;
	var vocals2:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var infoTextForPeople:FlxText;

	var scrollBar:Sprite;
	var scrollBarLine:Sprite;
	var waveform:WaveformVisual;
	var waveformVoice:WaveformVisual;
	var waveformVoice2:WaveformVisual;
	var waveformVoiceStatic:WaveformVisual;
	var waveformVoice2Static:WaveformVisual;
	public static var hitsoundsDadA:Bool = false;
	public static var hitsoundsBFA:Bool = false;

	var notesThatAlreadyPlayedHitSounds:Array<Dynamic> = [];

	override function create()
	{
		FlxG.camera.zoom -= 0.05;
		var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));
		menuBG.color = 0xFF303030;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.3));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		menuBG.antialiasing = true;
		menuBG.alpha = 0.7;
		add(menuBG);

		scrollBar = new Sprite(0, 0).makeGraphics(20, 600, FlxColor.GRAY);
		add(scrollBar);
		scrollBar.screenCenter(Y);
		scrollBarLine = new Sprite(0, 0).makeGraphics(20, 1, FlxColor.BLUE);
		add(scrollBarLine);

		

		

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);
		gridBG.screenCenter();
		
		
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');

		leftIcon.setGraphicSize(0, 60);
		rightIcon.setGraphicSize(0, 60);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(564 - 75, gridBG.y - 100);
		rightIcon.setPosition(716 - 75, gridBG.y - 100);
		dummyArrow = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);
		var gridBlackLine:Sprite = new Sprite(gridBG.x + gridBG.width / 2).makeGraphics(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);
		gridBlackLine.screenCenter(Y);

		infoTextForPeople = new FlxText(-15, -15, 0, "To set notes off-grid - hold SHIFT\nTo change sustain length - press Q/E\nTo back on previous section - press LEFT ARROW\n", 16);
		add(infoTextForPeople);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Bopeebo',
				notes: [],
				bpm: 100,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				speed: 1,
				validScore: false
			};
		}
		if(lastSection < _song.notes.length)
			curSection = lastSection;
		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(0, 0, 0, "", 16);
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(GRID_SIZE * 8, 4, FlxColor.BLUE);
		strumLine.screenCenter(X);
		add(strumLine);

		

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width - 275;
		UI_box.y = gridBG.y;
		add(UI_box);
		bpmTxt.y = gridBG.y + gridBG.height - bpmTxt.height;
		bpmTxt.x = UI_box.x;
		var hitSoundsDad = new FlxUICheckBox(UI_box.x, UI_box.y + UI_box.height + 10, null, null, "Hitsounds Dad", 100);
		hitSoundsDad.checked = ChartingState.hitsoundsDadA;
		hitSoundsDad.callback = function()
		{
			ChartingState.hitsoundsDadA = hitSoundsDad.checked;
			trace('CHECKED!');
		};
		add(hitSoundsDad);
		var hitSoundsBF = new FlxUICheckBox(UI_box.x, UI_box.y + UI_box.height + 20 + hitSoundsDad.height, null, null, "Hitsounds BF", 100);
		hitSoundsBF.checked = ChartingState.hitsoundsBFA;
		hitSoundsBF.callback = function()
		{
			ChartingState.hitsoundsBFA = hitSoundsBF.checked;
			trace('CHECKED!');
		};
		add(hitSoundsBF);
		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		updateHeads();

		super.create();
		updateScrollBar();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};


		var check_mute_v1 = new FlxUICheckBox(10, 230, null, null, "Mute Voices1 (in editor)", 100);
		check_mute_v1.checked = false;
		check_mute_v1.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_v1.checked)
				vol = 0;

			vocals1.volume = vol;
		};

		var check_mute_v2 = new FlxUICheckBox(10, 260, null, null, "Mute Voices2 (in editor)", 100);
		check_mute_v2.checked = false;
		check_mute_v2.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_v2.checked)
				vol = 0;

			vocals2.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});


		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		var startHereButton:FlxButton = new FlxButton(reloadSongJson.x, loadAutosaveBtn.y + 60, "Playtest here", function()
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			var timeA:Float = (FlxG.sound.music.time);
			FlxG.sound.music.stop();
			vocals1.stop();
			vocals2.stop();
			
			PlayState.StartFromTime(timeA);
		});
		var openFileChart:FlxButton = new FlxButton(110, 38, "Open", function()
		{
			openFileChart();
		});
		var restart = new FlxButton(10,140,"Reset", function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });

		var restartCam = new FlxButton(10,170,"To Begin", function()
            {
                resetSection(true);
            });

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 100, 2);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 2022, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel:FlxText = new FlxText(74,65,'BPM');
		var stepperSpeedLabel:FlxText = new FlxText(74,80,'Scroll Speed');

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;
		

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;


		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_v1);
		tab_group_song.add(check_mute_v2);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(restart);
		tab_group_song.add(restartCam);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(startHereButton);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(openFileChart);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
	}

	function openFileChart()
	{
		var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, _onSelect, false, 0, true);
		var filters:Array<FileFilter> = new Array<FileFilter>();
		filters.push(new FileFilter("JSON Files", "*.json"));
		fr.browse(filters);
		//fr.
		//var result:Array<String> = Dialogs.openFile("Select a file please!", "Please select chart file", filters);
		//_onSelect(result);
	}
	function _onSelect(E:Event):Void
	{
		var fr:FileReference = cast(E.target, FileReference);
		fr.load();
		PlayState.SONG = Song.parseJSONshit(fr.data.toString());
		FlxG.resetState();
		updateGrid();
	}	

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		check_altAnim = new FlxUICheckBox(0, UI_box.y + UI_box.height + 25, null, null, "Alt Animation for curSection", 100);
		tab_group_section.add(check_altAnim);

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}


	var stepperSusLength:FlxUINumericStepper;
	var infoAboutAltNote:FlxText;
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		infoAboutAltNote = new FlxText(10,60,'Alt Anim Note:' + (curSelectedNote != null ? (curSelectedNote[3] == true ? "ON" : "OFF") : "OFF") + " [Press V to toggle]");

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(infoAboutAltNote);

		
		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		if(vocals1AudioBuffer != null) 
		{
			vocals1AudioBuffer.dispose();
		}
		if(vocals2AudioBuffer != null) 
		{
			vocals2AudioBuffer.dispose();
		}
		if(instAudioBuffer != null) 
		{
			instAudioBuffer.dispose();
		}
		FlxG.sound.playMusic((PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)), 0.6);
		FlxG.sound.music.pause();
		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals1 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[0] : Paths.voicesFunky(daSong)[0]));
		vocals2 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[1] : Paths.voicesFunky(daSong)[1]));
		FlxG.sound.list.add(vocals1);
		FlxG.sound.list.add(vocals2);

		vocals1AudioBuffer = AudioBuffer.fromFile("./" + (PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[0] : Paths.voicesFunky(daSong)[0]).substr(6));
		vocals2AudioBuffer = AudioBuffer.fromFile("./" + (PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[1] : Paths.voicesFunky(daSong)[1]).substr(6));
		instAudioBuffer = AudioBuffer.fromFile("./" + (PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)).substr(6));

		if(waveform != null)
			remove(waveform);
		waveform = new WaveformVisual(102, 0, 100, 600, FlxColor.RED, instAudioBuffer);
		add(waveform);
		waveform.screenCenter(Y);
		waveform.alpha = 0.7;

		if(vocals1AudioBuffer != null){
			if(waveformVoice != null)
				remove(waveformVoice);
			waveformVoice = new WaveformVisual(102 + 110, waveform.y, 100, 290, FlxColor.BLUE, vocals1AudioBuffer);
			add(waveformVoice);
			waveformVoice.alpha = 0.7;
		}
		if(vocals2AudioBuffer != null){
			if(waveformVoice2 != null)
				remove(waveformVoice2);
			waveformVoice2 = new WaveformVisual(102 + 110, waveform.y + 310, 100, 290, FlxColor.BLUE, vocals2AudioBuffer);
			add(waveformVoice2);
			waveformVoice2.alpha = 0.7;
		}
		
		if(vocals1AudioBuffer != null){
			if(waveformVoiceStatic != null)
				remove(waveformVoiceStatic);
			waveformVoiceStatic = new WaveformVisual(gridBG.x + gridBG.width + 10, 0, 100, gridBG.height, FlxColor.CYAN, vocals1AudioBuffer, true);
			add(waveformVoiceStatic);
			waveformVoiceStatic.screenCenter(Y);
			waveformVoiceStatic.alpha = 0.7;
		}
		if(vocals2AudioBuffer != null){
			if(waveformVoice2Static != null)
				remove(waveformVoice2Static);
			waveformVoice2Static = new WaveformVisual(gridBG.x - 10 - 100, 0, 100, gridBG.height, FlxColor.CYAN, vocals2AudioBuffer, true);
			add(waveformVoice2Static);
			waveformVoice2Static.screenCenter(Y);
			waveformVoice2Static.alpha = 0.7;
		}
		
		FlxG.sound.music.pause();
		vocals1.pause();
		vocals2.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals1.pause();
			vocals1.time = 0;
			vocals2.pause();
			vocals2.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Int = Conductor.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			daPos += 4 * Conductor.crochet;
		}
		return daPos;
	}
	function sectionEndTime():Float
	{
		var daBPM:Int = Conductor.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			daPos += 4 * Conductor.crochet;
		}
		return daPos + 15 * Conductor.stepCrochet;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		bpmTxt.y = gridBG.y + gridBG.height - bpmTxt.height;
		updateHeads();
		scrollBarLine.y = scrollBar.y + FlxG.sound.music.time / FlxG.sound.music.length * 600;
		Conductor.songPosition = FlxG.sound.music.time;
		
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false, false);
		}
		else if(curStep <= 16 * curSection - 1)
		{
			changeSection(curSection - 1, false, true);
		}
		if(ChartingState.hitsoundsDadA)
		{
			for (note in _song.notes[curSection].sectionNotes)
			{
				var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

				if (note[1] > 3)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}
				if(note[0] <= Conductor.songPosition && FlxG.sound.music.playing && !notesThatAlreadyPlayedHitSounds.contains(note) && !gottaHitNote)
				{
					notesThatAlreadyPlayedHitSounds.push(note);
					FlxG.sound.play(Paths.sound("hit2"), 0.8);
				}
			}
		}
		if(ChartingState.hitsoundsBFA)
		{
			for (note in _song.notes[curSection].sectionNotes)
			{
				var gottaHitNote:Bool = _song.notes[curSection].mustHitSection;

				if (note[1] > 3)
				{
					gottaHitNote = !_song.notes[curSection].mustHitSection;
				}
				if(note[0] <= Conductor.songPosition && FlxG.sound.music.playing && !notesThatAlreadyPlayedHitSounds.contains(note) && gottaHitNote)
				{
					notesThatAlreadyPlayedHitSounds.push(note);
					FlxG.sound.play(Paths.sound("hit2"), 0.8);
				}
			}
		}
		
		
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);
		if(FlxG.mouse.overlaps(scrollBar) && FlxG.mouse.pressed)
		{
			var timetogoxd = (FlxG.mouse.y - scrollBar.y) / 600 * FlxG.sound.music.length;
			
			changeSectionAndTime(Math.floor(timetogoxd / (4 * Conductor.crochet)), Math.round(timetogoxd));
		}
		if (FlxG.mouse.justPressed)
		{
			
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.keys.justPressed.V)
		{
			toggleAltAnimNote();
		}
		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals1.stop();
			vocals2.stop();
			vocals2AudioBuffer.dispose();
			vocals1AudioBuffer.dispose();
			instAudioBuffer.dispose();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					notesThatAlreadyPlayedHitSounds = [];
					FlxG.sound.music.pause();
					vocals2.pause();
					vocals1.pause();
				}
				else
				{
					vocals2.play();
					vocals1.play();
					FlxG.sound.music.play();
				}
				vocals1.time = Conductor.songPosition;
				vocals2.time = Conductor.songPosition;
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals1.time = FlxG.sound.music.time;
				vocals2.time = FlxG.sound.music.time;
				notesThatAlreadyPlayedHitSounds = [];
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if ((FlxG.keys.pressed.UP || FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN))
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();
					notesThatAlreadyPlayedHitSounds.splice(0, notesThatAlreadyPlayedHitSounds.length);

					var daTime:Float = (FlxG.keys.pressed.CONTROL ? 100 : 700) * FlxG.elapsed;

					if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals1.time = FlxG.sound.music.time;
					vocals2.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();

					var daTime:Float = Conductor.stepCrochet * (FlxG.keys.pressed.CONTROL ? 1 : 2);

					if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals1.time = FlxG.sound.music.time;
					vocals2.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = 
			_song.song + "\n"
			+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep
			+ "\nBeat: "
			+ curBeat
			+ "\nBPM: "
			+ Conductor.bpm;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function toggleAltAnimNote()
	{
        if(curSelectedNote != null){
        	if(curSelectedNote[3] != null){
        		trace("ALT NOTE SHIT");
        		curSelectedNote[3] = !curSelectedNote[3];
        		trace(curSelectedNote[3]);
        	}
        	else
        	{
        		curSelectedNote[3] = false;
        	}
			updateNoteUI();
        }
		
    }

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals1.pause();
		vocals2.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals1.time = FlxG.sound.music.time;
		vocals2.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}


	

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true, ?endOfSection:Bool = false):Void
	{
		trace('changing section' + sec);
		
		var sectionA = _song.notes[curSection];

		if (_song.notes[sec] != null)
		{

			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = !endOfSection ? sectionStartTime() : sectionEndTime();
				vocals1.time = FlxG.sound.music.time;
				vocals2.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		if(waveformVoiceStatic != null)
		{
			waveformVoiceStatic.curSection = curSection;
			waveformVoiceStatic.updateWaveform();
		}
			
		if(waveformVoice2Static != null)
		{
			waveformVoice2Static.curSection = curSection;
			waveformVoice2Static.updateWaveform();
		}
		notesThatAlreadyPlayedHitSounds = [];
	}
	function changeSectionAndTime(sec:Int = 0, time:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);
		
		var sectionA = _song.notes[curSection];

		if (_song.notes[sec] != null)
		{

			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = time;
				vocals1.time = FlxG.sound.music.time;
				vocals2.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		if(waveformVoiceStatic != null)
		{
			waveformVoiceStatic.curSection = curSection;
			waveformVoiceStatic.updateWaveform();
		}
			
		if(waveformVoice2Static != null)
		{
			waveformVoice2Static.curSection = curSection;
			waveformVoice2Static.updateWaveform();
		}
			
		notesThatAlreadyPlayedHitSounds = [];
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;


		updateHeads();
	}

	

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeIcon(_song.player1);
			rightIcon.changeIcon(_song.player2);
		}
		else
		{
			leftIcon.changeIcon(_song.player2);
			rightIcon.changeIcon(_song.player1);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
		infoAboutAltNote.text = 'Alt Anim Note:' + (curSelectedNote != null ? (curSelectedNote[3] == true ? "ON" : "OFF") : "OFF") + " [Press V to toggle]";
	}
	var colorsList:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	function updateScrollBar():Void
	{
		scrollBar.makeGraphics(20, 600, FlxColor.WHITE);
		scrollBar.pixels.fillRect(new Rectangle(0, 0, 20, 600), FlxColor.WHITE);
		for(a in _song.notes)
		{
			var sectionInfo:Array<Dynamic> = a.sectionNotes;
			for (i in sectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var aa:Bool = false;
				if(daNoteInfo >= 4 && a.mustHitSection)
				{
					daNoteInfo -= 4;
					aa = true;
				}
				if(daNoteInfo < 4 && a.mustHitSection && !aa)
				{
					daNoteInfo += 4;
				}
				scrollBar.pixels.fillRect(new Rectangle(daNoteInfo * 2.5, daStrumTime / (FlxG.sound.music.length) * 600, 2.5, 2.5 + (daSus / 1000 * 2.5)), colorsList[daNoteInfo % 4]);
			}
		}
		
	}
	var vocals1AudioBuffer:AudioBuffer;
	var vocals2AudioBuffer:AudioBuffer;
	var instAudioBuffer:AudioBuffer;

	function updateGrid():Void
	{
		updateScrollBar();
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + gridBG.x;
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:Sprite = new Sprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphics(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (FlxMath.roundDecimal(i[0] + Conductor.offset, 2) == note.strumTime && i[1] % 4 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, false]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, true]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;


	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}
	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}