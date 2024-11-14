package states.stages;

import states.stages.objects.*;

class Dorm extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('persona/stages/dorm/dorm', -600, -300);
		add(bg);
	}
}