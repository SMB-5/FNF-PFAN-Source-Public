//Script by @dapootisbird
import states.stages.objects.ABotSpeaker;

var MIN_BLINK_DELAY:Int = 3;
var MAX_BLINK_DELAY:Int = 7;
var VULTURE_THRESHOLD:Float = 0.5;
var blinkCountdown:Int = 3;

var abot:ABotSpeaker;

var currentNeneState:String = "STATE_DEFAULT";
var animationFinished:Bool = false;

function onCreatePost(){
    if (PlayState.SONG.stage == "phillyStreets" || PlayState.SONG.stage == "phillyBlazin") return;

    var curLevel = Paths.currentLevel;

    Paths.setCurrentLevel('weekend1');
    
    //game.gfGroup.x += game.defaultGirlfriendX + 50;
    //game.gfGroup.y += game.defaultGirlfriendY - 200;
    abot = new ABotSpeaker(game.gfGroup.x + 30, game.gfGroup.y + 320);
    abot.antialiasing = ClientPrefs.data.antialiasing;
    for (i in [abot.bg, abot.eyeBg, abot.eyes, abot.speaker]) {
        if (i == abot.bg) continue;
        i.shader = game.gf.shader;
    }
    for (i in abot.vizSprites) i.shader = game.gf.shader;
    Paths.setCurrentLevel(curLevel);

    updateABotEye("dad", true);
    game.addBehindGF(abot);
    //game.setOnScripts("abot", abot);
	if(gf != null){
		gf.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int){
			switch(currentNeneState){
				case "STATE_PRE_RAISE":
					if (name == 'danceLeft' && frameNumber >= 14){
						animationFinished = true;
						transitionState();
					}
				default:
					// Ignore.
			}
		}
	}
}

function onUpdatePost(e){
    if (PlayState.SONG.stage == "phillyStreets" || PlayState.SONG.stage == "phillyBlazin") return;
    abot.flipX = game.gf.flipX;
    abot.flipY = game.gf.flipY;
    abot.scrollFactor.x = game.gf.scrollFactor.x;
    abot.scrollFactor.y = game.gf.scrollFactor.y;
    abot.alpha = game.gf.alpha;
    for (i in [abot.bg, abot.eyeBg, abot.eyes, abot.speaker]) {
        if (i == abot.bg) continue;
        i.color = game.gf.color;
    }
    if(gf == null || !game.startedCountdown) return;
		animationFinished = gf.isAnimationFinished();
		transitionState();
}

function transitionState(){
	switch (currentNeneState){
		case "STATE_DEFAULT":
			if (game.health <= VULTURE_THRESHOLD){
				currentNeneState = "STATE_PRE_RAISE";
				gf.skipDance = true;
			}
		case "STATE_PRE_RAISE":
			if (game.health > VULTURE_THRESHOLD){
				currentNeneState = "STATE_DEFAULT";
				gf.skipDance = false;
			}
			else if (animationFinished){
				currentNeneState = "STATE_RAISE";
				gf.playAnim('raiseKnife');
				gf.skipDance = true;
				gf.danced = true;
				animationFinished = false;
			}
		case "STATE_RAISE":
			if (animationFinished){
				currentNeneState = "STATE_READY";
				animationFinished = false;
			}
		case "STATE_READY":
			if (game.health > VULTURE_THRESHOLD){
				currentNeneState = "STATE_LOWER";
				gf.playAnim('lowerKnife');
			}
		case "STATE_LOWER":
			if (animationFinished){
				currentNeneState = "STATE_DEFAULT";
				animationFinished = false;
				gf.skipDance = false;
			}
	}
}
function beatHit(){
	switch(currentNeneState) {
		case "STATE_READY":
			if (blinkCountdown == 0){
				gf.playAnim('idleKnife', false);
				blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
			}
			else blinkCountdown--;

		default:
				// In other states, don't interrupt the existing animation.
	}
}
function goodNoteHit(note){
	// 10% chance of playing combo50/combo100 animations for Nene
	if(FlxG.random.bool(10)){
		switch(game.combo){
			case 50, 100:
				var animToPlay:String = 'combo${game.combo}';
				if(gf.animation.exists(animToPlay)){
					gf.playAnim(animToPlay);
					gf.specialAnim = true;
				}
		}
	}
}
function onSongStart() {
    if (PlayState.SONG.stage == "phillyStreets" || PlayState.SONG.stage == "phillyBlazin") return;
    abot.snd = FlxG.sound.music;
}

function onMoveCamera(who) {
    if (PlayState.SONG.stage == "phillyStreets" || PlayState.SONG.stage == "phillyBlazin") return;
    updateABotEye(who, false);
}

function updateABotEye(who:String = "dad", finishInstantly:Bool = false){
    if (abot == null) return;
    if (PlayState.SONG.stage == "phillyStreets" || PlayState.SONG.stage == "phillyBlazin") return;
    
    if (who == "dad") abot.lookLeft(); else abot.lookRight();

    if (finishInstantly) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
}