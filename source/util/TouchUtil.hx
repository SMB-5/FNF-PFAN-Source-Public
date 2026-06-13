package util;

import flixel.FlxObject;

class TouchUtil
{
	public static var justPressed(get, never):Bool;
	public static var pressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool {
		for (touch in FlxG.touches.list) {
			if (touch.overlaps(object, camera ?? object.camera)) {
				return true;
			}
		}

		return false;
	}

	static function get_justPressed():Bool {
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				return true;
			}
		}

		return false;
	}

	static function get_pressed():Bool {
		for (touch in FlxG.touches.list) {
			if (touch.pressed) {
				return true;
			}
		}

		return false;
	}

	static function get_justReleased():Bool {
		for (touch in FlxG.touches.list) {
			if (touch.justReleased) {
				return true;
			}
		}

		return false;
	}

	static function get_released():Bool {
		for (touch in FlxG.touches.list) {
			if (touch.released) {
				return true;
			}
		}

		return false;
	}
}