package substates;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
import flixel.addons.display.shapes.FlxShapeCircle;

import backend.Song;
import objects.AttachedSprite;
import states.FreeplayState.SongMetadata;

class MusicPlayerSubstate extends MusicBeatSubstate
{
	public static var songPlaylist:Array<SongMetadata> = [];
	public static var curSong(default, set):Int = 0;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var playing(get, never):Bool;
	public var playbackRate(default, set):Float = 1;
	public var loop:String = 'Disabled';
	public var autoplay:Bool = false;

	var settings:Array<Array<Dynamic>> = [
		// Name, Variable, Type, Default Value, Min Value, Max Value, Decrement Value, Increment Value, Options (for STRING and BOOL type), OnChange (Callback name, as a STRING as the real functions can't be used)
		#if FLX_PITCH
		['Playback Rate', 'playbackRate', MusicPlayerType.FLOAT, 1, 0.05, 3, 0.05, 0.05, null, null],
		#end
		['Instrumental Volume', null, MusicPlayerType.FLOAT, 1, 0, 1, 0.1, 0.1, null, 'onChangeInstVolume'],
		['Vocals Volume', null, MusicPlayerType.FLOAT, 1, 0, 1, 0.1, 0.1, null, 'onChangeVocalsVolume'],
		['Opponent Vocals Volume', null, MusicPlayerType.FLOAT, 1, 0, 1, 0.1, 0.1, null, 'onChangeOppVocalsVolume'],
		['Loop', 'loop', MusicPlayerType.STRING, 'Disabled', 0, 0, 0, 0, ['Disabled', 'Song', 'Playlist'], null],
		['Autoplay', 'autoplay', MusicPlayerType.BOOL, false, 0, 0, 0, 0, null, null]
	];

	var playerIcons:FlxSpriteGroup;
	var settingsIcons:FlxSpriteGroup;

	var curSelected:Int = 0;

	var camUI:FlxCamera;
	var camSettings:FlxCamera;
	var inSettings:Bool = false;
	var settingBox:FlxSprite;
	var settingGroup:FlxTypedSpriteGroup<MusicPlayerOption>;
	var allowScrolling:Bool = false;
	var scrollBar:FlxSprite;
	var scrollTimer:Float = 0;
	var scrollTween:FlxTween;
	var holdingBox:Bool = false;
	#if mobile var prevMouseY:Float = 0; #end

	var grpBackgrounds:FlxTypedGroup<FlxSprite>;

	var songTxt:FlxText;
	var bar:FlxBar;
	var barCircle:FlxShapeCircle;
	var previousSong:FlxSprite;
	var playButton:FlxSprite;
	var nextSong:FlxSprite;
	var settingButton:FlxSprite;
	var timeTxt:FlxText;

	var setTime:Float = 0;
	var wasPlaying:Bool = false;
	var holdingBar:Bool = false;

	var savedInstVolume:Null<Float> = null;
	var savedVocalsVolume:Null<Float> = null;
	var savedOppVocalsVolume:Null<Float> = null;

	var mask:FlxSpriteGroup;

	var backButton:BackButton;

	public function new(song:Int) {
		super();
		curSong = song;
	}

	override function create() {
		super.create();

		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		camSettings = new FlxCamera();
		camSettings.bgColor.alpha = 0;
		camSettings.visible = false;
		FlxG.cameras.add(camSettings, false);

		cameras = [camUI];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.6;
		add(bg);

		songTxt = new FlxText(0, FlxG.height / 2 - 200, FlxG.width, '', 32);
		songTxt.font = Paths.font('p5hatty-1.ttf');
		songTxt.scale.set(1.5, 1.5);
		songTxt.borderStyle = OUTLINE;
		songTxt.borderSize = 1.5;
		songTxt.alignment = CENTER;
		songTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(songTxt);

		bar = new FlxBar(0, FlxG.height - 200, null, FlxG.width - 200, 15);
		bar.numDivisions = 800;
		bar.screenCenter(X);
		bar.antialiasing = ClientPrefs.data.antialiasing;
		add(bar);

		barCircle = new FlxShapeCircle(bar.x - 5, bar.y - 5, 12, {thickness: 1}, 0xFFFFFFFF);
		barCircle.antialiasing = ClientPrefs.data.antialiasing;
		add(barCircle);

		playButton = new FlxSprite(0, bar.y + 40).loadGraphic(Paths.image('playerButtons'), true, 150, 150);
		playButton.antialiasing = ClientPrefs.data.antialiasing;
		playButton.setGraphicSize(75, 75);
		playButton.updateHitbox();
		playButton.animation.add('paused', [2]);
		playButton.animation.add('playing', [3]);
		playButton.animation.play('paused');
		playButton.x = bar.getMidpoint().x - 40;
		add(playButton);

		previousSong = new FlxSprite(playButton.x - 90, playButton.y).loadGraphic(Paths.image('playerButtons'), true, 150, 150);
		previousSong.antialiasing = ClientPrefs.data.antialiasing;
		previousSong.setGraphicSize(75, 75);
		previousSong.updateHitbox();
		previousSong.animation.add('prev', [0]);
		previousSong.animation.play('prev');
		add(previousSong);

		nextSong = new FlxSprite(playButton.x + 90, playButton.y).loadGraphic(Paths.image('playerButtons'), true, 150, 150);
		nextSong.antialiasing = ClientPrefs.data.antialiasing;
		nextSong.setGraphicSize(75, 75);
		nextSong.updateHitbox();
		nextSong.animation.add('next', [4]);
		nextSong.animation.play('next');
		add(nextSong);

		settingButton = new FlxSprite(playButton.x + 225, playButton.y + 7, Paths.image('settingButton'));
		settingButton.antialiasing = ClientPrefs.data.antialiasing;
		settingButton.setGraphicSize(60, 60);
		settingButton.updateHitbox();
		add(settingButton);

		timeTxt = new FlxText(0, FlxG.height / 2 - 125, FlxG.width, '', 32);
		timeTxt.font = Paths.font('p5hatty-1.ttf');
		timeTxt.scale.set(1.5, 1.5);
		timeTxt.borderStyle = OUTLINE;
		timeTxt.borderSize = 1.5;
		timeTxt.alignment = CENTER;
		timeTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(timeTxt);

		mask = new FlxTypedSpriteGroup();
		add(mask);

		var maskPart = new FlxSprite(0, 0, Paths.image('persona/mask/mask1'));
		maskPart.antialiasing = ClientPrefs.data.antialiasing;
		maskPart.scale.set(0.5, 0.5);
		maskPart.updateHitbox();
		maskPart.screenCenter();
		mask.add(maskPart);

		var maskPart = new FlxSprite(0, 0, Paths.image('persona/mask/mask2'));
		maskPart.antialiasing = ClientPrefs.data.antialiasing;
		maskPart.scale.set(0.5, 0.5);
		maskPart.updateHitbox();
		maskPart.screenCenter();
		mask.add(maskPart);

		var maskPart = new FlxSprite(0, 0, Paths.image('persona/mask/mask3'));
		maskPart.antialiasing = ClientPrefs.data.antialiasing;
		maskPart.scale.set(0.5, 0.5);
		maskPart.updateHitbox();
		maskPart.screenCenter();
		mask.add(maskPart);

		loadMusic(curSong);

		settingBox = new FlxSprite().makeGraphic(425, Std.int(52 * Math.min(settings.length, 6)), 0xFF000000);
		settingBox.x = settingButton.x + settingButton.width - 55;
		settingBox.y = settingButton.y - settingBox.height - 50;
		settingBox.alpha = 0.8;
		settingBox.visible = false;
		add(settingBox);

		if (settings.length > 6) allowScrolling = true;

		grpBackgrounds = new FlxTypedGroup<FlxSprite>();
		grpBackgrounds.cameras = [camSettings];
		add(grpBackgrounds);

		settingGroup = new FlxTypedSpriteGroup<MusicPlayerOption>();
		settingGroup.cameras = [camSettings];
		add(settingGroup);

		var settingOutline:AttachedSprite = new AttachedSprite();
		settingOutline.makeGraphic(Std.int(settingBox.width), Std.int(settingBox.height), 0);
		settingOutline.drawRect(0, 0, settingOutline.width, settingOutline.height, 0, {thickness: 5, color: 0xFFFFFFFF});
		settingOutline.sprTracker = settingBox;
		settingOutline.copyVisible = true;
		settingOutline.cameras = [camSettings];
		add(settingOutline);

		camSettings.x = settingBox.x;
		camSettings.y = settingBox.y;
		camSettings.width = Std.int(settingBox.width);
		camSettings.height = Std.int(settingBox.height);

		for (i in 0...settings.length) {
			if (settings[i][0] == 'Vocals Volume' && vocals == null || settings[i][0] == 'Opponent Vocals Volume' && opponentVocals == null) continue;

			var optionBG:FlxSprite = new FlxSprite(0, 10 + (50 * i)).makeGraphic(Std.int(camSettings.width), 40, 0xFF333333);
			optionBG.alpha = 0.3;
			optionBG.ID = i;
			grpBackgrounds.add(optionBG);

			var setting:MusicPlayerOption = new MusicPlayerOption(this, optionBG.x + 20, optionBG.y + 10, settings[i][0], settings[i][1], settings[i][2], camSettings.width - 50, settings[i][3], settings[i][4], settings[i][5], settings[i][6], settings[i][7], settings[i][8]);
			if (settings[i][9] != null) setting.onChange = settings[i][9];
			setting.valueText.fieldWidth = camSettings.width - setting.valueText.x - setting.rightArrow.width;
			settingGroup.add(setting);
		}

		scrollBar = new FlxSprite().makeGraphic(10, Math.round(camSettings.height * camSettings.height / settingGroup.height), 0xFFFFFFFF);
		scrollBar.x = camSettings.width - scrollBar.width;
		scrollBar.camera = camSettings;
		scrollBar.alpha = 0.6;
		scrollBar.visible = allowScrolling;
		scrollBar.scrollFactor.set();
		add(scrollBar);

		playerIcons = new FlxSpriteGroup();
		add(playerIcons);

		settingsIcons = new FlxSpriteGroup();
		settingsIcons.visible = false;
		add(settingsIcons);

		#if !mobile
		var switchIcon:KeyIcon = new KeyIcon(0, FlxG.height - 44, 'dpad_left_right', 1, 'ui_switch_song', 0.15, 24);
		playerIcons.add(switchIcon);

		var playIcon:KeyIcon = new KeyIcon(switchIcon.x + switchIcon.width + 20, FlxG.height - 44, controls.controllerMode ? 'Y' : 'SPACE', 0, 'ui_play_song', 0.15, 24);
		playerIcons.add(playIcon);

		var restartIcon:KeyIcon = new KeyIcon(playIcon.x + playIcon.width + 15, FlxG.height - 44, 'reset', 0, 'ui_restart_song', 0.15, 24);
		playerIcons.add(restartIcon);

		var settingsIcon:KeyIcon = new KeyIcon(restartIcon.x + restartIcon.width + 15, FlxG.height - 44, controls.controllerMode ? 'START' : 'TAB', 0, 'ui_open_settings', 0.15, 24);
		playerIcons.add(settingsIcon);

		var backIcon:KeyIcon = new KeyIcon(settingsIcon.x + settingsIcon.width + 15, FlxG.height - 44, 'back', 0, 'ui_back', 0.15, 24);
		playerIcons.add(backIcon);

		var selectIcon:KeyIcon = new KeyIcon(0, FlxG.height - 44, 'dpad', 1, 'ui_select', 0.15, 24);
		settingsIcons.add(selectIcon);

		var backIcon:KeyIcon = new KeyIcon(selectIcon.x + selectIcon.width + 20, FlxG.height - 44, 'back', 0, 'ui_back', 0.15, 24);
		settingsIcons.add(backIcon);
		#end

		backButton = new BackButton();
		add(backButton);

		FlxG.autoPause = false;

		playMusic();
		#if !mobile
		changeSelection(0);
		#end
	}

	override function update(elapsed:Float) {
		if (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end) {
			if ((controls.BACK #if android || FlxG.android.justReleased.BACK #end) && inSettings) {
				goToSettings(false);
			}
			else {
				stopMusic();
				close();
			}
		}

		if (inSettings) {
			scrollTimer += elapsed;
			if (TouchUtil.justPressed && !TouchUtil.overlaps(settingBox)) {
				goToSettings(false);
				if (allowScrolling) {
					scrollTimer = 0;
					if (scrollTween != null) scrollTween.cancel();
					scrollTween = null;
					scrollBar.alpha = 0.6;
					scrollBar.y = 0;
					camSettings.scroll.y = 0;
					#if mobile prevMouseY = 0; #end
					holdingBox = false;
				}
			}

			#if !mobile
			if (FlxG.mouse.justMoved) {
				for (bg in grpBackgrounds) {
					if (FlxG.mouse.overlaps(bg, camSettings) && curSelected != bg.ID) {
						changeSelection(bg.ID);
					}
				}
			}

			// i'm too lazy to make this scroll the camera screw you
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				changeSelection(curSelected + (controls.UI_DOWN_P ? 1 : -1));
			}

			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				controls.UI_LEFT_P ? settingGroup.members[curSelected].decrement() : settingGroup.members[curSelected].increment();
			}
			#end

			if (allowScrolling) {
				if (scrollTimer >= 1 && scrollTween == null) {
					scrollTween = FlxTween.tween(scrollBar, { alpha: 0 }, 0.25);
				}
				#if !mobile
				if (FlxG.mouse.wheel != 0) {
					var val:Float = -FlxG.mouse.wheel * 13;
					camSettings.scroll.y += val;
					if (scrollTween != null) {
						scrollTween.cancel();
						scrollTween = null;
					}
					scrollBar.alpha = 0.6;
					scrollBar.y += val * (camSettings.height / (settingGroup.height + 30));
					scrollTimer = 0;
				}
				#end
				if (TouchUtil.pressed && (TouchUtil.overlaps(settingBox, camUI) || holdingBox)) {
					if (TouchUtil.justPressed) {
						holdingBox = true;
						#if mobile prevMouseY += TouchUtil.input.viewY; #end
					}
					#if !mobile
					var val:Float = camSettings.scroll.y - FlxG.mouse.deltaViewY;
					#else
					var val:Float = prevMouseY - TouchUtil.input.viewY;
					#end
					camSettings.scroll.y = val;
					if (scrollTween != null) {
						scrollTween.cancel();
						scrollTween = null;
					}
					scrollBar.alpha = 0.6;
					scrollBar.y = val * (camSettings.height / (settingGroup.height + 30));
					scrollTimer = 0;
				}
				if (TouchUtil.justReleased && holdingBox) {
					holdingBox = false;
					#if mobile prevMouseY = FlxMath.bound(camSettings.scroll.y, 0, settingGroup.height - camSettings.height + 30); #end
				}

				camSettings.scroll.y = FlxMath.bound(camSettings.scroll.y, 0, settingGroup.height - camSettings.height + 30);
				scrollBar.y = FlxMath.bound(scrollBar.y, 0, camSettings.height - scrollBar.height);
			}
		}
		else {
			if (TouchUtil.justPressed && TouchUtil.overlaps(settingButton) || FlxG.keys.justPressed.TAB || FlxG.gamepads.anyJustPressed(START)) {
				goToSettings();
			}

			if (TouchUtil.justPressed && TouchUtil.overlaps(bar) || TouchUtil.pressed && holdingBar) {
				if (playing) {
					wasPlaying = true;
					pauseMusic();
				}
				if (!holdingBar) holdingBar = true;
				var touchX = TouchUtil.input.getScreenPosition(FlxG.camera).x;
				bar.percent = FlxMath.bound((touchX - bar.x) / bar.width * 100, bar.min, bar.max);
				barCircle.x = touchX - 5;
				setMusicTime(FlxMath.bound((touchX - bar.x) / bar.width * inst.length, 0, inst.length));
				timeTxt.text = FlxStringUtil.formatTime(inst.time / 1000) + ' - ' + FlxStringUtil.formatTime(inst.length / 1000);
			}
			else if (holdingBar) {
				holdingBar = false;
				var time = inst.time;
				if (inst != null && time >= inst.length) stopMusic();
				if (wasPlaying) {
					wasPlaying = false;
					if (inst != null) {
						if (time < inst.length) playMusic();
						else if (inst.onComplete != null) inst.onComplete();
					}
				}
			}

			if (TouchUtil.overlaps(playButton) && TouchUtil.justPressed || FlxG.keys.justPressed.SPACE || FlxG.gamepads.anyJustPressed(Y)) {
				if (playing) pauseMusic();
				else playMusic();
			}
			if (songPlaylist.length > 1 && ((TouchUtil.overlaps(previousSong) || TouchUtil.overlaps(nextSong)) && TouchUtil.justPressed || (controls.UI_LEFT_P || controls.UI_RIGHT_P))) {
				stopMusic();
				if (TouchUtil.overlaps(previousSong) || controls.UI_LEFT_P) curSong--;
				else if (TouchUtil.overlaps(nextSong) || controls.UI_RIGHT_P) curSong++;
				loadMusic(curSong);
				playMusic();
			}
			if (controls.RESET) {
				setMusicTime(0);
				playMusic();
			}
		}

		if (playing) updateTime(inst.time);
		barCircle.x = FlxMath.bound(barCircle.x, bar.x - 5, bar.x + bar.width - 5);
		super.update(elapsed);
	}

	override function destroy() {
		FlxG.autoPause = ClientPrefs.data.autoPause;
		super.destroy();
	}

	public function updateTime(time:Float) {
		if (inst == null) return;
		bar.percent = (time / inst.length) * 100;
		@:privateAccess
		barCircle.x = bar.x + bar._filledBarRect.width - 5;
		timeTxt.text = FlxStringUtil.formatTime(time / 1000) + ' - ' + FlxStringUtil.formatTime(inst.length / 1000);
	}

	public function loadMusic(song:Int) {
		if (songPlaylist.length < 1) return;
		song = FlxMath.wrap(song, 0, songPlaylist.length - 1);
		var chart = Song.getChart(songPlaylist[song].songName, songPlaylist[song].songName);
		if (inst == null) inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(songPlaylist[song].songName));
		FlxG.sound.list.add(inst);
		if (savedInstVolume != null) inst.volume = savedInstVolume;
		inst.onComplete = ()->new FlxTimer().start(0.0001, t->onMusicFinished());
		inst.play();
		inst.pause();
		if (chart.needsVoices) {
			if (vocals == null) vocals = new FlxSound();
			try {
				var playerVocals:String = getVocalFromCharacter(chart.player1);
				var loadedVocals = Paths.voices(chart.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
				if (loadedVocals == null) loadedVocals = Paths.voices(chart.song);
						
				if (loadedVocals != null && loadedVocals.length > 0) {
					vocals.loadEmbedded(loadedVocals);
					FlxG.sound.list.add(vocals);
					if (savedVocalsVolume != null) vocals.volume = savedVocalsVolume;
					vocals.play();
					vocals.pause();
				}
				else vocals = FlxDestroyUtil.destroy(vocals);
			}
			catch(e:Dynamic) {
				vocals = FlxDestroyUtil.destroy(vocals);
			}
					
			if (opponentVocals == null) opponentVocals = new FlxSound();
			try {
				var oppVocals:String = getVocalFromCharacter(chart.player2);
				var loadedVocals = Paths.voices(chart.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
				if (loadedVocals != null && loadedVocals.length > 0) {
					opponentVocals.loadEmbedded(loadedVocals);
					FlxG.sound.list.add(opponentVocals);
					if (savedOppVocalsVolume != null) opponentVocals.volume = savedOppVocalsVolume;
					opponentVocals.play();
					opponentVocals.pause();
				}
				else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
			}
			catch(e:Dynamic) {
				opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
			}
		}
		else {
			if (vocals != null) vocals = FlxDestroyUtil.destroy(vocals);
			if (opponentVocals != null) opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
		}
		playbackRate = playbackRate; // repitch music
		songTxt.text = chart.song;
		recolor(songPlaylist[song].color);
		updateTime(inst.time);
	}

	public function onMusicFinished() {
		if (loop == 'Song') {
			stopMusic();
			playMusic();
		}
		else if (autoplay && curSong < songPlaylist.length - 1) {
			stopMusic();
			curSong++;
			loadMusic(curSong);
			playMusic();
		}
		else if (loop == 'Playlist' && curSong == songPlaylist.length - 1) {
			stopMusic();
			curSong = 0;
			loadMusic(curSong);
			playMusic();
		}
		else if (loop == 'Disabled' || autoplay && curSong == songPlaylist.length - 1) {
			stopMusic();
			updateTime(inst.length);
		}
	}

	public function recolor(color:FlxColor) {
		bar.createFilledBar(0xFF555555, color);
		barCircle.fillColor = color;
		mask.members[2].color = color;
	}

	public function playMusic() {
		if (inst == null) return;
		playButton.animation.play('playing');
		playButton.centerOffsets();
		playButton.offset.x -= 5;
		if (setTime > -1) {
			inst.play(false, setTime);
			if (vocals != null) vocals.play(false, setTime);
			if (opponentVocals != null) opponentVocals.play(false, setTime);
			setTime = -1;
		}
		else {
			inst.play();
			if (vocals != null) vocals.play();
			if (opponentVocals != null) opponentVocals.play();
		}
	}

	public function pauseMusic() {
		if (inst == null) return;
		playButton.animation.play('paused');
		playButton.centerOffsets();
		inst.pause();
		if (vocals != null) vocals.pause();
		if (opponentVocals != null) opponentVocals.pause();
	}

	public function stopMusic() {
		if (inst == null) return;
		playButton.animation.play('paused');
		playButton.centerOffsets();
		setTime = -1;
		inst.stop();
		if (vocals != null) vocals.stop();
		if (opponentVocals != null) opponentVocals.stop();
	}

	public function setMusicTime(time:Float) {
		if (inst == null) return;
		time = Math.max(time, 0);
		setTime = time;
		inst.time = time;
		if (vocals != null) vocals.time = time;
		if (opponentVocals != null) opponentVocals.time = time;
	}

	public function goToSettings(value:Bool = true) {
		inSettings = settingsIcons.visible = settingBox.visible = camSettings.visible = value;
		playerIcons.visible = !value;
	}

	function changeSelection(option:Int = 0) {
		if (option < 0 || option > settings.length - 1) return;
		// can't use null-safe field access?
		if (grpBackgrounds.members[curSelected] != null) grpBackgrounds.members[curSelected].alpha = 0.3;
		curSelected = option;
		if (grpBackgrounds.members[curSelected] != null) grpBackgrounds.members[curSelected].alpha = 0.6;
	}

	function getVocalFromCharacter(char:String) {
		try {
			var path:String = Paths.getPath('characters/$char.json');
			#if MODS_ALLOWED
			var character:Dynamic = haxe.Json.parse(File.getContent(path));
			#else
			var character:Dynamic = haxe.Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	function onChangeInstVolume(value:Dynamic) {
		if (inst != null) savedInstVolume = inst.volume = value;
	}

	function onChangeVocalsVolume(value:Dynamic) {
		if (vocals != null) savedVocalsVolume = vocals.volume = value;
	}

	function onChangeOppVocalsVolume(value:Dynamic) {
		if (opponentVocals != null) savedOppVocalsVolume = opponentVocals.volume = value;
	}

	static function set_curSong(value:Int):Int {
		return curSong = FlxMath.wrap(value, 0, Std.int(Math.max(songPlaylist.length - 1, 0)));
	}

	function get_playing():Bool {
		return inst != null ? inst.playing : false;
	}

	function set_playbackRate(value:Float):Float {
		#if FLX_PITCH
		if (inst != null) {
			inst.pitch = value;
			if (vocals != null) vocals.pitch = value;
			if (opponentVocals != null) opponentVocals.pitch = value;
		}
		#end
		return playbackRate = value;
	}
}

enum MusicPlayerType
{
	STRING;
	INT;
	FLOAT;
	BOOL;
}

class MusicPlayerOption extends FlxTypedSpriteGroup<FlxText>
{
	public var instance:MusicPlayerSubstate;
	public var name:String;
	public var variable:String;
	public var type:MusicPlayerType;
	public var options:Array<String> = [];
	public var curValue:Dynamic;
	public var minValue:Float;
	public var maxValue:Float;
	public var decrementValue:Float;
	public var incrementValue:Float;
	public var onChange:String;

	public var optionText:FlxText;
	public var valueText:FlxText;
	public var leftArrow:FlxText;
	public var rightArrow:FlxText;

	public function new(instance:MusicPlayerSubstate = null, x:Float = 0, y:Float = 0, name:String = '', variable:String = '', type:MusicPlayerType = FLOAT, textWidth:Float = 0, defaultValue:Dynamic = null, minValue:Float = 0, maxValue:Float = 1, decrementValue:Float = 0.1, incrementValue:Float = 0.1, options:Array<String> = null) {
		super(x, y);
		this.instance = instance;
		this.name = name;
		this.variable = variable;
		this.type = type;
		this.curValue = defaultValue;
		if (options != null) this.options = options;
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.decrementValue = decrementValue;
		this.incrementValue = incrementValue;

		if (type == STRING && !this.options.contains(defaultValue)) this.options.insert(0, defaultValue);

		optionText = new FlxText(0, 0, textWidth, Language.getPhrase('musicplayer_setting_$name', name), 28);
		optionText.font = Paths.font('p5hatty-1.ttf');
		optionText.borderStyle = OUTLINE;
		optionText.borderSize = 1.5;
		optionText.antialiasing = ClientPrefs.data.antialiasing;
		add(optionText);

		leftArrow = new FlxText(optionText.textField.textWidth + 15, -3, 30, '<', 36);
		leftArrow.font = Paths.font('p5hatty-1.ttf');
		leftArrow.borderStyle = OUTLINE;
		leftArrow.borderSize = 1.5;
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		add(leftArrow);

		valueText = new FlxText(optionText.textField.textWidth + leftArrow.textField.textWidth + 30, 1, 0, '', 28);
		valueText.font = Paths.font('p5hatty-1.ttf');
		valueText.borderStyle = OUTLINE;
		valueText.borderSize = 1.5;
		valueText.antialiasing = ClientPrefs.data.antialiasing;
		add(valueText);

		rightArrow = new FlxText(0, -3, 30, '>', 36);
		rightArrow.font = Paths.font('p5hatty-1.ttf');
		rightArrow.borderStyle = OUTLINE;
		rightArrow.borderSize = 1.5;
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		add(rightArrow);

		setValue(defaultValue);
	}

	override function update(elapsed:Float) {
		if (TouchUtil.justPressed) {
			if (TouchUtil.overlaps(leftArrow, camera, FlxPoint.get(-5, -2))) decrement();
			else if (TouchUtil.overlaps(rightArrow, camera, FlxPoint.get(-5, -2))) increment();
		}
		super.update(elapsed);
	}

	public function decrement() {
		if (type == STRING) {
			setValue(options[FlxMath.wrap(Std.int(options.indexOf(curValue) - 1), 0, Std.int(options.length - 1))]);
		}
		else if (type == INT || type == FLOAT) {
			setValue(curValue - decrementValue);
		}
		else if (type == BOOL) {
			setValue(!curValue);
		}
	}

	public function increment() {
		if (type == STRING) {
			setValue(options[FlxMath.wrap(Std.int(options.indexOf(curValue) + 1), 0, Std.int(options.length - 1))]);
		}
		else if (type == INT || type == FLOAT) {
			setValue(curValue + incrementValue);
		}
		else if (type == BOOL) {
			setValue(!curValue);
		}
	}
	
	public function setValue(value:Dynamic) {
		if (type == INT || type == FLOAT) value = FlxMath.bound(FlxMath.roundDecimal(value, 2), minValue, maxValue);
		curValue = value;
		updateValueText();
		if (instance != null && variable != null && variable.length > 0) Reflect.setProperty(instance, variable, value);
		if (instance != null && onChange != null && onChange.length > 0) Reflect.callMethod(instance, Reflect.getProperty(instance, onChange), [value]);
	}

	public function updateValueText() {
		var value:String = Std.string(curValue);
		if (type == STRING) value = Language.getPhrase('musicplayer_setting_$name-$curValue', curValue);
		else if (type == BOOL) value = Language.getPhrase(curValue == true ? 'On' : 'Off');
		valueText.text = value;
		rightArrow.x = valueText.x + valueText.textField.textWidth + 15;
	}
}