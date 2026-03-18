package states.stages;

import states.stages.objects.*;

class Mementos extends BaseStage
{
	//var mementosTrain:MementosTrain;
	override function create()
	{
		var walls:BGSprite = new BGSprite('persona/stages/mementos/walls', -450, -150, 0.8, 1);
		walls.setGraphicSize(Std.int(walls.width * 1.2));
		add(walls);

		//mementosTrain = new MementosTrain(3000, -150);
		//add(mementosTrain);

		var platform:BGSprite = new BGSprite('persona/stages/mementos/platform', -450, -150);
		platform.setGraphicSize(Std.int(platform.width * 1.2));
		add(platform);
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) {
			var overlay:BGSprite = new BGSprite('persona/stages/mementos/overlay', -450, -150);
			overlay.setGraphicSize(Std.int(overlay.width * 1.2));
			add(overlay);
		}
	}

	override function beatHit()
	{
		//mementosTrain.beatHit(curBeat);
	}
}