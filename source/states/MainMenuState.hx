package states;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import options.MainMenuOptions;
import substates.PersonaCardSubstate;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';
	public static var curSelected:Int = 0;
	public static var curChar:String = '';
	public static var characters:Array<String> = [
		'BF',
		'Joker',
		'Makoto',
		'Yu'
	];

	public var transIn:Bool = false;

	var bg:FlxBackdrop;
	var topBG:FlxSprite;
	var topGradient:FlxSprite;

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

	var menuChar:FlxSprite;

	public function new(transIn:Bool = false) {
		super();
		this.transIn = transIn;
	}

	override function create()
	{
		if (transIn) FlxTransitionableState.skipNextTransOut = true;
		super.create();

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

		bg = new FlxBackdrop(Paths.image('menuWall'), X);
		bg.setPosition(-150, -150);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		topBG = new FlxSprite(0, 0, Paths.image('menuWall'));
		topBG.y -= topBG.height;
		topBG.flipY = true;
		topBG.antialiasing = ClientPrefs.data.antialiasing;
		add(topBG);

		topGradient = FlxGradient.createGradientFlxSprite(Std.int(topBG.width), Std.int(topBG.height), [FlxColor.BLACK, 0x0]);
		topGradient.y = topBG.y;
		topGradient.antialiasing = ClientPrefs.data.antialiasing;
		add(topGradient);

		textBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		textBG.antialiasing = ClientPrefs.data.antialiasing;
		add(textBG);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 248 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxText = new FlxText(30, (i * 80) + offset, 0, Language.getPhrase('menu_${optionShit[i]}', optionShit[i]), 48);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.setFormat(Paths.font("FOT-Rodin Pro EB.otf"), 48, getItemColor(i), LEFT);
			menuItems.add(menuItem);

			var hitbox = new FlxObject(0, menuItem.getMidpoint().y - 37.5, menuItem.width + 50, 75);
			hitbox.ID = i;
			add(hitbox);
			optionHitboxes.push(hitbox);
		}

		// precache all chars
		for (char in characters) Paths.image('persona/menus/mainmenu/$char-Menu');
		if (MainMenuOptions.curChar == null) curChar = characters[FlxG.random.int(0, characters.length - 1)];
		menuChar = new FlxSprite().setFrames(Paths.getSparrowAtlas('persona/menus/mainmenu/$curChar-Menu'));
		menuChar.setPosition(getCharPosition(curChar).x, getCharPosition(curChar).y);
		menuChar.animation.addByPrefix('idle', 'menu_idle', 24, false);
		add(menuChar);

		var pfanVer:FlxText = new FlxText(12, FlxG.height - 154, 0, "Persona: Funkin' All Night v" + FlxG.stage.application.meta.get('version'), 12);
		pfanVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pfanVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 134, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 114, 0, "Friday Night Funkin' v0.2.8", 12);
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		#if mobile
		pfanVer.y = FlxG.height - 64;
		psychVer.y = FlxG.height - 44;
		fnfVer.y = FlxG.height - 24;
		#end

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad_up_down', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_confirm', 0.15, 24);
		add(acceptIcon);

		FlxG.mouse.visible = true;
		#end

		changeItem(0, false);

		for (i => menuItem in menuItems) {
			menuItem.offset.x += menuItem.textField.textWidth + 150;
			FlxTween.tween(menuItem.offset, { x: menuItem.offset.x - menuItem.textField.textWidth - 150 }, 0.35, { ease: FlxEase.circInOut, startDelay: 0.05 * i });
		}
		textBG.x -= textBG.width + 150;
		FlxTween.tween(textBG, { x: textBG.x + textBG.width + 150 }, 0.35, { ease: FlxEase.circInOut, startDelay: 0.05 * curSelected });

		if (transIn) {
			FlxG.camera.scroll.y -= bg.height * 2;
			FlxTween.tween(FlxG.camera.scroll, { y: FlxG.camera.scroll.y + bg.height * 2 }, 1, { ease: FlxEase.cubeInOut });
		}

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end
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
					#if mobile if (TouchUtil.justPressed) #end
					{
						if (curSelected != hitbox.ID) {
							curSelected = hitbox.ID;
							changeItem();
						}
						else #if !mobile if (TouchUtil.justPressed) #end
							pressedAccept = true;
					}
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

					if (optionShit[curSelected] != 'CONFIG')
					{
						MainMenuOptions.curChar = null;
						var newState:FlxState = null;
						switch (optionShit[curSelected])
						{
							case 'FREEPLAY':
								newState = new FreeplayState();
							case 'GALLERY':
								newState = new GalleryState();
							case 'CREDITS':
								newState = new CreditsState();
								canFadeIn = false;
								FlxG.sound.music.fadeOut(0.35, 0);
						}

						if (newState != null)
						{
							FlxTween.cancelTweensOf(FlxG.camera);
							FlxTween.tween(FlxG.camera.scroll, { y: FlxG.camera.scroll.x - bg.height * 2 }, 1, { ease: FlxEase.cubeInOut, onComplete:t->{
								MusicBeatState.switchState(newState);
							} });
						}
					}
					else
					{
						playTransition();
						OptionsState.onPlayState = false;
						if (PlayState.SONG != null)
						{
							PlayState.SONG.arrowSkin = null;
							PlayState.SONG.splashSkin = null;
							PlayState.stageUI = 'normal';
						}
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

	public static function getCharPosition(char:String = '', side:String = 'right'):FlxPoint
	{
		side = side.toLowerCase();
		var point:FlxPoint = FlxPoint.get(side == 'right' ? 650 : 100, 100);
		switch(char) {
			case 'BF' if (side == 'left'):
				point.x -= 100;
			case 'Joker':
				point.x -= side == 'right' ? 400 : 50;
				point.y -= 50;
		}
		return point;
	}

	function playTransition()
	{
		if (MainMenuOptions.curChar == null) {
			MainMenuOptions.curChar = characters[FlxG.random.int(0, characters.length - 1, [characters.indexOf(curChar)])];
		}
		var secondChar = new FlxSprite().setFrames(Paths.getSparrowAtlas('persona/menus/mainmenu/' + MainMenuOptions.curChar + '-Menu'));
		secondChar.setPosition(getCharPosition(MainMenuOptions.curChar, 'left').x, getCharPosition(MainMenuOptions.curChar, 'left').y);
		secondChar.flipX = true;
		secondChar.x += bg.width * 2;
		secondChar.animation.addByPrefix('idle', 'menu_idle', 24, false);
		secondChar.animation.play('idle');
		add(secondChar);
		FlxTween.tween(FlxG.camera.scroll, { x: FlxG.camera.scroll.x + bg.width * 2 }, 1.25, { ease: FlxEase.cubeInOut, onComplete:t->{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new options.MainMenuOptions());
		} });
	}

	function changeItem(change:Int = 0, playSound:Bool = true)
	{
		FlxTween.completeTweensOf(textBG);
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
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
