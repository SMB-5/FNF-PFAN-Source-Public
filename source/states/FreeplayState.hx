package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;
import objects.AttachedSprite;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import substates.StickerSubState;

import flixel.math.FlxMath;
import flixel.util.FlxTimer;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 1;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var catText:Alphabet;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var picked_random = false;

	public static var mode:String = "story";

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var grpTextBG:FlxTypedGroup<FlxSprite>;
	var rankSprites:Array<AttachedSprite> = [];
	private var curPlaying:Bool = false;

	//private var iconArray:Array<HealthIcon> = [];
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	public static var opponentMode:Bool = false;
	public static var onDisallowedSong:Bool = false;

	var gameplayModifiers:Map<String, GameplayOption> = [];

	var bg:FlxSprite;
	var songBG:FlxSprite;
	var bar:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var portrait:FlxSprite;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var stickerSubState:StickerSubState;

	public function new(?stickers:StickerSubState = null)
	{
		super();
		stickerSubState = stickers;
	}

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

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

		var bg:FlxSprite = new FlxSprite(-150, -110).loadGraphic(Paths.image('title-bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		portrait = new FlxSprite().loadGraphic(Paths.image(''));
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		add(portrait);
		portrait.x = 400;
		portrait.y = -100;
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
		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		bar = new FlxSprite().loadGraphic(Paths.image('persona/menus/freeplay/bar'));
		bar.antialiasing = ClientPrefs.data.antialiasing;
		add(bar);
		bar.screenCenter();

		catText = new Alphabet(0, 0, '', true);
		catText.screenCenter(X);
		catText.x = 0;
		catText.y = 10;
		catText.scaleX = 0.8;
		catText.scaleY = 0.8;
		add(catText);

		switch(mode)
		{
			case 'story':
				catText.text = "< Main Story >";
			case 'freeplay':
				catText.text = "< Side Stories >";
			case 'all':
				catText.text = "< All >";
		}

		//if (mode == "cover")
		//{
		//catText.text = "     < Covers >";
		//}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.y = 20;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		//add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		//add(diffText);

		add(scoreText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		regenerateSongs('');
		Mods.loadTopMod();
		WeekData.setDirectoryFromWeek();

		if(curSelected >= songs.length) curSelected = 0;
		//bg.color = songs[curSelected].color;
		//intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);

		for (option in GameplayChangersSubstate.getOptions())
		{
			gameplayModifiers.set(option.variable, option);
			if (option.variable.toLowerCase() == 'opponentmode')
			{
				opponentMode = ClientPrefs.getGameplaySetting('opponentmode');
				if (opponentMode && option.disallowedSongs.contains(Paths.formatToSongPath(songs[curSelected].songName)))
					opponentMode = false;
			}
		}

		changeSelection();
		updatePortrait();
		updateTexts();
		updateAllRanks();
		super.create();
	}

	function regenerateSongs(?start:String = '') {
		songs = [new SongMetadata("Random", 0, "Face", FlxColor.fromRGB(255, 255, 255))];
		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			// weeks in story mode category
			// wtf
			if (mode == "story" && 
				WeekData.weeksList[i] != "week1" && 
				WeekData.weeksList[i] != "week2" && 
				WeekData.weeksList[i] != "week3" &&
				WeekData.weeksList[i] != "week4" &&
				WeekData.weeksList[i] != "week5") continue;
			// Weeks in freeplay category
			if (mode == "freeplay" && 
				WeekData.weeksList[i] != "bonusp5") continue;
			// Weeks in cover category
			//if (mode == "cover" && WeekData.weeksList[i] != "covers") continue;
			// All of the weeks (yes it has to be specified)
			if (mode == "all" && 
				WeekData.weeksList[i] != "week1" && 
				WeekData.weeksList[i] != "week2" && 
				WeekData.weeksList[i] != "week3" &&
				WeekData.weeksList[i] != "week4" &&
				WeekData.weeksList[i] != "week5" && 
				WeekData.weeksList[i] != "bonusp5" &&
				WeekData.weeksList[i] != "extras") continue;

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
				if(colors == null || colors.length < 3)
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
		regenList();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		updateAllRanks();
		super.closeSubState();
	}

	function updateAllRanks()
	{
		for (i in 0...songs.length)
		{
			var rating:Float = Highscore.getRating(songs[i].songName, curDifficulty, opponentMode);
			var rank = rankSprites[i];

			if (rank == null) continue;

			rank.loadGraphic(getRankGraphic(rating));
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
		//curSelected = 0;
		rankSprites = [];

		for (item in grpSongs.members) item.destroy();
		for (sprite in grpTextBG.members) sprite.destroy();
		for (obj in grpIcons.members) obj.destroy();

		//thank you melodie -SMB
		grpSongs.clear();
		_lastVisibles = [];

		for (i in 0...songs.length)
		{
			Mods.currentModDirectory = songs[i].folder;

			//had a clipping issue with the text ugh I hate flixel
			var songText:FlxText = new FlxText(90, 320, songs[i].songName + "\n ", 48);
			//songText.isPersonaItem = true; //what is this used for? -SMB
			songText.ID = i;
			songText.setFormat(Paths.font("p5hatty-1.ttf"), 42, FlxColor.BLACK, LEFT);
			songText.autoSize = false;
			songText.textField.multiline = true;
			//songText.targetY = (i - curSelected);

			//songText.scaleX = Math.min(0.8, 480 / songText.width);

			//songText.x += 60;
			//songText.y += 320;
			//songText.scaleX = 0.8;
			//songText.scaleY = 0.8;
			//songText.startPosition.set(songText.x, songText.y);

			//songText.snapToPosition();

			var textbg: AttachedSprite = new AttachedSprite('persona/menus/freeplay/textbg');
			textbg.antialiasing = ClientPrefs.data.antialiasing;
			textbg.xAdd = songText.x - 520;
			textbg.yAdd = songText.y - 660;
			textbg.scale.x = 0.35;
			textbg.scale.y = 0.1;
			textbg.sprTracker = songText;
			textbg.color = songs[i].color;

			var rank: AttachedSprite = new AttachedSprite('blank');
			rank.antialiasing = ClientPrefs.data.antialiasing;
			rank.xAdd = songText.x + 210;
			rank.yAdd = songText.y - 390;
			rank.scale.x = 0.3;
			rank.scale.y = 0.3;
			rank.sprTracker = songText;

			var rating:Float = Highscore.getRating(songs[i].songName, curDifficulty, opponentMode);

			rank.loadGraphic(getRankGraphic(rating));

			rankSprites.push(rank);

			grpTextBG.add(textbg);
			grpTextBG.add(rank);
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.ID = i;
			//grpIcons.add(icon);
		}

		changeSelection();
		updatePortrait();
		changeDiff();
		updateAllRanks();
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
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
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic)
		{
			if(opponentMode)
			{
				scoreText.text = 'OPPONENT HIGHSCORE: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			}
			else
			{
				scoreText.text = 'HIGHSCORE: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			}
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P && !picked_random)
				{
					changeSelection(-shiftMult);
					updatePortrait();
					holdTime = 0;
				}
				if (controls.UI_DOWN_P && !picked_random)
				{
					changeSelection(shiftMult);
					updatePortrait();
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					updatePortrait();
				}
			}

			if ((controls.UI_RIGHT_P) && !picked_random)
			{
				changeDiff(controls.UI_RIGHT_P ? -1 : 1);
				_updateSongLastDifficulty();

				if (mode == "story")
				{
					mode = "freeplay";
					trace('loaded bonus songs');
					regenerateSongs('');
					catText.text = "< Side Stories >";
				}
				else if (mode == "freeplay")
				{
					mode = "all";
					trace('loaded every single song');
					regenerateSongs('');
					catText.text = "< All >";
				}
				//else if (mode == "freeplay")
				//{
					//mode = "cover";
					//trace('loaded covers');
					//regenerateSongs('');
					//catText.text = "     < Covers >";
				//}
				else if (mode == "all")
				{
					mode = "story";
					trace('loaded story songs');
					regenerateSongs('');
					catText.text = "< Main Story >";
				}
			}
			// Literally the opposite as above
			if ((controls.UI_LEFT_P) && !picked_random)
			{
				changeDiff(controls.UI_LEFT_P ? -1 : 1);
				_updateSongLastDifficulty();

				if (mode == "story")
				{
					mode = "all";
					trace('loaded every single song');
					regenerateSongs('');
					catText.text = "< All >";
				}
				else if (mode == "all")
				{
					mode = "freeplay";
					trace('loaded bonus songs');
					regenerateSongs('');
					catText.text = "< Side Stories >";
				}
				//else if (mode == "freeplay")
				//{
					//mode = "cover";
					//trace('loaded covers');
					//regenerateSongs('');
					//catText.text = "     < Covers >";
				//}
				else if (mode == "freeplay")
				{
					mode = "story";
					trace('loaded story songs');
					regenerateSongs('');
					catText.text = "< Main Story >";
				}
			}
		}
		else if (controls.UI_UP_P || controls.UI_DOWN_P) changeDiff();

		if (controls.BACK)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate(this));
		}
		else if(FlxG.keys.justPressed.SPACE && songs[curSelected].songName.toLowerCase() != 'random')
		{
			if(instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					FlxG.sound.list.add(vocals);
					vocals.persist = true;
					vocals.looped = true;
				}
				else if (vocals != null)
				{
					vocals.stop();
					vocals.destroy();
					vocals = null;
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				if(vocals != null) //Sync vocals to Inst
				{
					vocals.play();
					vocals.volume = 0.8;
				}
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(player.paused);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			if (songs[curSelected].songName.toLowerCase() == 'random')
			{
				changeSelection(FlxG.random.int(1, songs.length - 1, [curSelected]));
				picked_random = true;
				new FlxTimer().start(1, function(tmr) {
					LoadingState.loadAndSwitchState(new PlayState());
				});
			}

			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			var shouldSave:Bool = false;
			for (option in gameplayModifiers)
			{
				if (option.disallowedSongs.contains(songLowercase) && option.getValue() != option.defaultValue)
				{
					option.setValue(option.defaultValue);
					shouldSave = true;
				}
			}
			if (shouldSave) ClientPrefs.saveSettings();

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				//updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			if (!picked_random)
				LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		//if (player.playingMusic)
			//return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty, opponentMode);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty, opponentMode);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected] == null) return;
		Mods.currentModDirectory = songs[curSelected].folder;

		for (i in grpIcons.members) i.alpha = (i.ID == curSelected ? 1 : 0.6);

		//for (item in grpSongs.members)
		//{
			//item.ID = item.ID - curSelected;
			//item.alpha = 0.6;
            //if (item.ID == 0) item.alpha = 1;
		//}
		
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		if (gameplayModifiers.get('opponentmode') != null)
		{
			if (opponentMode && gameplayModifiers.get('opponentmode').disallowedSongs?.contains(Paths.formatToSongPath(songs[curSelected].songName)))
			{
				opponentMode = false;
				onDisallowedSong = true;
			}
			else if (onDisallowedSong && !gameplayModifiers.get('opponentmode').disallowedSongs?.contains(Paths.formatToSongPath(songs[curSelected].songName)))
			{
				opponentMode = true;
				onDisallowedSong = false;
			}
		}

		changeDiff();
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
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
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 16;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			//iconArray[i].visible = iconArray[i].active = false;
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

			//var icon:HealthIcon = iconArray[i];
			//icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
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
		if(this.folder == null) this.folder = '';
	}
}