package mobile.objects;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.GradientType;

import objects.StrumNote;

import mobile.input.MobileInputID;
import mobile.input.MobileInputManager;
import mobile.objects.TouchButton;

class Hitbox extends MobileInputManager
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.NOTE_RIGHT]);
	
	public var baseGame:Bool = false;

	public function new(style:String = 'Normal', baseGame:Bool = false) {
		super();

		this.baseGame = baseGame;

		var storedKeys:Map<String, Array<MobileInputID>> = [];
		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) storedKeys.set(button, spr.IDs);
		}

		add(buttonLeft = createHitbox(0, 0, Std.int(FlxG.width / 4), FlxG.height, style));
		add(buttonDown = createHitbox(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, style));
		add(buttonUp = createHitbox(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, style));
		add(buttonRight = createHitbox((FlxG.width / 4) + (FlxG.width / 2), 0, Std.int(FlxG.width / 4), FlxG.height, style));

		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) spr.IDs = storedKeys.get(button);
		}
		updateTrackedButtons();
	}

	function createHitbox(x:Float = 0, y:Float = 0, width:Int = 1, height:Int = 1, style:String = 'Normal'):TouchButton {
		var button = new TouchButton(x, y);
		button.loadGraphic(createHitboxGraphic(style, width, height));
		button.alpha = 0.0001;
		button.label = new FlxSprite();
		if (ClientPrefs.data.hitboxHints) {
			button.label.loadGraphic(createHitboxGraphic('Hint', width, height));
		}
		else {
			button.label.makeGraphic(1, 1, 0);
		}
		button.label.alpha = ClientPrefs.data.controlAlpha;
		button.changeLabelAlpha = false;

		button.onDown.callback = function() {
			onPressed.dispatch(button);
			if (!baseGame) {
				FlxTween.cancelTweensOf(button, ['alpha']);
				FlxTween.cancelTweensOf(button.label, ['alpha']);
				FlxTween.tween(button, { alpha: ClientPrefs.data.controlAlpha }, ClientPrefs.data.controlAlpha / 100, { ease: FlxEase.circInOut });
				FlxTween.tween(button.label, { alpha: 0.0001 }, ClientPrefs.data.controlAlpha / 10, { ease: FlxEase.circInOut });
			}
		}

		button.onOut.callback = button.onUp.callback = function() {
			onReleased.dispatch(button);
			if (!baseGame) {
				FlxTween.cancelTweensOf(button, ['alpha']);
				FlxTween.cancelTweensOf(button.label, ['alpha']);
				FlxTween.tween(button, { alpha: 0.0001 }, ClientPrefs.data.controlAlpha / 10, { ease: FlxEase.circInOut });
				FlxTween.tween(button.label, { alpha: ClientPrefs.data.controlAlpha }, ClientPrefs.data.controlAlpha / 100, { ease: FlxEase.circInOut });
			}
		}

		return button;
	}

	function createHitboxGraphic(style:String, width:Int, height:Int) {
		if (baseGame) {
			return FlxG.bitmap.add(new BitmapData(width, height, true, 0));
		}
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.lineStyle(3, 0xFFFFFF, 1);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.lineStyle(0, 0, 0);
		shape.graphics.drawRect(3, 3, width - 6, height - 6);
		shape.graphics.endFill();
		if (style.toLowerCase() == 'gradient') shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [1, 0], [0, 255], null, null, null, 0.5);
		else if (style.toLowerCase() == 'hint') shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [0, 0], [0, 255], null, null, null, 0.5);
		else shape.graphics.beginGradientFill(RADIAL, [0xFFFFFF, FlxColor.TRANSPARENT], [0.3, 0], [0, 255], null, null, null, 0.75);
		shape.graphics.drawRect(3, 3, width - 6, height - 6);
		shape.graphics.endFill();
		var bitmap:BitmapData = new BitmapData(width, height, true, 0);
		bitmap.draw(shape);
		return FlxG.bitmap.add(bitmap);
	}

	public function updateBaseGameHitbox(strum:StrumNote, id:Int) {
		var button = id == 0 ? buttonLeft : id == 1 ? buttonDown : id == 2 ? buttonUp : buttonRight; // lol
		button.setPosition(strum.x, strum.y);
		button.setGraphicSize(strum.frameWidth, strum.frameHeight);
		button.updateHitbox();
		button.loadGraphic(createHitboxGraphic('', Std.int(button.width), Std.int(button.height)));
	}
}