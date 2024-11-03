package substates.results;

import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.FreeplayState;
import states.PlayState;
import backend.Highscore;
import backend.Song;
import backend.Rating;
import backend.Metadata;
import flixel.util.FlxTimer;

class P4Results extends MusicBeatSubstate
{
    public var camHUD:FlxCamera;

    var base:FlxSprite;
    var path:String = "persona/results/p4/";

    var result:FlxText;
    var missesTxt:FlxText;
    var accTxt:FlxText;
    var status:FlxText;
    var bfText:FlxText;

    var black:FlxSprite;
    var screen:FlxSprite;
    var shit:FlxSprite;

    var data:MetadataFile;

    override function create()
    {
        camHUD = new FlxCamera();
        FlxG.cameras.add(camHUD, false);
        FlxTransitionableState.skipNextTransOut = false;

        // ASSETS
        var yellow:FlxSprite = new FlxSprite(-1280).makeGraphic(1280, 720, 0xFFFFEB2C);
        yellow.scrollFactor.set();
        yellow.updateHitbox();
        add(yellow);

        var beef:FlxSprite = new FlxSprite(500, 500).loadGraphic(Paths.image(path + 'bf'));
        beef.scrollFactor.set();
        beef.antialiasing = ClientPrefs.data.antialiasing;
        beef.updateHitbox();
        add(beef);

        var filter:FlxSprite = new FlxSprite(700).loadGraphic(Paths.image(path + 'darkercolor'));
        filter.scrollFactor.set();
        filter.antialiasing = ClientPrefs.data.antialiasing;
        filter.blend = "multiply";
        filter.updateHitbox();
        add(filter);

        var borders:FlxSprite = new FlxSprite(900).loadGraphic(Paths.image(path + 'borders'));
        borders.scrollFactor.set();
        borders.antialiasing = ClientPrefs.data.antialiasing;
        borders.updateHitbox();
        add(borders);

        var highscore:FlxSprite = new FlxSprite(30, 400).loadGraphic(Paths.image('persona/results/highscore'));
        highscore.scrollFactor.set();
        highscore.antialiasing = ClientPrefs.data.antialiasing;
        highscore.updateHitbox();
        highscore.setGraphicSize(Std.int(highscore.width * 0.4));
        add(highscore);
        highscore.visible = false;

        var items:FlxSprite = new FlxSprite(30, 60).loadGraphic(Paths.image(path + 'items'));
        items.scrollFactor.set();
        items.antialiasing = ClientPrefs.data.antialiasing;
        items.updateHitbox();
        add(items);

        var text:FlxSprite = new FlxSprite(269, 800).loadGraphic(Paths.image(path + 'text'));
        text.scrollFactor.set();
        text.antialiasing = ClientPrefs.data.antialiasing;
        text.updateHitbox();
        add(text);

        // actual text
        data = PlayState.metadata;
        var score = PlayState.instance.songScore;
        var misses = PlayState.instance.songMisses;
        var percent:Float = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);

        var songTxt:FlxText = new FlxText(10, 0, FlxG.width, PlayState.SONG.song + ' By ' + formString(), 46);
        songTxt.setFormat(Paths.font("p4resultsfont.otf"), 36, FlxColor.BLACK);
        songTxt.scrollFactor.set();
        songTxt.updateHitbox();
        songTxt.alpha = 1;
        add(songTxt);

        var scoreTxt:FlxText = new FlxText(120, 120, FlxG.width, '${PlayState.instance.songScore} PTS', 40);
        scoreTxt.setFormat(Paths.font("p4resultsfont.otf"), 48, 0xFFE37B00);
        scoreTxt.scrollFactor.set();
        scoreTxt.updateHitbox();
        scoreTxt.alpha = 0.3;
        add(scoreTxt);

        var missTxt:FlxText = new FlxText(120, 250, FlxG.width, '${PlayState.instance.songMisses}', 40);
        missTxt.setFormat(Paths.font("p4resultsfont.otf"), 48, 0xFFE37B00);
        missTxt.scrollFactor.set();
        missTxt.updateHitbox();
        missTxt.alpha = 0.3;
        add(missTxt);

        var accTxt:FlxText = new FlxText(120, 380, FlxG.width, '${percent}%', 40);
        accTxt.setFormat(Paths.font("p4resultsfont.otf"), 48, 0xFFE37B00);
        accTxt.scrollFactor.set();
        accTxt.updateHitbox();
        accTxt.alpha = 0.3;
        add(accTxt);

        // swoosh
        screen = new FlxSprite(-2360).loadGraphic(Paths.image(path + 'screenWipe'));
        screen.scrollFactor.set();
        screen.updateHitbox();
        screen.antialiasing = ClientPrefs.data.antialiasing;
        add(screen);

        yellow.cameras = [camHUD];
        beef.cameras = [camHUD];
        filter.cameras = [camHUD];
        borders.cameras = [camHUD];
        highscore.cameras = [camHUD];
        items.cameras = [camHUD];
        text.cameras = [camHUD];
        
        scoreTxt.cameras = [camHUD];
        missTxt.cameras = [camHUD];
        accTxt.cameras = [camHUD];
        songTxt.cameras = [camHUD];
        screen.cameras = [camHUD];

        if (PlayState.instance.songScore > Highscore.getScore(PlayState.instance.songName, PlayState.storyDifficulty)) 
        {
        new FlxTimer().start(1.3, function(tmr:FlxTimer)
        {
        highscore.visible = true;
        FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
        });
        }

        super.create();

        FlxTween.tween(yellow, {x:0}, 0.4, {ease:FlxEase.quadInOut});
        FlxTween.tween(beef, {x:0, y:0}, 0.4, {ease:FlxEase.quadInOut});
        FlxTween.tween(filter, {x:0}, 0.7, {ease:FlxEase.expoInOut});
        FlxTween.tween(borders, {x:0}, 0.9, {ease:FlxEase.expoInOut});
        FlxTween.tween(items, {x:30}, 0.3, {ease:FlxEase.expoInOut, onComplete:function(twn:FlxTween){
            FlxTween.tween(scoreTxt, {x:150, alpha:1}, 0.6, {ease:FlxEase.expoInOut});
            FlxTween.tween(missTxt, {x:150, alpha:1}, 0.6, {ease:FlxEase.expoInOut});
            FlxTween.tween(accTxt, {x:150, alpha:1}, 0.6, {ease:FlxEase.expoInOut});
        }});
        FlxTween.tween(text, {y:629}, 0.5, {ease:FlxEase.expoInOut});

        FlxG.sound.playMusic(Paths.music('persona/songs from the games/P4/Period'));
    }

    public function formString():String
    {
        return '${data.credits.music.join(', ')}';
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.ACCEPT)
        {
            FlxTween.tween(screen, {x:0}, 1.1, {ease:FlxEase.expoInOut, 
                onComplete:function(twn){endthis();}});
        }
    }

    function endthis(){
        var percent:Float = PlayState.instance.ratingPercent;
		if(Math.isNaN(percent)) percent = 0;
		Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, percent);

        if (PlayState.isStoryMode) 
        {
        LoadingState.loadAndSwitchState(new PlayState());
        if (PlayState.storyPlaylist.length <= 0)
        {
        MusicBeatState.switchState(new StoryMenuState());
        }
        }
        else
        {
        MusicBeatState.switchState(new FreeplayState());
        }

        FlxG.sound.playMusic(Paths.music('freakyMenu'));
    }
}