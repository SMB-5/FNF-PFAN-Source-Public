package mobile.options;

import options.*;
import mobile.backend.MobileData;

class HitboxSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = '';
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Hitbox Style:',
			'Which hitbox style should be used?',
			'hitboxStyle',
			STRING,
			MobileData.hitboxStyles);
		addOption(option);

		var option:Option = new Option('Show Hints',
			'Whether to show the hitbox hints while idling.',
			'hitboxHints',
			BOOL);
		addOption(option);

		super();

		bg.alpha = 0.75;
		bg.color = 0xFFFFFFFF;
	}
}