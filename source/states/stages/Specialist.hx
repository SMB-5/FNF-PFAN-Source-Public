package states.stages;

class Specialist extends BaseStage
{
	override function create()
	{
		game.startVideo('Persona 4 - Specialist', true, false, false, false); // Precache first
		PlayState.instance.videoCutscene.camera = game.camHUD;
	}

	override function songStart()
	{
		game.videoCutscene?.play(); // Now play
	}
}