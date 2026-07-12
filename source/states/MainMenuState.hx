package states;

import flixel.FlxObject;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import substates.PersonaCardSubstate;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';
	public static var curSelected:Int = 0;
	public static var curChar:String = '';

	var menuItems:FlxTypedGroup<FlxText>;
	var optionShit:Array<String> = [
		'STORY MODE',
		'FREEPLAY',
		'AWARDS',
		'GALLERY',
		'CREDITS',
		'CONFIG'
	];
	var optionHitboxes:Array<FlxObject> = [];
	var textBG:FlxSprite;

	var characters:Array<String> = [
		'BF',
		'Joker',
		'Makoto',
		'Yu'
	];
	var menuChar:FlxSprite;
	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
		}

		Conductor.bpm = 125;

		persistentUpdate = false;
		persistentDraw = true; 

		var bg:FlxSprite = new FlxSprite(-150, -150).loadGraphic(Paths.image('menuWall'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		textBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		textBG.antialiasing = ClientPrefs.data.antialiasing;
		add(textBG);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 248 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxText = new FlxText(30, (i * 80) + offset, Language.getPhrase('menu_${optionShit[i]}', optionShit[i]), 48);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, getItemColor(i), LEFT);
			menuItems.add(menuItem);

			var hitbox = new FlxObject(0, menuItem.getMidpoint().y - 37.5, menuItem.width + 50, 75);
			hitbox.ID = i;
			add(hitbox);
			optionHitboxes.push(hitbox);
		}

		curChar = characters[FlxG.random.int(0, characters.length - 1)];
		var x:Float = 650;
		var y:Float = 100;
		switch(curChar) {
			case 'Joker':
				x -= 400;
				y -= 50;
		}

		menuChar = new FlxSprite(x, y).setFrames(Paths.getSparrowAtlas('persona/menus/mainmenu/$curChar-Menu'));
		menuChar.animation.addByPrefix('idle', 'menu_idle', 24, false);
		add(menuChar);

		var pfanVer:FlxText = new FlxText(12, FlxG.height - 154, 0, "Persona: Funkin' All Night v" + FlxG.stage.application.meta.get('version'), 12);
		pfanVer.scrollFactor.set();
		pfanVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pfanVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 134, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 114, 0, "Friday Night Funkin' v0.2.8", 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		#if mobile
		pfanVer.y = FlxG.height - 64;
		psychVer.y = FlxG.height - 44;
		fnfVer.y = FlxG.height - 24;
		#end

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(0, FlxG.height - 44, 'movement', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.width + 30, FlxG.height - 44, 'accept', 1, 'ui_confirm', 0.15, 24);
		add(acceptIcon);

		FlxG.mouse.visible = true;
		#end

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;
	var canFadeIn:Bool = true;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8 && canFadeIn)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			var pressedAccept:Bool = controls.ACCEPT;
			for (hitbox in optionHitboxes) {
				if (TouchUtil.overlaps(hitbox, FlxG.camera)) {
					#if mobile if (TouchUtil.justPressed) { #end
					if (curSelected != hitbox.ID) {
						curSelected = hitbox.ID;
						changeItem();
					}
					else #if !mobile if (TouchUtil.justPressed) #end {
						pressedAccept = true;
					}
					#if mobile } #end
				}
			}

			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (pressedAccept)
			{
				if (getItemColor(curSelected) == FlxColor.GRAY)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					selectedSomethin = true;
					new FlxTimer().start(0.5, function(tmr) {
						openSubState(new PersonaCardSubstate("LockedDemo"));
					});
				}
				else
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					selectedSomethin = true;

					if (optionShit[curSelected] == 'CREDITS')
					{
						canFadeIn = false;
						FlxG.sound.music.fadeOut(1, 0);
					}

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						switch (optionShit[curSelected])
						{
							case 'FREEPLAY':
								MusicBeatState.switchState(new FreeplayState());

							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end

							case 'GALLERY':
								MusicBeatState.switchState(new GalleryState());

							case 'CREDITS':
								MusicBeatState.switchState(new CreditsState());

							case 'CONFIG':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			menuChar.animation.play('idle');
		}

		lastBeatHit = curBeat;
	}

	override function closeSubState() {
		selectedSomethin = false;
		super.closeSubState();
	}

	function changeItem(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		textBG.y = menuItems.members[curSelected].getMidpoint().y - 37.5;
		textBG.setGraphicSize(menuItems.members[curSelected].width + 50, 75);
		textBG.updateHitbox();
	}

	function getItemColor(index:Int):FlxColor
	{
		if (optionShit[index] == 'STORY MODE' || optionShit[index] == 'AWARDS')
			return FlxColor.GRAY;

		return FlxColor.WHITE;
	}
}
