package mobile.input;

import flixel.system.macros.FlxMacroUtil;

enum abstract MobileInputID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, MobileInputID> = FlxMacroUtil.buildMap('mobile.input.MobileInputID');
	public static var toStringMap(default, null):Map<MobileInputID, String> = FlxMacroUtil.buildMap('mobile.input.MobileInputID', true);
	// Key Indices
	var ANY = -2;
	var NONE = -1;

	var NOTE_LEFT = 0;
	var NOTE_DOWN = 1;
	var NOTE_UP = 2;
	var NOTE_RIGHT = 3;
	var A = 4;
	var B = 5;
	var C = 6;
	var D = 7;
	var E = 8;
	var F = 9;
	var G = 10;
	var P = 11;
	var S = 12;
	var V = 13;
	var X = 14;
	var Y = 15;
	var Z = 16;
	var UP = 17;
	var DOWN = 18;
	var LEFT = 19;
	var RIGHT = 20;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}