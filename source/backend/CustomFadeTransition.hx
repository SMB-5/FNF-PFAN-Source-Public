package backend;

import flixel.util.FlxGradient;

enum FadeType
{
	IN;
	OUT;
	IN_BOTTOM;
	OUT_BOTTOM;
}

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var fadeType:FadeType;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	var duration:Float;
	public function new(duration:Float, fadeType:FadeType)
	{
		this.duration = duration;
		this.fadeType = fadeType;
		super();
	}

	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transGradient = FlxGradient.createGradientFlxSprite(1, height, ((fadeType == IN || fadeType == OUT_BOTTOM) ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		switch(fadeType)
		{
			case IN:
				transGradient.y = transBlack.y - transBlack.height;
			case OUT:
				transGradient.y = -transGradient.height;
			case IN_BOTTOM:
				transGradient.y = transBlack.y + transBlack.height;
			case OUT_BOTTOM:
				transGradient.y = transGradient.height;
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0) {
			switch(fadeType) {
				case IN, OUT:
					transGradient.y += (height + targetPos) * elapsed / duration;
				case IN_BOTTOM, OUT_BOTTOM:
					transGradient.y -= (height + targetPos) * elapsed / duration;
			}
		}
		else
			transGradient.y = (targetPos) * elapsed;

		switch(fadeType) {
			case IN, OUT_BOTTOM:
				transBlack.y = transGradient.y + transGradient.height;
			case OUT, IN_BOTTOM:
				transBlack.y = transGradient.y - transBlack.height;
		}

		if((fadeType == IN || fadeType == OUT) && transGradient.y >= targetPos || (fadeType == IN_BOTTOM || fadeType == OUT_BOTTOM) && transGradient.y <= -targetPos)
		{
			close();
		}
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}