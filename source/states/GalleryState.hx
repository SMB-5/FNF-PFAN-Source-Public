package states;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import sys.io.File;

/*
 * HEY! I know you see this, CREDIT ME! IF YOU PUBLISH A MOD USING THIS SCRIPT OR EDIT IT IN ANY WAY, YOU HAVE TO CREDIT ME! NOT DOING SO WILL BE FOLLOWED BY A REPORT, TAKING DOWN YOUR MOD AND MAKING YOU LOOK LIKE
 * A CLOWN. SO PLEASE, JUST CREDIT MY GAMEBANANA, SAVES BOTH OF US TIME -> https://gamebanana.com/members/2041479
 */
class GalleryState extends MusicBeatState {
	// DATA STUFF
	var itemGroup:FlxTypedGroup<GalleryImage>;

	var imagePaths:Array<String>;
	var imageDescriptions:Array<String>;
	var imageTitle:Array<String>;
	var linkOpen:Array<String>;
	var descriptionText:FlxText;
	var imageData:Array<ImageData>;

	// UI STUFF
	var currentIndex:Int = 0;
	var floatIndex:Float = 0;
	var previousIndex:Int = 0;
	var allowInputs:Bool = true;
	var swiping:Bool = false;
	#if mobile
	var backButton:BackButton;
	#end

	var uiGroup:FlxSpriteGroup;
	var hideUI:Bool = false;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var imageSprite:FlxSprite;
	var background:FlxSprite;
	var titleText:FlxText;
	var backspace:FlxSprite;
	var hudTopBar:FlxSprite;
	var hudBottomBar:FlxSprite;

	// Customize the image path here
	var imagePath:String = "gallery/";

	override public function create():Void {
		var jsonData:String = File.getContent("assets/shared/images/gallery/gallery.json");
		imageData = haxe.Json.parse(jsonData);

		imagePaths = [];
		imageDescriptions = [];
		imageTitle = [];
		linkOpen = [];

		for (data in imageData) {
			imagePaths.push(data.path);
			imageDescriptions.push(data.description);
			imageTitle.push(data.title);
			linkOpen.push(data.link);
		}

		itemGroup = new FlxTypedGroup<GalleryImage>();
		uiGroup = new FlxSpriteGroup();

		for (i in 0...imagePaths.length) {
			var newItem = new GalleryImage();
			newItem.loadGraphic(Paths.image(imagePath + imagePaths[i]));
			newItem.antialiasing = ClientPrefs.data.antialiasing;
			newItem.screenCenter();
			newItem.ID = i;
			itemGroup.add(newItem);
		}

		#if !mobile FlxG.mouse.visible = true; #end

		background = new FlxSprite(-150, -150).loadGraphic(Paths.image('menuWall'));
		add(background);

		hudTopBar = new FlxSprite(0, 0);
		hudTopBar.makeGraphic(FlxG.width, 45, FlxColor.BLACK);

		hudBottomBar = new FlxSprite(0, FlxG.height - 45);
		hudBottomBar.makeGraphic(FlxG.width, 45, FlxColor.BLACK);

		uiGroup.add(hudTopBar);
		uiGroup.add(hudBottomBar);

		add(itemGroup);

		descriptionText = new FlxText(50, -100, FlxG.width - 100, imageDescriptions[currentIndex]);
		descriptionText.setFormat("vcr.ttf", 32, 0xffffff, CENTER);
		descriptionText.screenCenter();
		descriptionText.y += 275;
		uiGroup.add(descriptionText);

		titleText = new FlxText(50, -100, FlxG.width - 100, imageTitle[currentIndex]);
		titleText.screenCenter();
		titleText.setFormat(Paths.font("vcr.ttf"), 32, 0xffffff, CENTER);
		titleText.y -= 275;
		uiGroup.add(titleText);

		add(uiGroup);

		#if mobile
		backButton = new BackButton(null, 10);
		add(backButton);
		#end

		persistentUpdate = true;
		changeSelection();

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (allowInputs) {
			var pressedAccept:Bool = controls.ACCEPT;
			if (!swiping) {
				for (option in itemGroup) {
					if (TouchUtil.overlaps(option) && TouchUtil.justReleased) {
						if (currentIndex != option.ID) {
							currentIndex = option.ID;
							changeSelection();
						}
						else {
							pressedAccept = true;
						}
					}
				}
			}

			if (TouchUtil.pressed) {
				@:privateAccess
				var leftInput = #if !mobile TouchUtil.input._leftButton #else TouchUtil.input #end;
				var offset:Float = leftInput.justPressedPosition.x - TouchUtil.input.getScreenPosition(FlxG.camera).x;
				if (Math.abs(offset) > 10) {
					if (!swiping) {
						previousIndex = currentIndex;
					}
					swiping = true;
					floatIndex = previousIndex + offset * 0.003;
					for (num => item in itemGroup) {
						item.posX = num - floatIndex;
					}
					var boundedIndex:Int = Math.round(FlxMath.bound(floatIndex, 0, itemGroup.length - 1));
					if (boundedIndex != currentIndex) {
						currentIndex = boundedIndex;
						changeSelection();
					}
				}
			}
			else if (swiping) {
				swiping = false;
				for (num => item in itemGroup) {
					item.posX = num - currentIndex;
				}
			}

			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeSelection(controls.UI_LEFT_P ? -1 : 1);
				FlxG.sound.play(Paths.sound("scrollMenu"));
			}

			if (controls.BACK #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.justPressed #end) {
				allowInputs = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (pressedAccept)
				CoolUtil.browserLoad(linkOpen[currentIndex]);
		}

		if (FlxG.keys.justPressed.X && !hideUI) {
			hideUI = true;
			FlxTween.tween(uiGroup, {alpha: 0}, 0.2, {ease: FlxEase.linear});
		} else if (FlxG.keys.justPressed.X && hideUI) {
			hideUI = false;
			FlxTween.tween(uiGroup, {alpha: 1}, 0.2, {ease: FlxEase.linear});
		}
	}

	private function changeSelection(i:Int = 0) {
		currentIndex = FlxMath.wrap(currentIndex + i, 0, imageTitle.length - 1);

		if (imageData != null && currentIndex >= 0 && currentIndex < imageData.length) {
			descriptionText.text = imageDescriptions[currentIndex];
			titleText.text = imageTitle[currentIndex];
		} else {
			trace("Error: imageData is null or invalid when trying to change selection.");
		}

		var change = 0;
		for (item in itemGroup) {
			if (!swiping) item.posX = change++ - currentIndex;
			item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
		}
	}

	public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('');
		color = StringTools.trim(color);

		if (color.substr(0, 2) == '0x')
			color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
}

class GalleryImage extends FlxSprite {
	public var lerpSpeed:Float = 6;
	public var posX:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (width > 0) {
			var targetX = (FlxG.width - width) / 2 + posX * 760;
			x = FlxMath.lerp(x, targetX, elapsed * lerpSpeed);
		}
	}
}

typedef ImageData = {
	path:String,
	description:String,
	title:String,
	link:String,
	color:String
}
