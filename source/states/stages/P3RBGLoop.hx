package states.stages;

class P3RBGLoop extends BaseStage
{
	override function create()
	{
		game.startVideo('P3R-BGLoop', true, false, true, false); // Precache first
		PlayState.instance.videoCutscene.camera = camHUD;

		game.videoCutscene?.play();
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
}