package objects;

class SustainSplash extends FlxSprite
{
	public static var startCrochet:Float = 0.0;
	public static var frameRate:Int = 0;

	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas('noteSplashes/holdSplashes/holdSplash');
		animation.addByPrefix('hold', 'hold', 24, true);
		animation.addByPrefix('end', 'end', 24, false);
	}

	public function setupSusSplash(strum:StrumNote, daNote:Note, ?playbackRate:Float = 1)
	{
		animation.play('hold', true);
		animation.curAnim.frameRate = frameRate;
		animation.curAnim.looped = true;

		var realNote:Note = !daNote.isSustainNote ? daNote : daNote.parent;
		var lengthToGet:Int = realNote.tail.length;
		var timeToGet:Float = realNote.strumTime;
		var timeThingy:Float = (startCrochet * lengthToGet + (timeToGet - Conductor.songPosition + ClientPrefs.data.ratingOffset)) / playbackRate * .001;

		var tailEnd:Note = realNote.tail[realNote.tail.length - 1];

		clipRect = new flixel.math.FlxRect(0, !PlayState.isPixelStage ? 0 : -210, frameWidth, frameHeight);

		if (daNote.shader != null) {
			shader = new objects.NoteSplash.PixelSplashShaderRef().shader;
			shader.data.r.value = daNote.shader.data.r.value;
			shader.data.g.value = daNote.shader.data.g.value;
			shader.data.b.value = daNote.shader.data.b.value;
			shader.data.mult.value = daNote.shader.data.mult.value;
		}

		alpha = realNote.alpha;
		setPosition(strum.x, strum.y);
		offset.set(PlayState.isPixelStage ? 112.5 : 106.25, 100);

		new FlxTimer().start(timeThingy, (_) -> {
			if (tailEnd.mustPress != PlayState.opponentMode && !realNote.noteSplashData.disabled && ClientPrefs.data.splashAlpha != 0) {
				alpha = realNote.noteSplashData.a;
				animation.play('end', true);
				animation.curAnim.looped = false;
				animation.curAnim.frameRate = 24;
				clipRect = null;
				animation.onFinish.add((_) -> kill());
				return;
			}
			kill();
		});
	}
}
