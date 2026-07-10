game.gf.kill();
game.camZooming = true;
game.camZoomingOnBeat = false;

function onBeatHit() {
	if (curBeat % 2 != 0) {
		if (curBeat >= 4 && curBeat < 34 || curBeat >= 36 && curBeat < 46 || curBeat >= 53 && curBeat < 66 || curBeat >= 132 && curBeat < 146 || curBeat >= 149 && curBeat < 162 || curBeat >= 344 && curBeat < 364) {
			FlxG.camera.zoom += 0.015;
			game.camHUD.zoom += 0.03;
		}
	}
	else {
		if (curBeat >= 212 && curBeat < 228) {
			FlxG.camera.zoom += 0.015;
			game.camHUD.zoom += 0.03;
		}
	}
	if (curBeat >= 228 && curBeat < 236 || curBeat >= 276 && curBeat < 341) {
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}
	if (curBeat == 100) {
		game.camZoomingOnBeat = true;
	}
	else if (curBeat == 127) {
		game.camZoomingOnBeat = false;
	}
}