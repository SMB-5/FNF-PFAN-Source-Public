package substates;

import states.StoryMenuState;
import states.FreeplayState;
import substates.StickerSubState;
import backend.Highscore;
import backend.WeekData;
import flixel.math.FlxMath;
import flixel.util.FlxSort;

enum PersonaMode
{
	P3;
	P4;
	P5;
}

class ResultsSubstate extends MusicBeatSubstate
{
	public var camHUD:FlxCamera;
	public var mode:PersonaMode = P5;

	var events:Array<{time:Float, func:Void->Void}> = [];

	var scoreTxt:FlxText;
	var missTxt:FlxText;
	var accTxt:FlxText;
	var sickTxt:FlxText;
	var goodTxt:FlxText;
	var badTxt:FlxText;
	var shitTxt:FlxText;
	var songTxt:FlxText;

	var portrait:FlxSprite;

	var canEnd:Bool = false;
	var fastForwarding:Bool = false;

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
	var songName:String;

	var showScore:Bool = false;
	var showMisses:Bool = false;
	var showAccuracy:Bool = false;
	var showSick:Bool = false;
	var showGood:Bool = false;
	var showBad:Bool = false;
	var showShit:Bool = false;

	var musicTime:Float = 1;
	var resultMusic:openfl.media.Sound;

	override function create()
	{
		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		switch(PlayState.SONG.song)
		{
			case 'Blue Moon' | 'Tartarus' | 'Destruction' | 'Answer':
				mode = P3;
			case 'Truth' | 'Specialist':
				mode = P4;
			default:
				mode = P5;
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
			songName = WeekData.getCurrentWeek().weekName;
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
			songName = PlayState.SONG.song;
		}

		var bg:FlxSprite = new FlxSprite(0, 0, Paths.image('persona/results/resultsbg'));
		bg.cameras = [camHUD];
		bg.y += FlxG.height;
		add(bg);

		var line:FlxSprite = new FlxSprite(450, -50, Paths.image('persona/results/resultsline'));
		line.cameras = [camHUD];
		line.x += FlxG.width;
		add(line);

		portrait = new FlxSprite(350, -300);
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		portrait.scale.x = 0.4;
		portrait.scale.y = 0.4;
		loadPortrait();
		portrait.cameras = [camHUD];
		portrait.x += FlxG.width;
		add(portrait);

		var bg2:FlxSprite = new FlxSprite(0, 0, Paths.image('persona/results/resultsbg2'));
		bg2.cameras = [camHUD];
		bg2.x -= FlxG.width;
		add(bg2);

		var results:FlxSprite = new FlxSprite(20, 0, Paths.image('persona/results/results'));
		results.cameras = [camHUD];
		results.y -= 250;
		add(results);

		songTxt = new FlxText(50, 120, FlxG.width, songName, 50);
		songTxt.setFormat(Paths.font("p5hatty-1.ttf"), 40, FlxColor.BLACK);
		songTxt.angle += 1;
		songTxt.cameras = [camHUD];
		songTxt.y -= 250;
		add(songTxt);

		var sickBG:FlxSprite = new FlxSprite(20, 170, Paths.image('persona/results/results-sick'));
		sickBG.cameras = [camHUD];
		sickBG.x += 10;
		sickBG.y -= 160;
		sickBG.visible = false;
		insert(members.indexOf(results), sickBG);

		sickTxt = new FlxText(180, 120, FlxG.width, '' + lerpSick, 50);
		sickTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		sickTxt.angle = -9;
		sickTxt.cameras = [camHUD];
		sickTxt.x += 10;
		sickTxt.y -= 160;
		sickTxt.visible = false;
		insert(members.indexOf(results), sickTxt);

		var goodBG:FlxSprite = new FlxSprite(180, 230, Paths.image('persona/results/results-good'));
		goodBG.cameras = [camHUD];
		goodBG.x -= 160;
		goodBG.y -= 70;
		goodBG.visible = false;
		insert(members.indexOf(sickBG), goodBG);

		goodTxt = new FlxText(360, 185, FlxG.width, '' + lerpGood, 50);
		goodTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		goodTxt.angle = -9;
		goodTxt.cameras = [camHUD];
		goodTxt.x -= 160;
		goodTxt.y -= 70;
		goodTxt.visible = false;
		insert(members.indexOf(sickBG), goodTxt);

		var badBG:FlxSprite = new FlxSprite(20, 360, Paths.image('persona/results/results-bad'));
		badBG.cameras = [camHUD];
		badBG.x += 180;
		badBG.y -= 130;
		badBG.visible = false;
		insert(members.indexOf(goodBG), badBG);

		badTxt = new FlxText(180, 310, FlxG.width, '' + lerpBad, 50);
		badTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		badTxt.angle = -9;
		badTxt.cameras = [camHUD];
		badTxt.x += 180;
		badTxt.y -= 130;
		badTxt.visible = false;
		insert(members.indexOf(goodBG), badTxt);

		var shitBG:FlxSprite = new FlxSprite(190, 420, Paths.image('persona/results/results-shit'));
		shitBG.cameras = [camHUD];
		shitBG.x -= 180;
		shitBG.y -= 70;
		shitBG.visible = false;
		insert(members.indexOf(badBG), shitBG);

		shitTxt = new FlxText(370, 380, FlxG.width, '' + lerpShit, 50);
		shitTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		shitTxt.angle = -9;
		shitTxt.cameras = [camHUD];
		shitTxt.x -= 180;
		shitTxt.y -= 70;
		shitTxt.visible = false;
		insert(members.indexOf(badBG), shitTxt);

		var missBG:FlxSprite = new FlxSprite(0, 510, Paths.image('persona/results/results-miss'));
		missBG.cameras = [camHUD];
		missBG.x += 250;
		missBG.y -= 80;
		missBG.visible = false;
		insert(members.indexOf(shitBG), missBG);

		missTxt = new FlxText(100, 480, FlxG.width, '' + lerpMisses, 50);
		missTxt.setFormat(Paths.font("p5hatty-1.ttf"), 50, FlxColor.BLACK);
		missTxt.angle = -9;
		missTxt.cameras = [camHUD];
		missTxt.x += 250;
		missTxt.y -= 80;
		missTxt.visible = false;
		insert(members.indexOf(shitBG), missTxt);

		var scoreBG:FlxSprite = new FlxSprite(0, 495, Paths.image('persona/results/results-score'));
		scoreBG.cameras = [camHUD];
		scoreBG.y += 300;
		add(scoreBG);

		scoreTxt = new FlxText(210, 575, FlxG.width, '' + lerpScore, 70);
		scoreTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
		scoreTxt.angle = -9;
		scoreTxt.cameras = [camHUD];
		scoreTxt.y += 300;
		add(scoreTxt);

		accTxt = new FlxText(330, 40, FlxG.width, 'Accuracy: ' + lerpRating + '%', 50);
		accTxt.setFormat(Paths.font("p5hatty-1.ttf"), 40, FlxColor.WHITE);
		accTxt.cameras = [camHUD];
		accTxt.x -= 250;
		accTxt.visible = false;
		add(accTxt);

		var ratingSpr:FlxSprite = new FlxSprite(600, 515, getRankGraphic());
		ratingSpr.cameras = [camHUD];
		ratingSpr.alpha = 0;
		ratingSpr.x -= 300;
		add(ratingSpr);

		var highscore:FlxSprite = new FlxSprite(850, 570, Paths.image('persona/results/highscore'));
		highscore.antialiasing = ClientPrefs.data.antialiasing;
		highscore.cameras = [camHUD];
		highscore.visible = false;
		add(highscore);

		switch(mode) {
			case P3:
				musicTime = 1.75;
				resultMusic = Paths.music('persona/songs from the games/P3-RELOAD/After The Battle-RELOAD');
			case P4:
				musicTime = 0.65;
				resultMusic = Paths.music('persona/songs from the games/P4/Period');
			default:
				musicTime = 1;
				resultMusic = Paths.music('persona/songs from the games/P5/Triumph');
		}

		if (PlayState.isStoryMode && PlayState.campaignScore > Highscore.getWeekScore(WeekData.getCurrentWeek().weekName, PlayState.storyDifficulty) || !PlayState.isStoryMode && PlayState.instance.songScore > Highscore.getScore(PlayState.instance.songName, PlayState.storyDifficulty, PlayState.opponentMode)) 
		{
			addEvent(5.5, ()->{
				FlxG.sound.play(Paths.sound('persona/highscore'));
				highscore.visible = true;
				FlxTween.shake(highscore, 0.05, 0.25);
			});
		}

		addEvent(0.5, ()->FlxTween.tween(bg, { y: bg.y - FlxG.height }, 1, { ease: FlxEase.expoOut }));
		addEvent(musicTime, ()->FlxG.sound.playMusic(resultMusic));
		addEvent(1.5, ()->FlxTween.tween(bg2, { x: bg2.x + FlxG.width }, 0.5, { ease: FlxEase.expoOut }));
		addEvent(1.75, ()->{
			camHUD.flash(0xFFFFFFFF, 0.25);
			FlxTween.tween(portrait, { x: portrait.x - FlxG.width }, 0.35, { ease: FlxEase.expoOut });
			FlxTween.tween(line, { x: line.x - FlxG.width }, 0.35, { ease: FlxEase.expoOut });
			FlxTween.tween(results, { y: results.y + 250 }, 0.35, { ease: FlxEase.expoOut });
			FlxTween.tween(songTxt, { y: songTxt.y + 250 }, 0.35, { ease: FlxEase.expoOut });
		});
		addEvent(2.35, ()->{
			sickBG.visible = sickTxt.visible = true;
			FlxTween.tween(sickBG, { x: sickBG.x - 10, y: sickBG.y + 160 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(sickTxt, { x: sickTxt.x - 10, y: sickTxt.y + 160 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(2.55, ()->showSick = true);
		addEvent(2.75, ()->{
			goodBG.visible = goodTxt.visible = true;
			FlxTween.tween(goodBG, { x: goodBG.x + 160, y: goodBG.y + 70 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(goodTxt, { x: goodTxt.x + 160, y: goodTxt.y + 70 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(2.95, ()->showGood = true);
		addEvent(3.15, ()->{
			badBG.visible = badTxt.visible = true;
			FlxTween.tween(badBG, { x: badBG.x - 180, y: badBG.y + 130 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(badTxt, { x: badTxt.x - 180, y: badTxt.y + 130 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(3.35, ()->showBad = true);
		addEvent(3.55, ()->{
			shitBG.visible = shitTxt.visible = true;
			FlxTween.tween(shitBG, { x: shitBG.x + 180, y: shitBG.y + 70 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(shitTxt, { x: shitTxt.x + 180, y: shitTxt.y + 70 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(3.75, ()->showShit = true);
		addEvent(3.95, ()->{
			missBG.visible = missTxt.visible = true;
			FlxTween.tween(missBG, { x: missBG.x - 250, y: missBG.y + 80 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(missTxt, { x: missTxt.x - 250, y: missTxt.y + 80 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(4.15, ()->showMisses = true);
		addEvent(4.35, ()->{
			scoreBG.visible = scoreTxt.visible = true;
			FlxTween.tween(scoreBG, { y: scoreBG.y - 300 }, 0.4, { ease: FlxEase.expoOut });
			FlxTween.tween(scoreTxt, { y: scoreTxt.y - 300 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(4.35, ()->{
			accTxt.visible = true;
			FlxTween.tween(accTxt, { x: accTxt.x + 250 }, 0.4, { ease: FlxEase.expoOut });
		});
		addEvent(4.45, ()->showAccuracy = true);
		addEvent(4.5, ()->showScore = true);
		addEvent(5, ()->{
			FlxTween.tween(ratingSpr, { alpha: 1, x: ratingSpr.x + 300 }, 0.4, { ease: FlxEase.expoOut });
		});

		super.create();
	}

	var eventTimer:Float = 0;
	override function update(elapsed:Float)
	{
		eventTimer += elapsed;
		if (events.length > 0) {
			haxe.ds.ArraySort.sort(events, (a, b) -> return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
			if (eventTimer >= events[0].time) events.shift().func();
			if (events.length <= 0) canEnd = true; // All events finished
		}

		if(showScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 14)));

			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;
		}

		if(showMisses)
		{
			lerpMisses = Math.floor(FlxMath.lerp(intendedMisses, lerpMisses, Math.exp(-elapsed * 10)));

			if (Math.abs(lerpMisses - intendedMisses) <= 10)
				lerpMisses = intendedMisses;
		}

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating, 2)).split('.');

		if(showAccuracy)
		{
			lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 8));

			if (Math.abs(lerpRating - intendedRating) <= 0.01)
				lerpRating = intendedRating;

			if(ratingSplit.length < 2) { //No decimals found, add 2 decimals
				ratingSplit.push('00');
			}

			while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
				ratingSplit[1] += '0';
			}
		}

		if(showSick)
		{
			lerpSick = Math.floor(FlxMath.lerp(intendedSick, lerpSick, Math.exp(-elapsed * 10)));

			if (Math.abs(lerpSick - intendedSick) <= 10)
				lerpSick = intendedSick;
		}
		if(showGood)
		{
			lerpGood = Math.floor(FlxMath.lerp(intendedGood, lerpGood, Math.exp(-elapsed * 10)));

			if (Math.abs(lerpGood - intendedGood) <= 10)
				lerpGood = intendedGood;
		}
		if(showBad)
		{
			lerpBad = Math.floor(FlxMath.lerp(intendedBad, lerpBad, Math.exp(-elapsed * 10)));

			if (Math.abs(lerpBad - intendedBad) <= 10)
				lerpBad = intendedBad;
		}
		if(showShit)
		{
			lerpShit = Math.floor(FlxMath.lerp(intendedShit, lerpShit, Math.exp(-elapsed * 10)));

			if (Math.abs(lerpShit - intendedShit) <= 10)
				lerpShit = intendedShit;
		}

		scoreTxt.text = Std.string(lerpScore);
		missTxt.text = Std.string(lerpMisses);
		accTxt.text = 'Accuracy:  ' + ratingSplit.join('.') + '%';
		sickTxt.text = Std.string(lerpSick);
		goodTxt.text = Std.string(lerpGood);
		badTxt.text = Std.string(lerpBad);
		shitTxt.text = Std.string(lerpShit);

		if (controls.ACCEPT || controls.BACK || TouchUtil.justPressed)
		{
			if (canEnd) {
				endResults();
				FlxG.sound.music.stop();
			}
			else if (!fastForwarding) {
				fastForwarding = true;
				for (event in events) event.time *= 0.5;
			}
		}

		super.update(elapsed);
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

	function addEvent(time:Float, func:Void->Void) {
		events.push({time: time, func: func});
	}

	function loadPortrait() {
		var char:String = !PlayState.opponentMode ? PlayState.SONG.player1 : PlayState.SONG.player2;
		if (char.endsWith('-player')) char = char.substring(0, char.length - 7);

		switch(char) {
			case 'yu-narukami':
				portrait.loadGraphic(Paths.image('persona/portraits/yu-portrait'));
				portrait.y = -190;
			case 'makoto-yuki':
				portrait.loadGraphic(Paths.image('persona/portraits/makoto-portrait'));
				portrait.y = -200;
			case 'joker':
				portrait.loadGraphic(Paths.image('persona/portraits/joker-portrait'));
				portrait.y = -290;
			default:
				portrait.loadGraphic(Paths.image('persona/portraits/bf-portrait'));
		}
	}
	
	function getRankGraphic() {
		if (intendedRating >= 100) return Paths.image('persona/results/P');
		else if (intendedRating >= 94.99) return Paths.image('persona/results/S');
		else if (intendedRating >= 89.99) return Paths.image('persona/results/A');
		else if (intendedRating >= 79.99) return Paths.image('persona/results/B');
		else if (intendedRating >= 69.99) return Paths.image('persona/results/C');
		else if (intendedRating >= 39.99) return Paths.image('persona/results/D');
		else if (intendedRating >= 19.99) return Paths.image('persona/results/E');
		else return Paths.image('persona/results/F');
	}
}