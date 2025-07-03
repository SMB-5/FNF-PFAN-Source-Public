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
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import objects.Bar;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import backend.Metadata;

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
	var resultsTxt:FlxText;

    public var progressBar:FlxBar;
    public var barTween:FlxTween = null;
    var can_leave = false;

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

	var data:MetadataFile;

    override function create()
    {
        camHUD = new FlxCamera();
        FlxG.cameras.add(camHUD, false);
        camHUD.bgColor.alpha = 0;

		data = PlayState.metadata;

        var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.4;
		bg.scrollFactor.set();
		add(bg);

        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

        var player = new FlxSprite(800, -400).loadGraphic(Paths.image('persona/portraits/placeholder'));
		player.antialiasing = ClientPrefs.data.antialiasing;
		add(player);

		resultsTxt = new FlxText(20, 10, "RESULTS!!!", 50);
        resultsTxt.setFormat(Paths.font("p5hatty-1.ttf"), 80, FlxColor.BLACK);
        resultsTxt.scrollFactor.set();
        resultsTxt.updateHitbox();
        add(resultsTxt);

        songTxt = new FlxText(20, 100, FlxG.width, PlayState.SONG.song + ' By ' + data.credits.music, 50);
        songTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        songTxt.scrollFactor.set();
        songTxt.updateHitbox();
        add(songTxt);

        sickTxt = new FlxText(20, 175, FlxG.width, 'Sicks: ' + lerpSick, 50);
        sickTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        sickTxt.scrollFactor.set();
        sickTxt.updateHitbox();
        add(sickTxt);

        goodTxt = new FlxText(20, 250, FlxG.width, 'Goods: ' + lerpGood, 50);
        goodTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        goodTxt.scrollFactor.set();
        goodTxt.updateHitbox();
        add(goodTxt);

        badTxt = new FlxText(20, 325, FlxG.width, 'Bads: ' + lerpBad, 50);
        badTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        badTxt.scrollFactor.set();
        badTxt.updateHitbox();
        add(badTxt);

        shitTxt = new FlxText(20, 400, FlxG.width, 'Shits: ' + lerpShit, 50);
        shitTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        shitTxt.scrollFactor.set();
        shitTxt.updateHitbox();
        add(shitTxt);

        scoreTxt = new FlxText(20, 650, FlxG.width, 'Score: ' + lerpScore, 70);
        scoreTxt.setFormat(Paths.font("p5hatty-1.ttf"), 80, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();
        scoreTxt.updateHitbox();
        add(scoreTxt);

        missTxt = new FlxText(20, 475, FlxG.width, 'Misses: ' + lerpMisses, 50);
        missTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        missTxt.scrollFactor.set();
        missTxt.updateHitbox();
        add(missTxt);

        accTxt = new FlxText(20, 550, FlxG.width, 'Accuracy: ' + lerpRating + '%', 50);
        accTxt.setFormat(Paths.font("p5hatty-1.ttf"), 60, FlxColor.BLACK);
        accTxt.scrollFactor.set();
        accTxt.updateHitbox();
        add(accTxt);

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

		var highscore:FlxSprite = new FlxSprite(250, 500).loadGraphic(Paths.image('persona/results/highscore'));
		highscore.scrollFactor.set();
		highscore.antialiasing = ClientPrefs.data.antialiasing;
		highscore.updateHitbox();
		highscore.setGraphicSize(Std.int(highscore.width * 0.4));
		add(highscore);
		highscore.visible = false;

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
        new FlxTimer().start(7, function(tmr:FlxTimer)
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
        new FlxTimer().start(7, function(tmr:FlxTimer)
 	    {
		highscore.visible = true;
		FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
        });
        }
        }

        if (PlayState.isStoryMode)
        {
        if (intendedRating > 80)
        {
        FlxG.sound.play(Paths.sound('results-intro'), function() {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        });
        }
        else
        FlxG.sound.play(Paths.sound('results-shit-intro'), function() {
        FlxG.sound.playMusic(Paths.music('results/shit'));
        });
        }
        else
        {
        if (PlayState.instance.ratingPercent > 0.8)
        {
        FlxG.sound.play(Paths.sound('results-intro'), function() {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        });
        }
        else
        FlxG.sound.play(Paths.sound('results-shit-intro'), function() {
        FlxG.sound.playMusic(Paths.music('results/shit'));
        });
        }

        new FlxTimer().start(1.5, function(tmr) {
        can_leave = true;
        showSick = true;
        });

        new FlxTimer().start(2, function(tmr) {
        showGood = true;
        });

        new FlxTimer().start(2.5, function(tmr) {
        showBad = true;
        });

        new FlxTimer().start(3, function(tmr) {
        showShit = true;
        });

        new FlxTimer().start(3.5, function(tmr) {
        showMisses = true;
        });

        new FlxTimer().start(4, function(tmr) {
        if (PlayState.isStoryMode)
        {
        if (PlayState.isStoryMode)
        {
            barTween = FlxTween.tween(progressBar, {percent: PlayState.campaignPercent / PlayState.songsPlayed}, 1, {
                ease: FlxEase.quadOut,
                onComplete: function(twn:FlxTween) progressBar.updateBar(),
                onUpdate: function(twn:FlxTween) progressBar.updateBar()
            });
        }
        }
        else
        {
        var val1:Float = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
        var val2:Float = 100;
        barTween = FlxTween.tween(progressBar, {percent: (val1 / val2) * 100}, 1, {
            ease: FlxEase.quadOut,
            onComplete: function(twn:FlxTween) progressBar.updateBar(),
            onUpdate: function(twn:FlxTween) progressBar.updateBar()
        });
        }
        showScore = true;
        showAccuracy = true;
        });


        bg.cameras = [camHUD];
        grid.cameras = [camHUD];
		resultsTxt.cameras = [camHUD];
        songTxt.cameras = [camHUD];
        sickTxt.cameras = [camHUD];
        goodTxt.cameras = [camHUD];
        badTxt.cameras = [camHUD];
        shitTxt.cameras = [camHUD];
        scoreTxt.cameras = [camHUD];
        missTxt.cameras = [camHUD];
        accTxt.cameras = [camHUD];
        progressBar.cameras = [camHUD];
        bar.cameras = [camHUD];
        player.cameras = [camHUD];
		highscore.cameras = [camHUD];

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

        scoreTxt.text = 'Score: ' + lerpScore;
        missTxt.text = 'Misses: ' + lerpMisses;
        accTxt.text = 'Accuracy: ' + ' ' + ratingSplit.join('.') + '%';
        sickTxt.text = 'Sicks: ' + lerpSick;
        goodTxt.text = 'Goods: ' + lerpGood;
        badTxt.text = 'Bads: ' + lerpBad;
        shitTxt.text = 'Shits: ' + lerpShit;

        super.update(elapsed);

        if (controls.ACCEPT && can_leave == true)
        {
            endthis();
        }
    }

    function endthis(){
        var percent:Float = PlayState.instance.ratingPercent;
		if(Math.isNaN(percent)) percent = 0;
        
        if(PlayState.isStoryMode)
        {
        Highscore.saveWeekScore(WeekData.getWeekFileName(), PlayState.campaignScore, PlayState.storyDifficulty);
        }
        else
        {
		Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, percent);
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
        MusicBeatState.switchState(new FreeplayState());
        }

        FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }
}