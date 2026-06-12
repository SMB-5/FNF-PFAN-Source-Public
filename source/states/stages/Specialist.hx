package states.stages;

class Specialist extends BaseStage
{
	override function create()
	{
		game.startVideo('Persona 4 - Specialist', true, false, false, false); // Precache first
		PlayState.instance.videoCutscene.camera = camHUD;
	}

	override function countdownStart()
	{
		for (i => daStrum in PlayState.instance.strumLineNotes) {
			if (i < 4) {
				daStrum.x = 9999;
			}
			else {
				daStrum.x = 412 + (112 * (i - 4));
			}
		}
		dadGroup.visible = false;
		boyfriendGroup.visible = false;
		gfGroup.visible = false;
		game.iconP1.visible = false;
		game.iconP2.visible = false;
		game.healthBar.visible = false;
	}

	override function startSong()
	{
		game.videoCutscene?.play(); // Now play
	}
}