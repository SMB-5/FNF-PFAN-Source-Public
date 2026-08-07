package states;

import substates.PersonaCardSubstate;

class InitialState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();

		openSubState(new PersonaCardSubstate("WarningDemo"));
	}

	override function closeSubState()
	{
		leftState = true;
		MusicBeatState.switchState(new TitleState());
		super.closeSubState();
	}
}