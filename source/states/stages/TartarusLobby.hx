package states.stages;

import states.stages.objects.*;

class TartarusLobby extends BaseStage
{

	override function create()
	{
		var buildings:BGSprite = new BGSprite('persona/stages/tartarus-lobby/1', -740, -350, 0.4, 0.4);
		add(buildings);

		var pillars:BGSprite = new BGSprite('persona/stages/tartarus-lobby/2', -440, -450, 0.6, 0.6);
		add(pillars);

		var fg:BGSprite = new BGSprite('persona/stages/tartarus-lobby/3', -540, -350);
		add(fg);

        if(!ClientPrefs.data.lowQuality) {
		var shadows:BGSprite = new BGSprite('persona/stages/tartarus-lobby/4', -540, -350);
		add(shadows);
		}
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) {
		var light:BGSprite = new BGSprite('persona/stages/tartarus-lobby/5', -540, -350);
        add(light);

		var vig:BGSprite = new BGSprite('persona/stages/tartarus-lobby/6', 0, 0, 0, 0);
        add(vig);
		vig.cameras = [camHUD];

		var lvig:BGSprite = new BGSprite('persona/stages/tartarus-lobby/7', 0, 0, 0, 0);
        add(lvig);
		lvig.cameras = [camHUD];
		}
	}

}