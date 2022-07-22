package;

import Conductor.BPMChangeEvent;
import EventsSystemSection.SwagEventsSystemSection;
import EventSystemChart.SwagEventSystemChart;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flash.geom.Rectangle;
import lime.media.AudioBuffer;
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
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.FileFilter;

using StringTools;

class EventsEditorState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;


	var bpmTxt:FlxText;

	var strumLine:Sprite;
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:Sprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:Sprite;

	var curRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;

	var _song:SwagEventSystemChart;

	var typingShit:FlxInputText;


	var tempBpm:Int = 0;

	var vocals1:FlxSound;
	var vocals2:FlxSound;

	var scrollBar:Sprite;
	var scrollBarLine:Sprite;

	var waveform:WaveformVisual;
	var waveformStatic:WaveformVisual;
	override function create()
	{
		FlxG.camera.zoom -= 0.05;
		var menuBG:Sprite = new Sprite().loadGraphics(Paths.image("menuDesat"));
		menuBG.color = 0xFF303030;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.3));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		menuBG.alpha = 0.7;
		add(menuBG);

		scrollBar = new Sprite(0, 0).makeGraphics(20, 600, FlxColor.GRAY);
		add(scrollBar);
		scrollBar.screenCenter(Y);
		scrollBarLine = new Sprite(0, 0).makeGraphics(20, 1, FlxColor.BLUE);
		add(scrollBarLine);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
		add(gridBG);
		gridBG.screenCenter();

		dummyArrow = new Sprite(gridBG.x, gridBG.y).makeGraphics(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		curRenderedNotes = new FlxTypedGroup<Note>();

		if (PlayState.EVENTS != null)
			_song = PlayState.EVENTS;
		else
		{
			_song = {
				notes: []
			};
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = PlayState.SONG.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(PlayState.SONG.song);
		Conductor.changeBPM(PlayState.SONG.bpm);
		Conductor.mapBPMChanges(PlayState.SONG);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new Sprite(0, 50).makeGraphics(GRID_SIZE * 4, 4, FlxColor.BLUE);
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

		addSongUI();
		addNoteUI();
		addSectionUI();

		add(curRenderedNotes);

		noteInfoBG = new Sprite(0, 0).makeGraphics(0, 0, FlxColor.BLACK);
		noteInfoBG.scrollFactor.set();
		noteInfoBG.alpha = 0;
		add(noteInfoBG);

		noteInfoText = new FlxText(0, 0, 0, "", 16);
		noteInfoText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noteInfoText.borderSize = 1.25;
		add(noteInfoText);
		super.create();
		updateScrollBar();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, PlayState.SONG.song, 8);
		typingShit = UI_songTitle;


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
			loadSong(PlayState.SONG.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(PlayState.SONG.song.toLowerCase());
		});
		
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);
		var startHereButton:FlxButton = new FlxButton(reloadSongJson.x, loadAutosaveBtn.y + 30, "Playtest here", function()
		{

			PlayState.EVENTS = _song;
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

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

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
		//var result:Array<String> = Dialogs.openFile("Select a file please!", "Please select chart file", filters);
		//var result:Array<String> = fr.openFile("Select a file please!", "Please select chart file", filters);
		//_onSelect(result);
	}
	function _onSelect(E:Event):Void
	{
		var fr:FileReference = cast(E.target, FileReference);
		fr.load();
		PlayState.EVENTS = Song.parseJSONshit(fr.data.toString());
		FlxG.resetState();
		updateGrid();
	}	

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);


		UI_box.addGroup(tab_group_section);
	}

	var noteInfoText:FlxText;
	var noteInfoBG:Sprite;

	var curSelectedEvent:String = "changeDadCharacter";
	var curEventArgs:Array<Dynamic> = [0, 0, 0];
	public static var eventTypes:Array<String> = 
	[
		"changeDadCharacter", 
		"changeBFCharacter", 
		"chromaticAberrations", 
		"vignette", 
		"changeCameraBeat", 
		"changeZoom", 
		"changeRotationHUD",
		"changeRotationGame",
		"changeRotation",
		"playBFAnim", 
		"playDadAnim", 
		"playGFAnim", 
		"shakeCamera", 
		"pointAtGF", 
		"grayScale", 
		"invertColor", 
		"pixelate", 
		"zoomCam", 
		"rotateCamHUD", 
		"rotateCamGame",
		"rotateCam",
		"wavyStrumLine", 
		"countdown", 
		"flashCamera",
		"changeScrollSpeed",
		"cameraPoint",
		"callFunction"
	];

	public static var oldEventTypes:Array<String> =  // DO NOT CHANGE
	[
		"changeDadCharacter", 
		"changeBFCharacter", 
		"chromaticAberrations", 
		"vignette", 
		"changeCameraBeat", 
		"changeZoom", 
		"playBFAnim", 
		"playDadAnim", 
		"playGFAnim", 
		"shakeCamera", 
		"pointAtGF", 
		"grayScale", 
		"invertColor", 
		"pixelate", 
		"zoomCam", 
		"rotateCam", 
		"wavyStrumLine", 
		"countdown", 
		"callFunction"
	];

	var arg0NS:FlxUINumericStepper;
	var arg1NS:FlxUINumericStepper;
	var arg2NS:FlxUINumericStepper;

	var arg0DD:FlxUIDropDownMenu;
	var arg1DD:FlxUIDropDownMenu;
	var arg2DD:FlxUIDropDownMenu;

	var arg0Label:FlxText;
	var arg1Label:FlxText;
	var arg2Label:FlxText;

	var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
	var boolA:Array<String> = ["DISABLE", "ENABLE"];
	
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		
		arg0NS = new FlxUINumericStepper(10, 50);
		arg0NS.name = 'arg0NS';
		arg1NS = new FlxUINumericStepper(10, 70);
		arg1NS.name = 'arg1NS';
		arg2NS = new FlxUINumericStepper(10, 90);
		arg2NS.name = 'arg2NS';
		
		arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, true));
		arg0DD.selectedLabel = "FALSE";
		
		arg1DD = new FlxUIDropDownMenu(140, 70, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, true));
		arg1DD.selectedLabel = "FALSE";
		
		arg2DD = new FlxUIDropDownMenu(140, 90, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, true));
		arg2DD.selectedLabel = "FALSE";
		
		arg0Label = new FlxText(75, 50, 0, "");
		arg1Label = new FlxText(75, 70, 0, "");
		arg2Label = new FlxText(75, 90, 0, "");
		
		var eventsDropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(eventTypes, true), function(event:String)
		{
			
			curSelectedEvent = eventTypes[Std.parseInt(event)];
			
			curEventArgs = [0, 0, 0];
			
			updateNoteUI();
		});
		
		arg0DD.visible = false;
		arg1DD.visible = false;
		arg2DD.visible = false;
		
		arg0NS.visible = false;
		arg1NS.visible = false;
		arg2NS.visible = false;
		
		arg0DD.alpha = 0;
		arg1DD.alpha = 0;
		arg2DD.alpha = 0;
		
		arg0NS.alpha = 0;
		arg1NS.alpha = 0;
		arg2NS.alpha = 0;
		

		
		eventsDropDown.selectedLabel = curSelectedEvent;
		

		tab_group_note.add(arg0DD);
		tab_group_note.add(arg1DD);
		tab_group_note.add(arg2DD);
		
		tab_group_note.add(arg0NS);
		tab_group_note.add(arg1NS);
		tab_group_note.add(arg2NS);
		

		
		tab_group_note.add(arg0Label);
		tab_group_note.add(arg1Label);
		tab_group_note.add(arg2Label);
		
		tab_group_note.add(eventsDropDown);
		
		UI_box.addGroup(tab_group_note);
		
		updateNoteUI();
		
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		if(instAudioBuffer != null) 
		{
			instAudioBuffer.dispose();
		}
		FlxG.sound.playMusic((PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)), 0.6);
		FlxG.sound.music.pause();
		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals1 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[0] : Paths.voicesFunky(daSong)[0]));
		FlxG.sound.list.add(vocals1);
		vocals2 = new FlxSound().loadEmbedded((PlayState.storyDifficulty != 3 ? Paths.voices(daSong)[1] : Paths.voicesFunky(daSong)[1]));
		FlxG.sound.list.add(vocals2);
		instAudioBuffer = AudioBuffer.fromFile("./" + (PlayState.storyDifficulty != 3 ? Paths.inst(daSong) : Paths.instFunky(daSong)).substr(6));

		if(waveform != null)
			remove(waveform);
		waveform = new WaveformVisual(102, 0, 300, 600, FlxColor.RED, instAudioBuffer);
		add(waveform);
		waveform.screenCenter(Y);
		waveform.alpha = 0.7;
		if(waveformStatic != null)
			remove(waveformStatic);
		waveformStatic = new WaveformVisual(gridBG.x + gridBG.width + 10, 0, 200, gridBG.height, FlxColor.CYAN, instAudioBuffer, true);
		add(waveformStatic);
		waveformStatic.screenCenter(Y);
		waveformStatic.alpha = 0.7;
		

		FlxG.sound.music.pause();
		vocals1.pause();
		vocals2.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals1.pause();
			vocals2.time = 0;
			vocals1.pause();
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
				
				
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			if (wname == 'arg0NS')
			{
				curEventArgs[0] = nums.value;
				updateGrid();
			}
			else if (wname == 'arg1NS')
			{
				curEventArgs[1] = nums.value;
				updateGrid();
			}
			else if (wname == 'arg2NS')
			{
				curEventArgs[2] = nums.value;
				updateGrid();
			}
			FlxG.log.add(wname);
			
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
		scrollBarLine.y = scrollBar.y + FlxG.sound.music.time / FlxG.sound.music.length * 600;
		curStep = recalculateSteps();
		bpmTxt.y = gridBG.y + gridBG.height - bpmTxt.height;
		Conductor.songPosition = FlxG.sound.music.time;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * 16));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((16) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}
		else if(curStep <= 16 * curSection - 1)
		{
			changeSection(curSection - 1, false, true);
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
						trace('tryin to delete note...');
						deleteNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
				{
					FlxG.log.add('added note');
					addNote(Reflect.copy(curEventArgs));
				}
			}
		}
		if (FlxG.mouse.overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.mouse.overlaps(note))
				{
					noteInfoBG.visible = true;
					noteInfoText.visible = true;
					noteInfoText.text = "Event Type: " + note.eventType + "\nArg0: " + note.eventArgs[0] + "\nArg1: " + note.eventArgs[1] + "\nArg2: " + note.eventArgs[2] + "\n";
					noteInfoText.y = FlxG.mouse.y - GRID_SIZE;
					noteInfoText.x = FlxG.mouse.x;
					noteInfoBG.x = noteInfoText.x - 5;
					noteInfoBG.y = noteInfoText.y - 5;
					noteInfoBG.width = noteInfoText.fieldWidth + 5;
					noteInfoBG.height = noteInfoText.height + 5;
				}
				
			});
		}
		else
		{
			noteInfoText.visible = false;
			noteInfoBG.visible = false;
		}
			
		

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 16))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			
			PlayState.EVENTS = _song;
			FlxG.sound.music.stop();
			vocals1.stop();
			vocals2.stop();
			FlxG.switchState(new PlayState());
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
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();
				}
				else
				{
					vocals1.play();
					vocals2.play();
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
				
			}
			
			if (!FlxG.keys.pressed.SHIFT)
			{
				if ((FlxG.keys.pressed.UP || FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN))
				{
					FlxG.sound.music.pause();
					vocals1.pause();
					vocals2.pause();

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
			PlayState.SONG.song + "\n"
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
				vocals2.pause();
				vocals1.pause();
				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = !endOfSection ? sectionStartTime() : sectionEndTime();
				vocals2.time = FlxG.sound.music.time;
				vocals1.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		waveformStatic.curSection = curSection;
		waveformStatic.updateWaveform();
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
		waveformStatic.curSection = curSection;
		waveformStatic.updateWaveform();
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (16 * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];
	}

	


	function updateNoteUI():Void
	{
		
		arg0DD.visible = false;
		arg1DD.visible = false;
		arg2DD.visible = false;
		arg0NS.visible = false;
		arg1NS.visible = false;
		arg2NS.visible = false;
		

		
		arg0DD.alpha = 0;
		arg1DD.alpha = 0;
		arg2DD.alpha = 0;
		arg0NS.alpha = 0;
		arg1NS.alpha = 0;
		arg2NS.alpha = 0;
		

		

		arg0Label.text = "";
		arg1Label.text = "";
		arg2Label.text = "";
		

		
		//UI_box.getTabGroup("Note").remove(arg0NS);
		//UI_box.getTabGroup("Note").remove(arg1NS);
		//UI_box.getTabGroup("Note").remove(arg2NS);
		//UI_box.getTabGroup("Note").remove(arg0DD);
		//UI_box.getTabGroup("Note").remove(arg1DD);
		//UI_box.getTabGroup("Note").remove(arg2DD);
		switch(curSelectedEvent)
		{
			case "changeDadCharacter" | "changeBFCharacter": // changing characters
				
				trace("a");
				arg0Label.text = "Char";
				arg1Label.text = "X Spawn Offset";
				arg2Label.text = "Y Spawn Offset";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = characters[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 1, 0, -2000, 2000, 0);
				arg1NS.value = 0;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
				curEventArgs[1] = arg1NS.value;
				
				UI_box.getTabGroup("Note").add(arg1NS);
				UI_box.getTabGroup("Note").remove(arg2NS);
				arg2NS = new FlxUINumericStepper(10, 90, 1, 0, -2000, 2000, 0);
				arg2NS.value = 0;
				arg2NS.name = 'arg2NS';
				arg2NS.visible = true;
				arg2NS.alpha = 1;
				curEventArgs[2] = arg2NS.value;
				
				UI_box.getTabGroup("Note").add(arg2NS);
			case "chromaticAberrations": // chromatic aberrations
				trace("a");
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = boolA[0];
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "vignette": // vignette
				trace("a");
				arg1Label.text = "Radius";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = boolA[0];
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 0.05, 0.05, 0.05, 1, 2);
				arg1NS.value = 0.1;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
				curEventArgs[1] = arg1NS.value;
				
				UI_box.getTabGroup("Note").add(arg1NS);
			case "changeCameraBeat": // cam beat
				trace("a");
				arg0Label.text = "Camera Beat Zoom";
				arg1Label.text = "Camera Beat Speed";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 1, 1, 8, 0);
				arg0NS.value = 1;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 1, 4, 1, 16, 0);
				arg1NS.value = 4;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
				curEventArgs[1] = arg1NS.value;
				
				UI_box.getTabGroup("Note").add(arg1NS);
			case "changeZoom": // change zoom
				arg0Label.text = "New Zoom Value";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 0.05, 0.9, 0, 2, 2);
				arg0NS.value = 0.9;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "changeRotationHUD":
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 1);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "changeRotationGame":
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 1);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "changeRotation":
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -360, 360, 1);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "playBFAnim": // playing anims for bf
				arg0Label.text = "Anim";
				UI_box.getTabGroup("Note").remove(arg0DD);

				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(Character.getCharacterAnimsList(PlayState.SONG.player1), false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = "spinMic";
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "playDadAnim": // playing anims for dad
				arg0Label.text = "Anim";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(Character.getCharacterAnimsList(PlayState.SONG.player2), false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = "spinMic";
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "playGFAnim": // playing anims for gf
				arg0Label.text = "Anim";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(Character.getCharacterAnimsList("gf"), false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = "cheer";
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "shakeCamera": // shaking camera
				arg0Label.text = "Intensity of Shake";
				arg1Label.text = "Time";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 0.05, 1, 0, 10, 2); // intensity
				arg0NS.value = 1;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);

				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 0.05, 1, 0, 10, 2); // time
				arg1NS.value = 1;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
				curEventArgs[1] = arg1NS.value;
				UI_box.getTabGroup("Note").add(arg1NS);
			case "flashCamera":
				arg0Label.text = "Duration";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 0.1, 0.5, 0, 10, 2);
				arg0NS.value = 0.5;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				UI_box.getTabGroup("Note").add(arg0NS);
			case "pointAtGF": // point at gf
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = boolA[0];
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "changeScrollSpeed":
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 0.1, FlxMath.roundDecimal(PlayState.SONG.speed, 2), 0.1, 100, 2);
				arg0NS.value = FlxMath.roundDecimal(PlayState.SONG.speed, 2);
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				UI_box.getTabGroup("Note").add(arg0NS);
			case "cameraPoint":
				arg1Label.text = "X";
				arg2Label.text = "Y";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				curEventArgs[0] = boolA[0];
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);

				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 0.5, 0, -2000, 2000, 2); // X
				arg1NS.value = 1;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
				curEventArgs[1] = arg1NS.value;
				UI_box.getTabGroup("Note").add(arg1NS);

				UI_box.getTabGroup("Note").remove(arg2NS);
				arg2NS = new FlxUINumericStepper(10, 90, 0.5, 0, -2000, 2000, 2); // Y
				arg2NS.value = 1;
				arg2NS.name = 'arg2NS';
				arg2NS.visible = true;
				arg2NS.alpha = 1;
				curEventArgs[2] = arg2NS.value;
				UI_box.getTabGroup("Note").add(arg2NS);

			case "grayScale": // grayScale
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				curEventArgs[0] = boolA[0];
				arg0DD.selectedLabel = curEventArgs[0];
				
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "invertColor": // invert color
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = boolA[0];
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "pixelate": // pixelate
				arg1Label.text = "Pixel Size";
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
					
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = boolA[0];
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
				UI_box.getTabGroup("Note").remove(arg1NS);
				arg1NS = new FlxUINumericStepper(10, 70, 5, 80, 20, 120, 1);
				arg1NS.value = 80;
				arg1NS.name = 'arg1NS';
				arg1NS.visible = true;
				arg1NS.alpha = 1;
					curEventArgs[1] = arg1NS.value;
				
				UI_box.getTabGroup("Note").add(arg1NS);
			case "zoomCam": // zoom
				arg0Label.text = "Zoom Value";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -16, 16, 0);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "rotateCam": // rotate
				arg0Label.text = "Rotation Angle";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -180, 180, 0);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "rotateCamGame": // rotate
				arg0Label.text = "Rotation Angle";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -180, 180, 0);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "rotateCamHUD": // rotate
				arg0Label.text = "Rotation Angle";
				UI_box.getTabGroup("Note").remove(arg0NS);
				arg0NS = new FlxUINumericStepper(10, 50, 1, 0, -180, 180, 0);
				arg0NS.value = 0;
				arg0NS.name = 'arg0NS';
				arg0NS.visible = true;
				arg0NS.alpha = 1;
				curEventArgs[0] = arg0NS.value;
				
				UI_box.getTabGroup("Note").add(arg0NS);
			case "wavyStrumLine": // wavy strum line
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(boolA, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = boolA[0];
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "countdown": // countdown
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(["Without Sound", "With Sound"], false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				arg0DD.selectedLabel = curEventArgs[0];
				curEventArgs[0] = "Without Sound";
				arg0DD.visible = true;
				arg0DD.alpha = 1;
				UI_box.getTabGroup("Note").add(arg0DD);
			case "callFunction": // callFunction
				UI_box.getTabGroup("Note").remove(arg0DD);
				arg2Label.text = "this event basically calls\npublic static function from PlayState.hx\n\nyou need to put every function name\nin the functionsList array in PlayState.hx";
				
				arg0DD = new FlxUIDropDownMenu(140, 50, FlxUIDropDownMenu.makeStrIdLabelArray(PlayState.functionsList, false), function(value:String)
				{
					curEventArgs[0] = value;
				});
				curEventArgs[0] = PlayState.functionsList[0];
				arg0DD.selectedLabel = curEventArgs[0];
				arg0DD.alpha = 1;

				UI_box.getTabGroup("Note").add(arg0DD);
		}
		//UI_box.getTabGroup("Note").add(arg0NS);
		//UI_box.getTabGroup("Note").add(arg1NS);
		//UI_box.getTabGroup("Note").add(arg2NS);
		//UI_box.getTabGroup("Note").add(arg0DD);
		//UI_box.getTabGroup("Note").add(arg1DD);
		//UI_box.getTabGroup("Note").add(arg2DD);
	}
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
				scrollBar.pixels.fillRect(new Rectangle(daNoteInfo * 5, daStrumTime / (FlxG.sound.music.length) * 600, 5, 5), FlxColor.GREEN);
			}
		}
		
	}
	var instAudioBuffer:AudioBuffer;
	
	function updateGrid():Void
	{
		updateScrollBar();
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}



		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;


			var daBPM:Int = PlayState.SONG.bpm;

			Conductor.changeBPM(daBPM);


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
			if(cast(i[2], String).startsWith("0") || cast(i[2], String).startsWith("1") || cast(i[2], String).startsWith("2"))
				i[2] = EventsEditorState.eventTypes[Std.parseInt(cast(i[2], String))];
			var daNoteEventTypeA = i[2];
			var daNoteEventArgsA = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4, true);
			note.setGraphicSize(GRID_SIZE + 5, GRID_SIZE + 5);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + gridBG.x;
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * 16)));
			note.eventArgs = daNoteEventArgsA;
			note.eventType = daNoteEventTypeA;
			curRenderedNotes.add(note);

		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagEventsSystemSection = {
			sectionNotes: []
		};

		_song.notes.push(sec);
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

	private function addNote(eventArgs:Array<Dynamic>):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, curSelectedEvent, eventArgs]);

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		//updateNoteUI();
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
		PlayState.EVENTS = EventSystemChart.loadFromJson(song.toLowerCase() + "-events", song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.EVENTS = EventSystemChart.parseJSONshit(FlxG.save.data.autosaveEvents);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosaveEvents = Json.stringify({
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
			_file.save(data.trim(), PlayState.SONG.song.toLowerCase() + "-events.json");
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
