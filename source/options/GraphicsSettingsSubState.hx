package options;

import objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'GRAPHICS');
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'Disables some background details, but improves performance and loading times.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'Smooths out the edges of sprites, removing jagged edges and sharpening them.\nThis will increase performance if enabled.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			"Enables shaders which enhance the visuals.\nNot recommended to be enabled if you have a low-end device as this heavily uses up your CPU.", //Description
			'shaders',
			BOOL);
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"Uses the GPU for caching purposes which will decrease RAM usage.\nNot recommended to be enabled if you have a bad graphics card.", //Description
			'cacheOnGPU',
			BOOL);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"The FPS at which the game will run on.",
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing()
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}
}