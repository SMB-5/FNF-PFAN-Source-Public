package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.Metadata;

import flixel.FlxObject;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;
import substates.StickerSubState;

class PauseSubState extends MusicBeatSubstate
{
	var pauseItems:Array<String> = ['Resume', 'Restart', 'Config', 'Exit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var data:MetadataFile;
	var creditArt:FlxText;
	var creditCode:FlxText;
	var creditChart:FlxText;

	var pauseButtons:FlxTypedGroup<FlxSprite>;
	var buttonHitboxes:Array<FlxObject> = [];
	var buttonsBG:FlxSprite;
	var buttonsBG2:FlxSprite;
	var back1:FlxSprite;
	var back2:FlxSprite;
	var back3:FlxSprite;
	var block1:FlxSprite;
	var block2:FlxSprite;
	var block3:FlxSprite;

	var tweens:Array<FlxTween> = [];

	override function create()
	{
		#if !mobile FlxG.mouse.visible = true; #end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('persona/songs from the games/P5/Have a Short Rest'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		data = PlayState.metadata;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		back1 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/bg1'));
		back1.antialiasing = ClientPrefs.data.antialiasing;
		add(back1);

		back2 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/bg2'));
		back2.antialiasing = ClientPrefs.data.antialiasing;
		back2.x = FlxG.width - back2.width;
		add(back2);

		back3 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/bg3'));
		back3.antialiasing = ClientPrefs.data.antialiasing;
		back3.x = FlxG.width - back3.width;
		back3.y = FlxG.height - back3.height;
		add(back3);

		block1 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/block1'));
		block1.antialiasing = ClientPrefs.data.antialiasing;
		add(block1);

		block2 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/block2'));
		block2.antialiasing = ClientPrefs.data.antialiasing;
		block2.x = FlxG.width - block2.width;
		add(block2);

		block3 = new FlxSprite(0, 0, Paths.image('persona/menus/pause/block3'));
		block3.antialiasing = ClientPrefs.data.antialiasing;
		block3.x = FlxG.width - block3.width;
		block3.y = FlxG.height - block3.height;
		add(block3);

		buttonsBG = new FlxSprite(0, 110, Paths.image('persona/menus/pause/buttonsback'));
		buttonsBG.antialiasing = ClientPrefs.data.antialiasing;
		add(buttonsBG);

		buttonsBG2 = new FlxSprite(50, 135, Paths.image('persona/menus/pause/buttonsback2'));
		buttonsBG2.antialiasing = ClientPrefs.data.antialiasing;
		add(buttonsBG2);

		var levelInfo:FlxText = new FlxText(35, 0, 0, PlayState.SONG.song + ' - Unknown', 24);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('ANDYB.TTF'), 18, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.alpha = 0;
		add(levelInfo);

		creditArt = new FlxText(865, 0, 0, "Art: Unknown", 24);
		creditArt.scrollFactor.set();
		creditArt.setFormat(Paths.font('ANDYB.TTF'), 18, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditArt.alpha = 0;
		add(creditArt);

		creditCode = new FlxText(920, 72, 0, "Code: Unknown", 24);
		creditCode.scrollFactor.set();
		creditCode.setFormat(Paths.font('ANDYB.TTF'), 18, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditCode.alpha = 0;
		add(creditCode);

		creditChart = new FlxText(60, 70, 0, "Chart: Unknown", 24);
		creditChart.scrollFactor.set();
		creditChart.setFormat(Paths.font('ANDYB.TTF'), 14, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditChart.alpha = 0;
		add(creditChart);

		if (CoolUtil.exists(Paths.json(PlayState.instance.songName + "/metadata")))
		{
			levelInfo.text = PlayState.SONG.song + ' - ' + data.credits.music;
			creditArt.text = 'Art: ${data.credits.art}';
			creditCode.text = 'Code: ${data.credits.code}';
			creditChart.text = 'Chart: ${data.credits.chart}';
		}

		var descTxt = new FlxText(675, 520, 600, "Nice Description you got there. Oh wait this only shows when it does not exist so where is it?", 20);
		descTxt.scrollFactor.set();
		descTxt.setFormat(Paths.font('ANDYB.TTF'), 20, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (CoolUtil.exists(Paths.txt(PlayState.instance.songName + "/desc"))) {
			descTxt.text = Language.getPhrase('desc_${PlayState.instance.songName}', CoolUtil.getText(Paths.txt(PlayState.instance.songName + "/desc")));
		}
		descTxt.text += "\n";
		descTxt.angle += 2;
		descTxt.alpha = 0;
		add(descTxt);

		back1.x -= back1.width;
		back2.x += back2.width;
		back3.x += back3.width;
		block1.x -= block1.width;
		block2.x += block2.width;
		block3.x += block3.width;
		buttonsBG.y += FlxG.height;
		buttonsBG2.y += FlxG.height;

		startTween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		startTween(back1, {x: back1.x + back1.width}, 0.35, {ease: FlxEase.cubeInOut});
		startTween(back2, {x: back2.x - back2.width}, 0.35, {ease: FlxEase.cubeInOut, startDelay: 0.15});
		startTween(back3, {x: back3.x - back3.width}, 0.35, {ease: FlxEase.cubeInOut, startDelay: 0.3});
		startTween(block1, {x: block1.x + block1.width}, 0.35, {ease: FlxEase.cubeInOut, startDelay: 0.15});
		startTween(block2, {x: block2.x - block2.width}, 0.35, {ease: FlxEase.cubeInOut, startDelay: 0.3});
		startTween(block3, {x: block3.x - block3.width}, 0.35, {ease: FlxEase.cubeInOut, startDelay: 0.45});
		startTween(buttonsBG, {y: buttonsBG.y - FlxG.height}, 0.65, {ease: FlxEase.quintOut});
		startTween(buttonsBG2, {y: buttonsBG2.y - FlxG.height}, 0.65, {ease: FlxEase.quintOut, startDelay: 0.05});
		startTween(levelInfo, {alpha: 1, y: levelInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		startTween(descTxt, {alpha: 1, y: descTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		startTween(creditArt, {alpha: 1, y: creditArt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.45});
		startTween(creditCode, {alpha: 1, y: creditCode.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.45});
		startTween(creditChart, {alpha: 1, y: creditChart.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.4});

		pauseButtons = new FlxTypedGroup<FlxSprite>();
		add(pauseButtons);

		for (i in 0...pauseItems.length)
		{
			var spacing:Float = 80;
			var pauseButton:FlxSprite = new FlxSprite(30, (i > 0 ? 70 : 0) + 150 + i * spacing);
			pauseButton.frames = Paths.getSparrowAtlas('persona/menus/pause/pause_' + pauseItems[i]);
			pauseButton.animation.addByPrefix('idle', 'unselected', 24);
			pauseButton.animation.addByPrefix('selected', 'selected', 24);
			pauseButton.animation.play('idle');
			pauseButton.antialiasing = ClientPrefs.data.antialiasing;
			pauseButton.ID = i;
			pauseButtons.add(pauseButton);

			var angle = 0;
			var width = pauseButton.width;
			var height = pauseButton.height;
			var x = pauseButton.x;
			var y = pauseButton.y;
			switch(i) {
				case 0:
					angle = 15;
					width -= 40;
					height -= 50;
					x += 30;
					y += 50;
				case 1:
					angle = 3;
					height -= 10;
					x += 5;
					y += 10;
				case 2:
					angle = -10;
					height -= 50;
					y += 15;
				case 3:
					angle = -20;
					height -= 145;
					x += 3;
					y += 58;
			}

			var hitbox = new FlxObject(x, y, width, height);
			hitbox.ID = i;
			hitbox.angle = angle;
			add(hitbox);
			buttonHitboxes.push(hitbox);

			pauseButton.y += FlxG.height;
			startTween(pauseButton, { y: pauseButton.y - FlxG.height }, 0.75, { ease: FlxEase.quintOut, startDelay: 0.05 * i });
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		if(controls.BACK)
		{
			close();
			return;
		}

		var pressedAccept:Bool = controls.ACCEPT;
		for (i in 0...buttonHitboxes.length) {
			// backwards loop so that lower hitboxes will have higher priority on touch
			var k = Std.int(Math.abs(i - buttonHitboxes.length) - 1);
			if (TouchUtil.input != null) {
				if (TouchUtil.input.overlaps(buttonHitboxes[k], camera)) {
					#if mobile if (TouchUtil.input.justPressed) { #end
					if (curSelected != buttonHitboxes[k].ID) {
						curSelected = buttonHitboxes[k].ID;
						changeSelection();
					}
					else #if !mobile if (TouchUtil.input.justPressed) #end {
						pressedAccept = true;
					}
					#if mobile } #end
					break;
				}
			}
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (pressedAccept && (cantUnpause <= 0 || !controls.controllerMode))
		{
			switch (pauseItems[curSelected])
			{
				case "Resume":
					close();
				case "Restart":
					restartSong();
				case 'Config':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					FlxG.sound.playMusic(Paths.music('persona/songs from the games/P5/Have a Short Rest'));
					FlxG.sound.music.time = pauseMusic.time;
					FlxG.sound.music.volume = pauseMusic.volume;
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
					OptionsState.onPlayState = true;
				case "Exit":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					Mods.loadTopMod();
					if(PlayState.isStoryMode)
					{
						MusicBeatState.switchState(new StoryMenuState());
					}
					else 
					{
						openSubState(new StickerSubState(null, (sticker) -> new FreeplayState(sticker)));
					}

					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}

		super.update(elapsed);
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	function startTween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions) {
		var tween = FlxTween.tween(Object, Values, Duration, Options);
		tweens.push(tween);
		return tween;
	}

	override function destroy()
	{
		// flixel sucks ass because i can't use cancelTweensOf without it crashing for some reason
		for (tween in tweens) tween.cancel();
		pauseMusic.destroy();
		#if !mobile FlxG.mouse.visible = false; #end
		FlxG.inputs.reset();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, pauseItems.length - 1);
		pauseButtons.forEach(spr->spr.animation.play(spr.ID == curSelected ? 'selected' : 'idle'));
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
}
