package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class WarningDemoState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,"Hey thank you so much for downloading the demo!\nWe hope you look forward to the full release of the mod and enjoy this short demo. If you encounter any bugs or want to suggest any features or ideas please be sure to let us know in our offical community discord server (link in the credits)\n\nPress ENTER or ESCAPE to Accept.",32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	public function goBack()
	{
		MusicBeatState.switchState(new FlashingState());
		FlxG.sound.play(Paths.sound('cancelMenu'), 0.5);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				if(!back) {
                MusicBeatState.switchState(new FlashingState());
		        FlxG.sound.play(Paths.sound('cancelMenu'), 0.5);
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new FlashingState());
				}
			}
		}
		super.update(elapsed);
	}
}
