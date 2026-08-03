package options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import lime.system.Clipboard;
import flixel.util.FlxGradient;
import objects.Note;

class QuantizationColorSubstate extends MusicBeatSubstate
{
	var ignoreCheckForThisFrame:Bool = false;

	var notesGroup:FlxTypedGroup<Note>;
	var btnGroup:FlxTypedGroup<FlxSprite>;
	var modeNotes:FlxTypedGroup<FlxSprite>;
	var editingGroup:FlxTypedGroup<Dynamic>;

	var box:FlxSprite;

	var currentTab:SelectionTab;

	var curSelectedMode:Int = 0;
	var editingNote:Int = 0;

	var hexTypeLine:FlxSprite;
	var hexTypeNum:Int = -1;
	var hexTypeVisibleTimer:Float = 0;

	var copyButton:FlxSprite;
	var pasteButton:FlxSprite;

	var colorGradient:FlxSprite;
	var colorGradientSelector:FlxSprite;
	var colorPalette:FlxSprite;
	var colorWheel:FlxSprite;
	var colorWheelSelector:FlxSprite;

	var alphabetR:Alphabet;
	var alphabetG:Alphabet;
	var alphabetB:Alphabet;
	var alphabetHex:Alphabet;

	var allowedTypeKeys:Map<FlxKey, String> = [
		ZERO => '0', ONE => '1', TWO => '2', THREE => '3', FOUR => '4', FIVE => '5', SIX => '6', SEVEN => '7', EIGHT => '8', NINE => '9',
		NUMPADZERO => '0', NUMPADONE => '1', NUMPADTWO => '2', NUMPADTHREE => '3', NUMPADFOUR => '4', NUMPADFIVE => '5', NUMPADSIX => '6',
		NUMPADSEVEN => '7', NUMPADEIGHT => '8', NUMPADNINE => '9', A => 'A', B => 'B', C => 'C', D => 'D', E => 'E', F => 'F'
	];

	var bigNote:Note;

	// controller support
	var controllerPointer:FlxSprite;
	var _lastControllerMode:Bool = false;

	#if mobile
	var backButton:BackButton;
	#end

	var tipTxt:FlxText;

	var _storedColor:FlxColor;
	var holdingOnObj:FlxSprite;

	override function create() {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);

		modeNotes = new FlxTypedGroup<FlxSprite>();
		add(modeNotes);

		notesGroup = new FlxTypedGroup<Note>();
		add(notesGroup);

		btnGroup = new FlxTypedGroup<FlxSprite>();
		add(btnGroup);

		editingGroup = new FlxTypedGroup<Dynamic>();
		add(editingGroup);

		FlxTween.tween(bg, { alpha: 0.4 }, 0.5, { ease: FlxEase.quadOut });

		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		add(controllerPointer);

		#if mobile
		backButton = new BackButton();
		add(backButton);
		#end
		
		#if !mobile FlxG.mouse.visible = !controls.controllerMode; #end
		controllerPointer.visible = controls.controllerMode;
		_lastControllerMode = controls.controllerMode;

		reloadTab();

		super.create();
	}

	override function update(elapsed:Float) {
		if (ignoreCheckForThisFrame) {
			ignoreCheckForThisFrame = false;
			super.update(elapsed);
			return;
		}

		super.update(elapsed);

		// Early controller checking
		if (FlxG.gamepads.anyJustPressed(ANY)) controls.controllerMode = true;
		else if (FlxG.mouse.justPressed || FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0) controls.controllerMode = false;
		
		var changedToController:Bool = false;
		if(controls.controllerMode != _lastControllerMode)
		{
			#if !mobile FlxG.mouse.visible = !controls.controllerMode; #end
			controllerPointer.visible = controls.controllerMode;

			// changed to controller mid state
			if(controls.controllerMode)
			{
				controllerPointer.x = FlxG.mouse.x;
				controllerPointer.y = FlxG.mouse.y;
				changedToController = true;
			}

			_lastControllerMode = controls.controllerMode;
		}

		// controller things
		var analogX:Float = 0;
		var analogY:Float = 0;
		var analogMoved:Bool = false;
		if (controls.controllerMode && (changedToController || FlxG.gamepads.anyInput())) {
			for (gamepad in FlxG.gamepads.getActiveGamepads())
			{
				analogX = gamepad.getXAxis(LEFT_ANALOG_STICK);
				analogY = gamepad.getYAxis(LEFT_ANALOG_STICK);
				analogMoved = (analogX != 0 || analogY != 0);
				if (analogMoved) break;
			}
			controllerPointer.x = Math.max(0, Math.min(FlxG.width, controllerPointer.x + analogX * 1000 * elapsed));
			controllerPointer.y = Math.max(0, Math.min(FlxG.height, controllerPointer.y + analogY * 1000 * elapsed));
		}
		var controllerPressed:Bool = (controls.controllerMode && controls.ACCEPT);

		var generalMoved:Bool = (FlxG.mouse.justMoved || analogMoved);
		var generalPressed:Bool = (FlxG.mouse.justPressed || controllerPressed);

		var pressedBack:Bool = false;
		for (spr in btnGroup) {
			if (!(spr is Alphabet)) continue;
			var btn:Alphabet = cast(spr, Alphabet);
			if (!btn.bold) continue;
			if (pointerOverlaps(btn) && generalPressed) {
				if (btn.text == 'EDIT') {
					editingNote = btn.ID;
					reloadTab(NOTE_EDITING);
					FlxG.sound.play(Paths.sound('scrollMenu'));
					return;
				}
				else if (btn.text == 'RESET') {
					var note:Note = notesGroup.members[btn.ID];
					note.rgbShader.r = ClientPrefs.data.arrowRGBQuantization[btn.ID][0] = ClientPrefs.defaultData.arrowRGBQuantization[btn.ID][0];
					note.rgbShader.g = ClientPrefs.data.arrowRGBQuantization[btn.ID][1] = ClientPrefs.defaultData.arrowRGBQuantization[btn.ID][1];
					note.rgbShader.b = ClientPrefs.data.arrowRGBQuantization[btn.ID][2] = ClientPrefs.defaultData.arrowRGBQuantization[btn.ID][2];
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
				else if (btn.text == 'BACK') {
					pressedBack = true;
				}
			}
		}

		switch(currentTab) {
			case NOTE_SELECTION:
				if (controls.BACK #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.justPressed #end) {
					ClientPrefs.saveSettings();
					close();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			case NOTE_EDITING:
				if (controls.BACK || pressedBack #if android || FlxG.android.justReleased.BACK #end) {
					reloadTab(NOTE_SELECTION);
					FlxG.sound.play(Paths.sound('cancelMenu'));
					return;
				}

				if (hexTypeNum > -1) {
					var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
					hexTypeVisibleTimer += elapsed;
					var changed:Bool = false;
					if (changed = FlxG.keys.justPressed.LEFT)
						hexTypeNum--;
					else if (changed = FlxG.keys.justPressed.RIGHT)
						hexTypeNum++;
					else if (allowedTypeKeys.exists(keyPressed)) {
						var curColor:String = alphabetHex.text;
						var newColor:String = curColor.substring(0, hexTypeNum) + allowedTypeKeys.get(keyPressed) + curColor.substring(hexTypeNum + 1);

						var colorHex:FlxColor = FlxColor.fromString('#' + newColor);
						setShaderColor(colorHex);
						_storedColor = getShaderColor();
						updateColors();
				
						// move you to next letter
						hexTypeNum++;
						changed = true;
					}
					else if (FlxG.keys.justPressed.ENTER) {
						hexTypeNum = -1;
					}
			
					var end:Bool = false;
					if (changed) {
						if (hexTypeNum > 5) { //Typed last letter
							hexTypeNum = -1;
							end = true;
							hexTypeLine.visible = false;
						}
						else {
							if (hexTypeNum < 0) hexTypeNum = 0;
							else if (hexTypeNum > 5) hexTypeNum = 5;
							centerHexTypeLine();
							hexTypeLine.visible = true;
						}
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
					if (!end) hexTypeLine.visible = Math.floor(hexTypeVisibleTimer * 2) % 2 == 0;
				}
				else {
					var add:Int = 0;
					if (analogX == 0 && !changedToController) {
						if (controls.UI_LEFT_P) add = -1;
						else if(controls.UI_RIGHT_P) add = 1;
					}

					if (add != 0) {
						changeSelectionMode(add);
					}
					hexTypeLine.visible = false;
				}

				// Copy/Paste buttons
				if (generalMoved) {
					copyButton.alpha = 0.6;
					pasteButton.alpha = 0.6;
				}

				if (pointerOverlaps(copyButton)) {
					copyButton.alpha = 1;
					if (generalPressed) {
						Clipboard.text = getShaderColor().toHexString(false, false);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						trace('copied: ' + Clipboard.text);
					}
					hexTypeNum = -1;
				}
				else if (pointerOverlaps(pasteButton)) {
					pasteButton.alpha = 1;
					if (generalPressed) {
						var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
						var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
						if (newColor != null && formattedText.length == 6) {
							setShaderColor(newColor);
							FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
							_storedColor = getShaderColor();
							updateColors();
						}
						else //errored
							FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
					}
					hexTypeNum = -1;
				}

				// Click
				if (generalPressed) {
					hexTypeNum = -1;
					if (pointerOverlaps(modeNotes)) {
						modeNotes.forEachAlive(function(note:FlxSprite) {
							if (curSelectedMode != note.ID && pointerOverlaps(note)) {
								curSelectedMode = note.ID;
								updateNotes();
								FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
							}
						});
					}
					else if (pointerOverlaps(colorWheel)) {
						_storedColor = getShaderColor();
						holdingOnObj = colorWheel;
					}
					else if (pointerOverlaps(colorGradient)) {
						_storedColor = getShaderColor();
						holdingOnObj = colorGradient;
					}
					else if (pointerOverlaps(colorPalette)) {
						setShaderColor(colorPalette.pixels.getPixel32(
							Std.int((pointerX() - colorPalette.x) / colorPalette.scale.x), 
							Std.int((pointerY() - colorPalette.y) / colorPalette.scale.y)
						));
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						updateColors();
					}
					else if(pointerY() >= hexTypeLine.y && pointerY() < hexTypeLine.y + hexTypeLine.height && (pointerX() - 1000) >= -220 && (pointerX() - 1000) <= -55) {
						hexTypeNum = 0;
						for (letter in alphabetHex.letters) {
							if (letter.x - letter.offset.x + letter.width <= pointerX()) hexTypeNum++;
							else break;
						}
						if (hexTypeNum > 5) hexTypeNum = 5;
						hexTypeLine.visible = true;
						centerHexTypeLine();
					}
					else holdingOnObj = null;
				}
				// holding
				if (holdingOnObj != null) {
					if (FlxG.mouse.justReleased || (controls.controllerMode && controls.justReleased('accept'))) {
						holdingOnObj = null;
						_storedColor = getShaderColor();
						updateColors();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
					else if (generalMoved || generalPressed) {
						if (holdingOnObj == colorGradient) {
							var newBrightness = 1 - FlxMath.bound((pointerY() - colorGradient.y) / colorGradient.height, 0, 1);
							_storedColor.alpha = 1;
							if (_storedColor.brightness == 0) //prevent bug
								setShaderColor(FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness));
							else
								setShaderColor(FlxColor.fromHSB(_storedColor.hue, _storedColor.saturation, newBrightness));
							updateColors(_storedColor);
						}
						else if (holdingOnObj == colorWheel) {
							var center:FlxPoint = new FlxPoint(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
							var mouse:FlxPoint = pointerFlxPoint();
							var hue:Float = FlxMath.wrap(FlxMath.wrap(Std.int(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
							var sat:Float = FlxMath.bound(mouse.dist(center) / colorWheel.width*2, 0, 1);
							if (sat != 0) setShaderColor(FlxColor.fromHSB(hue, sat, _storedColor.brightness));
							else setShaderColor(FlxColor.fromRGBFloat(_storedColor.brightness, _storedColor.brightness, _storedColor.brightness));
							updateColors();
						}
					} 
				}
				else if (controls.RESET && hexTypeNum < 0) {
					setShaderColor(ClientPrefs.defaultData.arrowRGBQuantization[editingNote][curSelectedMode]);
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
					updateColors();
				}
		}
	}

	public function reloadTab(tab:SelectionTab = NOTE_SELECTION) {
		if (box != null) {
			box.destroy();
			remove(box);
		}
		notesGroup.clear();
		btnGroup.clear();
		modeNotes.clear();
		editingGroup.clear();

		switch(tab) {
			case NOTE_SELECTION:
				#if mobile
				backButton.revive();
				#end

				box = new FlxSprite().makeGraphic(850, 500, 0xC9000000);
				box.screenCenter();
				box.drawRect(0, 0, box.width, box.height, 0, {thickness: 10, color: 0xFFFFFFFF});
				insert(members.indexOf(modeNotes), box);

				// this is hardcoded to 8 snaps only because i'm lazy LOL! - melodiekit
				for (i in 0...8) {
					var note = new Note(0, 0);
					note.scale.x *= 0.95;
					note.scale.y *= 0.95;
					note.x = i > 3 ? 640 : 240;
					note.y = 128 + (120 * (i > 3 ? i-4 : i));
					note.rgbShader.r = ClientPrefs.data.arrowRGBQuantization[i][0];
					note.rgbShader.g = ClientPrefs.data.arrowRGBQuantization[i][1];
					note.rgbShader.b = ClientPrefs.data.arrowRGBQuantization[i][2];
					notesGroup.add(note);

					var snapTxt = new Alphabet(note.x + 160, note.y - 15, Note.quantizations[i] + 'th Note', false);
					snapTxt.setScale(0.5, 0.5);
					for (letter in snapTxt.letters) letter.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
					btnGroup.add(snapTxt);

					var editTxt = new Alphabet(note.x + 140, note.y + 60, 'EDIT');
					editTxt.setScale(0.4, 0.4);
					editTxt.ID = i;
					btnGroup.add(editTxt);

					var resetTxt = new Alphabet(editTxt.x + 120, editTxt.y, 'RESET');
					resetTxt.setScale(0.4, 0.4);
					resetTxt.ID = i;
					btnGroup.add(resetTxt);

					var bg = new FlxSprite(editTxt.x - 20, editTxt.y - 5).makeGraphic(Math.round(editTxt.width * 1.5), Math.round(editTxt.height * 1.5), 0xFF1A1A1A);
					bg.drawRect(0, 0, bg.width, bg.height, 0, {thickness: 5, color: 0xFFFFFFFF});
					btnGroup.insert(btnGroup.members.indexOf(editTxt), bg);

					var bg = new FlxSprite(resetTxt.x - 20, resetTxt.y - 5).makeGraphic(Math.round(resetTxt.width * 1.5), Math.round(resetTxt.height * 1.5), 0xFF1A1A1A);
					bg.drawRect(0, 0, bg.width, bg.height, 0, {thickness: 5, color: 0xFFFFFFFF});
					btnGroup.insert(btnGroup.members.indexOf(resetTxt), bg);
				}
			case NOTE_EDITING:
				#if mobile
				backButton.kill();
				#end

				box = new FlxSprite().makeGraphic(950, 670, 0xC9000000);
				box.screenCenter();
				box.drawRect(0, 0, box.width, box.height, 0, {thickness: 10, color: 0xFFFFFFFF});
				insert(members.indexOf(modeNotes), box);

				var backTxt = new Alphabet(215, 625, 'BACK');
				backTxt.setScale(0.6, 0.6);
				btnGroup.add(backTxt);

				var bg = new FlxSprite(backTxt.x - 30, backTxt.y - 10).makeGraphic(Math.round(backTxt.width * 1.5), Math.round(backTxt.height * 1.5), 0xFF1A1A1A);
				bg.drawRect(0, 0, bg.width, bg.height, 0, {thickness: 5, color: 0xFFFFFFFF});
				btnGroup.insert(btnGroup.members.indexOf(backTxt), bg);

				var snap = new Alphabet(250, 10, Note.quantizations[editingNote] + 'th Note', false);
				snap.setScale(0.9, 0.9);
				for (letter in snap.letters) letter.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
				editingGroup.add(snap);

				copyButton = new FlxSprite(640, 50).loadGraphic(Paths.image('noteColorMenu/copy'));
				copyButton.alpha = 0.6;
				editingGroup.add(copyButton);

				pasteButton = new FlxSprite(1010, 50).loadGraphic(Paths.image('noteColorMenu/paste'));
				pasteButton.alpha = 0.6;
				editingGroup.add(pasteButton);

				colorGradient = FlxGradient.createGradientFlxSprite(60, 360, [FlxColor.WHITE, FlxColor.BLACK]);
				colorGradient.setPosition(580, 200);
				editingGroup.add(colorGradient);

				colorGradientSelector = new FlxSprite(570, 200).makeGraphic(80, 10, FlxColor.WHITE);
				colorGradientSelector.offset.y = 5;
				editingGroup.add(colorGradientSelector);

				colorPalette = new FlxSprite(705, 580).loadGraphic(Paths.image('noteColorMenu/palette', false));
				colorPalette.scale.set(20, 20);
				colorPalette.updateHitbox();
				colorPalette.antialiasing = false;
				editingGroup.add(colorPalette);
		
				colorWheel = new FlxSprite(690, 190).loadGraphic(Paths.image('noteColorMenu/colorWheel'));
				colorWheel.setGraphicSize(360, 360);
				colorWheel.updateHitbox();
				editingGroup.add(colorWheel);

				colorWheelSelector = new FlxShapeCircle(0, 0, 8, {thickness: 0}, FlxColor.WHITE);
				colorWheelSelector.offset.set(8, 8);
				colorWheelSelector.alpha = 0.6;
				editingGroup.add(colorWheelSelector);

				var txtX = 870;
				var txtY = 115;
				alphabetR = makeColorAlphabet(txtX - 100, txtY);
				editingGroup.add(alphabetR);
				alphabetG = makeColorAlphabet(txtX, txtY);
				editingGroup.add(alphabetG);
				alphabetB = makeColorAlphabet(txtX + 100, txtY);
				editingGroup.add(alphabetB);
				alphabetHex = makeColorAlphabet(txtX, txtY - 55);
				editingGroup.add(alphabetHex);
				hexTypeLine = new FlxSprite(0, 45).makeGraphic(5, 62, FlxColor.WHITE);
				hexTypeLine.visible = false;
				editingGroup.add(hexTypeLine);

				spawnNotes();
				updateNotes();

				var tip:FlxText = new FlxText(400, 630, 300, Language.getPhrase('note_colors_tip', 'Press RESET to Reset the selected Note Part.'), 16);
				tip.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				tip.borderSize = 2;
				editingGroup.add(tip);
		}

		ignoreCheckForThisFrame = true;
		currentTab = tab;
	}

	function pointerOverlaps(obj:Dynamic) {
		if (!controls.controllerMode) return FlxG.mouse.overlaps(obj);
		return FlxG.overlap(controllerPointer, obj);
	}

	function pointerX():Float {
		if (!controls.controllerMode) return FlxG.mouse.x;
		return controllerPointer.x;
	}
	function pointerY():Float {
		if (!controls.controllerMode) return FlxG.mouse.y;
		return controllerPointer.y;
	}
	function pointerFlxPoint():FlxPoint {
		if (!controls.controllerMode) return FlxG.mouse.getScreenPosition();
		return controllerPointer.getScreenPosition();
	}

	function centerHexTypeLine() {
		if (hexTypeNum > 0) {
			var letter = alphabetHex.letters[hexTypeNum-1];
			hexTypeLine.x = letter.x - letter.offset.x + letter.width;
		}
		else {
			var letter = alphabetHex.letters[0];
			hexTypeLine.x = letter.x - letter.offset.x;
		}
		hexTypeLine.x += hexTypeLine.width;
		hexTypeVisibleTimer = 0;
	}

	function changeSelectionMode(change:Int = 0) {
		curSelectedMode += change;
		if (curSelectedMode < 0)
			curSelectedMode = 2;
		if (curSelectedMode >= 3)
			curSelectedMode = 0;

		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function makeColorAlphabet(x:Float = 0, y:Float = 0):Alphabet {
		var text:Alphabet = new Alphabet(x, y, '', true);
		text.alignment = CENTERED;
		text.setScale(0.6);
		return text;
	}

	function spawnNotes() {
		modeNotes.clear();
		if(bigNote != null) {
			remove(bigNote);
			bigNote.destroy();
		}

		for (i in 0...3) {
			var newNote:FlxSprite = new FlxSprite(210 + (110 * i), 130).loadGraphic(Paths.image('noteColorMenu/note'), true, 160, 160);
			newNote.antialiasing = ClientPrefs.data.antialiasing;
			newNote.setGraphicSize(95);
			newNote.updateHitbox();
			newNote.animation.add('anim', [i], 24, true);
			newNote.animation.play('anim', true);
			newNote.ID = i;
			modeNotes.add(newNote);
		}

		bigNote = new Note(0, 0, null, false, true);
		bigNote.setPosition(230, 275);
		bigNote.setGraphicSize(280);
		bigNote.updateHitbox();
		bigNote.rgbShader.r = ClientPrefs.data.arrowRGBQuantization[editingNote][0];
		bigNote.rgbShader.g = ClientPrefs.data.arrowRGBQuantization[editingNote][1];
		bigNote.rgbShader.b = ClientPrefs.data.arrowRGBQuantization[editingNote][2];
		editingGroup.add(bigNote);
	}

	function updateNotes() {
		for (note in modeNotes) {
			note.alpha = (curSelectedMode == note.ID) ? 1 : 0.6;
		}
		updateColors();
	}

	function updateColors(specific:Null<FlxColor> = null)
	{
		var color:FlxColor = getShaderColor();
		var wheelColor:FlxColor = specific == null ? getShaderColor() : specific;
		alphabetR.text = Std.string(color.red);
		alphabetG.text = Std.string(color.green);
		alphabetB.text = Std.string(color.blue);
		alphabetHex.text = color.toHexString(false, false);
		for (letter in alphabetHex.letters) letter.color = color;

		colorWheel.color = FlxColor.fromHSB(0, 0, color.brightness);
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
		if(wheelColor.brightness != 0)
		{
			var hueWrap:Float = wheelColor.hue * Math.PI / 180;
			colorWheelSelector.x += Math.sin(hueWrap) * colorWheel.width/2 * wheelColor.saturation;
			colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height/2 * wheelColor.saturation;
		}
		colorGradientSelector.y = colorGradient.y + colorGradient.height * (1 - color.brightness);

		switch(curSelectedMode) {
			case 0:
				bigNote.rgbShader.r = color;
			case 1:
				bigNote.rgbShader.g = color;
			case 2:
				bigNote.rgbShader.b = color;
		}
	}

	function setShaderColor(value:FlxColor) ClientPrefs.data.arrowRGBQuantization[editingNote][curSelectedMode] = value;
	function getShaderColor() return ClientPrefs.data.arrowRGBQuantization[editingNote][curSelectedMode];
}

enum SelectionTab
{
	NOTE_SELECTION;
	NOTE_EDITING;
}