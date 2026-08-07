function onBeatHit() {
	if (curBeat >= 64 && curBeat < 128 && curBeat % 2 == 0) {
		FlxG.camera.zoom += 0.015;
		game.camHUD.zoom += 0.03;
	}
	if (curBeat >= 128 && curBeat < 256) {
		FlxG.camera.zoom += 0.015;
		game.camHUD.zoom += 0.03;
	}
	if (curBeat >= 384 && curBeat < 446 && curBeat % 2 == 0) {
		FlxG.camera.zoom += 0.015;
		game.camHUD.zoom += 0.03;
	}
	if (curBeat >= 448 && curBeat < 576) {
		FlxG.camera.zoom += 0.015;
		game.camHUD.zoom += 0.03;
	}
}