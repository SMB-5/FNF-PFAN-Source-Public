package states;

import flixel.FlxObject;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	static var defaultList:Array<Array<Dynamic>> = [
		// Name - Icon name - Role(s), Description - Link - Card Color - FlipX (set to false if the original icon isn't facing the right)
		['Persona: Funkin All Night'],
		['A Friday Night Funkin\' Mod by The Funkin Thieves'],
		['Programmers'],
		['SMB', 'SMB', 'Director, Main Programmer', 'Hey thank you so much for playing! I hope you enjoyed the mod as much as we did making it.', 'https://smb-bio.carrd.co/', 0xFFEC1C26],
		['Cobalt', 'cobalt', 'Programmer', 'I\'ve never heard of Persona before this mod, but I coded for it anyway. VS Github Actions is next.', 'https://cobaltbar.github.io/', 0xFF0065FF],
		['melodiekit', 'melodiekit', 'Programmer, Mobile Porter, Charter', 'Hi!\n\nI coded some of the UI that you see here like the Music Player, Credits Menu, Options Menu, etc lol\nI also tried my best to replicate the cool UI that Persona has, like their transitions... Whether it actually looks good or not is up to you\n\nI also charted Tartarus and Foggy Night. Let it be known that I only charted Tartarus because it was the same name of a Geometry Dash extreme demon :troll:.\n\nRegardless, I hope you enjoyed the mod as much as I had fun coding it!\n\nOh yeah I also made the mobile port I guess that\'s important', 'https://youtube.com/@melodiekit', 0xFFC0EBFF],
		['NotMagniill', 'bobbo', 'Programmer, Artist', 'I\'m a devil muehehehe... also SMB no offense your code sucks', 'https://twitter.com/magniill', 0xFF640911],
		['Musicians'],
		['Dog', 'doggo', 'Musician', 'Hi! I composed a few songs for le epic persona mod, like Truth, Game Over!! and the main menu theme! Hope you enjoyed listening to them! If you want to hear more of my music, press enter to go to my channel!', 'https://www.youtube.com/@you-know-its-dog.', 0xFFF5D79D, false],
		['MrEights', '', 'Musician', 'It ain\'t easy being cheesy!', 'https://www.youtube.com/@Mr3ights', 0xFF1E1E1E],
		['Artists'],
		['Clefanight', 'clefa', 'Artist, Animator, Charter', 'How the fuck did I even get here.', 'https://cremiesilver.newgrounds.com/', 0xFF11E92B],
		['Charters'],
		['DudeDX', 'dudedx', 'Charter', 'why are oranges called oranges, but an apple is not called red?', 'https://fakecrime.bio/dudeDX', 0xFF009116, false],
		['Chromatic Makers'],
		['NoahGani1', 'noah', 'Chromatic Maker', 'Say Gex.', 'https://x.com/noah_gani1', 0xFF203A53],
		['Contributors'],
		['Fearmonger Wade', 'g', 'Artist, Coder', 'Hii, I didn\'t do much for this mod really asides from 2 results screens but it was still really fun. Thanks for playing.', 'https://linktr.ee/ghostbnuuy', 0xFFE1E1E1, false],
		['JuhoSprite', 'juho', 'Artist', 'I don\'t play games.', 'https://twitter.com/JuhoSprite', 0xFFFD0FE3],
		['Special Thanks'],
		['DanthUltima', '', 'Made the Aigis Chromatic', '', 'https://gamebanana.com/members/2049728', 0xFFFFFFFF],
		['Mikolka9144', 'mikolka', 'Ported the soundtray and screenshot plugin to Psych Engine', '', 'https://gamebanana.com/members/3329541', 0xFF2EBCFA],
		['Moonlight_Catalyst', 'moonlight_catalyst', 'Ported ghost notes and constant scoring to Psych Engine', '', 'https://www.youtube.com/channel/ucmvsorfe7zldig4budmzela', 0xFF9764B7],
		['Pumpsuki', '', 'Hold Note Splashes Code', '', 'https://www.youtube.com/channel/UCGX_SXBkNjJqjh43KVVvdzg', 0xFFFFFFFF],
		/*
		[''],
		["Psych Engine Team"],
		["Shadow Mario",		"shadowmario",		"Main Programmer and Head of Psych Engine",					"https://ko-fi.com/shadowmario",	"444444"],
		["Riveren",				"riveren",			"Main Artist/Animator of Psych Engine",						"https://x.com/riverennn",			"14967B"],
		[""],
		["Former Engine Members"],
		["bb-panzu",			"bb",				"Ex-Programmer of Psych Engine",							"https://x.com/bbsub3",				"3E813A"],
		[""],
		["Engine Contributors"],
		["crowplexus",			"crowplexus",		"HScript Iris, Input System v3, and Other PRs",				"https://github.com/crowplexus",	"CFCFCF"],
		["Kamizeta",			"kamizeta",			"Creator of Pessy, Psych Engine's mascot.",				"https://www.instagram.com/cewweey/",	"D21C11"],
		["MaxNeton",			"maxneton",			"Loading Screen Easter Egg Artist/Animator.",	"https://bsky.app/profile/maxneton.bsky.social","3C2E4E"],
		["Keoiki",				"keoiki",			"Note Splash Animations and Latin Alphabet",				"https://x.com/Keoiki_",			"D2D2D2"],
		["SqirraRNG",			"sqirra",			"Crash Handler and Base code for\nChart Editor's Waveform",	"https://x.com/gedehari",			"E1843A"],
		["EliteMasterEric",		"mastereric",		"Runtime Shaders support and Other PRs",					"https://x.com/EliteMasterEric",	"FFBD40"],
		["MAJigsaw77",			"majigsaw",			".MP4 Video Loader Library (hxvlc)",						"https://x.com/MAJigsaw77",			"5F5F5F"],
		["Tahir Toprak Karabekiroglu",	"tahir",	"Note Splash Editor and Other PRs",							"https://x.com/TahirKarabekir",		"A04397"],
		["iFlicky",				"flicky",			"Composer of Psync and Tea Time\nAnd some sound effects",	"https://x.com/flicky_i",			"9E29CF"],
		["KadeDev",				"kade",				"Fixed some issues on Chart Editor and Other PRs",			"https://x.com/kade0912",			"64A250"],
		["superpowers04",		"superpowers04",	"LUA JIT Fork",												"https://x.com/superpowers04",		"B957ED"],
		["CheemsAndFriends",	"cheems",			"Creator of FlxAnimate",									"https://x.com/CheemsnFriendos",	"E1E1E1"],
		[""],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",						 'https://twitter.com/ninja_muffin99',	'CF2D2D'],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",							 'https://twitter.com/PhantomArcade3K',	'FADC45'],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",							 'https://twitter.com/evilsk8r',		'5ABD4B'],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",							 'https://twitter.com/kawaisprite',		'378FC7']*/
	];
	var list:Array<Array<Dynamic>> = [];

	var curSelected:Int = 0;
	var curID:Int = 0;
	var scrollCredits:Bool = true;
	#if mobile
	var prevSelected:Int = 0;
	var prevCamPos:Float = 0;
	var swiping:Bool = false;
	#end

	var titleGroup:FlxTypedSpriteGroup<FlxText>;
	var creditsGroup:FlxTypedSpriteGroup<FlxText>;
	var iconArray:Array<AttachedSprite> = [];
	var baldipliers:Array<Array<Dynamic>> = [['baldiplier', 'bald', 0xFF577099], ['daldiplier', 'dark', 0xFF3f3f3f], ['golden-baldiplier', 'golden', 0xFFFFFF48]];

	var camFollow:FlxObject;

	var arrow:FlxText;

	#if mobile
	var backButton:BackButton;
	#end

	override function create() {
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...defaultList.length) {
			list[i] = [];
			for (k in 0...defaultList[i].length) {
				list[i].push(defaultList[i][k]);
			}
		}

		if (FlxG.random.bool(0.5)) {
			var baldArray:Array<Dynamic> = FlxG.random.getObject(baldipliers, [90, 25, 5]);
			if (baldArray != null) {
				for (arr in list) {
					if (arr[0] == 'melodiekit') {
						arr[1] = baldArray[0];
						arr[3] = 'Hello. You caught me on my day off. Anyways, make sure to keep your pliers ${baldArray[1]}.';
						arr[5] = baldArray[2];
						arr[6] = false;
						break;
					}
				}
			}
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		arrow = new FlxText(65, 0, 100, '>', 30);
		arrow.font = Paths.font('p5hatty-1.ttf');
		arrow.visible = false;
		add(arrow);

		titleGroup = new FlxTypedSpriteGroup<FlxText>();
		add(titleGroup);

		creditsGroup = new FlxTypedSpriteGroup<FlxText>();
		add(creditsGroup);
	
		var offset = 0;
		for (i in 0...list.length) {
			if (list[i].length <= 1 && i != 0) offset += 30;
			if (i == 2) offset += 30;
			var yValue:Float = 32 * i + offset;
			var name:FlxText = new FlxText(50 + (list[i].length > 1 ? 15 : 0), yValue, FlxG.width, list[i][0], i == 0 ? 46 : list[i].length <= 1 ? 38 : 34);
			name.font = Paths.font('p5hatty-1.ttf');
			name.borderStyle = OUTLINE;
			name.ID = i;
			if (list[i].length <= 1) {
				titleGroup.add(name);
				continue;
			}
			else creditsGroup.add(name);

			var icon:AttachedSprite = new AttachedSprite();
			var imagePath:String = 'credits/${list[i][1]}';
			if (!FileSystem.exists(Paths.getPath('images/$imagePath.png'))) imagePath = 'icons/icon-bf';
			var graphic = Paths.image(imagePath);
			var iSize:Float = Math.round(graphic.width / graphic.height);
			icon.loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
			icon.animation.add("idle", [for (i in 0...icon.frames.frames.length) i], 0, false, list[i][6] != null ? list[i][6] == 'false' : false);
			icon.animation.play('idle');
			icon.setGraphicSize(35, 35);
			icon.updateHitbox();
			icon.sprTracker = name;
			icon.xAdd += name.textField.textWidth + 5;
			icon.yAdd -= name.textField.textHeight / 3 - 5;
			iconArray.push(icon);
			add(icon);
		}

		var tipString:String = #if mobile 'Swipe to select a member\nTap to view a member\'s status' #else 'Press UP or DOWN to select a member\nPress ACCEPT to view a member\'s status' #end;
		var tipText:FlxText = new FlxText(0, 0, FlxG.width, tipString, 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		tipText.y = FlxG.height - 22 - tipText.textField.textHeight;
		tipText.scrollFactor.set();
		add(tipText);

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2 - FlxG.height, 1, 1);

		#if mobile
		backButton = new BackButton();
		backButton.scrollFactor.set();
		add(backButton);
		#end

		FlxG.sound.playMusic(Paths.music('persona/songs from the games/P5/Beneath-the-Mask-instrumental'), 0.7);

		super.create();

		FlxG.camera.follow(camFollow, LOCKON, 0.2);
		FlxG.camera.snapToTarget();
	}

	var timeSinceLastInput:Float = 0;
	var holdTime:Float = 0;
	var exiting:Bool = false;
	override function update(elapsed:Float) {
		timeSinceLastInput += elapsed;

		if (scrollCredits) {
			camFollow.y += 60 * elapsed;
			for (i => credit in creditsGroup.group.keyValueIterator()) {
				if (credit.getScreenPosition().y <= FlxG.height / 3.25) curSelected = i;
			}
		}
		else {
			if (timeSinceLastInput >= 5) scroll();
		}

		var pressedAccept:Bool = controls.ACCEPT;
		#if mobile
		if (!swiping) {
			if (TouchUtil.justReleased && !TouchUtil.overlaps(backButton)) {
				timeSinceLastInput = 0;
				pressedAccept = true;
			}
		}
		#end

		if (creditsGroup.length > 1) {
			#if mobile
			if (TouchUtil.pressed) {
				timeSinceLastInput = 0;
				var offset:Float = TouchUtil.input.justPressedPosition.y - TouchUtil.input.getScreenPosition(FlxG.camera).y;
				if (Math.abs(offset) > 10) {
					if (!swiping) {
						prevSelected = curSelected;
						prevCamPos = creditsGroup.members[curSelected].y - 225;
						if (scrollCredits) changeSelection(0);
					}
					swiping = true;
					var floatSelected:Float = prevSelected + offset * 0.015;
					camFollow.y = FlxG.height / 2 + prevCamPos + offset;
					var boundSelected:Int = Math.round(FlxMath.bound(floatSelected, 0, creditsGroup.length - 1));
					if (boundSelected != curSelected) {
						curSelected = boundSelected;
						changeSelection();
					}
				}
			}
			else if (swiping) {
				swiping = false;
				camFollow.y = FlxG.height / 2 + creditsGroup.members[curSelected].y - 225;
			}
			#end

			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

			if (controls.UI_DOWN_P || controls.UI_UP_P) {
				if (scrollCredits) changeSelection(0);
				else changeSelection(controls.UI_DOWN_P ? 1 : -1);
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP) {
				timeSinceLastInput = 0;

				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) {
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}
		}

		if (!scrollCredits && pressedAccept) {
			openSubState(new substates.MemberCardSubstate(list[curID][0], list[curID][1], list[curID][2], list[curID][3], list[curID][4], list[curID][5], list[curID][6] ?? true));
			timeSinceLastInput = 0;
		}

		if (!exiting && (scrollCredits && camFollow.y >= FlxG.height / 2 + creditsGroup.height + 200 || controls.BACK #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.justPressed #end)) {
			exiting = true;
			FlxG.sound.music.fadeOut(0.25, 0);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}

	override function destroy() {
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
		super.destroy();
	}

	function changeSelection(change:Int = 0) {
		scrollCredits = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = Std.int(FlxMath.bound(curSelected + change, 0, creditsGroup.length - 1));
		curID = creditsGroup.members[curSelected].ID;
		for (i => credit in creditsGroup.group.keyValueIterator()) {
			credit.x = i == curSelected ? 85 : 65;
		}
		arrow.visible = true;
		arrow.y = creditsGroup.members[curSelected].y + 3;
		if (!swiping) camFollow.y = FlxG.height / 2 + creditsGroup.members[curSelected].y - 225;
	}

	function scroll() {
		scrollCredits = true;
		arrow.visible = false;
		creditsGroup.members[curSelected].x = 65;
	}
}
