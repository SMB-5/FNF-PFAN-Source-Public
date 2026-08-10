package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.AttachedSprite;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import options.GameplayChangersSubstate as Changers;
import substates.MusicPlayerSubstate;
import substates.PersonaPrompt;
import substates.StickerSubState;

import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;

import openfl.utils.Assets;

import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var categories:Array<CategoryMetadata> = [];
	var songs:Array<SongMetadata> = [];

	public static var curCategory:Int = 1;
	private static var curSelected:Int = 1;
	var lerpSelected:Float = 0;
	var selector:FlxText;
	var curDifficulty:Int = 0; // Difficulty always 0 for now

	var catText:Alphabet;
	var leftArrow:Alphabet;
	var rightArrow:Alphabet;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var pickedRandom:Bool = false;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var grpTextBG:FlxTypedGroup<FlxSprite>;
	var rankSprites:Array<AttachedSprite> = [];
	private var curPlaying:Bool = false;

	var opponentMode(get, never):Bool;

	var bg:FlxSprite;
	var grid:FlxBackdrop;
	var songBG:FlxSprite;
	var bgHitbox:FlxObject;
	var bar:FlxSprite;

	var portrait:FlxSprite;

	private var dot:FlxTypedGroup<FlxSprite>;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var keyIcons:FlxTypedGroup<KeyIcon>;

	var backButton:BackButton;
	var modsButton:FlxSprite;
	var resetButton:FlxSprite;
	var musicButton:FlxSprite;

	var stickerSubState:StickerSubState;

	public function new(?stickers:StickerSubState = null)
	{
		super();
		stickerSubState = stickers;
	}

	override function create()
	{
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		reloadCategories();
		Difficulty.list = [Difficulty.getDefault()]; // Only normal difficulty for now

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (stickerSubState != null)
		{
			openSubState(stickerSubState);
			stickerSubState.degenStickers();
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if !mobile FlxG.mouse.visible = true; #end

		bg = new FlxSprite(-150, -110).loadGraphic(Paths.image('title-bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		add(bg);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		bgHitbox = new FlxObject(0, 100, (FlxG.width / 2) + 150, FlxG.height);
		add(bgHitbox);

		portrait = new FlxSprite();
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		add(portrait);
		portrait.scale.x = 0.45;
		portrait.scale.y = 0.45;

		songBG = new FlxSprite().loadGraphic(Paths.image('persona/menus/freeplay/songbg'));
		songBG.antialiasing = ClientPrefs.data.antialiasing;
		add(songBG);
		songBG.screenCenter();

		grpTextBG = new FlxTypedGroup<FlxSprite>();
		add(grpTextBG);
		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		bar = new FlxSprite().loadGraphic(Paths.image('persona/menus/freeplay/bar'));
		bar.antialiasing = ClientPrefs.data.antialiasing;
		add(bar);
		bar.screenCenter();

		catText = new Alphabet(50, 10, '', true);
		catText.scaleX = 0.6;
		catText.scaleY = 0.6;
		add(catText);

		leftArrow = new Alphabet(catText.x - 40, catText.y, '<', true);
		leftArrow.scaleX = 0.6;
		leftArrow.scaleY = 0.6;
		add(leftArrow);

		rightArrow = new Alphabet(catText.x + catText.width + 1, catText.y, '>', true);
		rightArrow.scaleX = 0.6;
		rightArrow.scaleY = 0.6;
		add(rightArrow);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.y = 20;
		add(scoreText);

		dot = new FlxTypedGroup<FlxSprite>();
		add(dot);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		regenerateSongs();
		Mods.loadTopMod();
		WeekData.setDirectoryFromWeek();

		if (curSelected >= songs.length) curSelected = 0;
		lerpSelected = curSelected;

		keyIcons = new FlxTypedGroup<KeyIcon>();
		add(keyIcons);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 24, 'dpad', 1, 'ui_select', 0.1, 24);
		keyIcons.add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 5, FlxG.height - 24, 'accept', 0, 'ui_confirm', 0.1, 24);
		keyIcons.add(acceptIcon);

		var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 5, FlxG.height - 24, 'back', 0, 'ui_back', 0.1, 24);
		keyIcons.add(backIcon);

		var controlIcon:KeyIcon = new KeyIcon(backIcon.x + backIcon.width + 5, FlxG.height - 24, controls.controllerMode ? 'START' : 'CONTROL', 0, 'ui_gmodifiers', 0.1, 24, true);
		keyIcons.add(controlIcon);

		var resetIcon:KeyIcon = new KeyIcon(controlIcon.x + controlIcon.width + 5, FlxG.height - 24, 'reset', 0, 'ui_reset', 0.1, 24);
		keyIcons.add(resetIcon);

		var previewIcon:KeyIcon = new KeyIcon(resetIcon.x + resetIcon.width + 5, FlxG.height - 24, controls.controllerMode ? 'Y' : 'SPACE', 0, 'ui_preview', 0.1, 24);
		keyIcons.add(previewIcon);
		#end

		backButton = new BackButton(FlxG.width - 150, 90);
		add(backButton);

		modsButton = new FlxSprite(FlxG.width / 2 - 10, FlxG.height / 2 + 170, Paths.image('modsButton'));
		modsButton.setGraphicSize(Std.int(modsButton.width * 0.9));
		add(modsButton);

		resetButton = new FlxSprite(modsButton.x - 35, modsButton.y - 150, Paths.image('resetButton'));
		resetButton.setGraphicSize(Std.int(resetButton.width * 0.9));
		add(resetButton);

		musicButton = new FlxSprite(resetButton.x - 35, resetButton.y - 150, Paths.image('musicButton'));
		musicButton.setGraphicSize(Std.int(musicButton.width * 0.9));
		add(musicButton);

		changeSelection(0, false);
		updateTexts();
		updateAllRanks();
		super.create();
	}

	function reloadCategories() {
		var directories:Array<String> = [];
		#if MODS_ALLOWED
		directories = [Paths.mods()];

		for (mod in Mods.parseList().enabled)
			directories.push(Paths.mods(mod + '/'));
		#end
		directories.push(Paths.getSharedPath());

		for (dir in directories) {
			dir += 'weeks/categories/';
			if (!FileSystem.exists(dir)) continue;

			var categoryList:Array<String> = CoolUtil.coolTextFile(dir + 'categoryList.txt');
			for (cat in categoryList) {
				var fileToCheck:String = dir + cat + '.json';
				if (FileSystem.exists(fileToCheck)) {
					var parsedCategory = haxe.Json.parse(File.getContent(fileToCheck));
					addCategory(parsedCategory.categoryName, cat, parsedCategory.weeks);
				}
			}

			for (file in FileSystem.readDirectory(dir)) {
				var path:String = haxe.io.Path.join([dir, file]);
				if (!FileSystem.isDirectory(path) && path.endsWith('.json')) {
					var parsedCategory = haxe.Json.parse(File.getContent(path));
					addCategory(parsedCategory.categoryName, file.substring(0, file.length - 5), parsedCategory.weeks);
				}
			}
		}
	}

	function addCategory(name:String, file:String, weeks:Array<String>) {
		for (category in categories) {
			if (category.categoryName == name) return;
		}
		categories.push(new CategoryMetadata(name, file, weeks));
	}

	function regenerateSongs(?start:String = '') {
		if (categories.length < 1) {
			catText.text = Language.getPhrase('no_categories', 'NO CATEGORIES FOUND');
			return;
		}
		for (sprite in dot.members)
    		sprite.destroy();
		dot.clear();
		for (i in 0...categories.length)
		{
			var catdot:AttachedSprite = new AttachedSprite('persona/menus/freeplay/seperator');
			catdot.antialiasing = ClientPrefs.data.antialiasing;
			//catdot.scale.x = 0.35;
			//catdot.scale.y = 0.1;
			catdot.updateHitbox();
			catdot.x = 180 + ((i - (categories.length - 1) / 2) * 20);
			catdot.y = 65;
			catdot.color = (i == curCategory) ? FlxColor.WHITE : FlxColor.GRAY;
			dot.add(catdot);
		}
		songs = [new SongMetadata("Random", 0, "Face", FlxColor.fromRGB(255, 255, 255))];
		catText.text = Language.getPhrase('category_${categories[curCategory].fileName}', categories[curCategory].categoryName);
		catText.scaleX = 0.6;
		if (catText.width > 350)
			catText.scaleX = 0.6 * (350 / catText.width);
		rightArrow.x = catText.x + catText.width + 15;
		for (i in 0...WeekData.weeksList.length) {
			if (weekIsLocked(WeekData.weeksList[i]) || !categories[curCategory].weeks.contains(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				if (start != null && start.length > 0)
				{
					var songName = song[0].toLowerCase();
					var s = start.toLowerCase();
					if (songName.startsWith(s)) addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				}
				else addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2])); //??????????
			}
		}
		MusicPlayerSubstate.songPlaylist = songs.copy();
		MusicPlayerSubstate.songPlaylist.remove(MusicPlayerSubstate.songPlaylist[0]); // Remove random
		regenList();
	}

	override function closeSubState() {
		changeSelection(0, false, false);
		updateAllRanks();
		FlxG.inputs.reset();
		keyIcons.visible = true;
		backButton.visible = true;
		if (!FlxG.sound.music.playing) FlxG.sound.music.play();
		super.closeSubState();
	}

	function updateAllRanks()
	{
		for (i in 0...songs.length)
		{
			var showOpponentScore:Bool = ClientPrefs.getGameplaySetting('opponentmode');
			if (Changers.getModifierByVariable('opponentmode')?.disallowedSongs?.contains(songs[i].songName)) {
				showOpponentScore = false;
			}
			var rating:Float = Highscore.getRating(songs[i].songName, curDifficulty, showOpponentScore);
			var rank = rankSprites[i];

			if (rank == null) continue;

			rank.loadGraphic(getRankGraphic(rating));
		}
	}

	function updateDots()
	{
    	for (i in 0...dot.members.length)
    	{
        	var catdot = dot.members[i];
        	if (catdot != null)
        	{
            	catdot.color = (i == curCategory) ? FlxColor.WHITE : FlxColor.GRAY;
        	}
    	}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function regenList() {
		rankSprites = [];

		for (item in grpSongs.members) item.destroy();
		for (sprite in grpTextBG.members) sprite.destroy();

		grpSongs.clear();
		grpTextBG.clear();
		_lastVisibles = [];

		for (i in 0...songs.length)
		{
			Mods.currentModDirectory = songs[i].folder;

			//had a clipping issue with the text ugh I hate flixel
			var songText:FlxText = new FlxText(90, 320, songs[i].songName + "\n ", 48);
			//songText.isPersonaItem = true; //what is this used for? -SMB
			songText.antialiasing = ClientPrefs.data.antialiasing;
			songText.ID = i;
			songText.setFormat(Paths.font("p5hatty-1.ttf"), 42, FlxColor.BLACK, LEFT);
			songText.autoSize = false;
			songText.textField.multiline = true;

			var textBG:AttachedSprite = new AttachedSprite('persona/menus/freeplay/textbg');
			textBG.antialiasing = ClientPrefs.data.antialiasing;
			textBG.scale.x = 0.35;
			textBG.scale.y = 0.1;
			textBG.updateHitbox();
			textBG.xAdd = -20;
			textBG.yAdd = -20;
			textBG.sprTracker = songText;
			textBG.color = songs[i].color;
			textBG.ID = i;

			var rank:AttachedSprite = new AttachedSprite('blank');
			rank.antialiasing = ClientPrefs.data.antialiasing;
			rank.scale.x = 0.3;
			rank.scale.y = 0.3;
			rank.updateHitbox();
			rank.xAdd = 290;
			rank.yAdd = -72;
			rank.sprTracker = songText;
			rankSprites.push(rank);

			grpTextBG.add(textBG);
			grpTextBG.add(rank);
			grpSongs.add(songText);
		}

		if (curSelected > songs.length - 1) curSelected = songs.length - 1;
		changeSelection();
		updateAllRanks();
	}

	var holdTime:Float = 0;
	var swiping:Bool = false;
	var prevSelected:Int = curSelected;
	#if mobile var justChanged:Bool = false; #end
	override function tryUpdate(elapsed:Float)
	{
		grid.x += 40 * elapsed;
		grid.y += 40 * elapsed;
		super.tryUpdate(elapsed);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (missingText.visible && (FlxG.keys.justPressed.ANY || TouchUtil.justPressed)) missingText.visible = missingTextBG.visible = false;

		if (!opponentMode) {
			scoreText.text = Language.getPhrase('personal_best', 'HIGHSCORE: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
		}
		else {
			scoreText.text = Language.getPhrase('personal_best_opponent', 'OPPONENT HIGHSCORE: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
		}
		positionHighscore();

		var pressedAccept:Bool = controls.ACCEPT;
		if (!pickedRandom)
		{			
			if (songs.length > 1)
			{
				if (FlxG.keys.justPressed.HOME || FlxG.keys.justPressed.END)
				{
					curSelected = FlxG.keys.justPressed.HOME ? 0 : songs.length - 1;
					changeSelection();
				}
				if (controls.UI_DOWN_P || controls.UI_UP_P)
				{
					changeSelection(controls.UI_DOWN_P ? shiftMult : -shiftMult);
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_DOWN ? shiftMult : -shiftMult), true, false);
				}
				else if (controls.UI_DOWN_R || controls.UI_UP_R) {
					if (holdTime > 0.5) {
						updatePortrait();
					}
					holdTime = 0;
				}

				if (FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}

				if (!swiping) {
					for (bg in grpTextBG) {
						if (rankSprites.contains(cast bg)) continue;
						if (TouchUtil.overlaps(bg) && TouchUtil.justReleased) {
							if (curSelected != bg.ID) {
								curSelected = bg.ID;
								changeSelection();
								updatePortrait();
							}
							else {
								pressedAccept = true;
							}
						}
					}
				}

				if ((TouchUtil.overlaps(bgHitbox) && TouchUtil.initiallyOverlapped(bgHitbox) || swiping) && TouchUtil.pressed) {
					@:privateAccess
					var leftInput = #if !mobile TouchUtil.input._leftButton #else TouchUtil.input #end;
					var offset:Float = leftInput.justPressedPosition.y - TouchUtil.input.getScreenPosition(FlxG.camera).y;
					if (Math.abs(offset) > 10) {
						if (!swiping) {
							prevSelected = curSelected;
						}
						swiping = true;
						lerpSelected = prevSelected + offset * 0.01;
						var boundSelected:Int = Math.round(FlxMath.bound(lerpSelected, 0, songs.length - 1));
						if (boundSelected != curSelected) {
							curSelected = boundSelected;
							changeSelection();
							updatePortrait();
						}
					}
				}
				else if (swiping) {
					swiping = false;
				}
			}

			var keyboardPressed:Bool = controls.UI_LEFT_P || controls.UI_RIGHT_P;
			var arrowPressed:Bool = (TouchUtil.overlaps(leftArrow) || TouchUtil.overlaps(rightArrow)) && TouchUtil.justPressed;
			#if mobile
			var swipePressed:Bool = TouchUtil.input != null && TouchUtil.overlapsPoint(catText, TouchUtil.input.justPressedPosition) && TouchUtil.justSwiped && !justChanged;
			#end

			if (keyboardPressed || arrowPressed #if mobile || swipePressed #end) {
				var wentLeft:Bool = controls.UI_LEFT_P || TouchUtil.overlaps(leftArrow);
				#if mobile
				if (TouchUtil.justSwiped && TouchUtil.swipe != null) wentLeft = TouchUtil.swipe.endPosition.x > TouchUtil.swipe.startPosition.x;
				#end
				curCategory = FlxMath.wrap(curCategory + (wentLeft ? -1 : 1), 0, categories.length - 1);
				regenerateSongs();
				#if mobile justChanged = true; #end
			}
			#if mobile else if (TouchUtil.justReleased && justChanged) justChanged = false; #end

			if (FlxG.keys.justPressed.CONTROL || FlxG.gamepads.anyJustPressed(START) || TouchUtil.overlaps(modsButton) && TouchUtil.justPressed)
			{
				keyIcons.visible = false;
				backButton.visible = false;
				openSubState(new Changers(songs[curSelected].songName));
			}
			else if ((controls.RESET || TouchUtil.overlaps(resetButton) && TouchUtil.justPressed) && songs[curSelected].songName.toLowerCase() != 'random')
			{
				keyIcons.visible = false;
				backButton.visible = false;
				openSubState(new substates.PersonaPrompt('reset_score', ()->{
					Highscore.resetSong(songs[curSelected].songName, curDifficulty,  opponentMode);
				}, ()->{}, 1.5, null, [songs[curSelected].songName + '?' + (opponentMode ? '\n(' + Language.getPhrase('Opponent') + ')' : '')]));
			}
			else if (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState(true), OUT_BOTTOM);
			}
			else if ((FlxG.keys.justPressed.SPACE || FlxG.gamepads.anyJustPressed(Y) || TouchUtil.overlaps(musicButton) && TouchUtil.justPressed) && songs[curSelected].songName.toLowerCase() != 'random')
			{
				keyIcons.visible = false;
				backButton.visible = false;
				openSubState(new MusicPlayerSubstate(curSelected - 1));
				FlxG.sound.music.pause();
			}
			else if (pressedAccept)
			{
				if (songs.length <= 1) {
					missingText.text = 'There are no songs to play!';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}

				if (songs[curSelected].songName.toLowerCase() == 'random')
				{
					changeSelection(FlxG.random.int(1, songs.length - 1, [curSelected]));
					pickedRandom = true;
					new FlxTimer().start(1, function(tmr) {
						LoadingState.prepareToSong();
						LoadingState.loadAndSwitchState(new PlayState());
						#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
					});
				}

				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

				try
				{
					Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;

					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				}
				catch(e:haxe.Exception)
				{
					trace('ERROR! ${e.message}');

					var errorStr:String = e.message;
					if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
					else errorStr += '\n\n' + e.stack;

					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}
				@:privateAccess
				if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
				{
					trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
					Paths.freeGraphicsFromMemory();
				}
				if (!pickedRandom) {
					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState());
					#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				}

				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			}
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true, portraitUpdate:Bool = true)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

		if (songs[curSelected] == null) return;
		Mods.currentModDirectory = songs[curSelected].folder;
		
		PlayState.storyWeek = songs[curSelected].week;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty, opponentMode);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty, opponentMode);
		#end
		positionHighscore();

		if (musicButton != null) musicButton.alpha = songs[curSelected].songName == 'Random' ? 0.4 : 1;
		if (resetButton != null) resetButton.alpha = songs[curSelected].songName == 'Random' ? 0.4 : 1;
		if (portraitUpdate) updatePortrait();
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function getRankGraphic(rating:Float):Dynamic
	{
		var percent:Float = rating * 100;

		if (percent >= 100)
			return Paths.image('persona/results/P');
		else if (percent >= 94.99)
			return Paths.image('persona/results/S');
		else if (percent >= 89.99)
			return Paths.image('persona/results/A');
		else if (percent >= 79.99)
			return Paths.image('persona/results/B');
		else if (percent >= 69.99)
			return Paths.image('persona/results/C');
		else if (percent >= 39.99)
			return Paths.image('persona/results/D');
		else if (percent >= 19.99)
			return Paths.image('persona/results/E');
		else if (percent >= 0.99)
			return Paths.image('persona/results/F');
		else 
			return Paths.image('blank');
	}

	//probably gonna change how this works in the future
	private function updatePortrait()
	{
		portrait.x = 800;
		portrait.y = -100;
		FlxTween.cancelTweensOf(portrait);
		if (songs[curSelected].songName.toLowerCase() == 'tartarus' || songs[curSelected].songName.toLowerCase() == 'foggy night')
		{
			portrait.loadGraphic(Paths.image('persona/portraits/makoto-portrait'));
			FlxTween.tween(portrait, {x: 400}, 0.3, {ease: FlxEase.expoOut});
		}
		else if (songs[curSelected].songName.toLowerCase() == 'truth')
		{
			portrait.loadGraphic(Paths.image('persona/portraits/yu-portrait'));
			FlxTween.tween(portrait, {x: 430}, 0.3, {ease: FlxEase.expoOut});
		}
		else if (songs[curSelected].songName.toLowerCase() == 'desire')
		{
			portrait.loadGraphic(Paths.image('persona/portraits/joker-portrait'));
			FlxTween.tween(portrait, {x: 430}, 0.3, {ease: FlxEase.expoOut});
			portrait.y = -200;
		}
		else
		{
			portrait.loadGraphic(Paths.image('persona/portraits/blank'));
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 10;
	}

	var _drawDistance:Int = 16;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:FlxText = grpSongs.members[i];
			item.visible = item.active = true;
			var baseX = ((item.ID - lerpSelected) * 15) + 50;
			var targetX = baseX + ((item.ID == curSelected) ? 60 : 0);
			item.y = ((item.ID - lerpSelected) * 1.3 * 80) + 350;

			var offsetX:Float = (item.ID == curSelected) ? 60 : 0;

			item.x = FlxMath.lerp(item.x, targetX, Math.exp(-elapsed * 12));

			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
	}

	function get_opponentMode():Bool
	{
		if (Changers.getModifierByVariable('opponentmode')?.disallowedSongs?.contains(songs[curSelected].songName)) {
			return false;
		}
		return ClientPrefs.getGameplaySetting('opponentmode');
	}
}

class CategoryMetadata
{
	public var categoryName:String = '';
	public var fileName:String = '';
	public var weeks:Array<String> = [];

	public function new(categoryName:String, fileName:String, weeks:Array<String>) {
		this.categoryName = categoryName;
		this.fileName = fileName;
		this.weeks = weeks;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if (this.folder == null) this.folder = '';
	}
}