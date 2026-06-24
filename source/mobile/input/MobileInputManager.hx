package mobile.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;

import mobile.objects.TouchButton;
import mobile.input.MobileInputID;

class MobileInputManager extends FlxTypedSpriteGroup<TouchButton>
{
	public var trackedButtons:Map<MobileInputID, TouchButton> = [];

	public var onPressed:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();
	public var onReleased:FlxTypedSignal<TouchButton->Void> = new FlxTypedSignal<TouchButton->Void>();

	public function anyPressed(buttonArray:Array<MobileInputID>):Bool {
		return checkButtonArrayState(buttonArray, PRESSED);
	}

	public function anyJustPressed(buttonArray:Array<MobileInputID>):Bool {
		return checkButtonArrayState(buttonArray, JUST_PRESSED);
	}

	public function anyReleased(buttonArray:Array<MobileInputID>):Bool {
		return checkButtonArrayState(buttonArray, RELEASED);
	}

	public function anyJustReleased(buttonArray:Array<MobileInputID>):Bool {
		return checkButtonArrayState(buttonArray, JUST_RELEASED);
	}

	public function checkStatus(button:MobileInputID, state:FlxInputState):Bool {
		if (button == MobileInputID.ANY) {
			for (trackedButton in trackedButtons.keys()) {
				if (checkStatusUnsafe(trackedButton, state)) return true;
			}
		}
		
		if (button == MobileInputID.NONE) {
			for (trackedButton in trackedButtons.keys()) {
				if (checkStatusUnsafe(trackedButton, state)) return false;
			}
			return true;
		}

		if (trackedButtons.exists(button)) {
			return checkStatusUnsafe(button, state);
		}

		return false;
	}

	function checkStatusUnsafe(button:MobileInputID, state:FlxInputState):Bool {
		return switch(state) {
			case PRESSED: trackedButtons.get(button).pressed;
			case JUST_PRESSED: trackedButtons.get(button).justPressed;
			case RELEASED: trackedButtons.get(button).released;
			case JUST_RELEASED: trackedButtons.get(button).justReleased;
		}
	}

	function checkButtonArrayState(buttonArray:Array<MobileInputID>, state:FlxInputState):Bool {
		if (buttonArray == null) return false;

		for (code in buttonArray) {
			if (checkStatus(code, state)) return true;
		}

		return false;
	}

	public function updateTrackedButtons() {
		trackedButtons = [];
		for (button in this) {
			if (button.IDs != null) {
				for (id in button.IDs) {
					if (!trackedButtons.exists(id)) trackedButtons.set(id, button);
				}
			}
		}
	}
}