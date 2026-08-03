package mobile.options;

import options.*;

class MobileSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('mobile_menu', 'Mobile Settings');
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Edit Mobile Controls',
			'Change the current control mode or customize your controls.',
			'controlMode',
			SUBSTATE(mobile.options.MobileControlsSubState));
		addOption(option);

		var option:Option = new Option('Control Alpha',
			'How opaque do you want the controls to be?',
			'controlAlpha',
			FLOAT);
		option.defaultValue = 0.6;
		option.changeValue = 0.1;
		option.minValue = 0;
		option.maxValue = 1;
		option.scrollSpeed = 1;
		addOption(option);

		var option:Option = new Option('Enable Pause Button',
			'Whether or not the pause button should be enabled.\nYou can still press the back button to pause.',
			'pauseButton',
			BOOL);
		addOption(option);

		super();
	}
}