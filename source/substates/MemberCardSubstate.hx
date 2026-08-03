package substates;

import flixel.addons.display.FlxBackdrop;

import states.CreditsState.Member;

class MemberCardSubstate extends MusicBeatSubstate
{
	var name:String;
	var icon:String;
	var role:String;
	var description:String;
	var link:String;
	var color:FlxColor;
	var flipX:Bool = true;

	var camCard:FlxCamera;
	var camDesc:FlxCamera;

	var bg:FlxSprite;
	var cardBG:FlxSprite;
	var cardBG2:FlxSprite;
	var cardBG3:FlxSprite;
	var descBox:FlxSprite;
	var descOutline:FlxSprite;
	var scrollBar:FlxSprite;
	var iconSprite:FlxSprite;
	var iconSilhouette:FlxBackdrop;
	var statusHeader:FlxText;
	var statusHeader2:FlxText;
	var nameTxt:FlxText;
	var roleHeader:FlxText;
	var roleTxt:FlxText;
	var descHeader:FlxText;
	var descTxt:FlxText;
	var backIcon:KeyIcon;
	#if !mobile
	var acceptIcon:KeyIcon;
	#else
	var acceptTxt:FlxText;
	#end

	#if mobile
	var backButton:BackButton;
	#end

	var allowScrolling:Bool = false;
	var scrollTimer:Float = 0;
	var scrollTween:FlxTween;
	var holdingBox:Bool = false;
	#if mobile var prevMouseY:Float = 0; #end

	public function new(member:Member) {
		super();
		this.name = member.name;
		this.icon = member.icon;
		this.role = member.role;
		this.description = member.description;
		this.link = member.link;
		this.color = CoolUtil.colorFromString(member.cardColor);
		this.flipX = !member.flipIcon;
	}

	override function create() {
		FlxG.sound.play(Paths.sound('persona/deck_ui_toast'));

		camCard = new FlxCamera(0, 0, 953, 580);
		camCard.x = (FlxG.width - camCard.width) / 2;
		camCard.y = (FlxG.height - camCard.height) / 2;
		camCard.bgColor.alpha = 0;
		FlxG.cameras.add(camCard, false);

		camDesc = new FlxCamera();
		camDesc.bgColor.alpha = 0;
		FlxG.cameras.add(camDesc, false);

		cameras = [camCard];

		var color2:FlxColor = color;
		color2.brightness += color.brightness > 0.5 ? -0.25 : 0.25;

		var color3:FlxColor = color;
		color3.brightness += color2.brightness >= 0.5 ? -0.35 : 0.35;
		color3.saturation += color.saturation > 0.5 ? -0.25 : 0.25;

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.scrollFactor.set();
		bg.camera = FlxG.camera;
		bg.alpha = 0.6;
		add(bg);

		cardBG = new FlxSprite().makeGraphic(Std.int(camCard.width), Std.int(camCard.height + 1), color);
		add(cardBG);

		cardBG2 = new FlxSprite(0, 65).makeGraphic(Std.int(cardBG.width), Std.int(cardBG.height / 3), 0xFF00293F);
		add(cardBG2);

	 	cardBG3 = new FlxSprite().makeGraphic(Std.int(cardBG.width), Std.int(cardBG.height / 7.5), 0xFFFEBD5F);
		add(cardBG3);

		descBox = new FlxSprite(55, camCard.height - 255).makeGraphic(450, 200, color3);
		add(descBox);

		camDesc.x = descBox.x + camCard.x;
		camDesc.y = descBox.y + camCard.y;
		camDesc.width = Std.int(descBox.width);
		camDesc.height = Std.int(descBox.height);

		var imagePath:String = 'credits/$icon';
		if (!FileSystem.exists(Paths.getPath('images/$imagePath.png'))) imagePath = 'icons/icon-bf-classic';
		var graphic = Paths.image(imagePath);
		var iSize:Float = Math.round(graphic.width / graphic.height);
		iconSprite = new FlxSprite().loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
		iconSprite.animation.add("idle", [for (i in 0...iconSprite.frames.frames.length) i], 0, false, flipX);
		iconSprite.animation.play('idle');
		iconSprite.setGraphicSize(247, 247);
		iconSprite.updateHitbox();
		iconSprite.setPosition(camCard.width - iconSprite.width + 10, camCard.height - iconSprite.height - 192);
		iconSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(iconSprite);

		iconSilhouette = new FlxBackdrop(null, Y, 0, 70);
		iconSilhouette.loadGraphicFromSprite(iconSprite);
		iconSilhouette.setGraphicSize(450, 450);
		iconSilhouette.updateHitbox();
		iconSilhouette.setPosition(iconSprite.x - 200, iconSprite.y + 30);
		iconSilhouette.antialiasing = ClientPrefs.data.antialiasing;
		iconSilhouette.setColorTransform(0, 0, 0, 1, color.red, color.green, color.blue);
		iconSilhouette.velocity.y = -50;
		insert(members.indexOf(iconSprite), iconSilhouette);

		statusHeader = new FlxText(400, -13, camCard.width, 'STATUS', 85);
		statusHeader.scale.x += 0.25;
		statusHeader.scale.y += 0.2;
		statusHeader.updateHitbox();
		statusHeader.font = Paths.font('akira.otf');
		statusHeader.color = 0xFF00293F;
		add(statusHeader);

		statusHeader2 = new FlxText(statusHeader.x + 970, -13, camCard.width, 'STATUS', 85);
		statusHeader2.scale.x += 0.25;
		statusHeader2.scale.y += 0.2;
		statusHeader2.updateHitbox();
		statusHeader2.font = Paths.font('akira.otf');
		statusHeader2.color = 0xFF00293F;
		add(statusHeader2);

		nameTxt = new FlxText(cardBG2.x + 30, cardBG2.y + 40, cardBG.width, name, 30);
		nameTxt.font = Paths.font('Fontsona3FES.ttf');
		nameTxt.color = color;
		add(nameTxt);

		roleHeader = new FlxText(cardBG2.x + 50, cardBG2.y + 85, cardBG.width, 'ROLE', 35);
		roleHeader.letterSpacing = 2;
		roleHeader.font = Paths.font('Fontsona3FES.ttf');
		roleHeader.color = color;
		roleHeader.borderStyle = OUTLINE;
		roleHeader.borderColor = roleHeader.color;
		roleHeader.borderSize = 0.75;
		add(roleHeader);

		roleTxt = new FlxText(roleHeader.x + 5, roleHeader.y + 43, cardBG.width, role, 22);
		roleTxt.font = Paths.font('Fontsona3FES.ttf');
		roleTxt.color = color;
		add(roleTxt);

		descHeader = new FlxText(45, cardBG.height - 305, cardBG.width, 'INFO:', 34);
		descHeader.letterSpacing = 2;
		descHeader.font = Paths.font('Fontsona5Royal.ttf');
		descHeader.color = color3;
		descHeader.borderStyle = OUTLINE;
		descHeader.borderColor = descHeader.color;
		descHeader.borderSize = 0.75;
		add(descHeader);

		descTxt = new FlxText(10, 8, camDesc.width - 30, description != null && description.length > 0 ? description : 'No information found.', 20);
		@:privateAccess
		descTxt._defaultFormat.leading = 6;
		descTxt.font = Paths.font('FOT-Rodin Pro EB.otf');
		descTxt.borderStyle = OUTLINE;
		descTxt.borderSize = 0.5;
		descTxt.camera = camDesc;
		add(descTxt);
		if (descTxt.textField.textHeight >= 202) allowScrolling = true;

		scrollBar = new FlxSprite().makeGraphic(10, Math.round(camDesc.height * camDesc.height / descTxt.textField.textHeight), 0xFF000000);
		scrollBar.x = camDesc.width - scrollBar.width;
		scrollBar.camera = camDesc;
		scrollBar.alpha = 0.6;
		scrollBar.visible = allowScrolling;
		scrollBar.scrollFactor.set();
		add(scrollBar);

		descOutline = new FlxSprite(0, -1).makeGraphic(Std.int(descBox.width), Std.int(descBox.height + 1), 0);
		descOutline.drawRect(0, 0, descOutline.width, descOutline.height, 0, {thickness: 5, color: color2});
		descOutline.camera = camDesc;
		descOutline.scrollFactor.set();
		add(descOutline);

		#if !mobile
		backIcon = new KeyIcon(cardBG.width - 140, cardBG.height - 40, 'back', 1, 'ui_close');
		backIcon.iconText.font = Paths.font('p5hatty-1.ttf');
		add(backIcon);

		acceptIcon = new KeyIcon(backIcon.x - 180, backIcon.y, 'accept', 1, 'ui_open_link');
		acceptIcon.iconText.font = Paths.font('p5hatty-1.ttf');
		add(acceptIcon);
		#else
		acceptTxt = new FlxText(0, cardBG.height - 55, cardBG.width, Language.getPhrase('ui_open_link', 'Open Link'), 32);
		acceptTxt.setFormat(Paths.font('Fontsona5Royal.ttf'), 32, FlxColor.BLACK, LEFT);
		acceptTxt.x = cardBG.width - acceptTxt.textField.textWidth - 30;
		add(acceptTxt);

		// i'm so fucking annoyed at having to do Std.int for EVERY SINGLE TIME THAT I REFERENCE THE WIDTH AND HEIGHT IN MAKEGRAPHIC somebody please kill me - melodiekit
		var acceptBG:FlxSprite = new FlxSprite(acceptTxt.x - 8, acceptTxt.y - 7).makeGraphic(Std.int(acceptTxt.textField.textWidth + 20), Std.int(acceptTxt.textField.textHeight + 20), 0xFFFFFFFF);
		acceptBG.drawRect(0, 0, acceptBG.width, acceptBG.height, 0, {thickness: 5, color: 0xFF000000});
		insert(members.indexOf(acceptTxt), acceptBG);
		#end

		#if mobile
		var camUI:FlxCamera = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		backButton = new BackButton();
		backButton.camera = camUI;
		add(backButton);
		#end

		camCard.x -= 310;
		camCard.alpha = 0;
		camDesc.x -= 310;
		camDesc.alpha = 0;
		FlxTween.tween(camCard, { x: camCard.x + 310, alpha: 1 }, 0.3, { ease: FlxEase.expoOut });
		FlxTween.tween(camDesc, { x: camDesc.x + 310, alpha: 1 }, 0.3, { ease: FlxEase.expoOut });

		if (name == 'melodiekit') {
			descTxt.applyMarkup(description, [new FlxTextFormatMarkerPair(new FlxTextFormat(!flipX ? color : 0x577099), '&')]);
		}

		super.create();
	}

	var baldFrames:Int = 0;
	var exiting:Bool = false;
	override function update(elapsed:Float) {
		scrollTimer += elapsed;

		statusHeader.x -= 80 * elapsed;
		statusHeader2.x -= 80 * elapsed;
		if (statusHeader.x < -970) statusHeader.x = 970;
		if (statusHeader2.x < -970) statusHeader2.x = 970;

		if (!exiting && (controls.BACK #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.initiallyPressed || TouchUtil.justReleased && !TouchUtil.overlaps(backButton) && !TouchUtil.overlaps(cardBG, camCard) && !TouchUtil.initiallyOverlapped(cardBG, camCard, FlxPoint.get(camCard.x, camCard.y)) #end)) {
			exiting = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			#if mobile 
			FlxTween.tween(backButton, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			#end
			FlxTween.tween(bg, { alpha: 0 }, 0.3, { ease: FlxEase.expoOut });
			FlxTween.tween(camCard, { x: camCard.x + 310, alpha: 0 }, 0.3, { ease: FlxEase.expoOut });
			FlxTween.tween(camDesc, { x: camDesc.x + 310, alpha: 0 }, 0.3, { ease: FlxEase.expoOut, onComplete:t->close() });
		}

		if (controls.ACCEPT #if mobile || TouchUtil.overlaps(acceptTxt, camCard)&& TouchUtil.justPressed #end) {
			CoolUtil.browserLoad(link);
		}

		if (allowScrolling) {
			if (scrollTimer >= 1 && scrollTween == null) {
				scrollTween = FlxTween.tween(scrollBar, { alpha: 0 }, 0.25);
			}
			if (FlxG.mouse.wheel != 0) {
				var val:Float = -FlxG.mouse.wheel * 13;
				camDesc.scroll.y += val;
				if (scrollTween != null) {
					scrollTween.cancel();
					scrollTween = null;
				}
				scrollBar.alpha = 0.6;
				scrollBar.y += val * (camDesc.height / (descTxt.textField.textHeight + 16));
				scrollTimer = 0;
			}
			if (TouchUtil.pressed && (TouchUtil.initiallyOverlapped(descBox, camCard, FlxPoint.get(camCard.x, camCard.y)) && TouchUtil.overlaps(descBox, camCard) || holdingBox)) {
				if (TouchUtil.justPressed) {
					holdingBox = true;
					#if mobile prevMouseY += TouchUtil.input.viewY; #end
				}
				#if !mobile
				var val:Float = camDesc.scroll.y - FlxG.mouse.deltaViewY;
				#else
				var val:Float = prevMouseY - TouchUtil.input.viewY;
				#end
				camDesc.scroll.y = val;
				if (scrollTween != null) {
					scrollTween.cancel();
					scrollTween = null;
				}
				scrollBar.alpha = 0.6;
				scrollBar.y = val * (camDesc.height / (descTxt.textField.textHeight + 16));
				scrollTimer = 0;
			}
			if (TouchUtil.justReleased && holdingBox) {
				holdingBox = false;
				#if mobile prevMouseY = FlxMath.bound(camDesc.scroll.y, 0, descTxt.textField.textHeight - camDesc.height + 16); #end
			}

			camDesc.scroll.y = FlxMath.bound(camDesc.scroll.y, 0, descTxt.textField.textHeight - camDesc.height + 16);
			scrollBar.y = FlxMath.bound(scrollBar.y, 0, camDesc.height - scrollBar.height);
		}

		// this is way too much effort for a dumbass inside joke that only like 3 people know about
		if (name == 'melodiekit' && !flipX) {
			if (FlxG.random.bool(1) && nameTxt.text == name) {
				if (icon == 'golden-baldiplier') nameTxt.text = 'Golden Baldiplier';
				else nameTxt.text = CoolUtil.capitalize(icon);
			}
			else if (nameTxt.text != name) {
				baldFrames++;
				if (baldFrames > FlxG.random.int(5, 15)) {
					nameTxt.text = name;
					baldFrames = 0;
				}
			}
		}
		super.update(elapsed);
	}
}