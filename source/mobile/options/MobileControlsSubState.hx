package mobile.options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import mobile.backend.MobileData;
import mobile.objects.MobileControls;
import mobile.objects.TouchButton;

class MobileControlsSubState extends MusicBeatSubstate
{
	var options:Array<String> = [
		'HITBOX',
		'LEFT_FULL',
		'RIGHT_FULL',
		'CUSTOM',
		'BASE_GAME'
	];

	var curSelected:Int = 0;
	var showingUI:Bool = true;
	var movingButton:TouchButton;

	var curControl:Alphabet;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var exitButton:PsychUIButton;
	var optionsButton:PsychUIButton;
	var hideButton:PsychUIButton;
	var resetButton:PsychUIButton;

	override function create() {
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF77F24E);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.6}, 0.5, {ease: FlxEase.quadOut});
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		mobileControls = new MobileControls();
		add(mobileControls);

		curControl = new Alphabet(100, 50);
		add(curControl);

		leftArrow = new FlxSprite(curControl.x - 70, curControl.y - 5);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(curControl.x + curControl.width + 20, curControl.y - 5);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
		add(rightArrow);

		exitButton = new PsychUIButton(FlxG.width - 300, 50, Language.getPhrase('mobile_controls_save_and_exit', 'Save and Exit'), null, 250, 80);
		exitButton.normalStyle.bgColor = 0xFF00F24E;
		exitButton.text.size = 24;
		exitButton.text.y -= 7;
		add(exitButton);

		optionsButton = new PsychUIButton(exitButton.x - 280, 50, Language.getPhrase('mobile_controls_control_options', 'Control Options'), null, 250, 80);
		optionsButton.normalStyle.bgColor = 0xFF757171;
		optionsButton.text.size = 24;
		optionsButton.text.y -= 7;
		optionsButton.kill();
		add(optionsButton);

		hideButton = new PsychUIButton(20, optionsButton.y + 110, Language.getPhrase('mobile_controls_hide_ui', 'Hide UI'), null, 250, 80);
		hideButton.normalStyle.bgColor = 0xFF4AA3F0;
		hideButton.text.size = 24;
		hideButton.text.y -= 7;
		add(hideButton);

		resetButton = new PsychUIButton(exitButton.x, exitButton.y + 110, Language.getPhrase('mobile_controls_reset_positions', 'Reset Positions'), null, 250, 80);
		resetButton.normalStyle.bgColor = 0xFFFF0000;
		resetButton.text.size = 24;
		resetButton.text.y -= 7;
		resetButton.update(FlxG.elapsed);
		resetButton.kill();
		add(resetButton);

		curSelected = Std.int(Math.min(options.indexOf(ClientPrefs.data.controlMode.toUpperCase()), 0));
		changeControl();

		super.create();
	}

	override function update(elapsed:Float) {
		if (showingUI) {
			if (controls.BACK || TouchUtil.overlaps(exitButton) && TouchUtil.justPressed) {
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
				ClientPrefs.data.controlMode = options[curSelected];
				ClientPrefs.saveSettings();
				if (options[curSelected] == 'CUSTOM') {
					MobileData.saveCustomPad(mobileControls.virtualPad);
				}
				close();
			}

			if (TouchUtil.overlaps(optionsButton) && TouchUtil.justPressed) {
				switch(options[curSelected]) {
					case 'HITBOX':
						openSubState(new mobile.options.HitboxSettingsSubState());
				}
			}

			if (options[curSelected] == 'CUSTOM' && TouchUtil.overlaps(resetButton) && TouchUtil.justPressed) {
				MobileData.resetCustomPad();
				for (i => button in [mobileControls.virtualPad.buttonLeft, mobileControls.virtualPad.buttonDown, mobileControls.virtualPad.buttonUp, mobileControls.virtualPad.buttonRight]) {
					button.x = MobileData.save.data.customPad[i][0];
					button.y = MobileData.save.data.customPad[i][1];
				}
			}

			if (TouchUtil.overlaps(leftArrow) && TouchUtil.pressed) {
				leftArrow.animation.play('press');
				if (TouchUtil.justPressed) changeControl(-1);
			}
			else {
				leftArrow.animation.play('idle');
			}

			if (TouchUtil.overlaps(rightArrow) && TouchUtil.pressed) {
				rightArrow.animation.play('press');
				if (TouchUtil.justPressed) changeControl(1);
			}
			else {
				rightArrow.animation.play('idle');
			}

			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeControl(controls.UI_LEFT_P ? -1 : 1);
			}
		}

		if (TouchUtil.overlaps(hideButton) && TouchUtil.justPressed) {
			hideUI(showingUI);
		}

		if (options[curSelected] == 'CUSTOM') {
			for (button in [mobileControls.virtualPad.buttonLeft, mobileControls.virtualPad.buttonDown, mobileControls.virtualPad.buttonUp, mobileControls.virtualPad.buttonRight]) {
				if (TouchUtil.overlaps(button) && TouchUtil.pressed && movingButton == null) {
					movingButton = button;
				}
			}
			if (movingButton != null && TouchUtil.overlaps(movingButton) && TouchUtil.pressed) {
				movingButton.x = TouchUtil.input.x - (movingButton.width / 2);
				movingButton.y = TouchUtil.input.y - (movingButton.height / 2);
			}
			else if (TouchUtil.justReleased) {
				movingButton = null;
			}
		}

		super.update(elapsed);
	}

	override function closeSubState() {
		if (options[curSelected] == 'HITBOX') {
			changeControl();
		}
		super.closeSubState();
	}

	function changeControl(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		curControl.text = options[curSelected];
		rightArrow.x = curControl.x + curControl.width + 20;
		mobileControls.changeControl(MobileData.controlModes.get(options[curSelected]), ClientPrefs.data.hitboxStyle);
		MobileData.setControlColor(mobileControls.currentMode);
		if (options[curSelected] == 'CUSTOM') resetButton.revive();
		else if (resetButton.alive) resetButton.kill();
		if (options[curSelected] == 'HITBOX') optionsButton.revive();
		else if (optionsButton.alive) optionsButton.kill();
	}

	function hideUI(hide:Bool = false) {
		showingUI = !hide;
		for (button in [curControl, leftArrow, rightArrow, exitButton, optionsButton, resetButton, hideButton]) {
			if (button == hideButton) {
				var b:PsychUIButton = cast button;
				b.normalStyle.bgAlpha = b.hoverStyle.bgAlpha = b.clickStyle.bgAlpha = hide ? 0.15 : 1;
			}
			if (hide && button != hideButton) button.active = false;
			else if (!hide && button.alive) button.active = true;
			FlxTween.cancelTweensOf(button);
			FlxTween.tween(button, { alpha: (hide && button == hideButton) ? 0.15 : hide ? 0 : 1 }, 0.15);
		}
	}
}