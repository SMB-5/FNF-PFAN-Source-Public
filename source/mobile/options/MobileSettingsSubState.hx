package mobile.options;

import options.*;

import states.CopyState;

class MobileSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('mobile_menu', 'Mobile Settings');
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Edit Mobile Controls',
			'Change the current control mode or customize your controls.',
			'controlMode',
			BUTTON);
		option.onOpen = ()->openSubState(new mobile.options.MobileControlsSubState());
		addOption(option);

		var option:Option = new Option('Control Alpha',
			'How transparent should the controls be?',
			'controlAlpha',
			FLOAT);
		option.defaultValue = 0.6;
		option.changeValue = 0.1;
		option.minValue = 0;
		option.maxValue = 1;
		option.scrollSpeed = 1;
		addOption(option);

		var option:Option = new Option('Enable Pause Button',
			'Enables the pause button.\nPressing the back button on Android will still pause the game.',
			'pauseButton',
			BOOL);
		addOption(option);

		#if COPY_FILES
		var option:Option = new Option('Recopy Assets',
			'Deletes the assets folder and recopies everything again.\nUseful if some files aren\'t properly updated or if there are missing files.',
			null,
			BUTTON);
		option.onOpen = ()->openSubState(new substates.PersonaPrompt('prompt_recopy_assets', ()->{
			CopyState.recopyAssets = true;
			FlxG.sound.music.stop();

			var recopyBG:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
			recopyBG.scale.set(FlxG.width, FlxG.height);
			recopyBG.updateHitbox();
			recopyBG.cameras = [camUI];
			add(recopyBG);

			var recopyTxt:FlxText = new FlxText(0, 0, 0, Language.getPhrase('recopy_assets_preparation', 'Deleting assets folder in preparation, please wait...'), 36);
			recopyTxt.font = Paths.font('Fontsona3FES.ttf');
			recopyTxt.screenCenter();
			recopyTxt.cameras = [camUI];
			add(recopyTxt);

			new FlxTimer().start(0.001, _->FlxG.switchState(new CopyState()));
		}));
		option.buttonText = 'ui_confirm';
		addOption(option);
		#end

		super();
	}
}