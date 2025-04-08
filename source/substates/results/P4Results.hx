package substates.results;

import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.FreeplayState;
import states.PlayState;
import states.editors.ResultsTestState;
import backend.Highscore;
import backend.Song;
import backend.Rating;
import backend.Metadata;
import flixel.util.FlxTimer;

class P4Results extends MusicBeatSubstate
{
	var data:MetadataFile;
	var path:String = "persona/results/p4/";

	var screen:FlxSprite;

	override function create()
	{
		FlxTransitionableState.skipNextTransOut = false;
		data = PlayState.metadata;

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
		filter.blend = openfl.display.BlendMode.MULTIPLY;
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
		var percent:Float = CoolUtil.floorDecimal(99.99 * 100, 2);

		var songTxt:FlxText = new FlxText(10, 0, FlxG.width, 'Some Stupid Song By AMusician', 46);
		songTxt.setFormat(Paths.font("p4resultsfont.otf"), 36, FlxColor.BLACK);
		songTxt.scrollFactor.set();
		songTxt.updateHitbox();
		songTxt.alpha = 1;
		add(songTxt);

		var scoreTxt:FlxText = new FlxText(120, 120, FlxG.width, '1234567 PTS', 40);
		scoreTxt.setFormat(Paths.font("p4resultsfont.otf"), 48, 0xFFE37B00);
		scoreTxt.scrollFactor.set();
		scoreTxt.updateHitbox();
		scoreTxt.alpha = 0.3;
		add(scoreTxt);

		var missTxt:FlxText = new FlxText(120, 250, FlxG.width, '999', 40);
		missTxt.setFormat(Paths.font("p4resultsfont.otf"), 48, 0xFFE37B00);
		missTxt.scrollFactor.set();
		missTxt.updateHitbox();
		missTxt.alpha = 0.3;
		add(missTxt);

		var accTxt:FlxText = new FlxText(120, 380, FlxG.width, '99.99%', 40);
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

		if(!ResultsTestState.debug)
		{
		trace('not debug');
		percent = CoolUtil.floorDecimal(PlayState.instance.ratingPercent * 100, 2);
		songTxt.text = PlayState.SONG.song + ' By ' + data.credits.music;
		scoreTxt.text = '${PlayState.instance.songScore} PTS';
		missTxt.text = '${PlayState.instance.songMisses}';
		accTxt.text = '${percent}%';
		}

		if (!ResultsTestState.debug)
		{
		if (PlayState.instance.songScore > Highscore.getScore(PlayState.instance.songName, PlayState.storyDifficulty, PlayState.opponentMode)) 
		{
			new FlxTimer().start(1.3, function(tmr:FlxTimer)
			{
				highscore.visible = true;
				FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
			});
		}
		}
		else
		{
			new FlxTimer().start(1.3, function(tmr:FlxTimer)
			{
				highscore.visible = true;
				FlxG.sound.play(Paths.sound('persona/highscore'), 1.5);
			});
		}

		FlxTween.tween(yellow, {x: 0}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(beef, {x: 0, y: 0}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(filter, {x: 0}, 0.7, {ease: FlxEase.expoInOut});
		FlxTween.tween(borders, {x: 0}, 0.9, {ease: FlxEase.expoInOut});
		FlxTween.tween(items, {x: 30}, 0.3, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(scoreTxt, {x: 150, alpha: 1}, 0.6, {ease: FlxEase.expoInOut});
			FlxTween.tween(missTxt, {x: 150, alpha: 1}, 0.6, {ease: FlxEase.expoInOut});
			FlxTween.tween(accTxt, {x: 150, alpha: 1}, 0.6, {ease: FlxEase.expoInOut});
		}});
		FlxTween.tween(text, {y: 629}, 0.5, {ease: FlxEase.expoInOut});

		FlxG.sound.playMusic(Paths.music('persona/songs from the games/P4/Period'));

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			FlxTween.tween(screen, {x: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: (twn)->endResults()});
		}
	}

	public function endResults()
	{
		var percent:Float = 99.99;
		if (!ResultsTestState.debug)
		{
		var percent:Float = PlayState.instance.ratingPercent;
		if (Math.isNaN(percent)) percent = 0;
		Highscore.saveScore(PlayState.SONG.song, PlayState.instance.songScore, PlayState.storyDifficulty, percent, PlayState.opponentMode);
		}

		if (PlayState.isStoryMode) 
		{
			if (PlayState.storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				MusicBeatState.switchState(new StoryMenuState());
			}
			else
			{
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else if (ResultsTestState.debug)
		{
			FlxG.sound.music.volume = 0;
			close();
		}
		else
		{
			MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('PFAN-Electronica of the Soul'));
		}
	}
}