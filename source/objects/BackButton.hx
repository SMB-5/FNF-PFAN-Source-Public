package objects;

class BackButton extends FlxSprite
{
	public var initiallyPressed:Bool = false; // True after pressing immediately
	public var justPressed:Bool = false; // True after animation finishes after pressing
	public var onClick:Void->Void;
	public var canTween:Bool = true;
	var buttonTween:FlxTween;
	public function new(?x:Float, ?y:Float) {
		x ??= FlxG.width - 175;
		y ??= 20;
		super(x, y);
		frames = Paths.getSparrowAtlas('backButton');
		scale.set(0.5, 0.5);
		updateHitbox();
		alpha = 0.7;
		antialiasing = ClientPrefs.data.antialiasing;
		animation.addByIndices('back', 'back', [for (i in 4...10) i], '', 24, false);
		animation.play('back');
		animation.finish();
		animation.onFinish.add(function(name:String) {
			if (name == 'back') {
				justPressed = true;
				if (onClick != null) onClick();
			}
		});
	}

	override function update(elapsed:Float) {
		initiallyPressed = false;
		justPressed = false;
		if (TouchUtil.overlaps(this)) {
			if (canTween) {
				if (buttonTween != null) buttonTween.cancel();
				buttonTween = FlxTween.tween(this, { 'scale.x': 0.6, 'scale.y': 0.6, alpha: 1 }, 0.25, { ease: FlxEase.quintOut, onComplete: _->buttonTween = null });
			}
			if (TouchUtil.justPressed && animation.finished) {
				initiallyPressed = true;
				animation.play('back');
			}
		}
		else if (canTween && (!TouchUtil.overlaps(this) || !animation.finished)) {
			if (buttonTween != null) buttonTween.cancel();
			buttonTween = FlxTween.tween(this, { 'scale.x': 0.5, 'scale.y': 0.5, alpha: 0.7 }, 0.25, { ease: FlxEase.quintOut, onComplete: _->buttonTween = null });
		}
		super.update(elapsed);
	}
}