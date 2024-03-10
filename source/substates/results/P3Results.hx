package substates.results;

import states.StoryMenuState;
import states.FreeplayState;

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

    override function create()
    {
        camHUD = new FlxCamera();
        FlxG.cameras.add(camHUD, false);
        var score = PlayState.instance.songScore;
        var misses = PlayState.instance.songMisses;
        var percent:Float = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);

        // ASSETS
        var blue:FlxSprite = new FlxSprite(-2000, 0).makeGraphic(1920, 1080, 0xFF008FFF);
        blue.scrollFactor.set();
        blue.antialiasing = ClientPrefs.data.antialiasing;
        blue.angle = -33;
        blue.updateHitbox();
        add(blue);

        var shit:FlxSprite = new FlxSprite(600, -530).loadGraphic(Paths.image(path + 'exptext'));
        shit.scrollFactor.set();
        shit.antialiasing = ClientPrefs.data.antialiasing;
        shit.angle = -33;
        shit.updateHitbox();
        add(shit);

        var lines:FlxSprite = new FlxSprite(-1280, 270).loadGraphic(Paths.image(path + 'lines'));
        lines.scrollFactor.set();
        lines.updateHitbox();
        add(lines);

        var beef:FlxSprite = new FlxSprite(FlxG.width + 500, 135).loadGraphic(Paths.image(path + 'boyfriend'));
        beef.scrollFactor.set();
        beef.antialiasing = ClientPrefs.data.antialiasing;
        beef.updateHitbox();
        add(beef);

        var darkish:FlxSprite = new FlxSprite(-2000, -500).makeGraphic(1920, 1080, 0xFF001F45);
        darkish.scrollFactor.set();
        darkish.antialiasing = ClientPrefs.data.antialiasing;
        darkish.angle = -33;
        darkish.updateHitbox();
        add(darkish);

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

        FlxTween.tween(darkish, {x: -1500}, 0.5, {ease: FlxEase.expoInOut});
        FlxTween.tween(blue, {x: -200}, 0.55, {ease: FlxEase.expoInOut});
        FlxTween.tween(shit, {x: -100, y:-130}, 0.55, {ease: FlxEase.expoInOut});
        FlxTween.tween(lines, {x: 0}, 0.55, {ease: FlxEase.expoInOut});
        FlxTween.tween(beef, {x: FlxG.width - 500}, 0.65, {ease: FlxEase.elasticInOut});

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
        darkish.cameras = [camHUD];
        scoreTxt.cameras = [camHUD];
        scoreText.cameras = [camHUD];
        missTxt.cameras = [camHUD];
        missText.cameras = [camHUD];
        accTxt.cameras = [camHUD];
        accText.cameras = [camHUD];

        super.create();

        FlxG.sound.playMusic(Paths.music('persona/victory/p3Loop'));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.ACCEPT)
        {
            if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }
    }
}