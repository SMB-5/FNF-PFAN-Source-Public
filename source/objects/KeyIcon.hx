package objects;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class KeyIcon extends FlxSpriteGroup
{
	public static var defaultTranslations:Map<String, String> = [
		// Global
		'ui_select' => 'Select',
		'ui_confirm' => 'Confirm',
		'ui_close' => 'Close',
		'ui_back' => 'Back',
		'ui_reset' => 'Reset',
		'ui_reset_all' => 'Reset All',
		'ui_preview' => 'Preview',
		// Freeplay
		'ui_gmodifiers' => 'Modifiers',
		'ui_change_character' => 'Character',
		// Music Player
		'ui_play_song' => 'Play/Pause Song',
		'ui_switch_song' => 'Switch Song',
		'ui_restart_song' => 'Restart Song',
		'ui_skip_time' => 'Skip Time',
		'ui_skip_percentage' => 'Skip To Percentage',
		'ui_open_settings' => 'Open Settings',
		// Credits
		'ui_open_link' => 'Open Link',
		// Options
		'ui_view_description' => 'View Description',
		'ui_customize_option' => 'Customize Option',
		// Combo/Offset Menu
		'ui_change_offset' => 'Change Offset',
		'ui_multiply_offset' => 'Multiply Offset (Hold)',
		// Note/Splash Preview
		'ui_play_animation' => 'Play Animation'
	];
	public static var iconOffsets:Map<String, Array<{name:String, offsets:Array<Float>}>> = [
		'ps4' => [
			{name: 'BACK', offsets: [0, -5]},
			{name: 'START', offsets: [0, -5]}
		],
		'xbox' => [
			{name: 'LEFT_SHOULDER', offsets: [0, -5]},
			{name: 'LEFT_TRIGGER', offsets: [0, -5]},
			{name: 'RIGHT_SHOULDER', offsets: [0, -5]},
			{name: 'RIGHT_TRIGGER', offsets: [0, -5]}
		],
	];
	public static var DEFAULT_SCALE(default, never):Float = 0.15;

	public static function getIconPath(controller:Bool = false):String {
		if (controller) {
			var model:FlxGamepadModel = FlxG.gamepads.firstActive?.detectedModel;
			if (model == PS4 || model == PS5) return 'persona/ui/button-icons/controller/ps4/';
			else if (model == SWITCH_PRO || model == SWITCH_JOYCON_LEFT || model == SWITCH_JOYCON_RIGHT) return 'persona/ui/button-icons/controller/switch/';
			else return 'persona/ui/button-icons/controller/xbox/';
		}
		return 'persona/ui/button-icons/keyboard/';
	}

	public var icons:Array<FlxSprite> = [];
	public var iconText:FlxText;

	public function new(x:Float = 0, y:Float = 0, bindName:String = 'blank', bindIndex:Int = 0, translationText:String = 'blank', iconScale:Float = -1, textSize:Int = 24, forceCustomBind:Bool = false) {
		super(x, y);
		createIcon(bindName, bindIndex, translationText, iconScale, textSize, forceCustomBind);
	}

	public function createIcon(bindName:String = '', bindIndex:Int = 0, translationText:String = 'blank', iconScale:Float = -1, textSize:Int = 24, forceCustomBind:Bool = false) {
		clear();
		for (icon in icons) icon.destroy();
		icons = [];
		if (iconText != null) iconText.destroy();

		if (iconScale <= 0) iconScale = DEFAULT_SCALE;
		var keyBindMap:Map<String, Array<FlxKey>> = ClientPrefs.keyBinds;
		var gamepadBindMap:Map<String, Array<FlxGamepadInputID>> = ClientPrefs.gamepadBinds;
		var keyBind:String = 'blank';
		if (!bindName.toLowerCase().contains('dpad')) {
			if (!forceCustomBind) {
				if (!Controls.instance.controllerMode && keyBindMap.get(bindName) != null) {
					keyBind = Std.string(keyBindMap.get(bindName)[bindIndex]).toUpperCase();
				}
				else if (Controls.instance.controllerMode && gamepadBindMap.get(bindName) != null) {
					keyBind = Std.string(gamepadBindMap.get(bindName)[bindIndex]).toUpperCase();
				}
			}
			if (keyBind == 'blank' && FileSystem.exists(Paths.getSharedPath('images/' + getIconPath(Controls.instance.controllerMode) + bindName.toUpperCase() + '.png'))) keyBind = bindName.toUpperCase();
		}
		else keyBind = bindName.toUpperCase();
		switch(keyBind.toLowerCase()) {
			case 'dpad', 'dpad_left_right', 'dpad_up_down':
				if (!Controls.instance.controllerMode) {
					var left:String = ClientPrefs.keyBinds.get('ui_left')[bindIndex].toString().toUpperCase();
					var down:String = ClientPrefs.keyBinds.get('ui_down')[bindIndex].toString().toUpperCase();
					var up:String = ClientPrefs.keyBinds.get('ui_up')[bindIndex].toString().toUpperCase();
					var right:String = ClientPrefs.keyBinds.get('ui_right')[bindIndex].toString().toUpperCase();

					if (keyBind.toLowerCase() == 'dpad') {
						var iconLeft:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath() + left));
						iconLeft.scale.set(iconScale, iconScale);
						iconLeft.updateHitbox();
						iconLeft.antialiasing = true;
						add(iconLeft);
						icons.push(iconLeft);

						var iconDown:FlxSprite = new FlxSprite(iconLeft.width + (10 * (iconScale / DEFAULT_SCALE)), 0, Paths.image(getIconPath() + down));
						iconDown.scale.set(iconScale, iconScale);
						iconDown.updateHitbox();
						iconDown.antialiasing = true;
						add(iconDown);
						icons.push(iconDown);

						var iconUp:FlxSprite = new FlxSprite(0, -iconDown.height - (10 * (iconScale / DEFAULT_SCALE)), Paths.image(getIconPath() + up));
						iconUp.scale.set(iconScale, iconScale);
						iconUp.updateHitbox();
						iconUp.x = iconDown.x - x + (iconDown.width - iconUp.width) / 2;
						iconUp.antialiasing = true;
						add(iconUp);
						icons.push(iconUp);

						var iconRight:FlxSprite = new FlxSprite(iconDown.x - x + iconDown.width + (10 * (iconScale / DEFAULT_SCALE)), 0, Paths.image(getIconPath() + right));
						iconRight.scale.set(iconScale, iconScale);
						iconRight.updateHitbox();
						iconRight.antialiasing = true;
						add(iconRight);
						icons.push(iconRight);
					}
					else if (keyBind.toLowerCase() == 'dpad_left_right') {
						var iconLeft:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath() + left));
						iconLeft.scale.set(iconScale, iconScale);
						iconLeft.updateHitbox();
						iconLeft.antialiasing = true;
						add(iconLeft);
						icons.push(iconLeft);

						var iconRight:FlxSprite = new FlxSprite(iconLeft.width + (10 * (iconScale / DEFAULT_SCALE)), 0, Paths.image(getIconPath() + right));
						iconRight.scale.set(iconScale, iconScale);
						iconRight.updateHitbox();
						iconRight.antialiasing = true;
						add(iconRight);
						icons.push(iconRight);
					}
					else if (keyBind.toLowerCase() == 'dpad_up_down') {
						var iconDown:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath() + down));
						iconDown.scale.set(iconScale, iconScale);
						iconDown.updateHitbox();
						iconDown.antialiasing = true;
						add(iconDown);
						icons.push(iconDown);

						var iconUp:FlxSprite = new FlxSprite(0, -iconDown.height - (10 * (iconScale / DEFAULT_SCALE)), Paths.image(getIconPath() + up));
						iconUp.scale.set(iconScale, iconScale);
						iconUp.updateHitbox();
						iconUp.x = (iconDown.width - iconUp.width) / 2;
						iconUp.antialiasing = true;
						add(iconUp);
						icons.push(iconUp);
					}
				}
				else {
					var icon:FlxSprite = new FlxSprite(0, -5, Paths.image(getIconPath(true) + keyBind.toUpperCase()));
					icon.scale.set(iconScale, iconScale);
					icon.updateHitbox();
					icon.antialiasing = true;
					add(icon);
					icons.push(icon);
				}

				iconText = new FlxText(icons[icons.length - 1].x - x + icons[icons.length - 1].width + (10 * (iconScale / DEFAULT_SCALE)), 0, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'));
				iconText.setFormat("VCR OSD Mono", Math.round(textSize * (iconScale / DEFAULT_SCALE)), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				iconText.y = ((findMaxY() - y) / 2) - (iconText.height / 2);
				add(iconText);
			case 'blank':
				var icon:FlxSprite = new FlxSprite(0, 0, Paths.image('persona/ui/button-icons/keyboard/keyboard-button-blank'));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + (10 * (iconScale / DEFAULT_SCALE)), 0, 0, 'NO BUTTON FOUND');
				iconText.setFormat("VCR OSD Mono", Math.round(textSize * (iconScale / DEFAULT_SCALE)), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				iconText.y = (height - iconText.height) / 2;
				add(iconText);
			default:
				var offsetX:Float = 0;
				var offsetY:Float = 0;
				for (model => info in iconOffsets) {
					if (getIconPath(Controls.instance.controllerMode).contains(model)) {
						for (str in info) {
							if (keyBind.toUpperCase() == str.name.toUpperCase()) {
								offsetX = str.offsets[0];
								offsetY = str.offsets[1];
							}
						}
					}
				}

				var icon:FlxSprite = new FlxSprite(offsetX, offsetY, Paths.image(getIconPath(Controls.instance.controllerMode) + keyBind.toUpperCase()));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + (10 * (iconScale / DEFAULT_SCALE)) + offsetX, 0, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'));
				iconText.setFormat("VCR OSD Mono", Math.round(textSize * (iconScale / DEFAULT_SCALE)), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				iconText.y = (height - iconText.height) / 2 + offsetY;
				add(iconText);
		}
	}

	public function createCombinationIcon(bindNames:Array<String> = null, bindIndex:Int = 0, translationText:String = 'blank', iconScale:Float = -1, textSize:Int = 24, forceCustomBind:Bool = false, symbolBetweenIcons:String = '+') {
		clear();
		for (icon in icons) icon.destroy();
		icons = [];
		if (iconText != null) iconText.destroy();

		if (bindNames == null || bindNames.length < 1) bindNames = ['blank'];
		if (iconScale <= 0) iconScale = DEFAULT_SCALE;
		var keyBindMap:Map<String, Array<FlxKey>> = ClientPrefs.keyBinds;
		var gamepadBindMap:Map<String, Array<FlxGamepadInputID>> = ClientPrefs.gamepadBinds;
		var keyBinds:Array<String> = [];
		if (!forceCustomBind) {
			for (bindName in bindNames) {
				// Idk anymore dude
				if (!Controls.instance.controllerMode && keyBindMap.get(bindName) != null || Controls.instance.controllerMode && gamepadBindMap.get(bindName) != null) {
					if (!Controls.instance.controllerMode && keyBindMap.get(bindName) != null) {
						keyBinds.push(Std.string(keyBindMap.get(bindName)[bindIndex]).toUpperCase());
					}
					else if (Controls.instance.controllerMode && gamepadBindMap.get(bindName) != null) {
						keyBinds.push(Std.string(gamepadBindMap.get(bindName)[bindIndex]).toUpperCase());
					}
				}
				else {
					keyBinds.push(bindName.toUpperCase());
				}
			}
		}
		else keyBinds = bindNames.copy();

		var offsetX:Float = 0;
		var offsetY:Float = 0;
		for (i => keyBind in keyBinds) {
			if (!FileSystem.exists(Paths.getSharedPath('images/' + getIconPath(Controls.instance.controllerMode) + keyBind.toUpperCase() + '.png'))) {
				keyBind = 'blank';
			}

			if (icons.length > 0 && symbolBetweenIcons != null && symbolBetweenIcons.length > 0) {
				var symbol:FlxText = new FlxText(width + (10 * (iconScale / DEFAULT_SCALE)), 0, 0, symbolBetweenIcons);
				symbol.setFormat("VCR OSD Mono", Math.round(textSize * (iconScale / DEFAULT_SCALE)), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				symbol.y = (findMaxY() - y - symbol.height) / 2;
				add(symbol);
			}

			if (keyBind == 'blank') {
				var icon:FlxSprite = new FlxSprite(icons.length > 0 ? width + (10 * (iconScale / DEFAULT_SCALE)) : 0, 0, Paths.image('persona/ui/button-icons/keyboard/keyboard-button-blank'));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);
			}
			else {
				for (model => info in iconOffsets) {
					if (getIconPath(Controls.instance.controllerMode).contains(model)) {
						for (str in info) {
							if (keyBind.toUpperCase() == str.name.toUpperCase()) {
								offsetX = str.offsets[0];
								offsetY = str.offsets[1];
							}
						}
					}
				}

				var icon:FlxSprite = new FlxSprite(icons.length > 0 ? width + (10 * (iconScale / DEFAULT_SCALE)) + offsetX : offsetX, offsetY, Paths.image(getIconPath(Controls.instance.controllerMode) + keyBind.toUpperCase()));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);
			}
		}

		iconText = new FlxText(width + (10 * (iconScale / DEFAULT_SCALE)) + offsetX, 0, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'));
		iconText.setFormat("VCR OSD Mono", Math.round(textSize * (iconScale / DEFAULT_SCALE)), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		iconText.y = (icons[icons.length - 1].height - iconText.height) / 2 + offsetY;
		add(iconText);
	}
}