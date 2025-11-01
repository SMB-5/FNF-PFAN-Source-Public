package states.stages;

class DDR extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('persona/stages/ddr/p3', 0, 0, 1, 1);
		add(bg);
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