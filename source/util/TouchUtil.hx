package util;

import flixel.FlxObject;
import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;

class TouchUtil
{
	public static var justPressed(get, never):Bool;
	public static var pressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var input(get, never):#if mobile FlxTouch #else FlxMouse #end;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.overlaps(object, camera ?? object.camera)) {
				return true;
			}
		}
		#else
		return FlxG.mouse.overlaps(object, camera ?? object.camera);
		#end

		return false;
	}

	static function get_justPressed():Bool {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				return true;
			}
		}
		#else
		return FlxG.mouse.justPressed;
		#end

		return false;
	}

	static function get_pressed():Bool {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.pressed) {
				return true;
			}
		}
		#else
		return FlxG.mouse.pressed;
		#end

		return false;
	}

	static function get_justReleased():Bool {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justReleased) {
				return true;
			}
		}
		#else
		return FlxG.mouse.justReleased;
		#end

		return false;
	}

	static function get_released():Bool {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.released) {
				return true;
			}
		}
		#else
		return FlxG.mouse.released;
		#end

		return false;
	}

	static function get_input():#if mobile FlxTouch #else FlxMouse #end {
		return #if mobile FlxG.touches.getFirst() #else FlxG.mouse #end;
	}
}