package options;

import backend.StageData;
import objects.Character;
import options.MainMenuOptions;
import flixel.ui.FlxBar;
import flixel.addons.display.shapes.FlxShapeCircle;

import states.stages.StageWeek1 as BackgroundStage;

class NoteOffsetState extends MusicBeatState
{
	var stageDirectory:String = 'week1';
	var boyfriend:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var barPercent:Float = 0;
	var delayMin:Int = -500;
	var delayMax:Int = 500;
	var timeBG:FlxSprite;
	var timeBar:FlxBar;
	var timeTxt:FlxText;
	var leftArrow:Alphabet;
	var rightArrow:Alphabet;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var bg:FlxSprite;
	var leftSelector:FlxSprite;
	var rightSelector:FlxSprite;
	var curModeTxt:Alphabet;

	var controllerPointer:FlxSprite;
	var _lastControllerMode:Bool = false;

	#if mobile
	var backButton:BackButton;
	var resetButton:FlxSprite;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Delay/Combo Offset Menu", null);
		#end

		// Cameras
		camGame = initPsychCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();

		// Stage
		Paths.setCurrentLevel(stageDirectory);
		new BackgroundStage();

		// Characters
		gf = new Character(400, 130, 'gf');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(0.95, 0.95);
		boyfriend = new Character(770, 100, 'bf', true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(gf);
		add(boyfriend);

		// Combo stuff
		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		rating = new FlxSprite().loadGraphic(Paths.image('sick'));
		rating.cameras = [camHUD];
		rating.antialiasing = ClientPrefs.data.antialiasing;
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		
		add(rating);

		comboNums = new FlxSpriteGroup();
		comboNums.cameras = [camHUD];
		add(comboNums);

		var seperatedScore:Array<Int> = [];
		for (i in 0...3)
		{
			seperatedScore.push(FlxG.random.int(0, 9));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image('num' + i));
			numScore.cameras = [camHUD];
			numScore.antialiasing = ClientPrefs.data.antialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			comboNums.add(numScore);
			daLoop++;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		// Note delay stuff
		beatText = new Alphabet(0, 0, Language.getPhrase('delay_beat_hit', 'Beat Hit!'), true);
		beatText.setScale(0.6, 0.6);
		beatText.x += 420;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		beatText.visible = false;
		add(beatText);

		timeBG = new FlxSprite(0, FlxG.height - 180).makeGraphic(FlxG.width, 180, FlxColor.BLACK);
		timeBG.alpha = 0.6;
		timeBG.cameras = [camHUD];
		add(timeBG);
		
		timeTxt = new FlxText(0, 570, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.visible = false;
		timeTxt.cameras = [camHUD];
		add(timeTxt);

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();
		
		timeBar = new FlxBar(0, timeTxt.y + timeTxt.height + 20, LEFT_TO_RIGHT, 720, 50, ClientPrefs.data, 'noteOffset', -500, 500);
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.LIME);
		timeBar.numDivisions = 800;
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.visible = false;
		timeBar.cameras = [camHUD];
		add(timeBar);

		leftArrow = new Alphabet(0, timeBar.y - 10, '<');
		leftArrow.x = timeBar.x - leftArrow.width - 20;
		leftArrow.cameras = [camHUD];
		leftArrow.visible = false;
		add(leftArrow);

		rightArrow = new Alphabet(0, timeBar.y - 10, '>');
		rightArrow.x = timeBar.x + timeBar.width - rightArrow.width + 65;
		rightArrow.cameras = [camHUD];
		rightArrow.visible = false;
		add(rightArrow);

		///////////////////////

		bg = new FlxSprite().makeGraphic(425, 150, 0xFF000000);
		bg.alpha = 0.6;
		bg.cameras = [camHUD];
		add(bg);

		leftSelector = new FlxSprite(bg.x + 10, bg.y + 30);
		leftSelector.antialiasing = ClientPrefs.data.antialiasing;
		leftSelector.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftSelector.animation.addByPrefix('idle', "arrow left");
		leftSelector.animation.addByPrefix('press', "arrow push left");
		leftSelector.animation.play('idle');
		leftSelector.cameras = [camHUD];
		add(leftSelector);

		curModeTxt = new Alphabet(leftSelector.x + 60, leftSelector.y + 5, '');
		curModeTxt.cameras= [camHUD];
		add(curModeTxt);

		rightSelector = new FlxSprite(leftSelector.x + 345, leftSelector.y);
		rightSelector.antialiasing = ClientPrefs.data.antialiasing;
		rightSelector.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightSelector.animation.addByPrefix('idle', 'arrow right');
		rightSelector.animation.addByPrefix('press', "arrow push right", 24, false);
		rightSelector.animation.play('idle');
		rightSelector.cameras = [camHUD];
		add(rightSelector);
		
		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		controllerPointer.cameras = [camHUD];
		add(controllerPointer);

		#if mobile
		backButton = new BackButton();
		backButton.camera = camOther;
		add(backButton);

		resetButton = new FlxSprite(backButton.x - 150, backButton.y + 5, Paths.image('resetButton'));
		resetButton.camera = camOther;
		resetButton.scale.set(0.85, 0.85);
		resetButton.updateHitbox();
		resetButton.alpha = 0.7;
		add(resetButton);
		#end

		createTexts();
		repositionCombo();
		updateMode();
		_lastControllerMode = true;

		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();
	}

	var holdingBar:Bool = false;
	var holdTime:Float = 0;
	var onComboMenu:Bool = true;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();
	override public function update(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER))
		{
			if(onComboMenu)
				addNum = 10;
			else
				addNum = 3;
		}

		if(FlxG.gamepads.anyJustPressed(ANY)) controls.controllerMode = true;
		else if(TouchUtil.justPressed) controls.controllerMode = false;

		if(controls.controllerMode != _lastControllerMode)
		{
			//trace('changed controller mode');
			#if !mobile FlxG.mouse.visible = !controls.controllerMode; #end
			controllerPointer.visible = controls.controllerMode;

			// changed to controller mid state
			if(controls.controllerMode)
			{
				if (TouchUtil.input != null) {
					var mousePos = TouchUtil.input.getScreenPosition(camHUD);
					controllerPointer.x = mousePos.x;
					controllerPointer.y = mousePos.y;
				}
			}
			updateMode();
			_lastControllerMode = controls.controllerMode;
		}

		if(onComboMenu)
		{
			if(FlxG.keys.justPressed.ANY || FlxG.gamepads.anyJustPressed(ANY))
			{
				var controlArray:Array<Bool> = null;
				if(!controls.controllerMode)
				{
					controlArray = [
						FlxG.keys.justPressed.LEFT,
						FlxG.keys.justPressed.RIGHT,
						FlxG.keys.justPressed.UP,
						FlxG.keys.justPressed.DOWN,
					
						FlxG.keys.justPressed.A,
						FlxG.keys.justPressed.D,
						FlxG.keys.justPressed.W,
						FlxG.keys.justPressed.S
					];
				}
				else
				{
					controlArray = [
						FlxG.gamepads.anyJustPressed(DPAD_LEFT),
						FlxG.gamepads.anyJustPressed(DPAD_RIGHT),
						FlxG.gamepads.anyJustPressed(DPAD_UP),
						FlxG.gamepads.anyJustPressed(DPAD_DOWN),
					
						FlxG.gamepads.anyJustPressed(RIGHT_STICK_DIGITAL_LEFT),
						FlxG.gamepads.anyJustPressed(RIGHT_STICK_DIGITAL_RIGHT),
						FlxG.gamepads.anyJustPressed(RIGHT_STICK_DIGITAL_UP),
						FlxG.gamepads.anyJustPressed(RIGHT_STICK_DIGITAL_DOWN)
					];
				}

				if(controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if(controlArray[i])
						{
							switch(i)
							{
								case 0:
									ClientPrefs.data.comboOffset[0] -= addNum;
								case 1:
									ClientPrefs.data.comboOffset[0] += addNum;
								case 2:
									ClientPrefs.data.comboOffset[1] += addNum;
								case 3:
									ClientPrefs.data.comboOffset[1] -= addNum;
								case 4:
									ClientPrefs.data.comboOffset[2] -= addNum;
								case 5:
									ClientPrefs.data.comboOffset[2] += addNum;
								case 6:
									ClientPrefs.data.comboOffset[3] += addNum;
								case 7:
									ClientPrefs.data.comboOffset[3] -= addNum;
							}
						}
					}
					repositionCombo();
				}
			}
			
			// controller things
			var analogX:Float = 0;
			var analogY:Float = 0;
			var analogMoved:Bool = false;
			var gamepadPressed:Bool = false;
			var gamepadReleased:Bool = false;
			if(controls.controllerMode)
			{
				for (gamepad in FlxG.gamepads.getActiveGamepads())
				{
					analogX = gamepad.getXAxis(LEFT_ANALOG_STICK);
					analogY = gamepad.getYAxis(LEFT_ANALOG_STICK);
					analogMoved = (analogX != 0 || analogY != 0);
					if(analogMoved) break;
				}
				controllerPointer.x = Math.max(0, Math.min(FlxG.width, controllerPointer.x + analogX * 1000 * elapsed));
				controllerPointer.y = Math.max(0, Math.min(FlxG.height, controllerPointer.y + analogY * 1000 * elapsed));
				gamepadPressed = !FlxG.gamepads.anyJustPressed(START) && controls.ACCEPT;
				gamepadReleased = !FlxG.gamepads.anyJustReleased(START) && controls.justReleased('accept');
			}
			//

			// probably there's a better way to do this but, oh well.
			if (TouchUtil.justPressed || gamepadPressed)
			{
				holdingObjectType = null;
				if(!controls.controllerMode)
					TouchUtil.input.getScreenPosition(camHUD, startMousePos);
				else
					controllerPointer.getScreenPosition(startMousePos, camHUD);

				if (startMousePos.x - comboNums.x >= 0 && startMousePos.x - comboNums.x <= comboNums.width &&
					startMousePos.y - comboNums.y >= 0 && startMousePos.y - comboNums.y <= comboNums.height)
				{
					holdingObjectType = true;
					startComboOffset.x = ClientPrefs.data.comboOffset[2];
					startComboOffset.y = ClientPrefs.data.comboOffset[3];
					//trace('yo bro');
				}
				else if (startMousePos.x - rating.x >= 0 && startMousePos.x - rating.x <= rating.width &&
						 startMousePos.y - rating.y >= 0 && startMousePos.y - rating.y <= rating.height)
				{
					holdingObjectType = false;
					startComboOffset.x = ClientPrefs.data.comboOffset[0];
					startComboOffset.y = ClientPrefs.data.comboOffset[1];
					//trace('heya');
				}
			}
			if(TouchUtil.justReleased || gamepadReleased) {
				holdingObjectType = null;
				//trace('dead');
			}

			if(holdingObjectType != null)
			{
				if(#if !mobile FlxG.mouse.justMoved #else TouchUtil.pressed #end || analogMoved)
				{
					var mousePos:FlxPoint = null;
					if(!controls.controllerMode)
						mousePos = TouchUtil.input.getScreenPosition(camHUD);
					else
						mousePos = controllerPointer.getScreenPosition(camHUD);

					var addNum:Int = holdingObjectType ? 2 : 0;
					ClientPrefs.data.comboOffset[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startComboOffset.x);
					ClientPrefs.data.comboOffset[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startComboOffset.y);
					repositionCombo();
				}
			}

			if(controls.RESET #if mobile || TouchUtil.overlaps(resetButton, camOther) && TouchUtil.justPressed #end)
			{
				for (i in 0...ClientPrefs.data.comboOffset.length)
				{
					ClientPrefs.data.comboOffset[i] = 0;
				}
				repositionCombo();
			}
		}
		else
		{
			if ((TouchUtil.overlaps(timeBar) || holdingBar) && TouchUtil.pressed)
			{
				holdingBar = true;
				var touchX = TouchUtil.input.getScreenPosition(camHUD).x;
				timeBar.value = barPercent = FlxMath.bound(timeBar.pct * ((touchX - timeBar.x) / timeBar.width  * 100) - timeBar.max, timeBar.min, timeBar.max);
				updateNoteDelay();
			}
			else if (holdingBar) holdingBar = false;

			if(controls.UI_LEFT_P || TouchUtil.overlaps(leftArrow, camHUD) && TouchUtil.justPressed)
			{
				barPercent = FlxMath.bound(ClientPrefs.data.noteOffset - 1, delayMin, delayMax);
				updateNoteDelay();
			}
			else if(controls.UI_RIGHT_P || TouchUtil.overlaps(rightArrow, camHUD) && TouchUtil.justPressed)
			{
				barPercent = FlxMath.bound(ClientPrefs.data.noteOffset + 1, delayMin, delayMax);
				updateNoteDelay();
			}

			var mult:Int = 1;
			if(controls.UI_LEFT || controls.UI_RIGHT || (TouchUtil.overlaps(leftArrow, camHUD) || TouchUtil.overlaps(rightArrow, camHUD)) && TouchUtil.pressed)
			{
				holdTime += elapsed;
				if(controls.UI_LEFT || TouchUtil.overlaps(leftArrow, camHUD)) mult = -1;
			}

			if(controls.UI_LEFT_R || controls.UI_RIGHT_R || (!TouchUtil.overlaps(leftArrow, camHUD) && !TouchUtil.overlaps(rightArrow, camHUD)) && TouchUtil.pressed || TouchUtil.justReleased) holdTime = 0;

			if(holdTime > 0.5)
			{
				barPercent += 100 * addNum * elapsed * mult;
				barPercent = FlxMath.bound(barPercent, delayMin, delayMax);
				updateNoteDelay();
			}

			if(controls.RESET #if mobile || TouchUtil.overlaps(resetButton, camOther) && TouchUtil.justPressed #end)
			{
				holdTime = 0;
				barPercent = 0;
				updateNoteDelay();
			}
		}

		if((TouchUtil.overlaps(leftSelector) || TouchUtil.overlaps(rightSelector)) && TouchUtil.justPressed)
		{
			var xPos:Float = (controls.UI_LEFT_P || TouchUtil.overlaps(leftSelector)) ? -40 : 40;
			FlxTween.completeTweensOf(curModeTxt);
			curModeTxt.x += xPos;
			curModeTxt.alpha = 0.4;
			FlxTween.tween(curModeTxt, { x: curModeTxt.x + -xPos, alpha: 1 }, 0.15, { ease: FlxEase.cubeOut });
			onComboMenu = !onComboMenu;
			updateMode();
		}

		if (TouchUtil.overlaps(leftSelector) && TouchUtil.pressed) {
			leftSelector.animation.play('press');
		}
		else {
			leftSelector.animation.play('idle');
		}

		if (TouchUtil.overlaps(rightSelector) && TouchUtil.pressed) {
			rightSelector.animation.play('press');
		}
		else {
			rightSelector.animation.play('idle');
		}

		if(controls.BACK #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.justPressed #end)
		{
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			FlxG.sound.music.fadeOut(0.35, 0, t->FlxG.sound.music.stop());
			MusicBeatState.switchState(new MainMenuOptions(true), OUT_BOTTOM);
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			boyfriend.dance();
			gf.dance();
		}
		
		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 1.15;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 540;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function repositionCombo()
	{
		rating.screenCenter();
		rating.x = coolText.x - 40 + ClientPrefs.data.comboOffset[0];
		rating.y -= 60 + ClientPrefs.data.comboOffset[1];

		comboNums.screenCenter();
		comboNums.x = coolText.x - 90 + ClientPrefs.data.comboOffset[2];
		comboNums.y += 80 - ClientPrefs.data.comboOffset[3];
		reloadTexts();
	}

	function createTexts()
	{
		for (i in 0...4)
		{
			var text:FlxText = new FlxText(10, bg.y + bg.height + 10 + (30 * i), 0, '', 24);
			text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 2;
			dumbTexts.add(text);
			text.cameras = [camHUD];

			if(i > 1)
			{
				text.y += 24;
			}
		}
	}

	function reloadTexts()
	{
		for (i in 0...dumbTexts.length)
		{
			switch(i)
			{
				case 0: dumbTexts.members[i].text = Language.getPhrase('combo_rating_offset', 'Rating Offset:');
				case 1: dumbTexts.members[i].text = '[' + ClientPrefs.data.comboOffset[0] + ', ' + ClientPrefs.data.comboOffset[1] + ']';
				case 2: dumbTexts.members[i].text = Language.getPhrase('combo_numbers_offset', 'Numbers Offset:');
				case 3: dumbTexts.members[i].text = '[' + ClientPrefs.data.comboOffset[2] + ', ' + ClientPrefs.data.comboOffset[3] + ']';
			}
		}
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		timeTxt.text = Language.getPhrase('delay_current_offset', 'Current offset: {1} ms', [Math.floor(barPercent)]);
	}

	function updateMode()
	{
		rating.visible = onComboMenu;
		comboNums.visible = onComboMenu;
		dumbTexts.visible = onComboMenu;

		timeBG.visible = !onComboMenu;
		timeBar.visible = !onComboMenu;
		timeTxt.visible = !onComboMenu;
		beatText.visible = !onComboMenu;
		leftArrow.visible = !onComboMenu;
		rightArrow.visible = !onComboMenu;

		curModeTxt.text = onComboMenu ? 'COMBO' : 'OFFSET';

		controllerPointer.visible = false;
		#if !mobile FlxG.mouse.visible = false; #end
		if(onComboMenu)
		{
			#if !mobile FlxG.mouse.visible = !controls.controllerMode; #end
			controllerPointer.visible = controls.controllerMode;
		}
	}
}
