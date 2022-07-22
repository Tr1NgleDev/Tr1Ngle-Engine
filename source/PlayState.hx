package;

import openfl.geom.Rectangle;
import flixel.math.FlxRandom;
#if desktop
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import Section.SwagSection;
import Song.SwagSong;
import EventsSystemSection.SwagEventsSystemSection;
import EventSystemChart.SwagEventSystemChart;

import WiggleEffect.WiggleEffectType;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;


using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var EVENTS:SwagEventSystemChart;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;


	public static var instance:PlayState;

	var halloweenLevel:Bool = false;



	private var vocals1:FlxSound;
	private var vocals2:FlxSound;
	var judgementBar:Sprite;
	private var pointAtGF:Bool = false;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var shadersLoaded:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:Sprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	public var kps:Int = 0;
	public var kpsMax:Int = 0;
	private var time:Float = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<Sprite>;
	private var playerStrums:FlxTypedGroup<Sprite>;
	private var dadStrums:FlxTypedGroup<Sprite>;


	public var wavyStrumLineNotes:Bool = false;


	private var camZooming:Bool = false;
	private var curSong:String = "";

	var timeTxt:FlxText;

	private var chromOn:Bool = false;
	private var invertOn:Bool = false;
	private var pixelateOn:Bool = false;
	private var pixelateShaderPixelSize:Float = 80;
	private var grayScaleOn:Bool = false;
	private var vignetteOn:Bool = false;
	private var vignetteRadius:Float = 0.1;


	public var spinCamHud:Bool = false;
	public var spinCamGame:Bool = false;
	public var spinPlayerNotes:Bool = false;
	public var spinEnemyNotes:Bool = false;

	public var spinCamHudLeft:Bool = false;
	public var spinCamGameLeft:Bool = false;
	public var spinPlayerNotesLeft:Bool = false;
	public var spinEnemyNotesLeft:Bool = false;

	public var spinCamHudSpeed:Float = 0.5;
	public var spinCamGameSpeed:Float = 0.5;
	public var spinPlayerNotesSpeed:Float = 0.5;
	public var spinEnemyNotesSpeed:Float = 0.5;


	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	var filters:Array<BitmapFilter> = [];
	var camfilters:Array<BitmapFilter> = [];
	private var combo:Int = 0;
	private var misses:Int = 0;
	var totalAccuracy:Float = 0;
	var maxTotalAccuracy:Float = 0;
	public var hits:Array<Float> = [];
	var maxCombo:Int = 0;
	var totalRank:String = "S+";

	private var healthBarBG:Sprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var hitAccuracy:Array<Float> = [];

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:Sprite;
	var isHalloween:Bool = false;
	var botAutoPlayAlert:FlxText;

	var phillyCityLights:FlxTypedGroup<Sprite>;
	var phillyTrain:Sprite;
	var trainSound:FlxSound;

	var limo:Sprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:Sprite;

	var upperBoppers:Sprite;
	var bottomBoppers:Sprite;
	var santa:Sprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var deathCounter:Int = 0;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;


	// week 1 shit

	var backDudes:Sprite;
	var centralDudes:Sprite;
	var frontDudes:Sprite;



	var ch = 2 / 1000;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end


	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	// modifiers

	public static var instaFail:Bool = false;
	public static var noFail:Bool = false;
	public static var randomNotes:Bool = false;

	public static var seenCutscene:Bool = false;


	var spinMicBeat:Int = 0;
	var spinMicOffset:Int = 4;
	var spinMicBeat2:Int = 0;
	var spinMicOffset2:Int = 6;
	public var startTime:Float = 0;
	public var clicks:Array<Float> = [];


	public var limoSpeaker:Sprite;

	public static var functionsList:Array<String> = ["testFunction"];

	public static function testFunction()
	{
		trace("you called a function using event note");
	}

	public static function StartFromTime(time:Float)
	{
		var a:PlayState = new PlayState();
		a.startTime = time;
		FlxG.switchState(a);

	}
	private function CalculateKeysPerSecond()
	{

		for (i in 0 ... clicks.length)
		{
			if (clicks[i] <= time - 1)
			{
				clicks.remove(clicks[i]);
			}
		}
		kps = clicks.length;
	}

	override public function create()
	{
<<<<<<< HEAD
=======

		instance = this;
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		Bind.keyCheck();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash0);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		camGame.setFilters(filters);
		camGame.filtersEnabled = true;
		camHUD.setFilters(camfilters);
		camHUD.filtersEnabled = true;

		persistentUpdate = true;
		persistentDraw = true;

		

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		if (EVENTS == null)
			EVENTS = 
			{
				notes: []
			};

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Funky";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " , "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end
<<<<<<< HEAD
=======
		var stageLights:Sprite;
		var stageCurtains:Sprite;
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new Sprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                          {
		                  curStage = 'philly';

		                  var bg:Sprite = new Sprite(-100).loadGraphics(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:Sprite = new Sprite(-10).loadGraphics(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<Sprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:Sprite = new Sprite(city.x).loadGraphics(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:Sprite = new Sprite(-40, 50).loadGraphics(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new Sprite(2000, 360).loadGraphics(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:Sprite = new Sprite().loadGraphics(AssetPaths.win0.png);

		                  var street:Sprite = new Sprite(-40, streetBehind.y).loadGraphics(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                curStage = 'limo';
		                defaultCamZoom = 0.7;
		                /*
						  old code bruh
						var skyBG:Sprite = new Sprite(-120, -50).loadGraphics(Paths.image('limo/limoSunset'));
						skyBG.setGraphicSize(Std.int(skyBG.width * 1.2));
		                skyBG.scrollFactor.set(0.1, 0.1);
		                add(skyBG);
		                var bgLimo:Sprite = new Sprite(-200, 480);
		                bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                bgLimo.animation.play('drive');
		                bgLimo.scrollFactor.set(0.4, 0.4);
		                add(bgLimo);
		                grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                add(grpLimoDancers);
		                for (i in 0...5)
		                {
		                        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                        dancer.scrollFactor.set(0.4, 0.4);
		                        grpLimoDancers.add(dancer);
		                }
		                
		                limo = new Sprite(-120, 550);
		                limo.frames = limoTex;
		                limo.animation.addByPrefix('drive', "Limo stage", 24);
		                limo.animation.play('drive');
		                limo.antialiasing = true;*/


						var bgBack:Sprite = new Sprite(-738, -605).loadGraphics(Paths.image("limo/BGb"));
						bgBack.setGraphicSize(Std.int(bgBack.width * 1.6));
		                bgBack.scrollFactor.set(0.11, 0.11);
		                
						var bgFront:Sprite = new Sprite(-747, 163).loadGraphics(Paths.image("limo/BGf"));
						bgFront.setGraphicSize(Std.int(bgFront.width * 1.5));
		                bgFront.scrollFactor.set(0.115, 0.115);

						var road:Sprite = new Sprite(-2410, 211);
						road.frames = Paths.getSparrowAtlas("limo/road");
						road.animation.addByPrefix('road', 'road', 24, true);
						road.scrollFactor.set(0.9, 0.9);
						road.antialiasing = true;
						road.animation.play('road');

						var bgLimo:Sprite = new Sprite(-863, 107);
						bgLimo.frames = Paths.getSparrowAtlas("limo/bgLimo");
						bgLimo.animation.addByPrefix('limo', 'background limo pink', 24, true);
						bgLimo.antialiasing = true;
						bgLimo.scrollFactor.set(0.4, 0.4);
						bgLimo.animation.play('limo');

						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						for (i in 0...8)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + -116, 162);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}


						limo = new Sprite(-295, 587);
		                limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
		                limo.animation.addByPrefix('drive', "Limo stage", 24, false);
		                limo.antialiasing = true;

		                fastCar = new Sprite(-300, 160).loadGraphics(Paths.image('limo/fastCarLol'));
						fastCar.scrollFactor.set(0.4, 0.4);
						fastCar.antialiasing = true;
						
						limoSpeaker = new Sprite(1187, 412);
						limoSpeaker.frames = Paths.getSparrowAtlas('limo/speaker_car');
						limoSpeaker.antialiasing = true;
						limoSpeaker.animation.addByPrefix('boom', "speaker car0", 24, false);
						limoSpeaker.setGraphicSize(Std.int(limoSpeaker.width * 0.95));
						add(bgBack);
						add(bgFront);
						add(road);
						add(bgLimo);
						add(grpLimoDancers);
						resetFastCar();
						


		                // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:Sprite = new Sprite(-1000, -500).loadGraphics(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new Sprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:Sprite = new Sprite(-1100, -600).loadGraphics(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:Sprite = new Sprite(370, -250).loadGraphics(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new Sprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:Sprite = new Sprite(-600, 700).loadGraphics(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new Sprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:Sprite = new Sprite(-400, -500).loadGraphics(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:Sprite = new Sprite(300, -300).loadGraphics(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:Sprite = new Sprite(-200, 700).loadGraphics(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new Sprite().loadGraphics(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:Sprite = new Sprite(repositionShit, 0).loadGraphics(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:Sprite = new Sprite(repositionShit).loadGraphics(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:Sprite = new Sprite(repositionShit + 170, 130).loadGraphics(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:Sprite = new Sprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:Sprite = new Sprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:Sprite = new Sprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:Sprite = new Sprite(posX, posY).loadGraphics(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:Sprite = new Sprite(posX, posY).loadGraphics(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
		          default:
		          {
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:BGSprite = new BGSprite("week1/stageback", -71, -63, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * 1.4));
					add(bg);

					var stageFront:Sprite = new Sprite(-665, 718).loadGraphics(Paths.image('week1/stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.8));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(1, 1);
					stageFront.active = false;
					add(stageFront);
		          }
              }
			
		var gfVersion:String = 'gf';
		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		if(curStage == "limo")
			gf.scrollFactor.set(1, 1);
		dad = new Character(100, 100, SONG.player2);



		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 205;
				boyfriend.x += 260 + 180;
				gf.x += 510;
				gf.y += 185;
			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case "stage":
				dad.x += 100;
				boyfriend.x += 100;
				gf.x += 100;
		}
<<<<<<< HEAD

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo' && !FlxG.save.data.optimode)
			add(limo);
	
=======
		if (curStage == 'limo')
			add(limo);
		add(gf);
		if (curStage == 'limo')
			add(limoSpeaker);
		// Shitty layering but whatev it works LOL
		

>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		add(dad);
		add(boyfriend);

		if(curStage == 'limo')
			add(fastCar);

		if(curStage == "stage")
		{
			stageLights = new Sprite(-24, -115).loadGraphics(Paths.image('week1/stageLight'));
			stageLights.setGraphicSize(Std.int(stageLights.width * 1.9));
			stageLights.updateHitbox();
			stageLights.antialiasing = true;
			stageLights.scrollFactor.set(1.25, 1.25);
			stageLights.active = false;
			
			stageCurtains = new Sprite(-980, -553).loadGraphics(Paths.image('week1/stagecurtains'));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			backDudes = new Sprite(-1040, 619 + 500); // showing pos is y:500+;
			backDudes.frames = Paths.getSparrowAtlas("week1/back_dudes");
			backDudes.animation.addByPrefix("idle", "back dudes", 24, false);
			backDudes.animation.play("idle", true);
			backDudes.antialiasing = true;
			backDudes.setGraphicSize(Std.int(backDudes.width * 2));
			backDudes.updateHitbox();
			backDudes.scrollFactor.set(1.6, 1.6);

			centralDudes = new Sprite(-1228, 677 + 500); // showing pos is y:500+;
			centralDudes.frames = Paths.getSparrowAtlas("week1/central_dudes");
			centralDudes.animation.addByPrefix("idle", "mid dudes", 24, false);
			centralDudes.animation.play("idle", true);
			centralDudes.antialiasing = true;
			centralDudes.setGraphicSize(Std.int(centralDudes.width * 2));
			centralDudes.updateHitbox();
			centralDudes.scrollFactor.set(1.5, 1.5);

			frontDudes = new Sprite(-1033, 673 + 500); // showing pos is y:500+;
			frontDudes.frames = Paths.getSparrowAtlas("week1/front_dudes");
			frontDudes.animation.addByPrefix("idle", "front dudes", 24, false);
			frontDudes.animation.play("idle", true);
			frontDudes.antialiasing = true;
			frontDudes.setGraphicSize(Std.int(frontDudes.width * 2));
			frontDudes.updateHitbox();
			frontDudes.scrollFactor.set(1.35, 1.35);
			
			add(stageLights);
			add(stageCurtains);
			add(frontDudes);
			add(centralDudes);
			add(backDudes);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		var bgForNotes1:Sprite = new Sprite(40 + 50, 0).makeGraphics(470, FlxG.height);
		bgForNotes1.scrollFactor.set();
		bgForNotes1.screenCenter(Y);
		var bgForNotes2:Sprite = new Sprite(680 + 50, 0).makeGraphics(470, FlxG.height);
		bgForNotes2.scrollFactor.set();
		bgForNotes2.screenCenter(Y);
		bgForNotes2.color = FlxColor.BLACK;
		bgForNotes1.color = FlxColor.BLACK;
		bgForNotes1.alpha = 0.4;
		bgForNotes2.alpha = 0.4;

		var bgForNotes12:Sprite = new Sprite(30 + 50, 0).makeGraphics(490, FlxG.height);
		bgForNotes12.scrollFactor.set();
		bgForNotes12.screenCenter(Y);
		var bgForNotes22:Sprite = new Sprite(670 + 50, 0).makeGraphics(490, FlxG.height);
		bgForNotes22.scrollFactor.set();
		bgForNotes22.screenCenter(Y);
		bgForNotes22.color = FlxColor.BLACK;
		bgForNotes12.color = FlxColor.BLACK;
		bgForNotes12.alpha = 0.4;
		bgForNotes22.alpha = 0.4;

		
		{
			bgForNotes2.alpha = 0.2;
			bgForNotes1.alpha = 0.2;
			bgForNotes2.x = 360 + 50;
			bgForNotes1.x = 360 + 50;

			bgForNotes22.alpha = 0.2;
			bgForNotes12.alpha = 0.2;
			bgForNotes22.x = 350 + 50;
			bgForNotes12.x = 350 + 50;
		}


		

		strumLine = new Sprite(0, 50).makeGraphics(FlxG.width, 10);
		strumLine.scrollFactor.set();
		strumLine.screenCenter(X);
		timeTxt = new FlxText(strumLine.x + (FlxG.width / 2) - 245 + 50, strumLine.y - 40, 400, "0:00", 30);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0.5;
		timeTxt.borderSize = 1.25;

		
		
		if (FlxG.save.data.downscroll)
		{
			timeTxt.y = FlxG.height - 45;
			strumLine.y = FlxG.height - 150;
		}

		strumLineNotes = new FlxTypedGroup<Sprite>();
		
		if(FlxG.save.data.bgNotes)
		{
			add(bgForNotes1);
			add(bgForNotes2);
			add(bgForNotes12);
			add(bgForNotes22);
		}
		add(timeTxt);
		if(FlxG.save.data.judgementBar)
		{
			judgementBar = new Sprite(0, 5);
			judgementBar.scrollFactor.set();
			generateJudgementSprite();
			judgementBar.screenCenter(X);
			judgementBar.alpha = 0.8;
			judgementBar.cameras = [camHUD];
			add(judgementBar);
			
		}
		add(strumLineNotes);

		add(grpNoteSplashes);


		playerStrums = new FlxTypedGroup<Sprite>();
		dadStrums = new FlxTypedGroup<Sprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new Sprite(0, FlxG.height * 0.9).loadGraphics(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = FlxG.height * 0.1;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);



		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		changeHealthBarColor();
		add(healthBar);

		switch (FlxG.save.data.uiOption - 1)
		{
			case 0: // FNF Original
				scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
				scoreTxt.scrollFactor.set();
			case 1: // TE
				scoreTxt = new FlxText(healthBarBG.x + 50, healthBarBG.y + 45, 0, "", 20);
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				scoreTxt.scrollFactor.set();
				scoreTxt.borderSize = 1.25;
		}
		
		/*
		//code for changing ui :skull:
		switch (FlxG.save.data.uiOption - 1)
		{
			case 0: // FNF Original
			case 1: // TE
		}
		*/
		
		add(scoreTxt);


		if(FlxG.save.data.botAutoPlay)
		{
			botAutoPlayAlert = new FlxText(0, 500, 0, "BOT AUTO PLAY", 40);
			botAutoPlayAlert.screenCenter(X);
			botAutoPlayAlert.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botAutoPlayAlert.scrollFactor.set();
			add(botAutoPlayAlert);
		}
		if(FlxG.save.data.skillIssue)
		{
			var skillIssue = new FlxText(0, 0, 0, "skill issue mode activated", 16);
			skillIssue.screenCenter(X);
			skillIssue.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			skillIssue.scrollFactor.set();
			skillIssue.alpha = 0.1;
			add(skillIssue);
			skillIssue.cameras = [camHUD];
		}
		

		

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		#if desktop
		if(FileSystem.exists(Paths.txt(SONG.song.toLowerCase() + "/info")))
			{
				
				var songInfoName:String = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + "/info"))[0];
				var songInfoArtist:String = "Artist: " + CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + "/info"))[1];
				var songInfoText:FlxText = new FlxText(0, 0, 0, songInfoName + "\n\n" + songInfoArtist + "\n", 30);
				songInfoText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.BLACK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
				songInfoText.borderSize = 2;
				var songInfoBG:Sprite = new Sprite(0, 0).makeGraphics(Math.round(songInfoText.fieldWidth + 40), 130, FlxColor.BLACK);
				songInfoBG.scrollFactor.set();
				songInfoBG.screenCenter(Y);
				//songInfoBG.alpha = 0.6;
				songInfoBG.alpha = 0;
				songInfoBG.x -= songInfoBG.width;
				//songInfoText.alpha = 0.6;
				songInfoText.x = songInfoBG.x + 20;
				songInfoText.y = songInfoBG.y + 20;
				songInfoText.alpha = 0;
				add(songInfoBG);
				add(songInfoText);
				songInfoBG.cameras = [camHUD];
				songInfoText.cameras = [camHUD];
				FlxTween.tween(songInfoBG, {x: songInfoBG.x + songInfoBG.width, alpha: 0.6}, 1, {ease: FlxEase.quartInOut, startDelay: 0});
				FlxTween.tween(songInfoText, {x: songInfoText.x + songInfoBG.width, alpha: 0.8}, 1, {ease: FlxEase.quartInOut, startDelay: 0.016666666666666666});
				FlxTween.tween(songInfoBG, {x: songInfoBG.x - (songInfoBG.width + 100), alpha: 0}, 1, {ease: FlxEase.quartInOut, startDelay: 2.5});
				FlxTween.tween(songInfoText, {x: songInfoText.x - (songInfoBG.width + 100), alpha: 0}, 1, {ease: FlxEase.quartInOut, startDelay: 2.516666666666666666});
			}
		#end
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		bgForNotes1.cameras = [camHUD];
		bgForNotes2.cameras = [camHUD];
		bgForNotes12.cameras = [camHUD];
		bgForNotes22.cameras = [camHUD];
		if(FlxG.save.data.botAutoPlay)
			botAutoPlayAlert.cameras = [camHUD];
		
		doof.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		
		  #if android
    	addAndroidControls();
      androidc.visible = true;
      #end

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			PlayState.seenCutscene = true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:Sprite = new Sprite(0, 0).makeGraphics(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
		}


	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:Sprite = new Sprite(-100, -100).makeGraphics(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:Sprite = new Sprite(-100, -100).makeGraphics(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:Sprite = new Sprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		
		generateStaticArrowsDAD();
		generateStaticArrowsBF();

		
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			beatHit();
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}
	function startFakeCountdown(withSound:Bool):Void
	{

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if(withSound)FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:Sprite = new Sprite().loadGraphics(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic((storyDifficulty != 3 ? Paths.inst(PlayState.SONG.song) : Paths.instFunky(PlayState.SONG.song)), 1, false);
		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.time = startTime;
		vocals1.play();
		vocals2.play();
		vocals1.time = startTime;
		vocals2.time = startTime;
		FlxTween.tween(timeTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		

	}

	var debugNum:Int = 0;
	var curSpeed:Float = 0;
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		var eventsData = EVENTS;
		Conductor.changeBPM(songData.bpm);
		speed = SONG.speed;
		curSpeed = SONG.speed;
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals1 = new FlxSound().loadEmbedded((storyDifficulty != 3 ? Paths.voices(PlayState.SONG.song)[0] : Paths.voicesFunky(PlayState.SONG.song)[0]));
		else
			vocals1 = new FlxSound();
		if (SONG.needsVoices)
			vocals2 = new FlxSound().loadEmbedded((storyDifficulty != 3 ? Paths.voices(PlayState.SONG.song)[1] : Paths.voicesFunky(PlayState.SONG.song)[1]));
		else
			vocals2 = new FlxSound();
		trace(" song need voices: " + SONG.needsVoices);
		trace((storyDifficulty != 3 ? Paths.voices(PlayState.SONG.song)[1] : Paths.voicesFunky(PlayState.SONG.song)[1]));
		FlxG.sound.list.add(vocals1);
		FlxG.sound.list.add(vocals2);

		notes = new FlxTypedGroup<Note>();
		add(notes);


		var noteData:Array<SwagSection>;
		var eventsNoteData:Array<SwagEventsSystemSection>;

		// NEW SHIT
		noteData = songData.notes;
		eventsNoteData = eventsData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				if(daStrumTime >= startTime)
				{
					var daNoteData:Int = Std.int(songNotes[1] % 4);
					var daRandomNoteData:Int = FlxG.random.int(0,3);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, (!randomNotes ? daNoteData : daRandomNoteData), false, oldNote, false, (!gottaHitNote ? dad.noteSkin : ""));
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
					swagNote.altNote = songNotes[3];

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, (!randomNotes ? daNoteData : daRandomNoteData), false, oldNote, true, (!gottaHitNote ? dad.noteSkin : ""));
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.mustPress = gottaHitNote;

						if(sustainNote.mustPress)
						{
							if(!FlxG.save.data.middlescroll)
								sustainNote.x += ((FlxG.width / 2) * 1) + 50;
							else
								sustainNote.x += ((FlxG.width / 2) * 0.5) + 50;
						}
						else
						{
							if(!FlxG.save.data.middlescroll)
								sustainNote.x += ((FlxG.width / 2) * 0) + 50;
							else
								sustainNote.x += ((FlxG.width / 2) * 0.5) + 50;
						}
						if(gottaHitNote == false && (FlxG.save.data.middlescroll) && FlxG.save.data.showEnemyNotes)
							sustainNote.alpha = 0.2;
						else if(gottaHitNote == false && (FlxG.save.data.middlescroll) && !FlxG.save.data.showEnemyNotes)
							sustainNote.alpha = 0;
					}

					swagNote.mustPress = gottaHitNote;

					if(gottaHitNote == false && (FlxG.save.data.middlescroll) && FlxG.save.data.showEnemyNotes)
						swagNote.alpha = 0.35;
					else if(gottaHitNote == false && (FlxG.save.data.middlescroll) && !FlxG.save.data.showEnemyNotes)
						swagNote.alpha = 0;
					if(swagNote.mustPress)
					{
						if(!FlxG.save.data.middlescroll)
							swagNote.x += ((FlxG.width / 2) * 1) + 50;
						else
							swagNote.x += ((FlxG.width / 2) * 0.5) + 50;
					}
					else
					{
						if(!FlxG.save.data.middlescroll)
							swagNote.x += ((FlxG.width / 2) * 0) + 50;
						else
							swagNote.x += ((FlxG.width / 2) * 0.5) + 50;
					}
				}

				
			}
			daBeats += 1;
		}

		for (eventSection in eventsNoteData)
		{
			var coolSection:Int = Std.int(16 / 4);

			for (songNotes in eventSection.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				if(daStrumTime >= startTime)
				{
					var daNoteData:Int = Std.int(songNotes[1] % 5);
					if(cast(songNotes[2], String).startsWith("0") || cast(songNotes[2], String).startsWith("1") || cast(songNotes[2], String).startsWith("2"))
						songNotes[2] = EventsEditorState.oldEventTypes[Std.parseInt(cast(songNotes[2], String))];
					var daNoteEventType:String = songNotes[2];
					var daNoteEventArgs:Array<Dynamic> = songNotes[3];
					var gottaHitNote:Bool = false;
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, true, null, false);
					swagNote.scrollFactor.set(0, 0);
					unspawnNotes.push(swagNote);
					swagNote.eventType = daNoteEventType;
					swagNote.eventArgs = daNoteEventArgs;
					swagNote.eventNote = true;
	
					swagNote.mustPress = gottaHitNote;
					swagNote.alpha = 0;
				}
				
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}
	
	private function generateStaticArrowsBF(doEffect:Bool = true):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:Sprite = new Sprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphics(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas("NOTE_assets");
					babyArrow.animation.addByPrefix('green', 'arrowUP', 24, true);
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN', 24, true);
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT', 24, true);
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT', 24, true);

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);

						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);

						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);

						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);

					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if(doEffect)
			{
				if (!isStoryMode)
				{	
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
				else
				{	
					FlxG.save.data.downscroll ? babyArrow.y += 100 : babyArrow.y -= 100;
					babyArrow.alpha = 0.4;
					FlxTween.tween(babyArrow, {y: FlxG.save.data.downscroll ? babyArrow.y - 100 : babyArrow.y + 100, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.6 + (0.15 * i)});
				}
			}
			babyArrow.ID = i;

			playerStrums.add(babyArrow);
			
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			if(!FlxG.save.data.middlescroll)
				babyArrow.x += ((FlxG.width / 2) * 1) + 50;
			else
				babyArrow.x += ((FlxG.width / 2) * 0.5) + 50;

			strumLineNotes.add(babyArrow);
		}
	}

	private function generateStaticArrowsDAD(doEffect:Bool = true):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:Sprite = new Sprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphics(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas((dad.noteSkin != "" ? dad.noteSkin : "NOTE_assets"));
					babyArrow.animation.addByPrefix('green', 'arrowUP', 24, true);
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN', 24, true);
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT', 24, true);
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT', 24, true);

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);

						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);

						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);

						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);

					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if(FlxG.save.data.middlescroll)
				babyArrow.alpha = 0;

			if(doEffect && !FlxG.save.data.middlescroll)
			{
				if (!isStoryMode)
				{	
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
				else
				{	
					FlxG.save.data.downscroll ? babyArrow.y += 100 : babyArrow.y -= 100;
					babyArrow.alpha = 0.4;
					FlxTween.tween(babyArrow, {y: FlxG.save.data.downscroll ? babyArrow.y - 100 : babyArrow.y + 100, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.6 + (0.15 * i)});
				}
			}

			babyArrow.ID = i;

			dadStrums.add(babyArrow);
			
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			if(!FlxG.save.data.middlescroll)
				babyArrow.x += ((FlxG.width / 2) * 0) + 50;
			else
				babyArrow.x += ((FlxG.width / 2) * 0.5) + 50;

			strumLineNotes.add(babyArrow);
		}
	}
	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals1.pause();
				vocals2.pause();
			}
			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals1.pause();
		vocals2.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals1.time = Conductor.songPosition;
		vocals1.play();

		vocals2.time = Conductor.songPosition;
		vocals2.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var camRot:Float = 0;
	var camHUDRot:Float = 0;
	var camPointEventX:Float = 0;
	var camPointEventY:Float = 0;
	var camPointEventEnabled:Bool = false;
	var speed:Float = 0;
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		time += elapsed;
		CalculateKeysPerSecond();
		if(kps >= kpsMax)
			kpsMax = kps;
		
		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;
					

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}



		
		
		super.update(elapsed);

		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		if(totalAccuracy >= maxTotalAccuracy)
			maxTotalAccuracy = totalAccuracy;
		if(combo >= maxCombo)
			maxCombo = combo;


		if(spinCamHud)
		{
			spinHudCamera();
		}
		if(spinCamGame)
		{
			spinGameCamera();
		}
		if(spinPlayerNotes)
		{
			spinPlayerStrumLineNotes();
		}
		if(spinEnemyNotes)
		{
			spinEnemyStrumLineNotes();
		}

		

		if(FlxG.save.data.shadersOn)
		{
			if (chromOn)
			{
				ch = FlxG.random.int(1,5) / 1000;
				ch = FlxG.random.int(1,5) / 1000;
				Shaders.setChrome(ch);
			}
			else
			{
				Shaders.setChrome(0);
			}
			if (vignetteOn)
			{
				Shaders.setVignette(vignetteRadius);
			}
			else
			{
				Shaders.setVignette(0);
			}
			Shaders.setGrayScale((grayScaleOn == true ? 1 : 0));
			Shaders.setInvertColor((invertOn == true ? 1 : 0));
			if (pixelateOn)
			{
				Shaders.setPixelation(pixelateShaderPixelSize);
			}
			else
			{
				Shaders.setPixelation(0);
			}
		}

		// ranking system
		if(totalAccuracy == 100)
		{
			totalRank = "S++";
		}
		else if(totalAccuracy < 100 && totalAccuracy >= 95)
		{
			totalRank = "S+";
		}
		else if(totalAccuracy < 95 && totalAccuracy >= 90)
		{
			totalRank = "S";
		}
		else if(totalAccuracy < 90 && totalAccuracy >= 85)
		{
			totalRank = "S-";
		}
		else if(totalAccuracy < 85 && totalAccuracy >= 70)
		{
			totalRank = "A";
		}
		else if(totalAccuracy < 70 && totalAccuracy >= 60)
		{
			totalRank = "B";
		}
		else if(totalAccuracy < 60 && totalAccuracy >= 40)
		{
			totalRank = "C";
		}
		else if(totalAccuracy < 40 && totalAccuracy >= 20)
		{
			totalRank = "D";
		}
		else if(totalAccuracy < 20 && totalAccuracy >= 0)
		{
			totalRank = "F";
		}	
		

		if(instaFail == true && misses >= 1)
		{
			health = 0;
		}

		if(wavyStrumLineNotes)
		{
			for(i in 0...strumLineNotes.length)
			{
				strumLineNotes.members[i].y = strumLine.y
					+ Math.sin(Conductor.songPosition / 1000 * 5 + (i % 4 + 1)) * 20
					+ 20;
			}
		}
		else
		{
			for(i in 0...strumLineNotes.length)
			{
				strumLineNotes.members[i].y = strumLine.y;
			}
		}


		switch (FlxG.save.data.uiOption - 1)
		{
			case 0: // FNF Original
				scoreTxt.text = "Score:" + songScore;
			case 1: // TE
				scoreTxt.text = "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank;
		}
		
		

<<<<<<< HEAD
		if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end&& startedCountdown && canPause)
=======
		if (controls.PAUSE && startedCountdown && canPause)
>>>>>>> e5dca5e5d0ffa1bd7a713985ec1cf3b9aa588618
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 10000 chance for Gitaroo Man easter egg ( not 1 / 1000 as before >:) )
			if (FlxG.random.bool(0.01))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState());
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}
		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new EventsEditorState());

			#if desktop
			DiscordClient.changePresence("Events Editor", null, null, true);
			#end
		}
		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}

		

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(150 + 0.85 * (iconP1.width - 150)));
                iconP2.setGraphicSize(Std.int(150 + 0.85 * (iconP2.width - 150)));

                if(iconP1.angle < 0)
                	iconP1.angle = CoolUtil.coolLerp(iconP1.angle, 0, Conductor.crochet / 1000 / cameraBeatSpeed);
                if(iconP2.angle > 0)
                	iconP2.angle = CoolUtil.coolLerp(iconP2.angle, 0, Conductor.crochet / 1000 / cameraBeatSpeed);

                if(iconP1.angle > 0)
                	iconP1.angle = 0;
                if(iconP2.angle < 0)
                	iconP2.angle = 0;

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
		{
			//FlxColor.fromRGB(255, 64, 64)
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 64, 64), 0.3);
			iconP1.animation.curAnim.curFrame = 1;
			if(iconP2.animation.curAnim.numFrames == 3)
				iconP2.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80)
		{
			//FlxColor.fromRGB(100, 255, 100)
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(100, 255, 100), 0.3);
			iconP2.animation.curAnim.curFrame = 1;
			if(iconP1.animation.curAnim.numFrames == 3)
				iconP1.animation.curAnim.curFrame = 2;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 255, 255), 0.3);
		}


		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
				var curTime:Float = FlxG.sound.music.time;
				if(curTime < 0) curTime = 0;
				//songPercent = (curTime / songLength);
				var secondsTotal:Int = Math.floor((FlxG.sound.music.length - curTime) / 1000);
				if(secondsTotal < 0) secondsTotal = 0;
				var minutesRemaining:Int = Math.floor(secondsTotal / 60);
				var secondsRemaining:String = '' + secondsTotal % 60;
				if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
				timeTxt.text = minutesRemaining + ':' + secondsRemaining;
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		//Camera moving shit

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (/*camFollow.x != dad.getMidpoint().x + 150 && */!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && (!pointAtGF && !camPointEventEnabled))
			{
				var camFollowX:Float = dad.getMidpoint().x;
				var camFollowY:Float = dad.getMidpoint().y;

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollowY = dad.getMidpoint().y;
					case 'senpai':
						camFollowY = dad.getMidpoint().y - 380;
						camFollowX = dad.getMidpoint().x - 240;
					case 'senpai-angry':
						camFollowY = dad.getMidpoint().y - 380;
						camFollowX = dad.getMidpoint().x - 240;
					case 'senpai-pissed':
						camFollowY = dad.getMidpoint().y - 380;
						camFollowX = dad.getMidpoint().x - 240;
					case 'pico':
						camFollowY = dad.getMidpoint().y - 50;
						camFollowX = dad.getMidpoint().x + 100;
					default:
						camFollowX = dad.getMidpoint().x;
						camFollowY = dad.getMidpoint().y;
						
				}
				if(dad.animation.curAnim.name.startsWith("singLEFT") && curStage != "school" && curStage != "schoolEvil" && curStage != "mall" && curStage != "mallEvil" && dad.curCharacter != "pico"){
					camFollowX = camFollowX - 20;
				}
				if(dad.animation.curAnim.name.startsWith("singRIGHT")){
					camFollowX = camFollowX + 20;
				}
				if(dad.animation.curAnim.name.startsWith("singUP") && curStage != "school" && curStage != "schoolEvil" && curStage != "mall" && curStage != "mallEvil"){
					camFollowY = camFollowY - 20;
				}
				if(dad.animation.curAnim.name.startsWith("singDOWN") && curStage != "schoolEvil" && dad.curCharacter != "pico"){
					camFollowY = camFollowY + 20;
				}

				
				camFollow.setPosition(camFollowX + 150, camFollowY - 100);

				if (dad.curCharacter == 'mom'){
					vocals2.volume = 1;
					vocals1.volume = 1;
				}
					

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection/* && camFollow.x != boyfriend.getMidpoint().x - 100*/ && (!pointAtGF && !camPointEventEnabled))
			{
				var camFollowX:Float = boyfriend.getMidpoint().x;
				var camFollowY:Float = boyfriend.getMidpoint().y;
				

				switch (curStage)
				{
					case 'limo':
						camFollowX = boyfriend.getMidpoint().x - 200;
					case 'mall':
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'school':
						camFollowX = boyfriend.getMidpoint().x - 100;
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'schoolEvil':
						camFollowX = boyfriend.getMidpoint().x - 100;
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'philly':
						camFollowX = boyfriend.getMidpoint().x;
					default:
						camFollowX = boyfriend.getMidpoint().x;
						camFollowY = boyfriend.getMidpoint().y;
						
				}

				if(boyfriend.animation.curAnim.name.startsWith("singLEFT")){
					camFollowX = camFollowX - 20;
				}
				if(boyfriend.animation.curAnim.name.startsWith("singRIGHT") && curStage != "school" && curStage != "schoolEvil" && curStage != "mall" && curStage != "mallEvil"){
					camFollowX = camFollowX + 20;
				}
				if(boyfriend.animation.curAnim.name.startsWith("singUP") && curStage != "school" && curStage != "schoolEvil" && curStage != "mall" && curStage != "mallEvil"){
					camFollowY = camFollowY - 20;
				}
				if(boyfriend.animation.curAnim.name.startsWith("singDOWN") && curStage != "schoolEvil"){
					camFollowY = camFollowY + 20;
				}

				camFollow.setPosition(camFollowX - 100, camFollowY - 100);

				
				

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
			if(pointAtGF && !camPointEventEnabled)
				camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y - 20);
			if(camPointEventEnabled && !pointAtGF)
				camFollow.setPosition(camPointEventX, camPointEventY);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom - (curStage == "limo" ? 0.125 : 0), FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

			FlxG.camera.angle = FlxMath.lerp(camRot, FlxG.camera.angle, 0.95);
			camHUD.angle = FlxMath.lerp(camHUDRot, camHUD.angle, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals1.volume = 0;
					vocals2.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals1.stop();
			vocals2.stop();
			FlxG.sound.music.stop();

			deathCounter++;
			if(!FlxG.save.data.instRespawn)
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			else
				FlxG.switchState(new PlayState());

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") ","Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		curSpeed = CoolUtil.coolLerp(speed, curSpeed, 0.975);
		if (generatedMusic)
		{
			if (SONG.song != 'Tutorial')
				camZooming = true;
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				//daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				
				var c = strumLineNotes.members[daNote.noteData + (daNote.mustPress ? 4 : 0)].y + Note.swagWidth / 2;
				if(FlxG.save.data.downscroll)
				{
					daNote.y = strumLineNotes.members[daNote.noteData + (daNote.mustPress ? 4 : 0)].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(curSpeed, 2);
					if(daNote.isSustainNote)
					{
						if(daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y = daNote.y + daNote.prevNote.height;
						else
							daNote.y = daNote.y + daNote.height / 2;

						if( (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= c)
						{
							var d = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
			                                d.height = (c - daNote.y) / daNote.scale.y;
			                                d.y = daNote.frameHeight - d.height;
			                                daNote.clipRect = d;
			                        }
					}
				}
				else
				{
					daNote.y = strumLineNotes.members[daNote.noteData + (daNote.mustPress ? 4 : 0)].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(curSpeed, 2);
					if(daNote.isSustainNote)
					{
						if( (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= c)
						{
							var d = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
				                        d.y = (c - daNote.y) / daNote.scale.y;
				                        d.height -= d.y;
				                        daNote.clipRect = d;
				                }
				        }
				}
				/*if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}*/
				 
				if(daNote.eventNote && daNote.wasGoodHit)
				{
					var event:String = daNote.eventType;
					switch(event)
					{
						case "changeDadCharacter":
							changeDadCharacter(daNote.eventArgs[0], daNote.eventArgs[1], daNote.eventArgs[2]);
						case "changeBFCharacter":
							changeBFCharacter(daNote.eventArgs[0], daNote.eventArgs[1], daNote.eventArgs[2]);
						case "chromaticAberrations":
							chromOn = daNote.eventArgs[0] == "ENABLE";
						case "vignette":
							//trace("vignette" + " " + daNote.eventArgs[0] + " " + daNote.eventArgs[1]);
							vignetteOn = daNote.eventArgs[0] == "ENABLE";
							vignetteRadius = daNote.eventArgs[1];
						case "changeCameraBeat":
							//trace("a");
							cameraBeatZoom = 0.025 * daNote.eventArgs[0];
							cameraBeatSpeed = daNote.eventArgs[1];
						case "changeZoom":
							defaultCamZoom = daNote.eventArgs[0];
						case "changeRotation":
							camRot = daNote.eventArgs[0];
							camHUDRot = daNote.eventArgs[0];
						case "changeRotationHUD":
							camHUDRot = daNote.eventArgs[0];
						case "changeScrollSpeed":
							speed = daNote.eventArgs[0];
						case "changeRotationGame":
							camRot = daNote.eventArgs[0];
						case "cameraPoint":
							camPointEventEnabled = daNote.eventArgs[0] == "ENABLE";
							camPointEventX = daNote.eventArgs[1];
							camPointEventY = daNote.eventArgs[2];
						case "playBFAnim":
							boyfriend.playAnim(daNote.eventArgs[0], true);
						case "playDadAnim":
							dad.playAnim(daNote.eventArgs[0], true);
						case "playGFAnim":
							gf.playAnim(daNote.eventArgs[0], true);
						case "shakeCamera":
							FlxG.camera.shake(daNote.eventArgs[0] / 100, daNote.eventArgs[1]);
						case "pointAtGF":
							pointAtGF = daNote.eventArgs[0] == "ENABLE";
						case "grayScale":
							//trace(daNote.eventArgs[0]);
							grayScaleOn = daNote.eventArgs[0] == "ENABLE";
						case "invertColor":
							//trace(daNote.eventArgs[0]);
							invertOn = daNote.eventArgs[0] == "ENABLE";
						case "pixelate":
							//trace(daNote.eventArgs[0]);
							//trace(daNote.eventArgs[1]);
							pixelateOn = daNote.eventArgs[0] == "ENABLE";
							pixelateShaderPixelSize = daNote.eventArgs[1];
						case "zoomCam":
							FlxG.camera.zoom += 0.025 * daNote.eventArgs[0];
							camHUD.zoom += 0.025 * daNote.eventArgs[0] * 2;
						case "rotateCam":
							FlxG.camera.angle += daNote.eventArgs[0];
							camHUD.angle += daNote.eventArgs[0];
						case "rotateCamHUD":
							camHUD.angle += daNote.eventArgs[0];
						case "rotateCamGame":
							FlxG.camera.angle += daNote.eventArgs[0];
						case "wavyStrumLine":
							wavyStrumLineNotes = daNote.eventArgs[0] == "ENABLE";
						case "countdown":
							startFakeCountdown(daNote.eventArgs[0] == "With Sound");
						case "callFunction": // ayo wtf callFunction note
							if(Reflect.field(PlayState, daNote.eventArgs[0]) != null)
							{
								Reflect.callMethod(PlayState, Reflect.field(PlayState, daNote.eventArgs[0]), []);
							}
						case "flashCamera":
							FlxG.camera.flash(FlxColor.WHITE, daNote.eventArgs[0]);
					}
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.eventNote)
				{
					

					var altAnim:String = "";

					if (SONG.notes[Math.floor(Math.floor(curStep / 16))] != null)
					{
						if (SONG.notes[Math.floor(Math.floor(curStep / 16))].altAnim)
							altAnim = '-alt';
					}
					if(daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}
					if(FlxG.random.bool(85) && !daNote.isSustainNote && (FlxG.save.data.showEnemyNotes || !FlxG.save.data.middlescroll))
						createNoteSplash(daNote);

					dadStrums.forEach(function(spr:Sprite)
							{
								if(spr.ID == Math.abs(daNote.noteData))
								{
									spr.animation.play('confirm', true);
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										
										spr.animation.play('static', true);
										if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
										
									});
								
									if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
									{
										spr.animation.play('static', true);
									}
								}
								else if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
								{
									spr.animation.play('static', true);
								}
								

								if(dad.animation.curAnim.name == 'idle')
								{
									spr.animation.play('static', true);
								}

								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
								
							});

					dad.holdTimer = 0;
					if (SONG.needsVoices)
						vocals1.volume = 1;
					if (SONG.needsVoices)
						vocals2.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				/*if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
				{

					if ((daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote.noteData);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}*/
				var missNote:Bool = daNote.y < -daNote.height;
				if(FlxG.save.data.downscroll) missNote = daNote.y > FlxG.height;
				if(missNote && daNote.mustPress)
				{
					if(daNote.tooLate || !daNote.wasGoodHit)
						noteMiss(daNote.noteData);
					daNote.active = false;
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
		{
			keyShit();
		}
		

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.onComplete = null;

		vocals1.volume = 0;
		vocals2.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			var averageAccuracy:Float = 0;

			for (i in 0 ... hitAccuracy.length) 
			{
				averageAccuracy += hitAccuracy[i];
			}
			averageAccuracy = FlxMath.roundDecimal(averageAccuracy / hitAccuracy.length, 2);
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, averageAccuracy, maxCombo);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);



			if (storyPlaylist.length <= 0)
			{
				
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				




				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (storyDifficulty == 3)
					difficulty = '-funky';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:Sprite = new Sprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphics(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				#if desktop
				if(FileSystem.exists(Paths.json(PlayState.storyPlaylist[0].toLowerCase() + "/" + PlayState.storyPlaylist[0].toLowerCase() + (storyDifficulty != 3 ? "-events" : "-funky-events"))))
					PlayState.EVENTS = EventSystemChart.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + (storyDifficulty != 3 ? "-events" : "-funky-events"), PlayState.storyPlaylist[0].toLowerCase());
				else
				{
					PlayState.EVENTS = 
					{
						notes: []
					};
				}
				#else
				if(Assets.exists(Paths.json(PlayState.storyPlaylist[0].toLowerCase() + "/" + PlayState.storyPlaylist[0].toLowerCase() + (storyDifficulty != 3 ? "-events" : "-funky-events"))))
					PlayState.EVENTS = EventSystemChart.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + (storyDifficulty != 3 ? "-events" : "-funky-events"), PlayState.storyPlaylist[0].toLowerCase());
				else
				{
					PlayState.EVENTS = 
					{
						notes: []
					};
				}
				#end
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				}

				
			}
		
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.sound.music.stop();
			LoadingState.loadAndSwitchState(new FreeplayState(), true);
		}
	}

	var endingSong:Bool = false;
	private function createNoteSplash(note:Note):Void
	{
		var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		a.setupNoteSplash(note.x, note.y, note.noteData);
		grpNoteSplashes.add(a);
	}
	function generateJudgementSprite()
	{
		judgementBar.makeGraphics(166, 5);
		judgementBar.pixels.fillRect(new Rectangle(0, 0, 166, 5), FlxColor.fromRGB(204, 167, 65)); // shit

		judgementBar.pixels.fillRect(new Rectangle((166 - Conductor.safeZoneOffset * 0.7) / 2, 0, Conductor.safeZoneOffset * 0.7, 5), FlxColor.fromRGB(83, 216, 18)); // bad
		
		judgementBar.pixels.fillRect(new Rectangle((166 - Conductor.safeZoneOffset * 0.5) / 2, 0, Conductor.safeZoneOffset * 0.5, 5), FlxColor.fromRGB(48, 180, 221)); // good

		judgementBar.pixels.fillRect(new Rectangle((166 - Conductor.safeZoneOffset * 0.23) / 2, 0, Conductor.safeZoneOffset * 0.23, 5), FlxColor.fromRGB(79, 145, 226)); // sick
	}
	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		var noteDiffNoABS:Float = strumtime - Conductor.songPosition;
		hits.push(Conductor.safeZoneOffset - noteDiff);
		calculateAccuracy();
		// boyfriend.playAnim('hey');
		vocals1.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:Sprite = new Sprite();
		var score:Float = 350;

		var daRating:String = "sick";
		var healthAdd:Float = 0.025;

		
		
		

		if(noteDiff <= Conductor.safeZoneOffset * 0.23)
		{
			daRating = 'sick';
			createNoteSplash(note);
			score = 350;
			healthAdd = 0.025;
		}
		else if (noteDiff <= Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'good';

			score = 200;
			healthAdd = 0.01;
		}
		else if (noteDiff <= Conductor.safeZoneOffset * 0.7)
		{
			daRating = 'bad';

			score = 100;
			healthAdd = -0.0225;
		}
		else
		{
			daRating = 'shit';

			score = 50;
			healthAdd = -0.03;
		}

		var modifiers:Float = 1;
		if(randomNotes)
			modifiers += 1.15;
		if(instaFail)
			modifiers += 1.25;
		if(noFail || FlxG.save.data.botAutoPlay)
			modifiers = 0;
		songScore += Std.int(score * modifiers);
		health += healthAdd;
		if(FlxG.save.data.judgementBar)
		{
			var line:Sprite = new Sprite(0, 0).makeGraphics(2, 17);
			line.alpha = 0.8;
			line.x = judgementBar.x + judgementBar.width / 2 - 1;
			line.y = judgementBar.y - line.height / 2;
			line.x += noteDiffNoABS / 2;
			line.cameras = [camHUD];
			add(line);
			FlxTween.tween(line, {alpha: 0.1, color: FlxColor.fromRGB(51, 213, 234)}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					FlxTween.tween(line, {alpha: 0}, Conductor.crochet * 4 * 16 / 1000, {
						onComplete: function(tween:FlxTween)
						{
							line.destroy();
						},
						startDelay: Conductor.crochet * 0.002,
						ease: FlxEase.quadInOut
					});
				},
				startDelay: Conductor.crochet * 0.002,
				ease: FlxEase.quadInOut
			});
		}
		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphics(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:Sprite = new Sprite().loadGraphics(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x + 50;
		comboSpr.y += 50;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(comboSpr);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.55));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:Sprite = new Sprite().loadGraphics(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	

	private function keyShit():Void
	{
		var control = PlayerSettings.player1.controls;

		// control arrays, order L D U R
		var holdArray:Array<Bool> = [control.LEFT, control.DOWN, control.UP, control.RIGHT];
		var pressArray:Array<Bool> = [
			control.LEFT_P,
			control.DOWN_P,
			control.UP_P,
			control.RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			control.LEFT_R,
			control.DOWN_R,
			control.UP_R,
			control.RIGHT_R
		];

		if (FlxG.save.data.botAutoPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}
	 
		// FlxG.watch.addQuick('asdfa', upP);
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{

			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
					

				}
			});

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
					{
						goodNoteHit(coolNote);
						clicks.push(time);
					}

				}
			}
			else if(!FlxG.save.data.skillIssue)
			{
				badNoteCheck();
				clicks.push(time);
			}
		}

		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.alpha != 0.1)
					{
						
						goodNoteHit(daNote);
					}
					
				});
		}

		/*if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10 && boyfriend.animation.curAnim.name != "spinMic" || (boyfriend.animation.curAnim.name == "spinMic" && boyfriend.animation.curAnim.finished))
						boyfriend.dance();
				}*/

		notes.forEachAlive(function(daNote:Note)
		{
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (FlxG.save.data.botAutoPlay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botAutoPlay && daNote.tooLate && daNote.mustPress)
				{
					
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
					playerStrums.forEach(function(spr:Sprite)
							{
								if(spr.ID == Math.abs(daNote.noteData))
								{
									spr.animation.play('confirm', true);
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										
										spr.animation.play('static', true);
										if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
										
									});
								
									if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
									{
										spr.animation.play('static', true);
									}
								}
								else if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
								{
									spr.animation.play('static', true);
								}
								

								if(boyfriend.animation.curAnim.name == 'idle')
								{
									spr.animation.play('static', true);
								}

								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
								
							});
					
				}
			}
		});

		/*if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10 && boyfriend.animation.curAnim.name != "spinMic" || (boyfriend.animation.curAnim.name == "spinMic" && boyfriend.animation.curAnim.finished))
				boyfriend.dance();
		}*/

		if(!FlxG.save.data.botAutoPlay)
		{
			playerStrums.forEach(function(spr:Sprite)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
			});
		}
		
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (noFail == false)
		{
			vocals1.volume = 0;
			hits.push(-Conductor.safeZoneOffset);
			calculateAccuracy();
			hitAccuracy.push(totalAccuracy);
			var rating:Sprite = new Sprite();
			var coolText:FlxText = new FlxText(0, 0, 0, " ", 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			misses++;
			health -= 0.045;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 15;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.15, 0.25));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
			rating.loadGraphics(Paths.image(pixelShitPart1 + "miss" + pixelShitPart2));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			}
			add(rating);
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
			});

			
			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}
	function calculateAccuracy()
	{
		totalAccuracy = 0;
		for(item in hits)
		{
			totalAccuracy += item;
		}
		totalAccuracy /= Conductor.safeZoneOffset;
		if (hits.length != 0) totalAccuracy /= hits.length;
		totalAccuracy = FlxMath.roundDecimal(totalAccuracy * 100, 2);
		if(totalAccuracy < 0)
			totalAccuracy = 0;
	}
	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		
		
		
		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		
	}

	function goodNoteHit(note:Note):Void
	{
		
		
		
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				hitAccuracy.push(totalAccuracy);
				combo += 1;
				if(FlxG.save.data.hitSounds)
					FlxG.sound.play(Paths.sound("hit2"), FlxG.random.float(0.15, 0.3));
			}
			else
			{
				health += 0.01;
				if(FlxG.save.data.hitSounds)
					FlxG.sound.play(Paths.sound("hit1"), FlxG.random.float(0.01, 0.015));
			}
			

			var altAnim:String = "";

			if (SONG.notes[Math.floor(curSection)] != null)
			{
				if (SONG.notes[Math.floor(curSection)].altAnim)
					altAnim = '-alt';
			}
			if(note.altNote) altAnim = '-alt';

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT' + altAnim, true);
				case 1:
					boyfriend.playAnim('singDOWN' + altAnim, true);
				case 2:
					boyfriend.playAnim('singUP' + altAnim, true);
				case 3:
					boyfriend.playAnim('singRIGHT' + altAnim, true);
			}

			playerStrums.forEach(function(spr:Sprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals1.volume = 1;
			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = 425;
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			FlxG.camera.shake(FlxG.random.float(0.05, 0.025) / 16, 1 / 24);
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		FlxG.camera.flash(FlxColor.WHITE, 0.5);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	function boyfriendSpinMic():Void
	{
		if(boyfriend.animation.getByName("spinMic") != null)
		{
			spinMicBeat = curBeat;
			spinMicOffset = FlxG.random.int(4, 15);
			boyfriend.playAnim('spinMic', true);
		}
	}
	function dadSpinMic():Void
	{
		if(dad.animation.getByName("spinMic") != null)
		{
			spinMicBeat2 = curBeat;
			spinMicOffset2 = FlxG.random.int(4, 15);
			dad.playAnim('spinMic', true);
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		//for events
		switch (SONG.song.toLowerCase()) 
		{

			case 'blammed':
				if(curStep >= 512 && curStep < 768)
				{
					chromOn = true;
					if(curStep >= 618 && curStep < 640)
					{
						cameraBeatSpeed = 1;
						cameraBeatZoom = 0.025 * 6;
					}
					else if(curStep >= 752 && curStep < 768)
					{
						cameraBeatSpeed = 1;
						cameraBeatZoom = 0.025 * 6;
					}
					else
					{
						cameraBeatSpeed = 2;
						cameraBeatZoom = 0.025 * 3;
					}
				}
				else
				{
					chromOn = false;
					cameraBeatSpeed = 4;
					cameraBeatZoom = 0.025 * 1;
				}
			case "bopeebo":
				switch (curStep)
				{
					case 256:
						defaultCamZoom -= 0.17;
						FlxTween.tween(backDudes, {y: backDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(centralDudes, {y: centralDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(frontDudes, {y: frontDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
					case 320:
						defaultCamZoom += 0.17;
						FlxTween.tween(backDudes, {y: backDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(centralDudes, {y: centralDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(frontDudes, {y: frontDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
				}
			case "fresh":
				switch (curStep)
				{
					case 320 | 576:
						defaultCamZoom -= 0.17;
						FlxTween.tween(backDudes, {y: backDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(centralDudes, {y: centralDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(frontDudes, {y: frontDudes.y - 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
					case 448 | 636:
						defaultCamZoom += 0.17;
						FlxTween.tween(backDudes, {y: backDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(centralDudes, {y: centralDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
						FlxTween.tween(frontDudes, {y: frontDudes.y + 500}, Conductor.crochet / 1000, {ease: FlxEase.quadInOut});
				}
			case 'roses':

				// im actually using beats here so im multiplying it by 4 lol
				if(curStep >= 112 * 4 && curStep < 128 * 4)
				{
					chromOn = true;
				}
				else if(curStep >= 160 * 4 && curStep < 176 * 4)
				{
					chromOn = true;
				}
				else
				{
					chromOn = false;
				}

			case 'milf':
				if(curStep >= 168 * 4 && curStep < 200 * 4)
					chromOn = true;
				else
					chromOn = false;
			/* 

			// example
			case 'milf':
				switch (curStep)
				{
					case 512:
						// your event code
					case 1024:
						// your event code
				}
			*/

			default:
				// nothing lmao

		}

		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC,true,  songLength - Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	//some effects
	public function spinHudCamera()
	{
		camHUD.angle = camHUD.angle + (!spinCamHudLeft ? spinCamHudSpeed : spinCamHudSpeed / -1) / 1;
	}
	public function spinGameCamera()
	{
		camGame.angle = camGame.angle + (!spinCamGameLeft ? spinCamGameSpeed : spinCamGameSpeed / -1) / 1;
	}
	public function spinPlayerStrumLineNotes()
	{
		playerStrums.forEach(function(spr:Sprite)
			{
				spr.angle = spr.angle + (!spinPlayerNotesLeft ? spinPlayerNotesSpeed : spinPlayerNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}
	public function spinEnemyStrumLineNotes()
	{
		dadStrums.forEach(function(spr:Sprite)
			{
				spr.angle = spr.angle + (!spinEnemyNotesLeft ? spinEnemyNotesSpeed : spinEnemyNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}
	public function changeDadCharacter(char:String = "dad", xOffset:Int = 0, yOffset:Int = 0)
	{
		var oldDadX:Float = dad.x;
		var oldDadY:Float = dad.y;
		oldDadY = dad.y;
		oldDadX = dad.x;
		remove(dad);
		dad.destroy();
		dad = new Character(oldDadX + xOffset, oldDadY + yOffset,char);
		add(dad);
		iconP2.changeIcon(char);

		dadStrums.forEach(function(spr:Sprite)
		{
			spr.visible = false;
		});
		
		generateStaticArrowsDAD(false);

		changeHealthBarColor();
	}

	public function changeAllCharacters(charDad:String = "dad", charGf:String = "gf", charBf:String = "bf")
	{
		changeGFCharacter(charGf);
		changeDadCharacter(charDad);
		changeBFCharacter(charBf);
	}

	public function changeGFCharacter(char:String = "gf", xOffset:Int = 0, yOffset:Int = 0)
	{
		var oldGFX:Float = gf.x;
		var oldGFY:Float = gf.y;
		oldGFY = gf.y;
		oldGFX = gf.x;
		remove(gf);
		gf.destroy();
		gf = new Character(oldGFX + xOffset, oldGFY + yOffset,char);
		add(gf);
	}

	public function changeBFCharacter(char:String = "bf", xOffset:Int = 0, yOffset:Int = 0)
	{
		var oldBfX:Float = boyfriend.x;
		var oldBfY:Float = boyfriend.y;
		oldBfY = boyfriend.y;
		oldBfX = boyfriend.x;
		remove(boyfriend);
		boyfriend.destroy();
		boyfriend = new Boyfriend(oldBfX + xOffset, oldBfY + yOffset,char);
		add(boyfriend);
		iconP1.changeIcon(char);
		changeHealthBarColor();
	}

	var cameraBeatSpeed:Int = 4;
	var cameraBeatZoom:Float = 0.025;

	override function beatHit()
	{
		super.beatHit();

		if(FlxG.save.data.shadersOn)
		{
			if (curBeat >= 0 && !shadersLoaded)
			{
				shadersLoaded = true;

				filters.push(Shaders.chromaticAberration);
				camfilters.push(Shaders.chromaticAberration);

				filters.push(Shaders.grayScale);
				camfilters.push(Shaders.grayScale);

				filters.push(Shaders.invert);
				camfilters.push(Shaders.invert);

				filters.push(Shaders.pixelate);
				filters.push(Shaders.vignette);

			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		switch(SONG.song.toLowerCase())
		{
			case "roses":
				switch(curBeat)
				{
					case 96:
						changeDadCharacter("senpai-pissed");
					case 128:
						changeDadCharacter("senpai-angry");
					case 144:
						changeDadCharacter("senpai-pissed");
					
				}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += cameraBeatZoom;
			camHUD.zoom += cameraBeatZoom * 2;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % cameraBeatSpeed == 0)
		{
			FlxG.camera.zoom += cameraBeatZoom;
			camHUD.zoom += cameraBeatZoom * 2;
		}

		if(curBeat % cameraBeatSpeed == 0)
		{
			iconP1.angle -= 40;
			iconP2.angle += 40;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
                iconP2.setGraphicSize(Std.int(iconP2.width + 30));
                iconP1.updateHitbox();
                iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
			if(dad.curCharacter == "spooky")
				dad.dance();
		}

		if (boyfriend.curCharacter != "spooky" && !boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % 2 == 0 && boyfriend.animation.curAnim.name != "spinMic" || (boyfriend.animation.curAnim.name == "spinMic" && boyfriend.animation.curAnim.finished))
			boyfriend.dance();
		if(dad.curCharacter != "spooky" && !dad.animation.curAnim.name.startsWith("sing") && curBeat % 2 == 0 && dad.animation.curAnim.name != "spinMic" || (dad.animation.curAnim.name == "spinMic" && dad.animation.curAnim.finished))
			dad.dance();

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case "stage":
				backDudes.animation.play("idle", true);
				centralDudes.animation.play("idle", true);
				frontDudes.animation.play("idle", true);
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
				limo.animation.play('drive', true);
				limoSpeaker.animation.play('boom', true);
				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:Sprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;

					phillyCityLights.members[curLight].alpha = 1;
					FlxTween.cancelTweensOf(phillyCityLights.members[curLight]);
					phillyCityLights.members[curLight].alpha = 1;
					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.crochet / 1000 * 4 - 0.01, {ease: FlxEase.linear, startDelay: 0.001});
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		if((FlxG.random.bool(7) && !boyfriend.animation.curAnim.name.startsWith('sing') && curBeat > spinMicBeat + spinMicOffset) && boyfriend.animation.getByName("spinMic") != null)
		{
			boyfriendSpinMic();
		}
		if((FlxG.random.bool(5.5) && !dad.animation.curAnim.name.startsWith('sing') && curBeat > spinMicBeat2 + spinMicOffset2) && dad.animation.getByName("spinMic") != null)
		{
			dadSpinMic();
		}
	}
	public function changeHealthBarColor()
	{
		healthBar.createFilledBar(dad.healthBarColor, boyfriend.healthBarColor);
		healthBar.percent = healthBar.percent; // XD. dont ask, its just for updating color lol
	}
	var curLight:Int = 0;
}