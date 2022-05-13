package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import Section.SwagSection;
import Song.SwagSong;
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
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var shadersLoaded:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	public var kps:Int = 0;
	public var kpsMax:Int = 0;
	private var time:Float = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	var timeTxt:FlxText;

	private var chromOn:Bool = false;
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
	var maxCombo:Int = 0;
	var totalRank:String = "S+";
	var songNotesHit:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var hitAccuracy:Array<Float> = [0];

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var botAutoPlayAlert:FlxText;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var deathCounter:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;


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

	public var clicks:Array<Float> = [];

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



		
		Bind.keyCheck();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(100, 100, 0);
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

		CoolUtil.preloadImages(this);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

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

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
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

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
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

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
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

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
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
		                  var bg:BGSprite = new BGSprite("stageback", -600, -200, 0.9, 0.9);
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
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
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

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
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		var bgForNotes1:FlxSprite = new FlxSprite(40 + 50, 0).makeGraphic(470, FlxG.height);
		bgForNotes1.scrollFactor.set();
		bgForNotes1.screenCenter(Y);
		var bgForNotes2:FlxSprite = new FlxSprite(680 + 50, 0).makeGraphic(470, FlxG.height);
		bgForNotes2.scrollFactor.set();
		bgForNotes2.screenCenter(Y);
		bgForNotes2.color = FlxColor.BLACK;
		bgForNotes1.color = FlxColor.BLACK;
		bgForNotes1.alpha = 0.4;
		bgForNotes2.alpha = 0.4;

		var bgForNotes12:FlxSprite = new FlxSprite(30 + 50, 0).makeGraphic(490, FlxG.height);
		bgForNotes12.scrollFactor.set();
		bgForNotes12.screenCenter(Y);
		var bgForNotes22:FlxSprite = new FlxSprite(670 + 50, 0).makeGraphic(490, FlxG.height);
		bgForNotes22.scrollFactor.set();
		bgForNotes22.screenCenter(Y);
		bgForNotes22.color = FlxColor.BLACK;
		bgForNotes12.color = FlxColor.BLACK;
		bgForNotes12.alpha = 0.4;
		bgForNotes22.alpha = 0.4;

		if(FlxG.save.data.middlescroll)
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


		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
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

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		
		if(FlxG.save.data.bgNotes)
		{
			add(bgForNotes1);
			add(bgForNotes2);
			add(bgForNotes12);
			add(bgForNotes22);
		}
		add(timeTxt);
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

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

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = FlxG.height * 0.1;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);



		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var p1ColorBar:FlxColor = new FlxColor();
		var p2ColorBar:FlxColor = new FlxColor();

		switch (SONG.player1) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p1ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p1ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p1ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p1ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p1ColorBar.setRGB(188, 95, 183, 255);
			}
			case 'dad':
			{
				p1ColorBar.setRGB(175, 102, 206, 255);
			}
			case 'mom' | 'mom-car':
			{
				p1ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p1ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p1ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p1ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p1ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p1ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p1ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p1ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p1ColorBar.setRGB(255, 0, 0, 255);
			}
		}

		switch (SONG.player2) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p2ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p2ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p2ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p2ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p2ColorBar.setRGB(188, 95, 183, 255);
			}
			case 'dad':
			{
				p2ColorBar.setRGB(175, 102, 206, 255);
			}
			case 'mom' | 'mom-car':
			{
				p2ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p2ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p2ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p2ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p2ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p2ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p2ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p2ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p2ColorBar.setRGB(255, 0, 0, 255);
			}
		}
		
		healthBar.createFilledBar(p2ColorBar, p1ColorBar);
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + 50, healthBarBG.y + 45, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);


		if(FlxG.save.data.botAutoPlay)
		{
			botAutoPlayAlert = new FlxText(0, 500, 0, "BOT AUTO PLAY", 40);
			botAutoPlayAlert.screenCenter(X);
			botAutoPlayAlert.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botAutoPlayAlert.scrollFactor.set();
			add(botAutoPlayAlert);
		}
		

		

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

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
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
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
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
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
			dad.dance();
			gf.dance();
			boyfriend.dance();

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
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
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
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
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
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
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
			// generateSong('fresh');
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
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
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
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
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
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
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
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		FlxTween.tween(timeTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		

	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
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

				var swagNote:Note = new Note(daStrumTime, (!randomNotes ? daNoteData : daRandomNoteData), oldNote, false, (!gottaHitNote ? dad.noteSkin : ""));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.altNote = songNotes[3];

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, (!randomNotes ? daNoteData : daRandomNoteData), oldNote, true, (!gottaHitNote ? dad.noteSkin : ""));
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
					if(gottaHitNote == false && FlxG.save.data.middlescroll)
						sustainNote.alpha = 0.2;
				}

				swagNote.mustPress = gottaHitNote;

				if(gottaHitNote == false && FlxG.save.data.middlescroll)
					swagNote.alpha = 0.35;

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

	private function generateStaticArrowsBF():Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
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

	private function generateStaticArrowsDAD():Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
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

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if(!FlxG.save.data.middlescroll)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
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
				vocals.pause();
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
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		time += elapsed;
		CalculateKeysPerSecond();
		if(kps >= kpsMax)
			kpsMax = kps;

		if (FlxG.keys.justPressed.NINE)
		{
			/*if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');*/
			iconP1.swapOldIcon();
		}

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



		if(misses == 0 && songNotesHit == 0)
			totalAccuracy = 0;
		else if(songNotesHit == 0)
			totalAccuracy = 0;
		else
			totalAccuracy = FlxMath.roundDecimal((songNotesHit / (songNotesHit + misses) * 100), 2);

		
		if(songNotesHit == misses)
			totalAccuracy = 0;
		
		scoreTxt.text = "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank;
		

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
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
			

		
		

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

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

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (/*camFollow.x != dad.getMidpoint().x + 150 && */!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camFollowX:Float = dad.getMidpoint().x;
				var camFollowY:Float = dad.getMidpoint().y;

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollowY = dad.getMidpoint().y;
					case 'senpai':
						camFollowY = dad.getMidpoint().y - 400;
						camFollowX = dad.getMidpoint().x - 250;
					case 'senpai-angry':
						camFollowY = dad.getMidpoint().y - 400;
						camFollowX = dad.getMidpoint().x - 250;
					case 'pico':
						camFollowY = dad.getMidpoint().y;
					default:
						camFollowX = dad.getMidpoint().x;
						camFollowY = dad.getMidpoint().y;
						if(dad.animation.curAnim.name.startsWith("singLEFT")){
							camFollowX = camFollowX - 20;
						}
						if(dad.animation.curAnim.name.startsWith("singRIGHT")){
							camFollowX = camFollowX + 20;
						}
						if(dad.animation.curAnim.name.startsWith("singUP")){
							camFollowY = camFollowY - 20;
						}
						if(dad.animation.curAnim.name.startsWith("singDOWN")){
							camFollowY = camFollowY + 20;
						}
				}

				
				camFollow.setPosition(camFollowX + 150, camFollowY - 100);

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection/* && camFollow.x != boyfriend.getMidpoint().x - 100*/)
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
						if(boyfriend.animation.curAnim.name.startsWith("singLEFT")){
							camFollowX = camFollowX - 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singRIGHT")){
							camFollowX = camFollowX + 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singUP")){
							camFollowY = camFollowY - 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singDOWN")){
							camFollowY = camFollowY + 20;
						}
				}

				

				camFollow.setPosition(camFollowX - 100, camFollowY - 100);

				
				

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
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
					vocals.volume = 0;
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

			vocals.stop();
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

		if (generatedMusic)
		{
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
				var c = strumLine.y + Note.swagWidth / 2;
				if(FlxG.save.data.downscroll)
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
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
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
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

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

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

					dadStrums.forEach(function(spr:FlxSprite)
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
						vocals.volume = 1;

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
				if(missNote)
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
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			var averageAccuracy:Float = 0;

			for (i in 0 ... hitAccuracy.length) 
			{
				averageAccuracy += hitAccuracy[i];
			}
			averageAccuracy -= hitAccuracy.length;
			averageAccuracy = FlxMath.roundDecimal(averageAccuracy / hitAccuracy.length + 1, 2);
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, averageAccuracy, maxCombo);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);



			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

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

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				}

				
			}
		
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		var daRating:String = "sick";
		var splashIsOn:Bool = true;
		var healthAdd:Float = 0.025;

		if (noteDiff > Conductor.safeZoneOffset * 0.7)
		{
			daRating = 'shit';
			
			totalAccuracy += 0.2;
			score = 50;
			splashIsOn = false;
			healthAdd = 0.01;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';

			totalAccuracy += 0.5;
			score = 100;
			splashIsOn = false;
			healthAdd = 0.02;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.185)
		{
			daRating = 'good';
			
			totalAccuracy += 1;
			score = 200;
			splashIsOn = false;
			healthAdd = 0.025;
		}
		else
		{
			daRating = 'sick';

			totalAccuracy += 1.2;
			score = 350;
			splashIsOn = true;
			healthAdd = 0.035;
		}

		if (totalAccuracy > (misses + songNotesHit)) {
			totalAccuracy = (misses + songNotesHit);
		}

		if(splashIsOn == true)
		{
			var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			a.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(a);
		}

		var modifiers:Float = 1;
		if(randomNotes)
			modifiers += 1.15;
		if(instaFail)
			modifiers += 1.1;
		if(noFail)
			modifiers = 0;
		songScore += Std.int(score * modifiers);
		health += healthAdd;

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

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
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
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
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

			if (combo >= 10 || combo == 0)
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
			else
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

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.dance();
				}

		notes.forEachAlive(function(daNote:Note)
		{
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (FlxG.save.data.botAutoPlay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botAutoPlay && daNote.tooLate && daNote.mustPress)
				{
					
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
					playerStrums.forEach(function(spr:FlxSprite)
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

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.dance();
		}

		if(!FlxG.save.data.botAutoPlay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
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
			var rating:FlxSprite = new FlxSprite();
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

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			rating.loadGraphic(Paths.image("miss"));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.setGraphicSize(Std.int(rating.width * 0.8));
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

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		
		songNotesHit += 1;
		
		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		hitAccuracy.push(totalAccuracy);
	}

	function goodNoteHit(note:Note):Void
	{
		songNotesHit += 1;
		hitAccuracy.push(totalAccuracy);
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
				if(FlxG.save.data.hitSounds)
					FlxG.sound.play(Paths.sound("hit2"), FlxG.random.float(0.24, 0.48));
			}
			else
			{
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

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

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
		fastCar.y = FlxG.random.int(140, 250);
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
		spinMicBeat = curBeat;
		spinMicOffset = FlxG.random.int(4, 15);
		boyfriend.playAnim('spinMic', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}

		//for events like shaders
		switch (SONG.song.toLowerCase()) 
		{

			/* 

			// example of using chromatic aberration shaders
			case 'milf':
				switch (curStep)
				{
					case 512:
						chromOn = true;
					case 1024:
						chromOn = false;
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
		playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.angle = spr.angle + (!spinPlayerNotesLeft ? spinPlayerNotesSpeed : spinPlayerNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}
	public function spinEnemyStrumLineNotes()
	{
		dadStrums.forEach(function(spr:FlxSprite)
			{
				spr.angle = spr.angle + (!spinEnemyNotesLeft ? spinEnemyNotesSpeed : spinEnemyNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}

	public function changeDadCharacter(char:String = "dad")
	{
		var oldDadX:Float = dad.x;
		var oldDadY:Float = dad.y;
		oldDadY = dad.y;
		oldDadX = dad.x;
		remove(dad);
        	dad.destroy();
        	dad = new Character(oldDadX,oldDadY,char);
        	add(dad);
	}

	public function changeAllCharacters(charDad:String = "dad", charGf:String = "gf", charBf:String = "bf")
	{
		changeGFCharacter(charGf);
		changeDadCharacter(charDad);
		changeBFCharacter(charBf);
	}

	public function changeGFCharacter(char:String = "gf")
	{
		var oldGFX:Float = gf.x;
		var oldGFY:Float = gf.y;
		oldGFY = gf.y;
		oldGFX = gf.x;
		remove(gf);
        	gf.destroy();
        	gf = new Character(oldGFX,oldGFY,char);
        	add(gf);
	}

	public function changeBFCharacter(char:String = "bf")
	{
		var oldBfX:Float = boyfriend.x;
		var oldBfY:Float = boyfriend.y;
		oldBfY = boyfriend.y;
		oldBfX = boyfriend.x;
		remove(boyfriend);
        	boyfriend.destroy();
        	boyfriend = new Boyfriend(oldBfX,oldBfY,char);
        	add(boyfriend);
	}

	var cameraBeatSpeed:Int = 4;
	var cameraBeatZoom:Float = 0.015;

	override function beatHit()
	{
		super.beatHit();

		if(FlxG.save.data.shadersOn)
		{
			if (curBeat > 0 && !shadersLoaded)
			{
				shadersLoaded = true;

				filters.push(Shaders.chromaticAberration);
			
				camfilters.push(Shaders.chromaticAberration);

				filters.push(Shaders.vignette);

			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].changeDadCharacter)
			{
				changeDadCharacter(SONG.notes[Math.floor(curStep / 16)].changeDadCharacterChar);
				FlxG.log.add('CHANGED DAD!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].changeBFCharacter)
			{
				changeBFCharacter(SONG.notes[Math.floor(curStep / 16)].changeBFCharacterChar);
				FlxG.log.add('CHANGED BF!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].chromaticAberrationsShader)
			{
				chromOn = true;
				FlxG.log.add('Chromatic Aberrations enabled');
			}
			else
			{
				chromOn = false;
				FlxG.log.add('Chromatic Aberrations disabled');
			}
			if (SONG.notes[Math.floor(curStep / 16)].vignetteShader)
			{
				vignetteOn = true;
				FlxG.log.add('vignette enabled');
				vignetteRadius = SONG.notes[Math.floor(curStep / 16)].vignetteShaderRadius;
			}
			else
			{
				vignetteOn = false;
				FlxG.log.add('vignette disabled');
			}
			if(SONG.notes[Math.floor(curStep / 16)].changeCameraBeat)
			{
				cameraBeatZoom = 0.015 * SONG.notes[Math.floor(curStep / 16)].cameraBeatZoom;
				cameraBeatSpeed = SONG.notes[Math.floor(curStep / 16)].cameraBeatSpeed;
			}
			else
			{
				cameraBeatZoom = 0.015;
				cameraBeatSpeed = 4;
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
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
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % 2 == 0)
		{
			boyfriend.dance();

		}


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
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

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;

					phillyCityLights.members[curLight].alpha = 1;
					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.crochet / 1000 * 4, {ease: FlxEase.linear});
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
	}

	var curLight:Int = 0;
}
