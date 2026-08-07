package options;

import options.*;
import options.Option.OptionType;

class GameplayChangersSubstate extends BaseOptionsMenu
{
	public static var modifiers:Array<Option> = [];

	public static function createOption(name:String, description:String = '', variable:String, type:OptionType = BOOL, defaultValue:Dynamic = null, options:Array<String> = null):Option {
		var option:Option = new Option(name, description, variable, type, defaultValue, options, true);
		return option;
	}

	public static function getOptions():Array<Option> {
		// use createOption, DO NOT USE new Option() HERE!!!!!!!
		var modArray:Array<Option> = [];
		var goption:Option = createOption('Scroll Type', 'Which scroll type would you like to play on?', 'scrolltype', STRING, 'multiplicative', ["multiplicative", "constant"]);
		modArray.push(goption);

		var option:Option = createOption('Scroll Speed', 'How fast should the chart be?\n\nThis option changes depending on the Scroll Type option.', 'scrollspeed', FLOAT, 1);
		option.scrollSpeed = 2.0;
		option.minValue = 0.35;
		option.changeValue = 0.05;
		option.decimals = 2;
		if (goption.getValue() != "constant") {
			option.displayFormat = '%vx';
			option.maxValue = 3;
		}
		else {
			option.displayFormat = "%v";
			option.maxValue = 6;
		}
		modArray.push(option);

		#if FLX_PITCH
		var option:Option = createOption('Playback Rate', 'How fast should the game be?', 'songspeed', FLOAT, 1);
		option.scrollSpeed = 1;
		option.minValue = 0.5;
		option.maxValue = 3.0;
		option.changeValue = 0.05;
		option.displayFormat = '%vx';
		option.decimals = 2;
		modArray.push(option);
		#end

		var option:Option = createOption('Health Gain Multiplier', 'How much health should you gain when hitting notes?', 'healthgain', FLOAT, 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vx';
		modArray.push(option);

		var option:Option = createOption('Health Loss Multiplier', 'How much health should you lose when hitting notes?', 'healthloss', FLOAT, 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0.5;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vx';
		modArray.push(option);

		modArray.push(createOption('Merciless', 'Instantly results in a game over upon the player receiving a Bad/Shit rating or a miss.', 'merciless', BOOL, false));
		modArray.push(createOption('Instakill on Miss', 'Instantly results in a game over upon the player receiving a miss.', 'instakill', BOOL, false));
		modArray.push(createOption('Practice Mode', 'Disables the game over.', 'practice', BOOL, false));
		modArray.push(createOption('Botplay', 'Watch a perfect bot play through the song.', 'botplay', BOOL, false));

		var option:Option = createOption('Play As Opponent', 'Play as the opponent.', 'opponentmode', BOOL, false);
		option.disallowedSongs = ['Mass Destruction', 'Specialist', 'Acceptance', 'Shadow', 'Confrontation', 'Awakening', 'Smashin'];
		modArray.push(option);
		return modArray;
	}

	public static function getModifierByName(name:String) {
		for (i in modifiers) {
			var mod:Option = i;
			if (mod.name == name)
				return mod;
		}
		return null;
	}

	public static function getModifierByVariable(variable:String) {
		for (i in modifiers) {
			var mod:Option = i;
			if (mod.variable == variable)
				return mod;
		}
		return null;
	}

	public function new(songOrWeek:String = '', storyMode:Bool = false) {
		useRPC = false;
		title = '';

		optionsArray = getOptions();

		super(songOrWeek, storyMode);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.camera = FlxG.camera;
		insert(0, bg);
	}
}