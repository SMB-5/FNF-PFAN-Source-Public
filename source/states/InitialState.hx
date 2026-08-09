package states;

import options.LanguageSubState;
import substates.PersonaCardSubstate;
import substates.PersonaPrompt;

class InitialState extends MusicBeatState
{
	static var showUpdatePrompt:Bool = true;
	public static function checkInitialization():Bool {
		return #if TRANSLATIONS_ALLOWED FlxG.save.data.language != null && #end FlxG.save.data.flashing != null && !showUpdatePrompt;
	}

	override function create() {
		super.create();

		showUpdatePrompt = false;
		#if CHECK_FOR_UPDATES
		var latestVersion:String = CoolUtil.checkForUpdates();
		var currentVersion:String = FlxG.stage.application.meta.get('version');
		if (ClientPrefs.data.checkForUpdates) {
			showUpdatePrompt = latestVersion > currentVersion;
		}
		#end

		#if TRANSLATIONS_ALLOWED
		if (FlxG.save.data.language == null) {
			FlxG.camera.fade(0xFF000000, 0.25, true);
			openSubState(new LanguageSubState(false));
		}
		else #end if (FlxG.save.data.flashing == null) {
			ClientPrefs.data.flashing = true;
			ClientPrefs.saveSettings('flashing');
			 openSubState(new PersonaCardSubstate('WarningDemo'));
		}
		#if CHECK_FOR_UPDATES
		else if (showUpdatePrompt) {
			openSubState(new PersonaPrompt('prompt_outdated_warning', ()->{
				CoolUtil.browserLoad('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
			}, null, null, null, [currentVersion, latestVersion]));
			showUpdatePrompt = false;
		}
		#end
		else {
			finishInitialization();
		}
	}

	override function closeSubState() {
		finishInitialization();
		super.closeSubState();
	}

	function finishInitialization() {
		if (checkInitialization()) MusicBeatState.switchState(new TitleState());
		else new FlxTimer().start(1.5, _->FlxG.resetState());
	}
}