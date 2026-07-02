package mobile.backend;

import flixel.util.FlxSave;

import mobile.objects.TouchButton;
import mobile.objects.VirtualPad;

enum ControlMode {
	HITBOX;
	LEFT_FULL;
	RIGHT_FULL;
	CUSTOM;
	BASE_GAME;
}

class MobileData
{
	public static var controlModes:Map<String, ControlMode> = [];
	public static var baseGame:Bool = false;
	public static var hitboxStyles:Array<String> = ['Normal', 'Gradient'];
	public static var save:FlxSave;

	public static function load() {
		save = new FlxSave();
		save.bind('MobileData', CoolUtil.getSavePath());

		baseGame = ClientPrefs.data.controlMode == 'BASE_GAME';

		for (mode in ControlMode.createAll()) {
			controlModes.set(Std.string(mode), mode);
		}
	}

	public static function setControlColor(control:Dynamic, ?colors:Array<Array<FlxColor>>) {
		colors ??= PlayState.isPixelStage ? ClientPrefs.data.arrowRGBPixel : ClientPrefs.data.arrowRGB;
		for (i => button in [control.buttonLeft, control.buttonDown, control.buttonUp, control.buttonRight]) {
			button.color = colors[i][0];
			button.updateColorTransform();
			if (button.label != null) {
				button.label.color = colors[i][0];
				button.label.updateColorTransform();
			}
		}
	}

	public static function saveCustomPad(virtualPad:VirtualPad) {
		save.data.customPad = [];
		for (button in [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight]) {
			save.data.customPad.push([button.x, button.y]);
		}
		save.flush();
	}

	public static function loadCustomPad(virtualPad:VirtualPad) {
		if (save.data.customPad == null) resetCustomPad();

		for (i => button in [virtualPad.buttonLeft, virtualPad.buttonDown, virtualPad.buttonUp, virtualPad.buttonRight]) {
			if (save.data.customPad[i] == null || save.data.customPad[i].length < 1) continue;
			button.x = save.data.customPad[i][0];
			if (save.data.customPad[i][1] != null) button.y = save.data.customPad[i][1];
		}
	}

	public static function resetCustomPad() {
		// LEFT_FULL default position
		save.data.customPad = [
			[0, FlxG.height - 220],
			[98, FlxG.height - 124],
			[98, FlxG.height - 315],
			[196, FlxG.height - 220]
		];
		save.flush();
	}
}