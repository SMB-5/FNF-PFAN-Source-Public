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

		warnText = new FlxText(0, 0, FlxG.width,"WARNING\n\nThis Mod is still in active development so a lot of things\npresent might be changed, removed or unfinished.\n\nThis Demo serves as a tiny glimpse into what we want to do\nfor the Mod and does not represent the Full Mod.\n\nPress ENTER or ESCAPE to Accept.",32);
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
