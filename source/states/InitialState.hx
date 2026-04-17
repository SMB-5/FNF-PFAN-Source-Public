package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

import substates.PersonaCardSubstate;

class InitialState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		new FlxTimer().start(1, function(tmr) {
		openSubState(new PersonaCardSubstate("WarningDemo"));
		});
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		leftState = true;

		MusicBeatState.switchState(new TitleState());
	}
}