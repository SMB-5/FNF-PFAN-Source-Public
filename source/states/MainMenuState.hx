package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import substates.PersonaCardSubstate;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
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

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var textbg:FlxSprite;

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

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = false;
		persistentDraw = true; 

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-150, -150).loadGraphic(Paths.image('menuWall'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		//bg.scrollFactor.set(0, yScroll);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		//bg.updateHitbox();
		//bg.screenCenter();
		add(bg);

		//camFollow = new FlxObject(0, 0, 1, 1);
		//add(camFollow);

		textbg = new FlxSprite().makeGraphic(Std.int(450), Std.int(75), FlxColor.BLACK);
		add(textbg);
		textbg.antialiasing = ClientPrefs.data.antialiasing;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 258 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxText = new FlxText(30, (i * 80) + offset, "", 48);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.text = optionShit[i];
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			var color = FlxColor.WHITE;

    		if (optionShit[i] == 'STORY MODE' || optionShit[i] == 'AWARDS')
    		{
        		color = FlxColor.GRAY;
    		}

			menuItem.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, color, LEFT);
		}

		var pfanVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Persona: Funkin' All Night v" + Application.current.meta.get('version'), 12);
		pfanVer.scrollFactor.set();
		pfanVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pfanVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v0.2.8", 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			//if (controls.BACK)
			//{
				//selectedSomethin = true;
				//FlxG.sound.play(Paths.sound('cancelMenu'));
				//MusicBeatState.switchState(new TitleState());
			//}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'STORY MODE' || optionShit[curSelected] == 'AWARDS')
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					new FlxTimer().start(0.5, function(tmr) {
						openSubState(new PersonaCardSubstate("LockedDemo"));
					});
				}
				else
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					selectedSomethin = true;

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

		super.update(elapsed);
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
		textbg.x = 0;
		textbg.y = menuItems.members[curSelected].getMidpoint().y - 37.5;
	}

	function getItemColor(index:Int):FlxColor
	{
    	if (optionShit[index] == 'STORY MODE' || optionShit[index] == 'AWARDS')
        	return FlxColor.GRAY;

    	return FlxColor.WHITE;
	}
}
