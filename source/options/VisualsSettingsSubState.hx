package options;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;

class VisualsSettingsSubState extends BaseOptionsMenu
{
	public function new() {
		title = Language.getPhrase('visuals_menu', 'VISUALS');
		rpcTitle = 'Visuals Settings Menu'; //for Discord Rich Presence

		var noteSkins:Array<String> = [ClientPrefs.defaultData.noteSkin].concat(Mods.mergeAllTextsNamed('images/noteSkins/list.txt'));
		if (!noteSkins.contains(ClientPrefs.data.noteSkin)) {
			ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; // Reset to default if saved noteskin couldnt be found
		}

		var option:Option = new Option('Note Skin',
			'Select your preferred note skin.',
			'noteSkin',
			STRING,
			ClientPrefs.defaultData.noteSkin, noteSkins);
		addOption(option);
		option.onPreview = onPreviewNoteSkin;
		
		var noteSplashes:Array<String> = [ClientPrefs.defaultData.splashSkin].concat(Mods.mergeAllTextsNamed('images/noteSplashes/list.txt'));
		if (!noteSplashes.contains(ClientPrefs.data.splashSkin)) {
			ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; // Reset to default if saved splashskin couldnt be found
		}

		var option:Option = new Option('Note Splash',
			'Select your preferred note splash variation.',
			'splashSkin',
			STRING,
			ClientPrefs.defaultData.splashSkin, noteSplashes);
		addOption(option);
		option.onPreview = onPreviewSplashSkin;

		var option:Option = new Option('Note Splash Opacity',
			'How transparent should the note splashes be?',
			'splashAlpha',
			PERCENT);
		addOption(option);
		option.onPreview = onPreviewSplashSkin;

		var option:Option = new Option('Hold Note Splashes',
			'Enables splashes when holding down a sustain note.',
			'holdSplash',
			BOOL);
		addOption(option);

		var option:Option = new Option('Note Quantization',
			'Colors the notes based on their snap.',
			'noteQuantization',
			BOOL);
		option.customizable = true;
		option.customizationClass = options.QuantizationColorSubstate;
		addOption(option);

		var option:Option = new Option('Character Note Colors',
			'Enables custom note colors for characters.',
			'charRGB',
			BOOL);
		addOption(option);

		var option:Option = new Option('Strum Background Opacity',
			'How transparent should the Strumline Background be?',
			'strumlineBGAlpha',
			PERCENT);
		addOption(option);

		var option:Option = new Option('Strum Background Over HUD',
			'Should the Strumline Background be over the HUD?',
			'strumlineBGHUD',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'Hides most HUD elements.',
			'hideHud',
			BOOL);
		addOption(option);

		var option:Option = new Option('Show Misses and Accuracy',
			'Shows the misses and accuracy in the score text.\nDisabling this returns the HUD to the Base Game HUD.',
			'psychScore',
			BOOL);
		addOption(option);
		
		var option:Option = new Option('Time Bar Display',
			'What should the Time Bar display?',
			'timeBarType',
			STRING,
			'Time Left', ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Subtitles',
			'Shows subtitles if a character speaks.',
			'subtitles',
			BOOL);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			'Enables flashing lights.\nNot recommended to be enabled if you\'re photosensitive!',
			'flashing',
			BOOL);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			'Zooms the camera on beat hits.',
			'camZooms',
			BOOL);
		addOption(option);

		var option:Option = new Option('Score Text Grow on Hit',
			'Grows the score text each time you hit a note.',
			'scoreZoom',
			BOOL);
		addOption(option);

		var option:Option = new Option('Health Bar Colors',
			'Uses the respective character\'s icon color for the health bar instead of the usual red and green.',
			'healthBarColors',
			BOOL);
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
			'How transparent should the health bar and icons be?',
			'healthBarAlpha',
			PERCENT);
		addOption(option);
		
		var option:Option = new Option('FPS Counter',
			'Shows the FPS and RAM usage at the top left.',
			'showFPS',
			BOOL);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'Checks for any new updates to the mod upon launching the game.',
			'checkForUpdates',
			BOOL);
		addOption(option);
		#end

		#if DISCORD_ALLOWED
		var option:Option = new Option('Discord Rich Presence',
			'Shows Discord RPC on your profile while playing the mod.',
			'discordRPC',
			BOOL);
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			'Stacks the ratings.\nCan increase performance if enabled.',
			'comboStacking',
			BOOL);
		addOption(option);

		super();
	}

	function onPreviewNoteSkin() {
		openSubState(new NotePreviewSubstate());
	}

	function onPreviewSplashSkin() {
		openSubState(new SplashPreviewSubstate());
	}

	function onChangeFPSCounter() {
		if (Main.fpsVar != null) {
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
		}
	}
}

class NotePreviewSubstate extends MusicBeatSubstate
{
	var camUI:FlxCamera;
	var bg:FlxSprite;
	var strums:FlxTypedGroup<StrumNote>;

	var selector:FlxSprite;
	var usingSelector:Bool = false;
	var curSelected:Int = 0;

	var backButton:BackButton;

	override function create() {
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		cameras = [camUI];

		var darkBG:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		darkBG.scale.set(FlxG.width, FlxG.height);
		darkBG.updateHitbox();
		darkBG.alpha = 0.6;
		add(darkBG);

		bg = new FlxSprite().makeGraphic(600, 600, 0xFF454545);
		bg.screenCenter();
		bg.drawRect(0, 0, bg.width, bg.height, 0, {thickness: 10, color: 0xFFFFFFFF});
		add(bg);

		strums = new FlxTypedGroup<StrumNote>();
		add(strums);

		for (i in 0...4) {
			var strum:StrumNote = new StrumNote(bg.x + 20 + (150 * i), bg.y + 20, i, 0);
			strums.add(strum);

			var note:Note = new Note(0, i, null, false);
			note.setPosition(bg.x + 20 + (150 * i), bg.y + 170);
			add(note);

			var sus:Note = new Note(0, i, null, true);
			sus.setPosition(note.x + (note.width - sus.width) / 2, bg.y + 320);
			sus.setGraphicSize(sus.width, 125);
			sus.updateHitbox();
			add(sus);

			var end:Note = new Note(0, i, null, true);
			end.setPosition(note.x + (note.width - sus.width) / 2, bg.y + 500);
			end.animation.play(Note.colArray[i] + 'holdend');
			end.setGraphicSize(end.width, 50);
			end.updateHitbox();
			add(end);
		}

		selector = new FlxSprite();
		selector.visible = false;
		add(selector);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad_left_right', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_play_animation', 0.15, 24);
		add(acceptIcon);

		var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 10, FlxG.height - 44, 'back', 0, 'ui_back', 0.15, 24);
		add(backIcon);
		#end

		backButton = new BackButton();
		backButton.x += 50;
		add(backButton);

		#if !mobile
		if (controls.controllerMode) {
			changeSelection(0);
		}
		#end

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}

		#if !mobile
		if (FlxG.mouse.justMoved && usingSelector) {
			usingSelector = selector.visible = false;
			strums.members[curSelected].playAnim('static');
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			changeSelection(curSelected + (controls.UI_LEFT_P ? -1 : 1));
		}

		if (controls.ACCEPT) {
			if (!usingSelector) changeSelection(0);
			strums.members[curSelected].playAnim('confirm');
		}
		#end

		for (strum in strums) {
			if (TouchUtil.overlaps(strum, camUI)) {
				if (strum.animation.name != 'pressed' && strum.animation.name != 'confirm') {
					strum.playAnim('pressed');
				}
				if (TouchUtil.justPressed) {
					if (strum.animation.name != 'confirm') {
						strum.playAnim('confirm');
					}
				}
				if (TouchUtil.released && strum.animation.name == 'confirm' && strum.animation.finished) {
					strum.playAnim('static');
				}
			}
			else if (strum.animation.name == 'confirm' && strum.animation.finished || !usingSelector && strum.animation.name == 'pressed') {
				if (usingSelector) strum.playAnim('pressed');
				else strum.playAnim('static');
			}
		}

		super.update(elapsed);
	}

	override function destroy() {
		FlxG.cameras.remove(camUI);
		Note.globalRgbShaders = [];
		super.destroy();
	}

	function changeSelection(option:Int) {
		var value:Int = Std.int(FlxMath.bound(!usingSelector ? curSelected : option, 0, 3));
		if (value != curSelected || !usingSelector) {
			strums.members[curSelected].playAnim('static');
			strums.members[value].playAnim('pressed');
		}
		curSelected = value;
		usingSelector = true;
		selector.visible = true;
		selector.makeGraphic(Std.int(strums.members[curSelected].width + 20), Std.int(strums.members[curSelected].height + 20), 0);
		selector.drawRect(0, 0, selector.width, selector.height, 0, {thickness: 10, color: 0xFFFFFF00});
		selector.setPosition(strums.members[curSelected].x - 10, strums.members[curSelected].y - 10);
	}
}

class SplashPreviewSubstate extends MusicBeatSubstate
{
	var camUI:FlxCamera;
	var bg:FlxSprite;
	var strums:FlxTypedGroup<StrumNote>;
	var splashes:FlxTypedGroup<NoteSplash>;
	var leftArrow:FlxText;
	var rightArrow:FlxText;
	var curOption:FlxText;
	var setTxt:FlxText;

	var selector:FlxSprite;
	var usingSelector:Bool = false;
	var curSelected:Int = 0;
	var onAnimOption:Bool = false;

	var backButton:BackButton;

	override function create() {
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		cameras = [camUI];

		var darkBG:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		darkBG.scale.set(FlxG.width, FlxG.height);
		darkBG.updateHitbox();
		darkBG.alpha = 0.6;
		add(darkBG);

		bg = new FlxSprite().makeGraphic(600, 250, 0xFF454545);
		bg.screenCenter();
		bg.drawRect(0, 0, bg.width, bg.height, 0, {thickness: 10, color: 0xFFFFFFFF});
		add(bg);

		strums = new FlxTypedGroup<StrumNote>();
		add(strums);

		splashes = new FlxTypedGroup<NoteSplash>();
		add(splashes);

		for (i in 0...4) {
			var strum:StrumNote = new StrumNote(bg.x + 20 + (150 * i), bg.y + 120, i, 0);
			strums.add(strum);

			var splash:NoteSplash = new NoteSplash(0, 0);
			splash.babyArrow = strum;
			splash.spawnSplashNote(0, 0, i, null, false);
			splashes.add(splash);
		}

		leftArrow = new FlxText(bg.x + 210, bg.y + 60, 0, '<', 40);
		leftArrow.font = Paths.font('Fontsona3FES.ttf');
		add(leftArrow);

		rightArrow = new FlxText(leftArrow.x + 150, leftArrow.y, 0, '>', 40);
		rightArrow.font = Paths.font('Fontsona3FES.ttf');
		add(rightArrow);

		setTxt = new FlxText(0, leftArrow.y - 40, 0, Language.getPhrase('note_splash_preview_animation_set', 'Animation Set'), 28);
		setTxt.font = Paths.font('Fontsona3FES.ttf');
		setTxt.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - setTxt.width) / 2;
		add(setTxt);

		curOption = new FlxText(0, leftArrow.y + 10, 0, '1', 28);
		curOption.font = Paths.font('Fontsona3FES.ttf');
		curOption.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - curOption.width) / 2;
		add(curOption);

		selector = new FlxSprite();
		selector.visible = false;
		add(selector);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_play_animation', 0.15, 24);
		add(acceptIcon);

		var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 10, FlxG.height - 44, 'back', 0, 'ui_back', 0.15, 24);
		add(backIcon);
		#end

		backButton = new BackButton();
		backButton.x += 50;
		add(backButton);

		#if !mobile
		if (controls.controllerMode) {
			changeSelection(0);
		}
		#end

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}

		#if !mobile
		if (FlxG.mouse.justMoved) {
			usingSelector = selector.visible = false;
		}

		if (controls.UI_UP_P) {
			if (!usingSelector) changeSelection(0);
			else if (!onAnimOption) {
				onAnimOption = true;
				changeSelection(0);
			}
		}
		if (controls.UI_DOWN_P) {
			if (!usingSelector) changeSelection(0);
			else if (onAnimOption) {
				onAnimOption = false;
				changeSelection(curSelected);
			}
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			if (!usingSelector) {
				changeSelection(0);
			}
			else if (onAnimOption) {
				updateAnimationSet(Std.parseInt(curOption.text) + (controls.UI_LEFT_P ? -1 : 1));
			}
			else {
				changeSelection(curSelected + (controls.UI_LEFT_P ? -1 : 1));
			}
		}

		if (controls.ACCEPT) {
			if (!usingSelector) changeSelection(0);
			if (!onAnimOption) {
				playSplashAnim(curSelected);
			}
		}
		#end

		if ((TouchUtil.overlaps(leftArrow, camUI) || TouchUtil.overlaps(rightArrow, camUI)) && TouchUtil.justPressed) {
			updateAnimationSet(Std.parseInt(curOption.text) + (TouchUtil.overlaps(leftArrow, camUI) ? -1 : 1));
		}

		for (strum in strums) {
			if (TouchUtil.overlaps(strum, camUI) && TouchUtil.justPressed) {
				playSplashAnim(strum.noteData);
			}
		}

		super.update(elapsed);
	}

	override function destroy() {
		FlxG.cameras.remove(camUI);
		Note.globalRgbShaders = [];
		super.destroy();
	}

	function changeSelection(option:Int) {
		if (onAnimOption) {
			usingSelector = true;
			selector.visible = true;
			selector.makeGraphic(Std.int(setTxt.width + 20), Std.int(setTxt.height + leftArrow.height + 30), 0);
			selector.drawRect(0, 0, selector.width, selector.height, 0, {thickness: 10, color: 0xFFFFFF00});
			selector.setPosition(setTxt.x - 10, setTxt.y - 10);
			return;
		}
		curSelected = Std.int(FlxMath.bound(!usingSelector ? curSelected : option, 0, 3));
		usingSelector = true;
		selector.visible = true;
		selector.makeGraphic(Std.int(strums.members[curSelected].width + 20), Std.int(strums.members[curSelected].height + 20), 0);
		selector.drawRect(0, 0, selector.width, selector.height, 0, {thickness: 10, color: 0xFFFFFF00});
		selector.setPosition(strums.members[curSelected].x - 10, strums.members[curSelected].y - 10);
	}

	function playSplashAnim(noteData:Int) {
		splashes.members[noteData].revive();
		splashes.members[noteData].spawnSplashNote(0, 0, noteData + (Std.parseInt(curOption.text) - 1) * 4, null, false);
	}

	function updateAnimationSet(option:Int) {
		var curValue:Int = Std.int(FlxMath.bound(option, 1, splashes.members[0].maxAnims));
		curOption.text = Std.string(curValue);
		curOption.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - curOption.width) / 2;
	}
}