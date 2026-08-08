package options;

class LanguageSubState extends MusicBeatSubstate
{
	#if TRANSLATIONS_ALLOWED
	var inOptions:Bool = true;
	var grpLanguages:FlxTypedGroup<FlxSprite>;
	var languages:Array<String> = [];
	var curSelected:Int = 0;
	var maxPerRow:Int = 4;
	var backButton:BackButton;
	public function new(inOptions:Bool = true) {
		this.inOptions = inOptions;
		super();
	}

	override function create() {
		super.create();
		#if !mobile FlxG.mouse.visible = true; #end

		grpLanguages = new FlxTypedGroup<FlxSprite>();
		add(grpLanguages);

		languages = Language.getLanguages();

		//trace(ClientPrefs.data.language);
		curSelected = languages.indexOf(ClientPrefs.data.language);
		if (curSelected < 0) {
			//trace('Language not found: ' + ClientPrefs.data.language);
			ClientPrefs.data.language = ClientPrefs.defaultData.language;
			curSelected = Std.int(Math.max(0, languages.indexOf(ClientPrefs.data.language)));
		}

		var rows:Int = Std.int(Math.min(Math.ceil(languages.length / maxPerRow), 3));
		for (i => lang in languages) {
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

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_confirm', 0.15, 24);
		add(acceptIcon);

		if (inOptions) {
			var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 10, FlxG.height - 44, 'back', 0, 'ui_close', 0.15, 24);
			add(backIcon);
		}
		#end

		if (inOptions) {
			backButton = new BackButton();
			add(backButton);
		}

		changeSelection(0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_LEFT_P) {
			if (curSelected != 0) changeSelection(-1);
		}
		if (controls.UI_RIGHT_P) {
			if (curSelected == 0 || ((curSelected + 1) * maxPerRow) % maxPerRow != 0) changeSelection(1);
		}
		if (controls.UI_DOWN_P) {
			if (curSelected + 4 < grpLanguages.length - 1) changeSelection(4);
		}
		if (controls.UI_UP_P) {
			if (curSelected > 3) changeSelection(-4);
		}

		if (inOptions && (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)) {
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

		if (pressedAccept) {
			FlxG.sound.play(Paths.sound('confirmMenu')).persist = true;
			ClientPrefs.data.language = languages[curSelected];
			ClientPrefs.saveSettings('language');
			Language.reloadPhrases();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			if (inOptions) MusicBeatState.switchState(new MainMenuOptions(true));
			else close();
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected = Std.int(FlxMath.bound(curSelected + change, 0, languages.length - 1));
		for (num => lang in grpLanguages) {
			lang.color = 0xFF878787;
			if (num == curSelected) lang.color = 0xFFFFFFFF;
		}
	}
	#end
}