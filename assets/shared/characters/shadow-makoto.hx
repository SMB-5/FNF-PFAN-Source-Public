var curChar:Character = game.dad.curCharacter == 'shadow-makoto' ? game.dad : game.boyfriend.curCharacter == 'shadow-makoto' ? game.boyfriend : (game.gf != null && game.gf.curCharacter == 'shadow-makoto') ? game.gf : null;
function onCreatePost() {
	if (curChar != null) {
		var icon = curChar == game.dad ? game.iconP2 : curChar == game.boyfriend ? game.iconP1 : null;
		var healthBar = curChar == game.dad ? game.healthBar.leftBar : curChar == game.boyfriend ? game.healthBar.rightBar : null;
		var swap = new shaders.ColorSwap();
		swap.saturation = -1;
		if (icon != null) {
			icon.shader = swap.shader;
			icon.setColorTransform(1, 1, 1, ClientPrefs.data.healthBarAlpha, -125, -125, -125, 0);
		}
		if (healthBar != null) healthBar.setColorTransform(1, 1, 1, ClientPrefs.data.healthBarAlpha, -125, -125, -125, 0);
		curChar.shader = swap.shader;
		curChar.setColorTransform(1, 1, 1, curChar.alpha, -125, -125, -125, 0);
		if (curChar.ghost != null) {
			curChar.ghost.shader = swap.shader;
			curChar.ghost.setColorTransform(1, 1, 1, 0, -125, -125, -125, 0);
		}
	}
}