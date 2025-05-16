package states.stages;

import states.stages.objects.*;

class TVWorld extends BaseStage
{
	override function create()
	{
		var fog:BGSprite = new BGSprite('persona/stages/tv-world/fog', -600, 0, 0.7, 0.7);
		add(fog);

		var ladder:BGSprite = new BGSprite('persona/stages/tv-world/ladder', -600, 0);
		add(ladder);

		var floor:BGSprite = new BGSprite('persona/stages/tv-world/floor', -600, 0);
		add(floor);

		var platforms:BGSprite = new BGSprite('persona/stages/tv-world/platforms', -600, 0);
		add(platforms);

        if(!ClientPrefs.data.lowQuality) {
			
		}
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) {
			var light:BGSprite = new BGSprite('persona/stages/tv-world/light', -600, 0);
			add(light);
		}
	}
}