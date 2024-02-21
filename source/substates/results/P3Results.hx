package substates.results;

import states.StoryMenuState;
import states.FreeplayState;

class P3Results extends MusicBeatSubstate
{
    var base:FlxSprite;
    var path:String = "persona/results/p3/";

    var blue:FlxSprite;
    var darkish:FlxSprite;
    var shit:FlxSprite;
    var lines:FlxSprite;
    var beef:FlxSprite;

    var result:FlxText;
    var scoreTxt:FlxText;
    var missesTxt:FlxText;
    var accTxt:FlxText;
    var status:FlxText;
    var bfText:FlxText;

    override function create()
    {
        super.create();

        // ASSETS
        blue = new FlxSprite(-2000, 0).makeGraphic(1920, 1080, 0xFF008FFF);
        blue.scrollFactor.set();
        blue.antialiasing = ClientPrefs.data.antialiasing;
        blue.angle = -33;
        add(blue);

        shit = new FlxSprite(600, -530).loadGraphic(Paths.image(path + 'exptext'));
        shit.scrollFactor.set();
        shit.antialiasing = ClientPrefs.data.antialiasing;
        shit.angle = -33;
        add(shit);

        lines = new FlxSprite(-1280, 270).loadGraphic(Paths.image(path + 'lines'));
        lines.scrollFactor.set();
        add(lines);

        beef = new FlxSprite(FlxG.width + 500, 135).loadGraphic(Paths.image(path + 'boyfriend'));
        beef.scrollFactor.set();
        beef.antialiasing = ClientPrefs.data.antialiasing;
        add(beef);

        darkish = new FlxSprite(-2000, -500).makeGraphic(1920, 1080, 0xFF001F45);
        darkish.scrollFactor.set();
        darkish.antialiasing = ClientPrefs.data.antialiasing;
        darkish.angle = -33;
        add(darkish);

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