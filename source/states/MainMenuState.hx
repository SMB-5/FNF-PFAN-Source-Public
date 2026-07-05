package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import substates.PersonaCardSubstate;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;

	var optionShit:Array<String> = [
		'STORY MODE',
		'FREEPLAY',
		'AWARDS',
		'GALLERY',
		'CREDITS',
		'CONFIG'
	];

	var bgHitboxes:Array<FlxObject> = [];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var textBG:FlxSprite;

	var stickerSubState:Bool;

	var bf:FlxSprite;
	var makoto:FlxSprite;
	var yu:FlxSprite;
	var joker:FlxSprite;

	public function new(?stickers:Bool = false)
	{
		super();
		stickerSubState = stickers;
	}

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

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-150, -150).loadGraphic(Paths.image('menuWall'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		textBG = new FlxSprite().makeGraphic(450, 75, FlxColor.BLACK);
		add(textBG);
		textBG.antialiasing = ClientPrefs.data.antialiasing;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 248 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxText = new FlxText(30, (i * 80) + offset, "", 48);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.text = Language.getPhrase('menu_${optionShit[i]}', optionShit[i]);
			menuItems.add(menuItem);
			var color = FlxColor.WHITE;

			if (optionShit[i] == 'STORY MODE' || optionShit[i] == 'AWARDS')
			{
				color = FlxColor.GRAY;
			}

			menuItem.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, color, LEFT);

			var hitbox = new FlxObject(0, menuItem.getMidpoint().y - 37.5, textBG.width, textBG.height);
			hitbox.ID = i;
			add(hitbox);
			bgHitboxes.push(hitbox);
		}

		bf = new FlxSprite(650, 100);
		bf.frames = Paths.getSparrowAtlas('persona/menus/mainmenu/BF-Menu');
		bf.animation.addByPrefix('idle', 'menu_idle', 24, false);
        bf.updateHitbox();

		makoto = new FlxSprite(650, 100);
		makoto.frames = Paths.getSparrowAtlas('persona/menus/mainmenu/Makoto-Menu');
		makoto.animation.addByPrefix('idle', 'menu_idle', 24, false);
        makoto.updateHitbox();

		yu = new FlxSprite(600, 100);
		yu.frames = Paths.getSparrowAtlas('persona/menus/mainmenu/Yu-Menu');
		yu.animation.addByPrefix('idle', 'menu_idle', 24, false);
        yu.updateHitbox();

		joker = new FlxSprite(300, 50);
		joker.frames = Paths.getSparrowAtlas('persona/menus/mainmenu/Joker-Menu');
		joker.animation.addByPrefix('idle', 'menu_idle', 24, false);
        joker.updateHitbox();

		var randomChar:Int = FlxG.random.int(1, 4);

		//it'd be funny if they're number was their game number minus bf, gf and the rest of the characters
		switch (randomChar)
		{
    		case 1:
        		add(bf);
    		case 2:
        		add(joker);
			case 3:
        		add(makoto);
			case 4:
        		add(yu);
		}

		var pfanVer:FlxText = new FlxText(12, FlxG.height - 154, 0, "Persona: Funkin' All Night v" + Application.current.meta.get('version'), 12);
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

		FlxG.camera.follow(camFollow, null, 9);
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
			for (hitbox in bgHitboxes) {
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
				if (optionShit[curSelected] == 'STORY MODE' || optionShit[curSelected] == 'AWARDS')
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
							//case 'story_mode':
								//MusicBeatState.switchState(new StoryMenuState());
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
			bf.animation.play('idle');
			makoto.animation.play('idle');
			yu.animation.play('idle');
			joker.animation.play('idle');
		}

		lastBeatHit = curBeat;
	}

	override function closeSubState() {
		selectedSomethin = false;
		super.closeSubState();
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, getItemColor(curSelected), LEFT, 48);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, getItemColor(curSelected), LEFT, 48);

		//camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
		menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0);
		textBG.x = 0;
		textBG.y = menuItems.members[curSelected].getMidpoint().y - 37.5;
	}

	function getItemColor(index:Int):FlxColor
	{
		if (optionShit[index] == 'STORY MODE' || optionShit[index] == 'AWARDS')
			return FlxColor.GRAY;

		return FlxColor.WHITE;
	}
}
