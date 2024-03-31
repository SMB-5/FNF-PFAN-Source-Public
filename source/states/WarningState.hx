package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,"This story is a work of fiction.\n\nSimilarity's between those living or dead are purely coincidental.\n\nOnly those who agree to the above can partake in this game.\n\nIt is recomended that you are at least 16 years or older to play this mod, proceed at your own risk.\n\nThis mod will contain heavy spoilers for the following games: Persona 3, Persona 3: The Answer, Persona 4 and Persona 5.\n\nPress ENTER or ESCAPE to Accept.",32);
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
