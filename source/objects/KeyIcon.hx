package objects;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class KeyIcon extends FlxSpriteGroup
{
	public static var defaultTranslations:Map<String, String> = ['ui_select' => 'Select', 'ui_confirm' => 'Confirm', 'ui_close' => 'Close', 'ui_back' => 'Back', 'ui_gmodifiers' => 'Modifiers', 'ui_reset' => 'reset', 'ui_change_character' => 'Change Character', 
	'ui_music_player' => 'Preview', 'ui_open_link' => 'Open Link'];

	public var icons:Array<FlxSprite> = [];
	public var iconText:FlxText;

	public function new(x:Float = 0, y:Float = 0, bindName:String = 'blank', bindIndex:Int = 0, translationText:String = 'blank', iconScale:Float = 0.15, textSize:Int = 24) {
		super(x, y);
		var keyBindMap:Dynamic = Controls.instance.controllerMode ? ClientPrefs.gamepadBinds : ClientPrefs.keyBinds;
		var keyBind:FlxKey = NONE;
		var gamepadBind:FlxGamepadInputID = NONE;
		if (bindName != 'movement') {
			if (keyBindMap.get(bindName) != null) {
				if (!Controls.instance.controllerMode) keyBind = keyBindMap.get(bindName)[bindIndex];
				else gamepadBind = keyBindMap.get(bindName)[bindIndex];
			}
			if ((!Controls.instance.controllerMode && keyBind == NONE || Controls.instance.controllerMode && gamepadBind == NONE) && !FileSystem.exists(Paths.getSharedPath('images/' + getIconPath() + bindName.toUpperCase() + '.png'))) bindName = 'blank';
		}
		switch(bindName.toLowerCase()) {
			case 'movement':
				if (!Controls.instance.controllerMode) {
					var left:String = ClientPrefs.keyBinds.get('ui_left')[bindIndex].toString();
					var down:String = ClientPrefs.keyBinds.get('ui_down')[bindIndex].toString();
					var up:String = ClientPrefs.keyBinds.get('ui_up')[bindIndex].toString();
					var right:String = ClientPrefs.keyBinds.get('ui_right')[bindIndex].toString();

					var iconLeft:FlxSprite = new FlxSprite(17, 0, Paths.image(getIconPath() + left));
					iconLeft.scale.set(iconScale, iconScale);
					iconLeft.updateHitbox();
					iconLeft.antialiasing = true;
					add(iconLeft);
					icons.push(iconLeft);

					var iconDown:FlxSprite = new FlxSprite(iconLeft.x + iconLeft.width + 10, 0, Paths.image(getIconPath() + down));
					iconDown.scale.set(iconScale, iconScale);
					iconDown.updateHitbox();
					iconDown.antialiasing = true;
					add(iconDown);
					icons.push(iconDown);

					var iconUp:FlxSprite = new FlxSprite(0, -40, Paths.image(getIconPath() + up));
					iconUp.scale.set(iconScale, iconScale);
					iconUp.updateHitbox();
					iconUp.x = iconDown.x + (iconDown.width - iconUp.width) / 2;
					iconUp.antialiasing = true;
					add(iconUp);
					icons.push(iconUp);

					var iconRight:FlxSprite = new FlxSprite(iconDown.x + iconDown.width + 10, 0, Paths.image(getIconPath() + right));
					iconRight.scale.set(iconScale, iconScale);
					iconRight.updateHitbox();
					iconRight.antialiasing = true;
					add(iconRight);
					icons.push(iconRight);
				}
				else {
					var icon:FlxSprite = new FlxSprite(17, 0, Paths.image(getIconPath(true) + 'dpad'));
					icon.scale.set(iconScale, iconScale);
					icon.updateHitbox();
					icon.antialiasing = true;
					add(icon);
					icons.push(icon);
				}

				iconText = new FlxText(icons[icons.length - 1].x + icons[icons.length - 1].width + 10, 5, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'), 24);
				iconText.setFormat("VCR OSD Mono", textSize, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
			case 'blank':
				var icon:FlxSprite = new FlxSprite(0, 0, Paths.image('persona/ui/button-icons/keyboard/keyboard-button-blank'));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + 10, 5, 0, 'NO BUTTON FOUND', 24);
				iconText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
			default:
				var bind:String = (!Controls.instance.controllerMode && keyBind == NONE || Controls.instance.controllerMode && gamepadBind == NONE) ? bindName.toUpperCase() : Controls.instance.controllerMode ? gamepadBind.toString() : keyBind.toString();
				var icon:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath(Controls.instance.controllerMode) + bind));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + 10, 5, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'), 24);
				iconText.setFormat("VCR OSD Mono", textSize, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
		}
	}

	public static function getIconPath(controller:Bool = false):String {
		if (controller) {
			var model:FlxGamepadModel = FlxG.gamepads.firstActive?.detectedModel;
			if (model == PS4) return 'persona/ui/button-icons/controller/ps4/';
			else if (model == SWITCH_PRO || model == SWITCH_JOYCON_LEFT || model == SWITCH_JOYCON_RIGHT) return 'persona/ui/button-icons/controller/switch';
			else return 'persona/ui/button-icons/controller/xbox/';
		}
		return 'persona/ui/button-icons/keyboard/';
	}
}