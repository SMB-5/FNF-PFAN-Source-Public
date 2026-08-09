package options;

typedef Keybind = {
	keyboard:String,
	gamepad:String
}

enum OptionType {
	BOOL;
	INT;
	FLOAT;
	PERCENT;
	STRING;
	KEYBIND;
	BUTTON;
}

class Option
{
	public var child:FlxText;
	public var text(get, set):String;
	public var onChange:Void->Void = null; //Pressed enter (on Bool type options) or pressed/held left/right (on other types)
	public var onPreview:Void->Void = null; //Adds a preview button that calls this function
	public var onOpen:Void->Void = null; //Only works on BUTTON type, calls this function when the button is pressed
	public var type:OptionType = BOOL;
	public var gameplayOption:Bool = false; //Checks ClientPrefs.data.gameplaySettings instead of ClientPrefs.data

	public var buttonText:String = 'Open'; //Only used on BUTTON type, the text to show on the button. This can be a translation phrase or just a regular string

	public var playPreviewSound:Bool = true; //Used when pressing the preview button, decides if the confirmMenu sound should be played when pressing the button. This only exists because of hitsound volume lol

	public var customizable:Bool = false; //Adds a setting button and allows a substate to be opened to be used as extra customization for an option (Different from SUBSTATE which only opens a substate AS the option)
	public var customizationClass:Class<Dynamic>; //Class used for customizable

	public var scrollSpeed:Float = 50; //Only works on int/float/percent, defines how fast it scrolls per second while holding left/right
	public var variable(default, null):String = null; //Variable from ClientPrefs.hx. Can be NULL if you simply want an option without a variable attached to it
	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; //Don't change this
	public var options:Array<String> = null; //Only used in string type
	public var changeValue:Dynamic = 1; //Only used in int/float type, how much is changed when you PRESS
	public var minValue:Dynamic = null; //Only used in int/float type
	public var maxValue:Dynamic = null; //Only used in int/float type
	public var decimals:Int = 1; //Only used in float type

	// You don't need to change this variable as it will automatically change by checking all of the 3 disallowed conditions
	public var disallowed:Bool = false; //Changes option to the default value if any of the 3 disallowed conditions are true
	public var disallowedSongs:Array<String> = null;
	public var disallowStoryMode:Bool = false;
	public var disallowFreeplay:Bool = false;

	public var displayFormat:String = '%v'; //How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value
	public var description:String = '';
	public var name:String = 'Unknown';

	public var defaultKeys:Keybind = null; //Only used in keybind type
	public var keys:Keybind = null; //Only used in keybind type

	public function new(name:String, description:String = '', variable:String, type:OptionType = BOOL, defaultValue:Dynamic = null, options:Array<String> = null, gameplayOption:Bool = false)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;
		this.gameplayOption = gameplayOption;

		if (this.type != KEYBIND && this.defaultValue == null && variable != null) {
			if (gameplayOption)
				this.defaultValue = ClientPrefs.defaultData.gameplaySettings.get(variable);
			else
				this.defaultValue = Reflect.getProperty(ClientPrefs.defaultData, variable);
		}
		switch(type)
		{
			case BOOL:
				if (this.defaultValue == null) this.defaultValue = false;
			case INT, FLOAT:
				if (this.defaultValue == null) this.defaultValue = 0;
			case PERCENT:
				if (this.defaultValue == null) this.defaultValue = 1;
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
			case STRING:
				if (options != null && options.length > 0)
					this.defaultValue = options[0];
				if (this.defaultValue == null)
					this.defaultValue = '';

			case KEYBIND:
				this.defaultValue = '';
				defaultKeys = {gamepad: 'NONE', keyboard: 'NONE'};
				keys = {gamepad: 'NONE', keyboard: 'NONE'};

			default:
		}

		try
		{
			if(getValue() == null)
				setValue(this.defaultValue);
	
			switch(type)
			{
				case STRING:
					var num:Int = options.indexOf(getValue());
					if(num > -1) curOption = num;

				default:
			}
		}
		catch(e) {}
	}

	public function change()
	{
		if(onChange != null)
			onChange();
	}

	public function preview()
	{
		if(onPreview != null)
			onPreview();
	}

	public function open()
	{
		if(onOpen != null)
			onOpen();
	}

	dynamic public function getValue():Dynamic
	{
		if (variable == null) return null;
		var value:Dynamic;
		if (gameplayOption)
			value = ClientPrefs.data.gameplaySettings.get(variable);
		else
			value = Reflect.getProperty(ClientPrefs.data, variable);

		if (type == KEYBIND) return !Controls.instance.controllerMode ? value.keyboard : value.gamepad;
		return value;
	}

	dynamic public function setValue(value:Dynamic)
	{
		if (variable == null) return null;
		if (type == KEYBIND)
		{
			var keys;
			if (gameplayOption)
				keys = ClientPrefs.data.gameplaySettings.get(variable);
			else
				keys = Reflect.getProperty(ClientPrefs.data, variable);

			if(!Controls.instance.controllerMode) keys.keyboard = value;
			else keys.gamepad = value;
			return value;
		}

		if (gameplayOption)
			ClientPrefs.data.gameplaySettings.set(variable, value);
		else
			Reflect.setProperty(ClientPrefs.data, variable, value);

		return value;
	}

	var _text:String = null;
	private function get_text()
		return _text;

	private function set_text(newValue:String = '')
	{
		if(child != null)
		{
			_text = newValue;
			child.text = Language.getPhrase('setting_$name-${getValue()}', _text);
			return _text;
		}
		return null;
	}
}