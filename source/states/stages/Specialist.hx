package states.stages;

import states.stages.objects.*;
import objects.Character;
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
import states.PlayState;

class Specialist extends BaseStage
{
	override function create()
	{
		skipCountdown = true;

		var vid:VideoSprite = new VideoSprite();
		vid.play(Paths.video("Persona 4 - Specialist"));
		vid.cameras = [camOther];
		add(vid);
		vid.finishCallback = function()
		{
			vid.destroy();
		}
	}
}