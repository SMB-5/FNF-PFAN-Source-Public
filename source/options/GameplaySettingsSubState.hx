package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('gameplay_menu', 'GAMEPLAY');
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'Notes go down instead of up.', //Description
			'downScroll', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'Centers the notes.',
			'middleScroll',
			BOOL);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'Hides the opponent notes.',
			'opponentStrums',
			BOOL);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"Allows tapping while there are no notes present.",
			'ghostTapping',
			BOOL);
		addOption(option);

		var option:Option = new Option('Combo Break on Bad or Shit',
			"Bad and Shit ratings will result in a Combo Break.",
			'comboBreak',
			BOOL);
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
			"Pauses the game while unfocused.",
			'autoPause',
			BOOL);
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
			"Disables the RESET key in a song.",
			'noReset',
			BOOL);
		addOption(option);

		var option:Option = new Option('Sustains as One Note',
			"Long notes will act as a singular note.\nDisable this if you prefer the old input system.",
			'guitarHeroSustains',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny note goes \"Tick!\" when hit.',
			'hitsoundVolume',
			PERCENT);
		addOption(option);
		option.onPreview = onPreviewHitsoundVolume;
		option.playPreviewSound = false;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15.0;
		option.maxValue = 45.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15.0;
		option.maxValue = 90.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15.0;
		option.maxValue = 135.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			FLOAT);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onPreviewHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}