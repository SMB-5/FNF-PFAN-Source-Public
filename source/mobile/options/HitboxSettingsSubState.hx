package mobile.options;

import options.*;
import mobile.backend.MobileData;

class HitboxSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = '';
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Hitbox Style',
			'Which hitbox style should be used?',
			'hitboxStyle',
			STRING,
			'Normal', MobileData.hitboxStyles);
		addOption(option);

		var option:Option = new Option('Show Hints',
			'Shows the hitbox borders at all times.',
			'hitboxHints',
			BOOL);
		addOption(option);

		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.8;
		bg.cameras = [camBG];
		insert(0, bg);
	}
}