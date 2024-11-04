package substates.results;

import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.FreeplayState;
import states.PlayState;
import backend.Highscore;
import backend.Song;
import backend.Rating;
import flixel.util.FlxTimer;

class P3Results extends MusicBeatSubstate
{
    public var camHUD:FlxCamera;

    var base:FlxSprite;
    var path:String = "persona/results/p3/";

    var result:FlxText;
    var missesTxt:FlxText;
    var accTxt:FlxText;
    var status:FlxText;
    var bfText:FlxText;

    var black:FlxSprite;
    var screen:FlxSprite;
    var shit:FlxSprite;

    override function create()
    {
        camHUD = new FlxCamera();
        FlxG.cameras.add(camHUD, false);
        FlxTransitionableState.skipNextTransOut = false;

        var score = PlayState.instance.songScore;
        var misses = PlayState.instance.songMisses;
        var percent:Float = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);

        // ASSETS
        var blue:FlxSprite = new FlxSprite(-1280, 0).makeGraphic(1280, 720, 0xFF008FFF);
        blue.scrollFactor.set();
        blue.antialiasing = ClientPrefs.data.antialiasing;
        blue.updateHitbox();
        add(blue);

        var lines:FlxSprite = new FlxSprite(-1280, 270).loadGraphic(Paths.image(path + 'lines'));
        lines.scrollFactor.set();
        lines.updateHitbox();
        add(lines);

        var beef:FlxSprite = new FlxSprite(FlxG.width + 500, 135).loadGraphic(Paths.image(path + 'boyfriend'));
        beef.scrollFactor.set();
        beef.antialiasing = ClientPrefs.data.antialiasing;
        beef.updateHitbox();
        add(beef);

        var highscore:FlxSprite = new FlxSprite(300, 0).loadGraphic(Paths.image('persona/results/highscore'));
        highscore.scrollFactor.set();
        highscore.antialiasing = ClientPrefs.data.antialiasing;
        highscore.updateHitbox();
        highscore.setGraphicSize(Std.int(highscore.width * 0.4));
        add(highscore);
        highscore.visible = false;

        var scoreTxt:FlxText = new FlxText(375, 235, FlxG.width, '${PlayState.instance.songScore}', 40);
        scoreTxt.setFormat(Paths.font("akira.otf"), 40, FlxColor.WHITE);
        scoreTxt.scrollFactor.set();
        scoreTxt.updateHitbox();
        add(scoreTxt);

        var scoreText:FlxText = new FlxText(600, 235, FlxG.width, "Score", 40);
        scoreText.setFormat(Paths.font("akira.otf"), 40, FlxColor.BLACK);
        scoreText.scrollFactor.set();
        scoreText.updateHitbox();
        add(scoreText);

        var missTxt:FlxText = new FlxText(475, 318, FlxG.width, '${PlayState.instance.songMisses}', 40);
        missTxt.setFormat(Paths.font("akira.otf"), 40, FlxColor.WHITE);
        missTxt.scrollFactor.set();
        missTxt.updateHitbox();
        add(missTxt);

        var missText:FlxText = new FlxText(575, 318, FlxG.width, "Misses", 40);
        missText.setFormat(Paths.font("akira.otf"), 40, FlxColor.BLACK);
        missText.scrollFactor.set();
        missText.updateHitbox();
        add(missText);

        var accTxt:FlxText = new FlxText(250, 401, FlxG.width, '${percent}%', 40);
        accTxt.setFormat(Paths.font("akira.otf"), 40, FlxColor.WHITE);
        accTxt.scrollFactor.set();
        accTxt.updateHitbox();
        add(accTxt);

        var accText:FlxText = new FlxText(475, 401, FlxG.width, "Accuracy", 40);
        accText.setFormat(Paths.font("akira.otf"), 40, FlxColor.BLACK);
        accText.scrollFactor.set();
        accText.updateHitbox();
        add(accText);

        black = new FlxSprite(-1280, 0).makeGraphic(1280, 720, FlxColor.BLACK);
        black.scrollFactor.set();
        black.updateHitbox();
        add(black);

        screen = new FlxSprite(-3500, 0).loadGraphic(Paths.image(path + 'screenWipe'));
        screen.scrollFactor.set();
        screen.updateHitbox();
        add(screen);

        shit = new FlxSprite(-500, 0).loadGraphic(Paths.image(path + 'exptext'));
        shit.scrollFactor.set();
        shit.antialiasing = ClientPrefs.data.antialiasing;
        shit.updateHitbox();
        add(shit);

        FlxTween.tween(blue, {x: 0}, 0.75, {ease: FlxEase.expoInOut});
        FlxTween.tween(shit, {x: 0}, 0.75, {ease: FlxEase.expoInOut});
        FlxTween.tween(lines, {x: 0}, 0.75, {ease: FlxEase.expoInOut});
        FlxTween.tween(beef, {x: FlxG.width - 500}, 0.75, {ease: FlxEase.elasticInOut});
        FlxTween.tween(screen, {x: -2800}, 0.8, {ease: FlxEase.expoInOut});

        // for offset shit, i'll delete it later
        base = new FlxSprite().loadGraphic(Paths.image(path + 'reference'));
        base.screenCenter();
        base.scrollFactor.set();
        base.alpha = 0.4;
        //add(base);

        blue.cameras = [camHUD];
        shit.cameras = [camHUD];
        lines.cameras = [camHUD];
        beef.cameras = [camHUD];
        highscore.cameras = [camHUD];
        scoreTxt.cameras = [camHUD];
        scoreText.cameras = [camHUD];
        missTxt.cameras = [camHUD];
        missText.cameras = [camHUD];
        accTxt.cameras = [camHUD];
        accText.cameras = [camHUD];
        black.cameras = [camHUD];
        screen.cameras = [camHUD];

        if (PlayState.instance.songScore > Highscore.getScore(PlayState.instance.songName, PlayState.storyDifficulty)) 
        {
  	      new FlxTimer().start(1.3, function(tmr:FlxTimer)
	        {
  		      highscore.visible = true;
 		       FlxG.sound.play(Paths.sound('persona/highscore'), 1);
	        });
        }

        super.create();

        FlxG.sound.playMusic(Paths.music('persona/songs from the games/P3/After The Battle'));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.ACCEPT)
        {
            FlxTween.tween(black, {x:0}, 1.2, {ease:FlxEase.expoInOut});
            FlxTween.tween(screen, {x:1290}, 1.2, {ease:FlxEase.expoInOut, onComplete: function(twn:FlxTween){endthis();}});
            FlxTween.tween(shit, {x:1280}, 0.8, {ease:FlxEase.expoInOut});
        }
    }

    function endthis()
    {
        var percent:Float = PlayState.instance.ratingPercent;
		if (Math.isNaN(percent)) percent = 0;
		Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, percent);
        
        if (PlayState.isStoryMode) 
        {
        	if (PlayState.storyPlaylist.length <= 0)
	        {
	   	     MusicBeatState.switchState(new StoryMenuState());
	        }
			else
	        {
 	  	     LoadingState.loadAndSwitchState(new PlayState());
	        }
        }
        else
        {
 	       MusicBeatState.switchState(new FreeplayState());
        }

        FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }
}