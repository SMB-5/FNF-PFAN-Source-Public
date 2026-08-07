package options;

import flixel.FlxObject;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import backend.StageData;
import options.OptionsState;
import states.MainMenuState;

class MainMenuOptions extends MusicBeatState
{
	public static var curChar:Null<String> = null;
	private static var curSelected:Int = 0;
	public var transIn:Bool = false;
	var selected:Bool = false;

	var options:Array<String> = [
		'NOTE COLORS',
		'CONTROLS',
		#if mobile 'MOBILE', #end
		'COMBO/OFFSET',
		'GRAPHICS',
		'VISUALS',
		'GAMEPLAY'
		#if TRANSLATIONS_ALLOWED , 'LANGUAGE' #end
	];
	var grpOptions:FlxTypedGroup<FlxText>;
	var optionHitboxes:Array<FlxObject> = [];
	var camOptions:FlxCamera;

	var bg:FlxBackdrop;
	var topBG:FlxSprite;
	var topGradient:FlxSprite;
	var textBG:FlxSprite;
	var menuChar:FlxSprite;

	var backButton:FlxText;

	var eraseTxt:FlxText;
	var eraseTimer:Float = 0;

	var keyIcons:FlxTypedGroup<KeyIcon>;

	public function new(transIn:Bool = false) {
		super();
		this.transIn = transIn;
	}

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'NOTE COLORS':
				openSubState(new options.NotesColorSubState());
			case 'CONTROLS':
				openSubState(new options.ControlsSubState());
			#if mobile
			case 'MOBILE':
				openSubState(new mobile.options.MobileSettingsSubState());
			#end
			case 'GRAPHICS':
				openSubState(new options.GraphicsSettingsSubState());
			case 'VISUALS':
				openSubState(new options.VisualsSettingsSubState());
			case 'GAMEPLAY':
				openSubState(new options.GameplaySettingsSubState());
			case 'COMBO/OFFSET':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'LANGUAGE':
				openSubState(new options.LanguageSubState());
		}
	}

	override function create()
	{
		if (transIn) FlxTransitionableState.skipNextTransOut = true;
		super.create();

		// make a new camera BELOW FlxG.camera
		// this is so that substates don't have to make a new camera to not have the camera scroll mess up the substate
		camOptions = new FlxCamera();
		camOptions.bgColor.alpha = 0;
		camOptions.scroll.set();
		FlxG.cameras.insert(camOptions, 0, false);

		FlxG.camera.bgColor.alpha = 0;

		cameras = [camOptions];

		if (!FlxG.sound.music.playing) {
			if (OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('persona/songs from the games/P5/Have a Short Rest'), transIn ? 0 : 0.7);
			else FlxG.sound.playMusic(Paths.music('freakyMenu'), transIn ? 0 : 0.7);
		}

		Conductor.bpm = 125;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		bg = new FlxBackdrop(Paths.image('menuWall'), X);
		bg.setPosition(-150, -150);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		topBG = new FlxSprite(0, 0, Paths.image('menuWall'));
		topBG.y -= topBG.height;
		topBG.flipY = true;
		topBG.antialiasing = ClientPrefs.data.antialiasing;
		add(topBG);

		topGradient = FlxGradient.createGradientFlxSprite(Std.int(topBG.width), Std.int(topBG.height), [FlxColor.BLACK, 0x0]);
		topGradient.y = topBG.y;
		topGradient.antialiasing = ClientPrefs.data.antialiasing;
		add(topGradient);

		textBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		textBG.antialiasing = ClientPrefs.data.antialiasing;
		add(textBG);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var offset:Float = 218 - (Math.max(options.length, 6) - 6) * 80;
			var menuItem:FlxText = new FlxText(0, (i * 80) + offset, 0, Language.getPhrase('options_${options[i]}', options[i]), 48);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, FlxColor.WHITE, LEFT);
			menuItem.x = FlxG.width - menuItem.textField.textWidth - 30;
			grpOptions.add(menuItem);

			var hitbox = new FlxObject(0, menuItem.getMidpoint().y - 37.5, menuItem.width + 50, 75);
			hitbox.x = FlxG.width - hitbox.width;
			hitbox.ID = i;
			add(hitbox);
			optionHitboxes.push(hitbox);
		}

		if (curChar == null) curChar = MainMenuState.characters[FlxG.random.int(0, MainMenuState.characters.length - 1)];
		menuChar = new FlxSprite().setFrames(Paths.getSparrowAtlas('persona/menus/mainmenu/' + curChar + '-Menu'));
		menuChar.setPosition(MainMenuState.getCharPosition(curChar, 'left').x, MainMenuState.getCharPosition(curChar, 'left').y);
		menuChar.flipX = true;
		menuChar.animation.addByPrefix('idle', 'menu_idle', 24, false);
		add(menuChar);

		backButton = new FlxText(30, 58, 0, Language.getPhrase('Back').toUpperCase(), 48);
		backButton.antialiasing = ClientPrefs.data.antialiasing;
		backButton.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, FlxColor.WHITE, LEFT);
		add(backButton);

		var eraseString:String = Language.getPhrase('erase_save_data', 'Hold RESET to erase save data.');
		#if mobile
		eraseString = Language.getPhrase('erase_save_data_mobile', 'Press this text to erase save data.');
		#end
		eraseTxt = new FlxText(0, 30, 0, eraseString);
		eraseTxt.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		eraseTxt.screenCenter(X);
		add(eraseTxt);

		keyIcons = new FlxTypedGroup<KeyIcon>();
		add(keyIcons);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad_up_down', 1, 'ui_select', 0.15, 24);
		keyIcons.add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_confirm', 0.15, 24);
		keyIcons.add(acceptIcon);

		var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 10, FlxG.height - 44, 'back', 0, 'ui_close', 0.15, 24);
		keyIcons.add(backIcon);

		FlxG.mouse.visible = true;
		#end

		changeSelection(0, false);
		ClientPrefs.saveSettings();

		for (i => menuItem in grpOptions) {
			menuItem.offset.x -= menuItem.textField.textWidth + 150;
			FlxTween.tween(menuItem.offset, { x: menuItem.offset.x + menuItem.textField.textWidth + 150 }, 0.35, { ease: FlxEase.circInOut, startDelay: 0.05 * i });
		}
		textBG.x += textBG.width + 150;
		backButton.offset.x += 150;
		FlxTween.tween(textBG, { x: textBG.x - textBG.width - 150 }, 0.35, { ease: FlxEase.circInOut, startDelay: 0.05 * curSelected });
		FlxTween.tween(backButton.offset, { x: backButton.offset.x - 150 }, 0.35, { ease: FlxEase.circInOut });

		if (transIn) {
			var yValue:Float = bg.height * 2;
			#if TRANSLATIONS_ALLOWED
			if (options[curSelected] == 'LANGUAGE') yValue = bg.height;
			else
			#end
			{
				FlxG.sound.music.volume = 0;
				FlxTween.tween(FlxG.sound.music, { volume: 0.7 }, 0.35, { startDelay: 0.25 });
			}
			camOptions.scroll.y -= yValue;
			FlxTween.tween(camOptions.scroll, { y: camOptions.scroll.y + yValue }, 1, { ease: FlxEase.cubeInOut });
		}
	}

	override function closeSubState() {
		super.closeSubState();
		keyIcons.visible = true;
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
		if (selected) FlxTween.tween(camOptions.scroll, { y: camOptions.scroll.y + bg.height }, 0.75, { ease: FlxEase.cubeInOut, onComplete:t->selected = false });
	}

	var hoveringBack:Bool = false;
	override function update(elapsed:Float) {
		if (!selected) {
			if (controls.pressed('reset') #if mobile || TouchUtil.overlaps(eraseTxt, camOptions) && TouchUtil.justPressed #end) {
				if (eraseTimer < 1) {
					eraseTimer += elapsed;
					if (eraseTimer >= 1 #if mobile || TouchUtil.overlaps(eraseTxt, camOptions) && TouchUtil.justPressed #end) {
						eraseTimer = 1;
						// have to do this manually because some necessary data is bunched in with FlxG.save.data
						// Like literally every single ClientPrefs option Lol
						keyIcons.visible = false;
						openSubState(new substates.PersonaPrompt('prompt_erase_save_data', ()->{
							#if ACHIEVEMENTS_ALLOWED
							FlxG.save.data.achievementsUnlocked = [];
							FlxG.save.data.achievementsVariables = [];
							Achievements.achievementsUnlocked = [];
							Achievements.variables = [];
							#end
							FlxG.save.data.songScores = new Map<String, Int>();
							FlxG.save.data.songScoresOpponent = new Map<String, Int>();
							FlxG.save.data.weekScores = new Map<String, Int>();
							FlxG.save.data.songRating = new Map<String, Float>();
							FlxG.save.data.songRatingOpponent = new Map<String, Float>();
							FlxG.save.data.weekCompleted = new Map<String, Bool>();
							backend.Highscore.load();
							states.StoryMenuState.weekCompleted = new Map<String, Bool>();
							FlxG.save.flush();
						}, ()->{}, 3));
					}
				}
			}
			else {
				eraseTimer = 0;
			}

			var pressedAccept:Bool = controls.ACCEPT;
			for (option in optionHitboxes) {
				if (TouchUtil.overlaps(option, camOptions)) {
					#if mobile if (TouchUtil.justPressed) #end
					{
						if (curSelected != option.ID) {
							curSelected = option.ID;
							changeSelection();
						}
						else #if !mobile if (TouchUtil.justPressed) #end
							pressedAccept = true;
					}
				}
			}

			var pressedBack:Bool = controls.BACK #if android || FlxG.android.justReleased.BACK #end;
			if (TouchUtil.overlaps(backButton, camOptions)) {
				#if mobile if (TouchUtil.justPressed) #end
				{
					if (!hoveringBack) {
						selectBack(true);
					}
					else #if !mobile if (TouchUtil.justPressed) #end
						pressedBack = true;
				}
			}

			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				selectBack(!hoveringBack);
				if (!hoveringBack) changeSelection();
			}

			if (hoveringBack && controls.ACCEPT || pressedBack) {
				selected = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (OptionsState.onPlayState) {
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.fadeOut(0.35, 0);
				}
				else {
					FlxTween.tween(textBG, { alpha: 0 }, 0.15);
					playTransition();
				}
			}
			else if (pressedAccept && !hoveringBack) {
				selected = true;
				var yValue:Float = camOptions.scroll.y - bg.height;
				if (options[curSelected] == 'COMBO/OFFSET') {
					yValue = camOptions.scroll.y - bg.height * 2;
					FlxG.sound.music.fadeOut(0.35, 0);
				}
				FlxTween.tween(camOptions.scroll, { y: yValue }, 0.75, { ease: FlxEase.cubeInOut, onComplete:t->openSelectedSubstate(options[curSelected]) });
			}
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			menuChar.animation.play('idle');
		}

		lastBeatHit = curBeat;
	}

	function playTransition() {
		var secondChar = new FlxSprite().setFrames(Paths.getSparrowAtlas('persona/menus/mainmenu/' + MainMenuState.curChar + '-Menu'));
		secondChar.setPosition(MainMenuState.getCharPosition(MainMenuState.curChar).x, MainMenuState.getCharPosition(MainMenuState.curChar).y);
		secondChar.x -= bg.width * 2;
		secondChar.animation.addByPrefix('idle', 'menu_idle', 24, false);
		secondChar.animation.play('idle');
		add(secondChar);
		FlxTween.tween(camOptions.scroll, { x: camOptions.scroll.x - bg.width * 2 }, 1.25, { ease: FlxEase.cubeInOut, onComplete:t->{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new MainMenuState());
		} });
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		FlxTween.cancelTweensOf(textBG);
		#if mobile hoveringBack = false; #end
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		textBG.x = grpOptions.members[curSelected].x - 15;
		textBG.y = grpOptions.members[curSelected].getMidpoint().y - 37.5;
		textBG.setGraphicSize(grpOptions.members[curSelected].width + 50, 75);
		textBG.updateHitbox();
	}

	function selectBack(hover:Bool = true) {
		FlxTween.cancelTweensOf(textBG);
		hoveringBack = hover;
		if (hover) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			textBG.x = backButton.x - 30;
			textBG.y = backButton.getMidpoint().y - 37.5;
			textBG.setGraphicSize(backButton.width + 50, 75);
			textBG.updateHitbox();
		}
		else {
			textBG.y = 9999;
		}
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}