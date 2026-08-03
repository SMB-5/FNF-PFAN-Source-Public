package options;

import options.MainMenuOptions;

// this class will go (mostly) unused for now.
// i have plans for a custom option menu from the pause menu, and this class will act as a bridge.
// but for now, the pause menu will go to the same option menu as the main menu.
class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;
	override function create() {
		super.create();
		MusicBeatState.switchState(new MainMenuOptions());
	}
}