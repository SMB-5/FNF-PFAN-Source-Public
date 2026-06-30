package objects;

class BackButton extends FlxSprite
{
	public var initiallyPressed:Bool = false; // True after pressing immediately
	public var justPressed:Bool = false; // True after animation finishes after pressing
	public var onClick:Void->Void;
	public function new(?x:Float, ?y:Float) {
		x ??= FlxG.width - 225;
		y ??= 20;
		super(x, y);
		frames = Paths.getSparrowAtlas('backButton');
		scale.set(0.6, 0.6);
		updateHitbox();
		animation.addByIndices('back', 'back', [for (i in 4...10) i], '', 24, false);
		animation.play('back');
		animation.finish();
		animation.finishCallback = function(name:String) {
			if (name == 'back') {
				justPressed = true;
				if (onClick != null) onClick();
			}
		}
	}

	override function update(elapsed:Float) {
		if (TouchUtil.overlaps(this) && TouchUtil.justPressed && animation.finished) {
			initiallyPressed = true;
			animation.play('back');
		}
		else if (animation.finished) justPressed = false;
		super.update(elapsed);
	}
}