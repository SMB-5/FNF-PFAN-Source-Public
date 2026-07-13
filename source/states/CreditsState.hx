package states;

import flixel.FlxObject;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import objects.AttachedSprite;

typedef MemberFile =
{
	var icon:String;
	var flipIcon:Bool;
	var section:Array<String>;
	var role:String;
	var description:String;
	var link:String;
	var color:String;
}

typedef CreditFile =
{
	var title:String;
	var subtitle:String;
	var sections:Array<String>;
	var members:Dynamic;
}

class CreditsState extends MusicBeatState
{
	var credit:CreditFile;
	var memberList:Array<Array<Dynamic>> = [];

	var curSelected:Int = 0;
	var scrollCredits:Bool = true;
	#if mobile
	var prevSelected:Int = 0;
	var prevCamPos:Float = 0;
	var swiping:Bool = false;
	#end

	var titleGroup:FlxTypedSpriteGroup<FlxText>;
	var creditsGroup:FlxTypedSpriteGroup<Member>;
	var baldiplierGroup:Array<Array<String>> = [['baldiplier', 'bald', '577099'], ['daldiplier', 'dark', '3F3F3F'], ['golden-baldiplier', 'golden', 'FFFF48']];

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

		credit = getCreditData();
		if (credit == null) {
			trace('No credits found... returning back to menu');
			FlxG.switchState(new MainMenuState());
			return;
		}
		var arr = Reflect.fields(credit.members);
		arr.sort((a:String, b:String)->{
			if (a.toLowerCase() < b.toLowerCase()) return -1;
			else if (a.toLowerCase() > b.toLowerCase()) return 1;
			else return 0;
		});
		for (i => member in arr) {
			// why is haxe physically incapable of sorting maps
			memberList[i] = [member, Reflect.field(credit.members, member)];
		}

		var bigStinkyLoser:MemberFile = getMember('melodiekit');
		if (FlxG.random.bool(2) && bigStinkyLoser != null) {
			// Baldiplier arrives.
			var curBaldiplier:Array<String> = FlxG.random.getObject(baldiplierGroup, [90, 25, 5]);
			if (curBaldiplier != null) {
				bigStinkyLoser.icon = curBaldiplier[0];
				bigStinkyLoser.flipIcon = true;
				bigStinkyLoser.description = bigStinkyLoser.description.replace('Watch out for &Baldiplier&...', 'Make sure to keep your pliers &' + curBaldiplier[1] + '&.');
				bigStinkyLoser.color = curBaldiplier[2];
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

		var title:FlxText = new FlxText(50, 0, FlxG.width, credit.title, 46);
		title.font = Paths.font('p5hatty-1.ttf');
		title.borderStyle = OUTLINE;
		titleGroup.add(title);

		var subtitle:FlxText = new FlxText(50, 62, FlxG.width, credit.subtitle, 38);
		subtitle.font = Paths.font('p5hatty-1.ttf');
		subtitle.borderStyle = OUTLINE;
		titleGroup.add(subtitle);

		creditsGroup = new FlxTypedSpriteGroup<Member>();
		add(creditsGroup);

		var offset:Float = 0;
		for (i => section in credit.sections) {
			var sectionTxt:FlxText = new FlxText(50, 156 + (60 * i) + offset, FlxG.width, section, 38);
			sectionTxt.font = Paths.font('p5hatty-1.ttf');
			sectionTxt.borderStyle = OUTLINE;
			titleGroup.add(sectionTxt);

			var offsetText:Float = 0;
			for (member in memberList) {
				if (member == null || !member[1].section.contains(section)) continue;
				var memberText:Member = new Member(member[0], member[1].icon, member[1].flipIcon, member[1].role, member[1].description, member[1].link, member[1].color);
				offsetText += memberText.textField.textHeight + 3;
				memberText.y = sectionTxt.y + offsetText;
				creditsGroup.add(memberText);
				offset += memberText.textField.textHeight + 3;
			}
		}
		
		var tipString:String = #if mobile Language.getPhrase('credits_tip_mobile', 'Swipe to select a member\nTap to view a member\'s status') #else Language.getPhrase('credits_tip', 'Press UP or DOWN to select a member\nPress ACCEPT to view a member\'s status') #end;
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
			camFollow.y += 70 * elapsed;
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
					var floatSelected:Float = prevSelected + offset * 0.0175;
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
			openSubState(new substates.MemberCardSubstate(creditsGroup.members[curSelected]));
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

	public static function getCreditData():CreditFile {
		if (!FileSystem.exists(Paths.getSharedPath('data/credits.json'))) return null;
		try {
			var json:CreditFile = haxe.Json.parse(File.getContent(Paths.getSharedPath('data/credits.json')));
			return json;
		}
		catch(e:Dynamic) {
			trace('errored: $e');
			return null;
		}
	}

	function changeSelection(change:Int = 0) {
		scrollCredits = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = Std.int(FlxMath.bound(curSelected + change, 0, creditsGroup.length - 1));
		for (i => credit in creditsGroup.group.keyValueIterator()) {
			credit.x = i == curSelected ? 85 : 65;
		}
		arrow.visible = true;
		arrow.y = creditsGroup.members[curSelected].y + 3;
		#if mobile if (!swiping) #end camFollow.y = FlxG.height / 2 + creditsGroup.members[curSelected].y - 225;
	}

	function scroll() {
		scrollCredits = true;
		arrow.visible = false;
		creditsGroup.members[curSelected].x = 65;
	}

	function getMember(name:String):MemberFile {
		for (member in memberList) {
			if (member[0] == name) return member[1];
		}
		return null;
	}
}

class Member extends FlxText
{
	public var name:String;
	public var icon:String;
	public var iconSprite:AttachedSprite;
	public var flipIcon:Bool;
	public var role:String;
	public var description:String;
	public var link:String;
	public var cardColor:String;

	public function new(name:String, icon:String, flipIcon:Bool = false, role:String, description:String, link:String, cardColor:String) {
		this.name = name;
		this.icon = icon;
		this.flipIcon = flipIcon;
		this.role = role;
		this.description = description;
		this.link = link;
		this.cardColor = cardColor;
		super(65, 0, FlxG.width, name, 34);
		font = Paths.font('p5hatty-1.ttf');
		borderStyle = OUTLINE;

		iconSprite = new AttachedSprite();
		var imagePath:String = 'credits/$icon';
		if (!FileSystem.exists(Paths.getPath('images/$imagePath.png'))) imagePath = 'icons/icon-bf';
		var graphic = Paths.image(imagePath);
		var iSize:Float = Math.round(graphic.width / graphic.height);
		iconSprite.loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
		iconSprite.animation.add("idle", [for (i in 0...iconSprite.frames.frames.length) i], 0, false, flipIcon);
		iconSprite.animation.play('idle');
		iconSprite.setGraphicSize(35, 35);
		iconSprite.updateHitbox();
		iconSprite.sprTracker = this;
		iconSprite.xAdd += this.textField.textWidth + 5;
		iconSprite.yAdd -= this.textField.textHeight / 3 - 5;
	}

	override function draw() {
		super.draw();
		if (iconSprite != null) iconSprite.draw();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (iconSprite != null) iconSprite.update(elapsed);
	}
}