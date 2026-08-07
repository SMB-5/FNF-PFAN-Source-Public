package options;

import openfl.utils.Assets;

class LanguageSubState extends MusicBeatSubstate
{
	#if TRANSLATIONS_ALLOWED
	var grpLanguages:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var languages:Array<String> = [];
	var displayLanguages:Map<String, String> = [];
	var curSelected:Int = 0;
	var maxPerRow:Int = 4;
	var backButton:BackButton;
	public function new()
	{
		super();

		add(grpLanguages);

		var directories:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/');
		for (directory in directories)
		{
			for (file in FileSystem.readDirectory(directory))
			{
				if(file.toLowerCase().endsWith('.lang'))
				{
					var langFile:String = file.substring(0, file.length - '.lang'.length).trim();
					if(!languages.contains(langFile))
						languages.push(langFile);

					if(!displayLanguages.exists(langFile))
					{
						var path:String = '$directory/$file';
						#if MODS_ALLOWED 
						var txt:String = File.getContent(path);
						#else
						var txt:String = Assets.getText(path);
						#end

						var id:Int = txt.indexOf('\n');
						if(id > 0) //language display name shouldnt be an empty string or null
						{
							var name:String = txt.substr(0, id).trim();
							if(!name.contains(':')) displayLanguages.set(langFile, name);
						}
						else if(txt.trim().length > 0 && !txt.contains(':')) displayLanguages.set(langFile, txt.trim());
					}
				}
			}
		}

		languages.sort(function(a:String, b:String)
		{
			a = (displayLanguages.exists(a) ? displayLanguages.get(a) : a).toLowerCase();
			b = (displayLanguages.exists(b) ? displayLanguages.get(b) : b).toLowerCase();
			if (a < b) return -1;
			else if (a > b) return 1;
			return 0;
		});

		//trace(ClientPrefs.data.language);
		curSelected = languages.indexOf(ClientPrefs.data.language);
		if(curSelected < 0)
		{
			//trace('Language not found: ' + ClientPrefs.data.language);
			ClientPrefs.data.language = ClientPrefs.defaultData.language;
			curSelected = Std.int(Math.max(0, languages.indexOf(ClientPrefs.data.language)));
		}

		var rows:Int = Std.int(Math.min(Math.ceil(languages.length / maxPerRow), 3));
		for (i => lang in languages)
		{
			var flag = new FlxSprite(0, 0, Paths.image('languages/$lang'));
			flag.setGraphicSize(250, 125);
			flag.updateHitbox();
			flag.screenCenter();
			flag.ID = i;
			flag.color = 0xFF878787;
			var curRow = Math.floor(i / maxPerRow);
			var offset = i % maxPerRow - (Math.min(3, languages.length - 1)) / 2;
			flag.x = (FlxG.width - flag.width) / 2 + (offset * 300);
			flag.y = (FlxG.height - flag.height) / 2 + ((curRow - (rows - 1) / 2) * 200);
			if (curRow > 3) {
				flag.y += 200 * (curRow - 3);
			}
			grpLanguages.add(flag);
		}

		backButton = new BackButton();
		add(backButton);

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_LEFT_P) {
			if (curSelected != 0) changeSelection(-1);
		}
		if (controls.UI_RIGHT_P) {
			if (curSelected > 0 && curSelected - 1 % maxPerRow != 0) changeSelection(1);
		}
		if (controls.UI_DOWN_P) {
			if (curSelected + 4 < grpLanguages.length - 1) changeSelection(4);
		}
		if (controls.UI_UP_P) {
			if (curSelected > 3) changeSelection(-4);
		}

		if(controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		var pressedAccept:Bool = controls.ACCEPT;
		for (option in grpLanguages) {
			if (TouchUtil.overlaps(option, FlxG.camera)) {
				#if mobile if (TouchUtil.justPressed) #end
				{
					if (curSelected != option.ID) {
						curSelected = option.ID;
						changeSelection();
					}
					else #if !mobile if (TouchUtil.justPressed) #end
						pressedAccept = true;
				}
			}
		}
		if(pressedAccept)
		{
			FlxG.sound.play(Paths.sound('confirmMenu')).persist = true;
			ClientPrefs.data.language = languages[curSelected];
			ClientPrefs.saveSettings();
			Language.reloadPhrases();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new MainMenuOptions(true));
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = Std.int(FlxMath.bound(curSelected + change, 0, languages.length - 1));
		for (num => lang in grpLanguages)
		{
			lang.color = 0xFF878787;
			if (num == curSelected) lang.color = 0xFFFFFFFF;
		}
	}
	#end
}