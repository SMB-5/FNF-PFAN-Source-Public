package states;

import backend.WeekData;
import backend.ScreenshotPlugin;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.MainMenuState;
import states.editors.ResultsTestState;

import objects.VideoSprite;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;
	
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ftSpr:FlxSprite;
	var atlusSpr:FlxSprite;
	var logoSpr:FlxSprite;
	var ngSpr:FlxSprite;

	var atlusTxt:FlxText;
	var intro1Txt:FlxText;
	var intro2Txt:FlxText;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();
		}

		FlxG.fixedTimestep = false;

		ResultsTestState.debug = false;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if(!initialized)
		{
			//* FIRST INIT! iNITIALISE IMPORTED PLUGINS
			ScreenshotPlugin.initialize();

			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !InitialState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new InitialState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var logoPFAN:FlxSprite;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		loadJsonData();
		Conductor.bpm = musicBPM;

		var bg:FlxSprite = new FlxSprite(-150, -110).loadGraphic(Paths.image('title-bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		add(bg);

		logoPFAN = new FlxSprite(0, 0).loadGraphic(Paths.image('pfan-logo'));
		logoPFAN.updateHitbox();
		logoPFAN.screenCenter(X);
		logoPFAN.setGraphicSize(Std.int(logoPFAN.width * 0.75));
		logoPFAN.antialiasing = ClientPrefs.data.antialiasing;
		add(logoPFAN);

		var animFrames:Array<FlxFrame> = [];
		titleText = new FlxSprite(enterPosition.x, enterPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (newTitle = animFrames.length > 0)
		{
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ftSpr = new FlxSprite(0, 250).loadGraphic(Paths.image('funkinthieves-logo'));
		add(ftSpr);
		ftSpr.alpha = 0;
		ftSpr.setGraphicSize(Std.int(ftSpr.width * 0.5));
		ftSpr.updateHitbox();
		ftSpr.screenCenter(X);
		ftSpr.antialiasing = ClientPrefs.data.antialiasing;

		atlusSpr = new FlxSprite(280, FlxG.height * 0.4).loadGraphic(Paths.image('Atlus_Logo'));
		add(atlusSpr);
		atlusSpr.alpha = 0;
		atlusSpr.setGraphicSize(Std.int(atlusSpr.width * 2.5));
		atlusSpr.updateHitbox();
		atlusSpr.antialiasing = ClientPrefs.data.antialiasing;

		atlusTxt = new FlxText(0, 250, FlxG.width, 'A Love Letter to', 60);
		atlusTxt.setFormat(Paths.font("Fontsona5Royal.ttf"), 60, CENTER, FlxColor.WHITE);
		add(atlusTxt);
		atlusTxt.alpha = 0;
		atlusTxt.screenCenter(X);

		var leDate = Date.now();
		var leMonth = leDate.getMonth();
		var leDay = leDate.getDate();

		switch [leMonth, leDay]
		{
			case [3, 30]: intro1Txt = new FlxText(0, 250, FlxG.width, "Happy Birthday", 60);
			case [6, 6] | [8, 20] | [9, 5]: intro1Txt = new FlxText(0, 250, FlxG.width, "Happy Anniversary", 60);
			case [9, 31] | [0, 1]: intro1Txt = new FlxText(0, 250, FlxG.width, "Happy", 60);
			case [11, 25]: intro1Txt = new FlxText(0, 250, FlxG.width, "Merry", 60);
			default: intro1Txt = new FlxText(0, 250, FlxG.width, curWacky[0], 60);
		}

		intro1Txt.setFormat(Paths.font("Fontsona5Royal.ttf"), 60, FlxTextAlign.CENTER, FlxColor.WHITE);
		add(intro1Txt);
		intro1Txt.alpha = 0;
		intro1Txt.screenCenter(X);

		switch [leMonth, leDay]
		{
			case [3, 30]: intro2Txt = new FlxText(0, 350, FlxG.width, "Tom Fulp", 60);
			case [6, 6]: intro2Txt = new FlxText(0, 350, FlxG.width, "Newgrounds", 60);
			case [8, 20]: intro2Txt = new FlxText(0, 350, FlxG.width, "Persona", 60);
			case [9, 5]: intro2Txt = new FlxText(0, 350, FlxG.width, "Friday Night Funkin", 60);
			case [9, 31]: intro2Txt = new FlxText(0, 350, FlxG.width, "Halloween", 60);
			case [11, 25]: intro2Txt = new FlxText(0, 350, FlxG.width, "Christmas", 60);
			case [0, 1]: intro2Txt = new FlxText(0, 350, FlxG.width, "New Year", 60);
			default: intro2Txt = new FlxText(0, 350, FlxG.width, curWacky[1], 60);
		}

		intro2Txt.setFormat(Paths.font("Fontsona5Royal.ttf"), 60, FlxTextAlign.CENTER, FlxColor.WHITE);
		add(intro2Txt);
		intro2Txt.alpha = 0;
		intro2Txt.screenCenter(X);

		logoSpr = new FlxSprite(383, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.75));
		logoSpr.updateHitbox();
		logoSpr.antialiasing = ClientPrefs.data.antialiasing;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	// JSON data
	var characterImage:String = 'gfDanceTitle';
	var animationName:String = 'gfDance';

	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);
	
	var useIdle:Bool = false;
	var musicBPM:Float = 102;
	var danceLeftFrames:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
	var danceRightFrames:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

	function loadJsonData()
	{
		if(Paths.fileExists('images/gfDanceTitle.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('images/gfDanceTitle.json');
			if(titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					var titleJSON:TitleData = tjson.TJSON.parse(titleRaw);
					gfPosition.set(titleJSON.gfx, titleJSON.gfy);
					logoPosition.set(titleJSON.titlex, titleJSON.titley);
					enterPosition.set(titleJSON.startx, titleJSON.starty);
					musicBPM = titleJSON.bpm;
					
					if(titleJSON.animation != null && titleJSON.animation.length > 0) animationName = titleJSON.animation;
					if(titleJSON.dance_left != null && titleJSON.dance_left.length > 0) danceLeftFrames = titleJSON.dance_left;
					if(titleJSON.dance_right != null && titleJSON.dance_right.length > 0) danceRightFrames = titleJSON.dance_right;
					useIdle = (titleJSON.idle == true);
	
					if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.trim().length > 0)
					{
						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(titleJSON.backgroundSprite));
						bg.antialiasing = ClientPrefs.data.antialiasing;
						add(bg);
					}
				}
				catch(e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else trace('[WARN] No Title JSON detected, using default values.');
		}
		//else trace('[WARN] No Title JSON detected, using default values.');
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

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
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.sound.music.stop();

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro && !watching)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState)
		{
			if (!skippedIntro)
			{
				sickBeats++;
				switch (sickBeats)
				{
					case 1:
						FlxTween.tween(ftSpr, {alpha: 1}, 1, {ease: FlxEase.circOut});
					case 4:
						FlxTween.tween(ftSpr, {alpha: 0}, 1, {ease: FlxEase.circOut});
					case 6:
						FlxTween.tween(atlusTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(atlusSpr, {alpha: 1}, 1, {ease: FlxEase.circOut});
					case 8:
						FlxTween.tween(atlusTxt, {alpha: 0}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(atlusSpr, {alpha: 0}, 1, {ease: FlxEase.circOut});
					case 10:
						FlxTween.tween(intro1Txt, {alpha: 1}, 1, {ease: FlxEase.circOut});
					case 12:
						FlxTween.tween(intro2Txt, {alpha: 1}, 1, {ease: FlxEase.circOut});
					case 14:
						FlxTween.tween(intro1Txt, {alpha: 0}, 1, {ease: FlxEase.circOut});
						FlxTween.tween(intro2Txt, {alpha: 0}, 1, {ease: FlxEase.circOut});
					case 16:
						watching = true;
						startVideo('Title');
						trace('starting video...');
				}
			}
		}
	}

	var watching:Bool = false;
	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(ftSpr);
			remove(atlusSpr);
			remove(atlusTxt);
			remove(intro1Txt);
			remove(intro2Txt);
			remove(logoSpr);
			remove(credGroup);
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			Conductor.bpm = musicBPM;
			skippedIntro = true;
		}
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		#if VIDEOS_ALLOWED

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
			foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			function onVideoEnd()
				{
					videoCutscene = null;
					startIntro();
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			add(videoCutscene);

			if (playOnLoad)
				videoCutscene.play();
			return videoCutscene;
		}
		startIntro();
		#end
		return null;
	}
}
