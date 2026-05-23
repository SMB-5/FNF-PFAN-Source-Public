package substates;

import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.FreeplayState;
import states.PlayState;
import backend.Highscore;
import backend.WeekData;
import backend.Song;
import backend.Rating;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import objects.Bar;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import backend.Metadata;

import substates.StickerSubState;

class ResultsSubstate extends MusicBeatSubstate
{
	public var camHUD:FlxCamera;

	var scoreTxt:FlxText;
	var missTxt:FlxText;
	var accTxt:FlxText;
	var sickTxt:FlxText;
	var goodTxt:FlxText;
	var badTxt:FlxText;
	var shitTxt:FlxText;
	var songTxt:FlxText;

	var portrait:FlxSprite;

	public var progressBar:FlxBar;
	public var barTween:FlxTween = null;
	var can_leave = false;

	public var mode:String = "p5";

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var lerpMisses:Int = 0;
	var intendedMisses:Int = 0;
	var lerpRating:Float = 0;
	var intendedRating:Float = 0;
	var lerpSick:Int = 0;
	var intendedSick:Int = 0;
	var lerpGood:Int = 0;
	var intendedGood:Int = 0;
	var lerpBad:Int = 0;
	var intendedBad:Int = 0;
	var lerpShit:Int = 0;
	var intendedShit:Int = 0;

	var showScore = false;
	var showMisses = false;
	var showAccuracy = false;
	var showSick = false;
	var showGood = false;
	var showBad = false;
	var showShit = false;
	var showRank = false;

	override function create()
	{
		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		switch(PlayState.SONG.song)
		{
			case 'Blue Moon' | 'Tartarus' | 'Destruction' | 'Answer':
				mode = "p3";
			case 'Truth' | 'Specialist':
				mode = "p4";
			default:
				mode = "p5";
		}

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('persona/results/resultsbg'));
		bg.updateHitbox();
		bg.scrollFactor.set();
		add(bg);
		bg.cameras = [camHUD];

		var line:FlxSprite = new FlxSprite(450, -50).loadGraphic(Paths.image('persona/results/resultsline'));
		line.updateHitbox();
		line.scrollFactor.set();
		add(line);
		line.cameras = [camHUD];

		portrait = new FlxSprite().loadGraphic(Paths.image(''));
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		add(portrait);
		portrait.x = 350;
		portrait.y = -300;
		portrait.scale.x = 0.4;
		portrait.scale.y = 0.4;
		portrait.cameras = [camHUD];

		var bg2:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('persona/results/resultsbg2'));
		bg2.updateHitbox();
		bg2.scrollFactor.set();
		add(bg2);
		bg2.cameras = [camHUD];

		var results:FlxSprite = new FlxSprite(20, 0).loadGraphic(Paths.image('persona/results/results'));
		results.updateHitbox();
		results.scrollFactor.set();
		add(results);
		results.cameras = [camHUD];

		songTxt = new FlxText(50, 120, FlxG.width, PlayState.SONG.song, 50);
		songTxt.setFormat(Paths.font("p5hatty-1.ttf"), 40, FlxColor.BLACK);
		songTxt.scrollFactor.set();
		songTxt.angle += 1;
		songTxt.updateHitbox();
		add(songTxt);
		songTxt.cameras = [camHUD];

		var sickbg:FlxSprite = new FlxSprite(20, 170).loadGraphic(Paths.image('persona/results/results-sick'));
		sickbg.updateHitbox();
		sickbg.scrollFactor.set();
		add(sickbg);
		sickbg.cameras = [camHUD];

		sickTxt = new FlxText(180, 120, FlxG.width, '' + lerpSick, 50);
		sickTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		sickTxt.scrollFactor.set();
		sickTxt.updateHitbox();
		sickTxt.angle = -9;
		add(sickTxt);
		sickTxt.cameras = [camHUD];

		var goodbg:FlxSprite = new FlxSprite(180, 230).loadGraphic(Paths.image('persona/results/results-good'));
		goodbg.updateHitbox();
		goodbg.scrollFactor.set();
		add(goodbg);
		goodbg.cameras = [camHUD];

		goodTxt = new FlxText(360, 185, FlxG.width, '' + lerpGood, 50);
		goodTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		goodTxt.scrollFactor.set();
		goodTxt.updateHitbox();
		goodTxt.angle = -9;
		add(goodTxt);
		goodTxt.cameras = [camHUD];

		var badbg:FlxSprite = new FlxSprite(20, 360).loadGraphic(Paths.image('persona/results/results-bad'));
		badbg.updateHitbox();
		badbg.scrollFactor.set();
		add(badbg);
		badbg.cameras = [camHUD];

		badTxt = new FlxText(180, 310, FlxG.width, '' + lerpBad, 50);
		badTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		badTxt.scrollFactor.set();
		badTxt.updateHitbox();
		badTxt.angle = -9;
		add(badTxt);
		badTxt.cameras = [camHUD];

		var shitbg:FlxSprite = new FlxSprite(190, 420).loadGraphic(Paths.image('persona/results/results-shit'));
		shitbg.updateHitbox();
		shitbg.scrollFactor.set();
		add(shitbg);
		shitbg.cameras = [camHUD];

		shitTxt = new FlxText(370, 380, FlxG.width, '' + lerpShit, 50);
		shitTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		shitTxt.scrollFactor.set();
		shitTxt.updateHitbox();
		shitTxt.angle = -9;
		add(shitTxt);
		shitTxt.cameras = [camHUD];

		var missbg:FlxSprite = new FlxSprite(0, 510).loadGraphic(Paths.image('persona/results/results-miss'));
		missbg.updateHitbox();
		missbg.scrollFactor.set();
		add(missbg);
		missbg.cameras = [camHUD];

		missTxt = new FlxText(100, 480, FlxG.width, '' + lerpMisses, 50);
		missTxt.setFormat(Paths.font("p5hatty-1.ttf"), 50, FlxColor.BLACK);
		missTxt.scrollFactor.set();
		missTxt.updateHitbox();
		missTxt.angle = -9;
		add(missTxt);
		missTxt.cameras = [camHUD];

		var scorebg:FlxSprite = new FlxSprite(0, 495).loadGraphic(Paths.image('persona/results/results-score'));
		scorebg.updateHitbox();
		scorebg.scrollFactor.set();
		add(scorebg);
		scorebg.cameras = [camHUD];

		scoreTxt = new FlxText(210, 575, FlxG.width, '' + lerpScore, 70);
		scoreTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.updateHitbox();
		scoreTxt.angle = -9;
		add(scoreTxt);
		scoreTxt.cameras = [camHUD];

		accTxt = new FlxText(330, 40, FlxG.width, 'Accuracy: ' + lerpRating + '%', 50);
		accTxt.setFormat(Paths.font("p5hatty-1.ttf"), 40, FlxColor.WHITE);
		accTxt.scrollFactor.set();
		accTxt.updateHitbox();
		add(accTxt);
		accTxt.cameras = [camHUD];

		var F:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/F'));
		F.updateHitbox();
		F.scrollFactor.set();
		F.cameras = [camHUD];

		var E:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/E'));
		E.updateHitbox();
		E.scrollFactor.set();
		E.cameras = [camHUD];

		var D:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/D'));
		D.updateHitbox();
		D.scrollFactor.set();
		D.cameras = [camHUD];

		var C:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/C'));
		C.updateHitbox();
		C.scrollFactor.set();
		C.cameras = [camHUD];

		var B:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/B'));
		B.updateHitbox();
		B.scrollFactor.set();
		B.cameras = [camHUD];

		var A:FlxSprite = new FlxSprite(590, 515).loadGraphic(Paths.image('persona/results/A'));
		A.updateHitbox();
		A.scrollFactor.set();
		A.cameras = [camHUD];

		var S:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/S'));
		S.updateHitbox();
		S.scrollFactor.set();
		S.cameras = [camHUD];

		var P:FlxSprite = new FlxSprite(600, 515).loadGraphic(Paths.image('persona/results/P'));
		P.updateHitbox();
		P.scrollFactor.set();
		P.cameras = [camHUD];

		//I FUCKING HATE STRAY PIXELS!!!
		progressBar = new FlxBar(287.8, 437, LEFT_TO_RIGHT, 413, 15);
		progressBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		progressBar.scrollFactor.set();
		//add(progressBar);

		var bar:FlxSprite = new FlxSprite(150, 430).loadGraphic(Paths.image('timeBar'));
		bar.scrollFactor.set();
		bar.antialiasing = ClientPrefs.data.antialiasing;
		bar.updateHitbox();
		bar.setGraphicSize(Std.int(bar.width * 0.7));
		//add(bar);

		var highscore:FlxSprite = new FlxSprite(850, 570).loadGraphic(Paths.image('persona/results/highscore'));
		highscore.scrollFactor.set();
		highscore.antialiasing = ClientPrefs.data.antialiasing;
		highscore.updateHitbox();
		highscore.setGraphicSize(Std.int(highscore.width * 1.0));
		add(highscore);
		highscore.visible = false;
		highscore.cameras = [camHUD];

		if (PlayState.SONG.player1 == 'yu-narukami-player')
		{
			portrait.loadGraphic(Paths.image('persona/portraits/yu-portrait'));
			portrait.y = -190;
		}
		else if (PlayState.SONG.player2 == 'makoto-yuki' && PlayState.opponentMode == true)
		{
			portrait.loadGraphic(Paths.image('persona/portraits/makoto-portrait'));
			portrait.y = -200;
		}
		else if (PlayState.SONG.player2 == 'yu-narukami' && PlayState.opponentMode == true)
		{
			portrait.loadGraphic(Paths.image('persona/portraits/yu-portrait'));
			portrait.y = -190;
		}
		else if (PlayState.SONG.player2 == 'joker' && PlayState.opponentMode == true)
		{
			portrait.loadGraphic(Paths.image('persona/portraits/joker-portrait'));
			portrait.y = -290;
		}
		else
			portrait.loadGraphic(Paths.image('persona/portraits/bf-portrait'));

		if (mode == "p3")
		{
			FlxG.sound.playMusic(Paths.music('persona/songs from the games/P3-RELOAD/After The Battle-RELOAD'));
		}
		if (mode == "p4")
		{
			FlxG.sound.playMusic(Paths.music('persona/songs from the games/P4/Period'));
		}
		if (mode == "p5")
		{
			FlxG.sound.playMusic(Paths.music('persona/songs from the games/P5/Triumph'));
		}

		if (PlayState.isStoryMode)
		{
			intendedScore = PlayState.campaignScore;
			intendedMisses = PlayState.campaignMisses;
			intendedRating = PlayState.campaignPercent / PlayState.songsPlayed;
			intendedSick = PlayState.campaignSicks;
			intendedGood = PlayState.campaignGoods;
			intendedBad = PlayState.campaignBads;
			intendedShit = PlayState.campaignShits;
			songTxt.text = WeekData.getCurrentWeek().weekName;
		}
		else
		{
			intendedScore = PlayState.instance.songScore;
			intendedMisses = PlayState.instance.songMisses;
			intendedRating = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
			intendedSick = PlayState.instance.ratingsData[0].hits;
			intendedGood = PlayState.instance.ratingsData[1].hits;
			intendedBad = PlayState.instance.ratingsData[2].hits;
			intendedShit = PlayState.instance.ratingsData[3].hits;
		}

		if (PlayState.isStoryMode)
		{
			if (PlayState.campaignScore > Highscore.getWeekScore(WeekData.getCurrentWeek().weekName, PlayState.storyDifficulty)) 
			{
				new FlxTimer().start(3.5, function(tmr:FlxTimer)
				{
					trace("new highscore!!!");
					highscore.visible = true;
					FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
				});
			}
		}
		else
		{
			if (PlayState.instance.songScore > Highscore.getScore(PlayState.instance.songName, PlayState.storyDifficulty)) 
			{
				trace("new highscore!!!");
				new FlxTimer().start(3.5, function(tmr:FlxTimer)
				{
					highscore.visible = true;
					FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
				});
			}
		}

		new FlxTimer().start(1, function(tmr) {
			can_leave = true;
			showSick = true;
		});

		new FlxTimer().start(1.2, function(tmr) {
			showGood = true;
		});

		new FlxTimer().start(1.4, function(tmr) {
			showBad = true;
		});

		new FlxTimer().start(1.6, function(tmr) {
			showShit = true;
		});

		new FlxTimer().start(1.8, function(tmr) {
			showMisses = true;
		});

		new FlxTimer().start(2.0, function(tmr) {
			barTween = FlxTween.tween(progressBar, {percent: intendedRating}, 1, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) progressBar.updateBar(),
				onUpdate: function(twn:FlxTween) progressBar.updateBar()
			});
			showScore = true;
			showAccuracy = true;
		});

		trace(intendedRating);

		if (intendedRating == 100)
			add(P);
		else if (intendedRating >= 94.99)
			add(S);
		else if (intendedRating >= 89.99)
			add(A);
		else if (intendedRating >= 79.99)
			add(B);
		else if (intendedRating >= 69.99)
			add(C);
		else if (intendedRating >= 39.99)
			add(D);
		else if (intendedRating >= 19.99)
			add(E);
		else
			add(F);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if(showScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 14)));

			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;
		}

		if(showMisses)
		{
			lerpMisses = Math.floor(FlxMath.lerp(intendedMisses, lerpMisses, Math.exp(-elapsed * 16)));

			if (Math.abs(lerpMisses - intendedMisses) <= 10)
				lerpMisses = intendedMisses;
		}

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating, 2)).split('.');

		if(showAccuracy)
		{
			lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

			if (Math.abs(lerpRating - intendedRating) <= 0.01)
				lerpRating = intendedRating;

			if(ratingSplit.length < 2) { //No decimals, add an empty space
				ratingSplit.push('');
			}

			while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
				ratingSplit[1] += '0';
			}
		}

		if(showSick)
		{
			lerpSick = Math.floor(FlxMath.lerp(intendedSick, lerpSick, Math.exp(-elapsed * 16)));

			if (Math.abs(lerpSick - intendedSick) <= 10)
				lerpSick = intendedSick;
		}
		if(showGood)
		{
			lerpGood = Math.floor(FlxMath.lerp(intendedGood, lerpGood, Math.exp(-elapsed * 16)));

			if (Math.abs(lerpGood - intendedGood) <= 10)
				lerpGood = intendedGood;
		}
		if(showBad)
		{
			lerpBad = Math.floor(FlxMath.lerp(intendedBad, lerpBad, Math.exp(-elapsed * 16)));

			if (Math.abs(lerpBad - intendedBad) <= 10)
				lerpBad = intendedBad;
		}
		if(showShit)
		{
			lerpShit = Math.floor(FlxMath.lerp(intendedShit, lerpShit, Math.exp(-elapsed * 16)));

			if (Math.abs(lerpShit - intendedShit) <= 10)
				lerpShit = intendedShit;
		}

		scoreTxt.text = '' + lerpScore;
		missTxt.text = '' + lerpMisses;
		accTxt.text = 'Accuracy: ' + ' ' + ratingSplit.join('.') + '%';
		sickTxt.text = '' + lerpSick;
		goodTxt.text = '' + lerpGood;
		badTxt.text = '' + lerpBad;
		shitTxt.text = '' + lerpShit;

		super.update(elapsed);

		if (controls.ACCEPT && can_leave == true)
		{
			endResults();
			FlxG.sound.music.stop();
			FlxG.sound.music.destroy();
		}
	}

	function endResults() {
		var percent:Float = PlayState.instance.ratingPercent;
		if(Math.isNaN(percent)) percent = 0;
		
		if(PlayState.isStoryMode)
		{
			if (!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
				StoryMenuState.weekCompleted.set(WeekData.weeksList[PlayState.storyWeek], true);
				Highscore.saveWeekScore(WeekData.getWeekFileName(), PlayState.campaignScore, PlayState.storyDifficulty);

				FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
				FlxG.save.flush();
			}
		}
		else
		{
			Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, percent, PlayState.opponentMode);
		}

		PlayState.campaignPercent = PlayState.songsPlayed = 0;
		PlayState.campaignSicks = 0;
		PlayState.campaignGoods = 0;
		PlayState.campaignBads = 0;
		PlayState.campaignShits = 0;
		
		if (PlayState.isStoryMode) 
		{
			MusicBeatState.switchState(new StoryMenuState());
		}
		else
		{
			openSubState(new StickerSubState(null, (sticker) -> new FreeplayState(sticker)));
		}
	}
}