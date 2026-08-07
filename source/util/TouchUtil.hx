package util;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.input.FlxPointer;
import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxSwipe;

class TouchUtil
{
	public static var justPressed(get, never):Bool;
	public static var pressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var input(get, never):#if mobile FlxTouch #else FlxMouse #end;
	#if mobile
	public static var swipe(get, never):FlxSwipe;
	public static var justSwiped(get, never):Bool;
	#end

	public static function overlaps(object:FlxBasic, ?camera:FlxCamera, ?offset:FlxPoint):Bool {
		if (offset != null) {
			@:privateAccess {
			var result:Bool = false;
			var group = FlxTypedGroup.resolveGroup(object);
			if (group != null) {
				group.forEachExists(function(basic:FlxBasic) {
					if (TouchUtil.overlaps(basic, camera ?? basic.camera, offset)) {
						result = true;
						return;
					}
				});
			}
			else {
				#if mobile
				for (touch in FlxG.touches.list) {
					touch.getWorldPosition(camera ?? object.camera, FlxPointer._cachedPoint);
					var object:FlxObject = cast object;
					if (TouchUtil.overlapsPoint(object, FlxPointer._cachedPoint, offset, true, camera ?? object.camera)) {
						result = true;
					}
				}
				#else
				FlxG.mouse.getWorldPosition(camera ?? object.camera, FlxPointer._cachedPoint);
				var object:FlxObject = cast object;
				return TouchUtil.overlapsPoint(object, FlxPointer._cachedPoint, offset, true, camera ?? object.camera);
				#end
			}
			return result;
			}
		}
		else {
			#if mobile
			for (touch in FlxG.touches.list) {
				if (touch.overlaps(object, camera ?? object.camera)) {
					return true;
				}
			}
			#else
			return FlxG.mouse.overlaps(object, camera ?? object.camera);
			#end
		}

		return false;
	}

	public static function overlapsPoint(object:FlxObject, point:FlxPoint, ?offset:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool {
		if (offset == null) {
			offset = FlxPoint.get(0, 0);
		}
		if (!inScreenSpace) {
			var overlapping:Bool = (point.x >= object.x + offset.x) && (point.x < object.x + object.width + offset.x) && (point.y >= object.y + offset.y) && (point.y < object.y + object.height + offset.y);
			offset.put();
			return overlapping;
		}

		if (camera == null) {
			camera = FlxG.camera;
		}
		@:privateAccess {
		var xPos:Float = point.x - camera.scroll.x;
		var yPos:Float = point.y - camera.scroll.y;
		object.getScreenPosition(object._point, camera);
		point.putWeak();
		var overlapping:Bool = (xPos >= object._point.x + offset.x) && (xPos < object._point.x + object.width + offset.x) && (yPos >= object._point.y + offset.y) && (yPos < object._point.y + object.height + offset.y);
		offset.put();
		return overlapping;
		}
	}

	public static function initiallyOverlapped(object:FlxObject, ?camera:FlxCamera, ?offset:FlxPoint):Bool {
		if (TouchUtil.input == null) return false;
		return TouchUtil.overlapsPoint(object, TouchUtil.getJustPressedPosition(camera), offset, true, camera ?? object.camera);
	}

	public static function getJustPressedPosition(?camera:FlxCamera):FlxPoint {
		if (TouchUtil.input == null) return null;
		@:privateAccess
		var justPressedPosition:FlxPoint = #if mobile TouchUtil.input.justPressedPosition #else TouchUtil.input._leftButton.justPressedPosition #end;
		if (TouchUtil.justPressed) {
			justPressedPosition.copyFrom(TouchUtil.input.getViewPosition(camera));
		}
		return justPressedPosition;
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

	#if mobile
	static function get_swipe():FlxSwipe {
		return FlxG.swipes[0];
	}

	static function get_justSwiped():Bool {
		for (swipe in FlxG.swipes) {
			if (swipe.duration <= 0.5) {
				return true;
			}
		}

		return false;
	}
	#end
}