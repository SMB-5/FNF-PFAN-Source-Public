package states.stages;

import states.stages.objects.*;

class VelvetRoomP5 extends BaseStage
{

	override function create()
	{
		var room:BGSprite = new BGSprite('persona/stages/velvet-room-p5/Room', -600, -300);
		add(room);

		var desk:BGSprite = new BGSprite('persona/stages/velvet-room-p5/Desk', -600, -300);
		add(desk);
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) {
		var overlay:BGSprite = new BGSprite('persona/stages/velvet-room-p5/Velvet_Room_Overlay', -500, -300);
        add(overlay);

		var light:BGSprite = new BGSprite('persona/stages/velvet-room-p5/Velvet_Room_Overlay_2', -500, -300);
        add(light);
		}
	}

}