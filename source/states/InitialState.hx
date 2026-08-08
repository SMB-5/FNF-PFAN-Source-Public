package states;

import options.LanguageSubState;
import substates.PersonaCardSubstate;

class InitialState extends MusicBeatState
{
	public static function checkInitialization():Bool {
		return #if TRANSLATIONS_ALLOWED FlxG.save.data.language != null && #end FlxG.save.data.flashing != null;
	}

	override function create() {
		super.create();

		#if TRANSLATIONS_ALLOWED
		if (FlxG.save.data.language == null) {
			FlxG.camera.fade(0xFF000000, 0.25, true);
			openSubState(new LanguageSubState(false));
		}
		else #end if (FlxG.save.data.flashing == null) {
			ClientPrefs.data.flashing = true;
			ClientPrefs.saveSettings('flashing');
			new FlxTimer().start(1.5, _->openSubState(new PersonaCardSubstate("WarningDemo")));
		}
	}

	override function closeSubState() {
		if (checkInitialization()) MusicBeatState.switchState(new TitleState());
		else FlxG.resetState();
		super.closeSubState();
	}
}