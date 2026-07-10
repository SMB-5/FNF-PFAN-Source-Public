game.opponentCameraOffset[1] = -45;
game.cameraSpeed = 2;

function onStepHit() {
	switch(curStep) {
		case 8:
			game.zoomCamera(1.05, 0.5, { ease: FlxEase.circOut });
		case 72:
			game.camZoomingOnBeat = false;
		case 120:
			game.camZoomingOnBeat = true;
		case 133:
			game.zoomCamera(1.15, 0.5, { ease: FlxEase.circOut });
		case 136:
			game.zoomCamera(0.85, 0.5, { ease: FlxEase.circOut });
		case 264:
			game.zoomCamera(0.95, 0.5, { ease: FlxEase.circOut });
			game.camZoomingOnBeat = false;
		case 376:
			if (game.gf != null) {
				game.isCameraOnForcedPos = true;
				game.moveCameraToGirlfriend();
			}
			game.zoomCamera(1.15, 0.5, { ease: FlxEase.circOut });
			game.camZoomingOnBeat = true;
		case 379:
			game.zoomCamera(0.7, 0.5, { ease: FlxEase.circOut });
		case 388:
			game.isCameraOnForcedPos = false;
			game.zoomCamera(1.05, 0.5, { ease: FlxEase.circOut });
		case 392:
			game.zoomCamera(0.7, 0.5, { ease: FlxEase.circOut });
		case 482:
			game.defaultCamZoom = game.camGame.zoom = 1;
		case 488:
			game.zoomCamera(0.7, 0.5, { ease: FlxEase.circOut });
		case 520:
			game.zoomCamera(1.05, 0.5, { ease: FlxEase.circOut });
		case 648:
			game.zoomCamera(0.85, 0.5, { ease: FlxEase.circOut });
		case 856:
			game.zoomCamera(1.05, 4, { ease: FlxEase.sineIn });
		case 888:
			game.zoomCamera(1.15, 0.5, { ease: FlxEase.circOut });
		case 904:
			game.zoomCamera(0.7, 0.5, { ease: FlxEase.circOut });
		case 994:
			game.defaultCamZoom = game.camGame.zoom = 1;
		case 1000:
			game.zoomCamera(0.7, 0.5, { ease: FlxEase.circOut });
		case 1032:
			game.zoomCamera(1.05, 0.5, { ease: FlxEase.circOut });
		case 1150:
			game.zoomCamera(0.85, 2, { ease: FlxEase.sineOut });
			game.isCameraOnForcedPos = true;
			FlxTween.tween(game.camFollow, { x: game.gf.getMidpoint().x + game.gf.cameraPosition[0] + game.girlfriendCameraOffset[0], y: game.gf.getMidpoint().y + game.gf.cameraPosition[1] + game.girlfriendCameraOffset[1] }, 2.25, { ease: FlxEase.sineInOut, onUpdate: t->game.camGame.snapToTarget(), onComplete: t->game.isCameraOnForcedPos = false });
	}
}

function onBeatHit() {
	if (curBeat % 2 != 0 && (curBeat >= 18 && curBeat < 30 || curBeat >= 66 && curBeat < 94)) {
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}
	else if (curBeat >= 98 && curBeat < 120 || curBeat >= 122 && curBeat < 130 || curBeat >= 226 && curBeat < 248 || curBeat >= 250 && curBeat < 290) {
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}
}