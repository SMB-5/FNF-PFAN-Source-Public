package mobile.objects;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import mobile.backend.MobileData;
import mobile.objects.Hitbox;
import mobile.objects.VirtualPad;
import mobile.input.MobileInputManager;

class MobileControls extends FlxTypedSpriteGroup<MobileInputManager>
{
	public var currentMode(get, never):Dynamic;
	public var controlMode(get, set):String;
	public var virtualPad:VirtualPad;
	public var hitbox:Hitbox;

	private var _controlMode:ControlMode;

	public function new(controlMode:ControlMode = HITBOX, hitboxStyle:String = 'Normal') {
		super();
		changeControl(controlMode);
		alpha = ClientPrefs.data.controlAlpha;
	}

	public function changeControl(?controlMode:ControlMode, hitboxStyle:String = 'Normal') {
		controlMode ??= HITBOX;
		if (virtualPad != null) {
			remove(virtualPad);
			virtualPad.destroy();
		}
		if (hitbox != null) {
			remove(hitbox);
			hitbox.destroy();
		}
		_controlMode = controlMode;
		switch(controlMode) {
			case HITBOX:
				hitbox = new Hitbox(hitboxStyle);
				add(hitbox);
			case LEFT_FULL:
				virtualPad = new VirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case RIGHT_FULL:
				virtualPad = new VirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case CUSTOM:
				virtualPad = new VirtualPad(CUSTOM, NONE);
				add(virtualPad);
			case BASE_GAME: // the hitbox option but homeless
				hitbox = new Hitbox();
				add(hitbox);
		}
	}

	function get_currentMode():Dynamic {
		if (controlMode == 'HITBOX' || controlMode == 'BASE_GAME') return cast(hitbox, Hitbox);
		else if (controlMode != 'NONE') return cast(virtualPad, VirtualPad);
		return null;
	}

	function get_controlMode():String {
		return _controlMode == null ? 'NONE' : Std.string(_controlMode);
	}

	function set_controlMode(value:String):String {
		_controlMode = MobileData.controlModes.get(value.toUpperCase()) ?? HITBOX;
		return value.toUpperCase();
	}
}