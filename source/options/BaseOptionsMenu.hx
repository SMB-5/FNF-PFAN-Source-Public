// FlxText is ragebait
// I hate this class

package options;

import flixel.ui.FlxBar;

import flixel.addons.display.shapes.FlxShapeCircle;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

import objects.CheckboxThingie;
import objects.AttachedSprite;
import objects.AttachedText;
import options.Option;

import backend.WeekData;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var x:Null<Float> = null;
	private var y:Null<Float> = null;
	private var width:Null<Int> = null;
	private var height:Null<Int> = null;

	private var camOptions:FlxCamera;
	private var camUI:FlxCamera;

	private var keyIcons:FlxSpriteGroup;

	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var holdingBox:Bool = false;
	private var allowScrolling:Bool = false;
	private var scrollBar:FlxSprite;
	private var scrollTimer:Float = 0;
	private var scrollTween:FlxTween;

	private var bg:FlxSprite;
	private var patternBG:FlxSprite;
	private var outlineBG:FlxSprite;
	private var optionHeader:FlxText;
	private var optionHeader2:FlxText;

	// Five. Hundred. Groups.
	private var grpBackgrounds:FlxSpriteGroup;
	private var grpOptions:FlxTypedGroup<FlxText>;
	private var grpInfos:FlxTypedGroup<FlxSprite>;
	private var grpReset:FlxTypedGroup<FlxSprite>;
	private var grpSettings:FlxTypedGroup<FlxSprite>;
	private var grpValues:FlxTypedGroup<FlxText>;
	private var grpArrows:FlxTypedGroup<FlxText>;
	private var grpEdits:FlxTypedGroup<FlxSprite>;
	private var grpLocked:FlxTypedGroup<FlxSprite>;
	private var grpLockedDesc:FlxTypedGroup<FlxSprite>;
	private var grpDesc:FlxTypedGroup<FlxSprite>;
	private var lineArray:Array<Array<FlxSprite>> = [];
	private var barArray:Array<Array<FlxSprite>> = [];

	public var songOrWeek:String = '';
	public var storyMode:Bool = false;
	private var disallowedString:String = '';

	private var backButton:BackButton;

	public var title:String;
	public var rpcTitle:String;
	public var useRPC:Bool = true;

	public function new(songOrWeek:String = '', storyMode:Bool = false) {
		super();

		if (title == null) title = 'Options';
		if (rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if DISCORD_ALLOWED
		if (useRPC) DiscordClient.changePresence(rpcTitle, null);
		#end

		this.songOrWeek = songOrWeek;
		this.storyMode = storyMode;

		if (width == null) width = FlxG.width - 200;
		if (height == null) height = FlxG.height - #if !mobile 90 #else 70 #end;
		camOptions = new FlxCamera(0, 0, width, height);
		camOptions.bgColor.alpha = 0;
		if (x == null) x = camOptions.x = (FlxG.width - width) / 2 - 80;
		else camOptions.x = x;
		if (y == null) y = camOptions.y = (FlxG.height - height) / 2 #if !mobile - 20 #end;
		else camOptions.y = y;
		camOptions.visible = false;
		FlxG.cameras.add(camOptions, false);

		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		cameras = [camOptions];

		bg = new FlxSprite().makeGraphic(camOptions.width, camOptions.height, 0xFF454545);
		bg.scrollFactor.set();
		add(bg);

		patternBG = new FlxSprite(0, 0, Paths.image('persona/results/resultsbg'));
		patternBG.setGraphicSize(camOptions.width, camOptions.height);
		patternBG.updateHitbox();
		patternBG.scrollFactor.set();
		patternBG.alpha = 0.4;
		add(patternBG);

		optionHeader = new FlxText(camOptions.x + camOptions.width + 23, FlxG.height, 150, title, 120);
		optionHeader.alignment = CENTER;
		@:privateAccess
		optionHeader._defaultFormat.leading = -30;
		optionHeader.font = Paths.font('akira.otf');
		optionHeader.camera = camUI;
		add(optionHeader);

		optionHeader2 = new FlxText(camOptions.x + camOptions.width + 23, FlxG.height + optionHeader.height + 200, 150, title, 120);
		optionHeader2.alignment = CENTER;
		@:privateAccess
		optionHeader2._defaultFormat.leading = -30;
		optionHeader2.font = Paths.font('akira.otf');
		optionHeader2.camera = camUI;
		add(optionHeader2);

		grpBackgrounds = new FlxSpriteGroup();
		add(grpBackgrounds);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		grpInfos = new FlxTypedGroup<FlxSprite>();
		add(grpInfos);

		grpReset = new FlxTypedGroup<FlxSprite>();
		add(grpReset);

		grpSettings = new FlxTypedGroup<FlxSprite>();
		add(grpSettings);

		grpValues = new FlxTypedGroup<FlxText>();
		add(grpValues);

		grpArrows = new FlxTypedGroup<FlxText>();
		add(grpArrows);

		grpEdits = new FlxTypedGroup<FlxSprite>();
		add(grpEdits);

		grpLocked = new FlxTypedGroup<FlxSprite>();
		add(grpLocked);

		grpLockedDesc = new FlxTypedGroup<FlxSprite>();
		add(grpLockedDesc);

		grpDesc = new FlxTypedGroup<FlxSprite>();
		add(grpDesc);

		keyIcons = new FlxSpriteGroup();
		keyIcons.cameras = [camUI];
		add(keyIcons);

		if (optionsArray.length > 9) allowScrolling = true;

		for (i in 0...optionsArray.length) {
			if (optionsArray[i].disallowStoryMode && storyMode || optionsArray[i].disallowFreeplay && !storyMode || checkDisallowedSong(optionsArray[i], songOrWeek)) {
				optionsArray[i].disallowed = true;
			}

			var optionBG:FlxSprite = new FlxSprite(20, 30 + (70 * i)).makeGraphic(Std.int(camOptions.width - 40), 65, 0xFF000000);
			optionBG.alpha = 0.3;
			optionBG.ID = i;
			grpBackgrounds.add(optionBG);

			var info:FlxShapeCircle = new FlxShapeCircle(30, optionBG.y + 15, 17, {thickness: 5, color: 0xAF000000}, FlxColor.GRAY);
			info.ID = i;
			grpInfos.add(info);

			var infoTxt:FlxText = new FlxText(info.x + 12, info.y + 2, 100, 'i', 28);
			infoTxt.font = Paths.font('Fontsona3FES.ttf');
			infoTxt.color = 0xFF000000;
			infoTxt.alpha = 0.6;
			grpInfos.add(infoTxt);

			var option:FlxText = new FlxText(optionBG.x + 55, optionBG.y + 15, optionBG.width, Language.getPhrase('setting_' + optionsArray[i].name, optionsArray[i].name), 32);
			option.font = Paths.font('Fontsona3FES.ttf');
			option.ID = i;
			if (option.textField.textWidth > 500) {
				option.scale.x = option.scale.y = 500 / option.textField.textWidth;
				option.origin.y = option.textField.textHeight / 2;
				// i have to use a timer for some reason
				new FlxTimer().start(0.000001, (_)->{
					option.origin.x = 0;
				});
			}
			grpOptions.add(option);

			var optionWidth:Float = option.textField.textWidth * option.scale.x;

			var reset = new FlxSprite(option.x + optionWidth + 13, option.y, Paths.image('resetButton'));
			reset.setGraphicSize(40, 40);
			reset.updateHitbox();
			reset.color = FlxColor.GRAY;
			reset.ID = i;
			grpReset.add(reset);

			if (optionsArray[i].customizable) {
				var setting:FlxSprite = new FlxSprite(reset.x + reset.width + 7, option.y - 1, Paths.image('settingButton'));
				setting.scale.set(0.8, 0.8);
				setting.updateHitbox();
				setting.alpha = 0.8;
				setting.color = FlxColor.GRAY;
				setting.ID = i;
				grpSettings.add(setting);
			}

			switch(optionsArray[i].type) {
				case STRING, INT, FLOAT, BOOL:
					var leftArrow:FlxText = new FlxText(optionBG.x + optionBG.width - 325, optionBG.y + 5, 40, '<', 40);
					leftArrow.font = Paths.font('Fontsona3FES.ttf');
					leftArrow.ID = i;
					grpArrows.add(leftArrow);

					var rightArrow:FlxText = new FlxText(optionBG.x + optionBG.width - 50, optionBG.y + 5, 40, '>', 40);
					rightArrow.font = Paths.font('Fontsona3FES.ttf');
					rightArrow.ID = i;
					grpArrows.add(rightArrow);

					var curValue:String = optionsArray[i].type != BOOL ? Std.string(optionsArray[i].getValue()) : optionsArray[i].getValue() == true ? 'ON' : 'OFF';
					var curOption:FlxText = new FlxText(0, optionBG.y + 15, 0, curValue, 28);
					curOption.font = Paths.font('Fontsona3FES.ttf');
					curOption.x = (leftArrow.x + rightArrow.x - curOption.textField.textWidth) / 2 + 15;
					if (curOption.textField.textWidth >= 200) {
						curOption.scale.x = curOption.scale.y = 200 / curOption.textField.textWidth;
						curOption.origin.y = curOption.textField.textHeight / 2;
					}
					curOption.ID = i;
					grpValues.add(curOption);
					optionsArray[i].child = curOption;

					if (optionsArray[i].type == STRING) {
						lineArray[i] = [];
						for (k in 0...optionsArray[i].options.length) {
							var line = new FlxSprite(0, curOption.y + 40).makeGraphic(20, 5, 0xFFFFFFFF);
							line.color = 0xFF676767; // 67 67 67 67 67 67
							line.x = (curOption.x + curOption.textField.textWidth / 2) - (5 * (optionsArray[i].options.length - 1)) + (30 * k) - line.width / 2 * optionsArray[i].options.length;
							add(line);
							lineArray[i].push(line);
							if (optionsArray[i].getValue() == optionsArray[i].options[k]) {
								line.color = 0xFFFFFF00;
							}
						}
					}
				// Percent uses bar cuz it's cool!!! :D
				case PERCENT:
					barArray[i] = [];

					var bar:FlxBar = new FlxBar(0, optionBG.y + 48, LEFT_TO_RIGHT, 170, 10, null, '', optionsArray[i].minValue, optionsArray[i].maxValue * 100);
					bar.createFilledBar(0xFF000000, 0xFFFFFFFF);
					bar.x = optionBG.x + optionBG.width - bar.width - 87;
					bar.drawRect(0, 0, bar.width, bar.height, 0, {thickness: 1, color: 0xFFFFFFFF});
					bar.percent = optionsArray[i].getValue() * 100;
					bar.ID = i;
					add(bar);
					barArray[i].push(bar);

					var barCircle:FlxShapeCircle = new FlxShapeCircle(bar.x - 5, bar.y - 2, 7, {thickness: 1}, 0xFFFFFFFF);
					barCircle.ID = i;
					add(barCircle);
					barArray[i].push(barCircle);

					var curOption:FlxText = new FlxText(0, bar.y - 35, 300, Std.string(optionsArray[i].getValue()), 28);
					curOption.font = Paths.font('Fontsona3FES.ttf');
					curOption.x = bar.getMidpoint().x - curOption.textField.textWidth / 2;
					curOption.ID = i;
					grpValues.add(curOption);
					optionsArray[i].child = curOption;
				case SUBSTATE(cl):
					var editBG:FlxSprite = new FlxSprite(optionBG.x + optionBG.width - 260, optionBG.y + 13).makeGraphic(175, 40, 0xFFFFFFFF);
					editBG.drawRect(0, 0, editBG.width, editBG.height, 0, {thickness: 5, color: 0xFF000000});
					editBG.ID = i;
					grpEdits.add(editBG);

					// this isn't translated for now because i literally can't figure out how to center it properly
					var edit:FlxText = new FlxText(0, editBG.y + 3, editBG.width, 'Edit', 28);
					edit.x = editBG.x + edit.textField.textWidth - 7;
					edit.font = Paths.font('Fontsona5Royal.ttf');
					edit.color = 0xFF000000;
					grpEdits.add(edit);
				case _:
			}

			if (optionsArray[i].disallowed) {
				var lockedBG:FlxSprite = new FlxSprite(optionBG.x + 710, optionBG.y).makeGraphic(Std.int(optionBG.width - 710), Std.int(optionBG.height), 0xFF000000);
				lockedBG.ID = i;
				grpLocked.add(lockedBG);

				var locked:FlxText = new FlxText(0, lockedBG.y + 13, lockedBG.width, 'LOCKED', 36);
				locked.x = lockedBG.getMidpoint().x - 90;
				locked.font = Paths.font('Fontsona3FES.ttf');
				grpLocked.add(locked);

				var lockedDesc:FlxSprite = new FlxSprite(lockedBG.x - 320, lockedBG.y + 70).makeGraphic(500, 210, 0xFF000000);
				lockedDesc.alpha = 0.9;
				lockedDesc.drawRect(0, 0, lockedDesc.width, lockedDesc.height, 0, {thickness: 5, color: 0xFFFFFFFF});
				lockedDesc.visible = false;
				lockedDesc.ID = i;
				grpLockedDesc.add(lockedDesc);

				var lockedDescTxt:FlxText = new FlxText(lockedDesc.x + 20, lockedDesc.y + 10, lockedDesc.width - 40, getDisallowedString(optionsArray[i]), 20);
				@:privateAccess
				lockedDescTxt._defaultFormat.leading = 6;
				lockedDescTxt.font = Paths.font('Fontsona3FES.ttf');
				lockedDescTxt.visible = false;
				lockedDescTxt.ID = i;
				grpLockedDesc.add(lockedDescTxt);
			}

			var descBG:FlxSprite = new FlxSprite(info.x, info.y + 50).makeGraphic(500, 210, 0xFF000000);
			descBG.alpha = 0.9;
			descBG.drawRect(0, 0, descBG.width, descBG.height, 0, {thickness: 5, color: 0xFFFFFFFF});
			descBG.visible = false;
			descBG.ID = i;
			grpDesc.add(descBG);

			var descTxt:FlxText = new FlxText(descBG.x + 20, descBG.y + 10, descBG.width - 40, Language.getPhrase('description_' + optionsArray[i].name, optionsArray[i].description), 20);
			@:privateAccess
			descTxt._defaultFormat.leading = 6;
			descTxt.font = Paths.font('Fontsona3FES.ttf');
			descTxt.visible = false;
			descTxt.ID = i;
			grpDesc.add(descTxt);

			updateTextFrom(optionsArray[i]);
		}

		scrollBar = new FlxSprite().makeGraphic(20, Math.round(camOptions.height * camOptions.height / grpBackgrounds.height) - 27, 0xFF000000);
		scrollBar.x = camOptions.width - scrollBar.width;
		scrollBar.camera = camOptions;
		scrollBar.alpha = 0.6;
		scrollBar.visible = allowScrolling;
		scrollBar.scrollFactor.set();
		add(scrollBar);

		outlineBG = new FlxSprite(camOptions.x, camOptions.y).makeGraphic(camOptions.width, camOptions.height, 0);
		outlineBG.drawRect(0, 0, outlineBG.width, outlineBG.height, 0, {thickness: 10, color: 0xFFFFFFFF});
		outlineBG.camera = camUI;
		outlineBG.visible = false;
		add(outlineBG);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(0, FlxG.height - 44, 'dpad', 1, 'ui_select', 0.15, 24);
		keyIcons.add(movementIcon);

		var backIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 20, FlxG.height - 44, 'back', 0, 'ui_back', 0.15, 24);
		keyIcons.add(backIcon);

		var acceptIcon:KeyIcon = new KeyIcon(backIcon.x + backIcon.width + 15, FlxG.height - 44, 'accept', 0, 'ui_confirm', 0.15, 24);
		keyIcons.add(acceptIcon);

		var infoIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 15, FlxG.height - 44, controls.controllerMode ? 'X' : 'F1', 0, 'ui_view_description', 0.15, 24);
		keyIcons.add(infoIcon);

		var resetIcon:KeyIcon = new KeyIcon(infoIcon.x + infoIcon.width + 15, FlxG.height - 44, 'reset', 0, 'ui_reset', 0.15, 24);
		keyIcons.add(resetIcon);

		var customizableIcon:KeyIcon = new KeyIcon(resetIcon.x + resetIcon.width + 15, FlxG.height - 44, controls.controllerMode ? 'START' : 'TAB', 0, 'ui_customize_option', 0.15, 24);
		keyIcons.add(customizableIcon);
		#end

		backButton = new BackButton();
		backButton.x += 50;
		backButton.camera = camUI;
		add(backButton);

		FlxTween.tween(camOptions, { height: height }, 0.15, { startDelay: 0.25, onComplete: _->{
			updateCam(_);
			enableInputs = true;
		}, onUpdate: updateCam, onStart: _->{
			outlineBG.setGraphicSize(outlineBG.width, 10);
			camOptions.height = 10;
			camOptions.visible = true;
			outlineBG.visible = true;
			FlxG.sound.play(Paths.sound('persona/ui_open'));
		} });

		#if !mobile
		changeSelection(0, false);
		#end
	}

	function updateCam(_) {
		camOptions.y = (FlxG.height - camOptions.height) / 2 #if !mobile - 20 #end;
		outlineBG.setGraphicSize(outlineBG.width, camOptions.height);
		outlineBG.updateHitbox();
		outlineBG.y = camOptions.y;
		patternBG.y = (camOptions.height - patternBG.height) / 2;
	}

	public function addOption(option:Option) {
		if (optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var enableInputs:Bool = false;
	var holdTime:Float = 0;
	var holdTimeKey:Float = 0;
	var holdValue:Float = 0;
	var holdValueKey:Float = 0;
	var swiping:Bool = false;
	// GOD
	var hoveringArrow:Bool = false;
	var hoveringBar:Bool = false;
	var holdingArrow:Int = -1;
	var holdingBar:Int = -1;
	var holdingDesc:Int = -1;
	var holdingLockedDesc:Int = -1;
	var prevMouseY:Float = 0;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!enableInputs) return;

		scrollTimer += elapsed;

		optionHeader.y -= 140 * elapsed;
		optionHeader2.y -= 140 * elapsed;
		if (optionHeader.y <= -optionHeader.height) optionHeader.y = optionHeader.height + 400;
		if (optionHeader2.y <= -optionHeader2.height) optionHeader2.y = optionHeader.height + 400;

		#if !mobile
		if (FlxG.mouse.justMoved) {
			if (holdingDesc <= -1) {
				for (desc in grpDesc) desc.visible = false;
			}
			if (holdingLockedDesc <= -1) {
				for (desc in grpLockedDesc) desc.visible = false;
			}
			for (bg in grpBackgrounds) {
				if (!hoveringBar && !hoveringArrow && FlxG.mouse.overlaps(bg, camOptions) && curSelected != bg.ID) {
					changeSelection(bg.ID, false);
				}
			}
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P) {
			holdTimeKey = holdValueKey = 0;
			if (holdingDesc <= -1) {
				for (desc in grpDesc) desc.visible = false;
			}
			if (holdingLockedDesc <= -1) {
				for (desc in grpLockedDesc) desc.visible = false;
			}
			changeSelection(curSelected + (controls.UI_DOWN_P ? 1 : -1), false, true);
		}

		// i apologize for this
		if (controls.UI_LEFT || controls.UI_RIGHT) {
			var go = true;
			switch(curOption.type) {
				case KEYBIND: go = false;
				case SUBSTATE(cl): go = false;
				default:
			}
			if (!curOption.disallowed && go) {
				var justPressed:Bool = controls.UI_LEFT_P || controls.UI_RIGHT_P;
				if (holdTimeKey > 0.5 || justPressed) {
					if (curOption.type == INT || curOption.type == FLOAT || curOption.type == PERCENT) {
						if (controls.UI_LEFT_P && curOption.getValue() > curOption.minValue || controls.UI_RIGHT_P && curOption.getValue() < curOption.maxValue) {
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if (holdTimeKey <= 0.5) {
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}
					}
					else if (holdTimeKey <= 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				var add:Dynamic = null;
				if (justPressed) {
					if (curOption.type != STRING) {
						add = controls.UI_LEFT_P ? -curOption.changeValue : curOption.changeValue;
					}
					if (curOption.type == INT || curOption.type == FLOAT || curOption.type == PERCENT) {
						holdValueKey = FlxMath.bound(curOption.getValue() + add, curOption.minValue, curOption.maxValue);
					}
				}
				switch(curOption.type) {
					case BOOL if (justPressed):
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						updateTextFrom(curOption);
					default:
						if (justPressed) {
							switch(curOption.type) {
								case INT, FLOAT, PERCENT:
									if (curOption.type == INT) {
										holdValueKey = Math.round(holdValueKey);
									}
									else if (curOption.type == FLOAT) {
										holdValueKey = FlxMath.roundDecimal(Math.round(holdValueKey / curOption.changeValue) * curOption.changeValue, curOption.decimals);
									}
									else {
										holdValueKey = FlxMath.roundDecimal(holdValueKey, curOption.decimals);
									}
									curOption.setValue(holdValueKey);
		
								case STRING:
									var num:Int = curOption.curOption;
									num = FlxMath.wrap(num + (controls.UI_LEFT_P ? -1 : 1), 0, curOption.options.length - 1);
									curOption.curOption = num;
									curOption.setValue(curOption.options[num]);

									if (curOption.variable == 'scrolltype') {
										var oOption:Option = getOptionByVariable('scrollspeed');
										if (oOption != null) {
											if (curOption.getValue() == 'constant') {
												oOption.displayFormat = '%v';
												oOption.maxValue = 6;
											}
											else {
												oOption.displayFormat = '%vx';
												oOption.maxValue = 3;
												if (oOption.getValue() > 3) oOption.setValue(3);
											}
											updateTextFrom(oOption);
										}
									}

								default:
							}
							updateTextFrom(curOption);
							curOption.change();
						}
						else if (holdTimeKey > 0.5 && curOption.type != STRING) {
							holdValueKey = FlxMath.bound(holdValueKey + curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1), curOption.minValue, curOption.maxValue);
		
							switch(curOption.type) {
								case INT:
									curOption.setValue(Math.round(holdValueKey));
								case FLOAT, PERCENT:
									curOption.setValue(FlxMath.roundDecimal(holdValueKey, curOption.decimals));
								default:
							}
							updateTextFrom(curOption);
							curOption.change();
						}

						if (curOption.type != STRING) {
							holdTimeKey += elapsed;
						}
				}
			}
		}
		else {
			if (holdTimeKey > 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
			holdTimeKey = 0;
		}

		if (FlxG.keys.justPressed.F1 || FlxG.gamepads.anyJustPressed(X)) {
			var descBG:FlxSprite = grpDesc.getFirst(s->s.ID == curSelected);
			var descTxt:FlxText = cast grpDesc.members[grpDesc.members.indexOf(descBG) + 1];
			if (descBG != null && descTxt != null) {
				descBG.visible = descTxt.visible = !descBG.visible;
			}
		}

		if (controls.RESET) {
			resetOption(curOption);
		}

		if ((FlxG.keys.justPressed.TAB || FlxG.gamepads.anyJustPressed(START)) && curOption.customizable) {
			openSubState(Type.createInstance(curOption.customizationClass, []));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (controls.ACCEPT) {
			if (!curOption.disallowed) {
				switch(curOption.type) {
					case SUBSTATE(cl):
						openSubState(Type.createInstance(cl, []));
						FlxG.sound.play(Paths.sound('scrollMenu'));
					default:
				}
			}
			else {
				var descBG:FlxSprite = grpLockedDesc.getFirst(s->s.ID == curSelected);
				var descTxt:FlxText = cast grpLockedDesc.members[grpLockedDesc.members.indexOf(descBG) + 1];
				if (descBG != null && descTxt != null) {
					descBG.visible = descTxt.visible = !descBG.visible;
				}
			}
		}
		#end

		if (allowScrolling) {
			if (scrollTimer >= 1 && scrollTween == null) {
				scrollTween = FlxTween.tween(scrollBar, { alpha: 0 }, 0.25);
			}
			if (FlxG.mouse.wheel != 0) {
				var val:Float = -FlxG.mouse.wheel * 13;
				camOptions.scroll.y += val;
				if (scrollTween != null) {
					scrollTween.cancel();
					scrollTween = null;
				}
				scrollBar.alpha = 0.6;
				scrollBar.y += val * (camOptions.height / (grpBackgrounds.height + 50));
				scrollTimer = 0;
			}
			if (!hoveringBar && !hoveringArrow && (TouchUtil.justPressed && TouchUtil.overlaps(bg, camOptions) || TouchUtil.pressed && holdingBox)) {
				if (TouchUtil.justPressed) {
					holdingBox = true;
					#if mobile prevMouseY += TouchUtil.input.viewY; #end
				}
				@:privateAccess
				var leftInput = #if !mobile FlxG.mouse._leftButton #else TouchUtil.input #end;
				var offset:Float = leftInput.justPressedPosition.y - TouchUtil.input.getScreenPosition(camOptions).y;
				if (Math.abs(offset) > 40 || swiping) {
					swiping = true;
					#if !mobile
					var val:Float = camOptions.scroll.y - FlxG.mouse.deltaViewY;
					#else
					var val:Float = prevMouseY - TouchUtil.input.viewY;
					#end
					camOptions.scroll.y = val;
					if (scrollTween != null) {
						scrollTween.cancel();
						scrollTween = null;
					}
					scrollBar.alpha = 0.6;
					scrollBar.y = val * (camOptions.height / (grpBackgrounds.height + 50));
					scrollTimer = 0;
				}
			}

			camOptions.scroll.y = FlxMath.bound(camOptions.scroll.y, 0, grpBackgrounds.height - camOptions.height + 50);
			scrollBar.y = FlxMath.bound(scrollBar.y, 0, camOptions.height - scrollBar.height);
		}

		for (num => arrow in grpArrows) {
			var selectedOption:Option = optionsArray[arrow.ID];
			if (selectedOption.disallowed) continue;
			if (!swiping && !hoveringBar && (TouchUtil.pressed && hoveringArrow || TouchUtil.justPressed) && TouchUtil.overlaps(arrow, camOptions, FlxPoint.get(-12, 4))) {
				holdingArrow = num;
				var pressedLeft:Bool = arrow.text == '<';
				if (holdTime > 0.5 || TouchUtil.justPressed) {
					if (selectedOption.type == INT || selectedOption.type == FLOAT) {
						if (pressedLeft && selectedOption.getValue() > selectedOption.minValue || !pressedLeft && selectedOption.getValue() < selectedOption.maxValue) {
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if (holdTime <= 0.5) {
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}
					}
					else if (holdTime <= 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				var add:Dynamic = null;
				if (TouchUtil.justPressed) {
					if (selectedOption.type != STRING) {
						add = pressedLeft ? -selectedOption.changeValue : selectedOption.changeValue;
					}
					if (selectedOption.type == INT || selectedOption.type == FLOAT) {
						holdValue = FlxMath.bound(selectedOption.getValue() + add, selectedOption.minValue, selectedOption.maxValue);
					}
				}
				switch(selectedOption.type) {
					case BOOL if (TouchUtil.justPressed):
						selectedOption.setValue((selectedOption.getValue() == true) ? false : true);
						selectedOption.change();
						updateTextFrom(selectedOption);
					default:
						if (TouchUtil.justPressed) {
							switch(selectedOption.type) {
								case INT, FLOAT:		
									if (selectedOption.type == INT) {
										holdValue = Math.round(holdValue);
										selectedOption.setValue(holdValue);
									}
									else {
										holdValue = FlxMath.roundDecimal(Math.round(holdValue / selectedOption.changeValue) * selectedOption.changeValue, selectedOption.decimals);
										selectedOption.setValue(holdValue);
									}
		
								case STRING:
									var num:Int = selectedOption.curOption;
									num = FlxMath.wrap(num + (pressedLeft ? -1 : 1), 0, selectedOption.options.length - 1);
									selectedOption.curOption = num;
									selectedOption.setValue(selectedOption.options[num]);

									if (selectedOption.variable == 'scrolltype') {
										var oOption:Option = getOptionByVariable('scrollspeed');
										if (oOption != null) {
											if (selectedOption.getValue() == 'constant') {
												oOption.displayFormat = '%v';
												oOption.maxValue = 6;
											}
											else {
												oOption.displayFormat = '%vx';
												oOption.maxValue = 3;
												if (oOption.getValue() > 3) oOption.setValue(3);
											}
											updateTextFrom(oOption);
										}
									}

								default:
							}
							updateTextFrom(selectedOption);
							selectedOption.change();
						}
						else if (holdTime > 0.5 && selectedOption.type != STRING) {
							holdValue = FlxMath.bound(holdValue + selectedOption.scrollSpeed * elapsed * (pressedLeft ? -1 : 1), selectedOption.minValue, selectedOption.maxValue);
		
							switch(selectedOption.type) {
								case INT:
									selectedOption.setValue(Math.round(holdValue));
								case FLOAT:
									selectedOption.setValue(FlxMath.roundDecimal(holdValue, selectedOption.decimals));
								default:
							}
							updateTextFrom(selectedOption);
							selectedOption.change();
						}
						hoveringArrow = true;

						if (selectedOption.type != STRING) {
							holdTime += elapsed;
						}
				}
			}
			else if (holdingArrow == num && (!TouchUtil.overlaps(arrow, camOptions, FlxPoint.get(-12, 4)) || TouchUtil.released)) {
				holdTime = 0;
				holdValue = 0;
				hoveringArrow = false;
				holdingArrow = -1;
			}
		}

		for (bar in barArray) {
			if (bar == null) continue;
			var realBar:FlxBar = cast bar[0];
			var selectedOption:Option = optionsArray[realBar.ID];
			if (selectedOption.disallowed) continue;
			if (TouchUtil.justPressed && TouchUtil.overlaps(realBar, camOptions) || TouchUtil.pressed && holdingBar == realBar.ID) {
				holdingBar = realBar.ID;
				var touchX = TouchUtil.input.getScreenPosition(camOptions).x;
				var value = FlxMath.bound((touchX - realBar.x) / realBar.width, selectedOption.minValue, selectedOption.maxValue);
				if (value != selectedOption.getValue()) {
					selectedOption.setValue(value);
					selectedOption.change();
					updateTextFrom(selectedOption);
				}
				hoveringBar = true;
			}
			if (TouchUtil.justReleased && hoveringBar) hoveringBar = false;
			@:privateAccess
			bar[1].x = realBar.x + realBar._filledBarRect.width - 5;
			bar[1].x = FlxMath.bound(bar[1].x, realBar.x - 5, realBar.x + realBar.width - 5);
		}
		if (!hoveringBar && holdingBar != -1) {
			holdingBar = -1;
		}

		for (num => info in grpInfos) {
			if (info is FlxText) continue;
			var descBG:FlxSprite = grpDesc.members[num];
			var descTxt:FlxText = cast grpDesc.members[num + 1];
			if (descBG == null || descTxt == null) continue;
			if (descBG.y + descBG.height > camOptions.scroll.y + camOptions.height && descBG.y != info.y - descBG.height - 20) {
				descBG.y = info.y - descBG.height - 20;
				descTxt.y = descBG.y + 10;
			}
			else if (descBG.y < camOptions.scroll.y && descBG.y != info.y + 50) {
				descBG.y = info.y + 50;
				descTxt.y = descBG.y + 10;
			}
			if (!swiping #if mobile && TouchUtil.justReleased #end && TouchUtil.overlaps(info, camOptions) && !descBG.visible) {
				holdingDesc = num;
				descBG.visible = descTxt.visible = true;
			}
			#if !mobile
			if (!TouchUtil.overlaps(info, camOptions) && holdingDesc == num) {
				holdingDesc = -1;
				descBG.visible = descTxt.visible = false;
			}
			#else
			if (TouchUtil.justPressed && !TouchUtil.overlaps(info, camOptions) && holdingDesc == num) {
				holdingDesc = -1;
				descBG.visible = descTxt.visible = false;
			}
			#end
		}

		for (reset in grpReset) {
			if (reset is FlxText) continue;
			var selectedOption:Option = optionsArray[reset.ID];
			if (!swiping && TouchUtil.justReleased && TouchUtil.overlaps(reset, camOptions)) {
				resetOption(selectedOption);
			}
		}

		for (setting in grpSettings) {
			var selectedOption:Option = optionsArray[setting.ID];
			if (!swiping && TouchUtil.justReleased && TouchUtil.overlaps(setting, camOptions)) {
				openSubState(Type.createInstance(selectedOption.customizationClass, []));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		for (edit in grpEdits) {
			if (edit is FlxText) continue;
			var selectedOption:Option = optionsArray[edit.ID];
			if (selectedOption.disallowed) continue;
			switch(selectedOption.type) {
				case SUBSTATE(cl) if (!swiping && TouchUtil.justReleased && TouchUtil.overlaps(edit, camOptions)):
					openSubState(Type.createInstance(cl, []));
					FlxG.sound.play(Paths.sound('scrollMenu'));
				default:
			}
		}

		for (num => locked in grpLocked) {
			if (locked is FlxText) continue;
			var descBG:FlxSprite = grpLockedDesc.members[num];
			var descTxt:FlxText = cast grpLockedDesc.members[num + 1];
			if (descBG == null || descTxt == null) continue;
			if (descBG.y + descBG.height > camOptions.scroll.y + camOptions.height && descBG.y != locked.y - descBG.height - 20) {
				descBG.y = locked.y - descBG.height - 20;
				descTxt.y = descBG.y + 10;
			}
			else if (descBG.y < camOptions.scroll.y && descBG.y != locked.y + 70) {
				descBG.y = locked.y + 70;
				descTxt.y = descBG.y + 10;
			}
			if (!swiping #if mobile && TouchUtil.justReleased #end && TouchUtil.overlaps(locked, camOptions) && !descBG.visible) {
				holdingLockedDesc = num;
				descBG.visible = descTxt.visible = true;
			}
			#if !mobile
			if (!TouchUtil.overlaps(locked, camOptions) && holdingLockedDesc == num) {
				holdingLockedDesc = -1;
				descBG.visible = descTxt.visible = false;
			}
			#else
			if (TouchUtil.justPressed && !TouchUtil.overlaps(locked, camOptions) && holdingLockedDesc == num) {
				holdingLockedDesc = -1;
				descBG.visible = descTxt.visible = false;
			}
			#end
		}

		if (allowScrolling && TouchUtil.justReleased && holdingBox) {
			holdingBox = false;
			swiping = false;
			#if mobile prevMouseY = FlxMath.bound(camOptions.scroll.y, 0, grpBackgrounds.height - camOptions.height + 50); #end
		}

		if (controls.BACK || backButton.justPressed #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('persona/ui_close'));
			FlxTween.tween(camOptions, { height: 10 }, 0.15, { onComplete: (_)->{
				updateCam(_);
				camOptions.visible = false;
				close();
			}, onUpdate: updateCam });
		}
	}

	override function closeSubState() {
		FlxG.inputs.reset();
		super.closeSubState();
	}

	public function getOptionByName(name:String) {
		for (i in optionsArray) {
			var opt:Option = i;
			if (opt.name == name)
				return opt;
		}
		return null;
	}

	public function getOptionByVariable(variable:String) {
		for (i in optionsArray) {
			var opt:Option = i;
			if (opt.variable == variable)
				return opt;
		}
		return null;
	}

	function updateTextFrom(option:Option) {
		switch(option.type) {
			case SUBSTATE(cl):
			case KEYBIND:
			case BOOL:
				option.text = option.getValue() == true ? 'ON' : 'OFF';
				option.child.x = (grpArrows.members[option.child.ID].x + grpArrows.members[option.child.ID + 1].x - option.child.textField.textWidth) / 2 + 15;
			default:
				var text:String = option.displayFormat;
				var val:Dynamic = option.getValue();
				if (option.type == PERCENT) val = Math.floor(val * 100);
				var def:Dynamic = option.defaultValue;
				option.text = text.replace('%v', val).replace('%d', def);
				if (option.type == PERCENT) {
					cast(barArray[option.child.ID][0], FlxBar).percent = val;
					option.child.x = barArray[option.child.ID][0].getMidpoint().x - option.child.textField.textWidth / 2;
				}
				else {
					if (grpArrows.members[option.child.ID] == null || grpArrows.members[option.child.ID + 1] == null) return; // ?????????????
					option.child.x = (grpArrows.members[option.child.ID].x + grpArrows.members[option.child.ID + 1].x - option.child.textField.textWidth) / 2 + 15;
					if (option.type == STRING) {
						if (option.child.textField.textWidth >= 200) {
							option.child.scale.x = option.child.scale.y = 200 / option.child.textField.textWidth;
							option.child.origin.y = option.child.textField.textHeight / 2;
						}
						for (i => arr in lineArray) {
							if (arr == null) continue;
							if (i == option.child.ID) {
								for (k => line in arr) {
									line.color = k == option.curOption ? 0xFFFFFF00 : 0xFF676767;
								}
							}
						}
					}
				}
		}
	}

	function resetOption(option:Option) {
		option.setValue(option.defaultValue);
		if (option.type == STRING) option.curOption = option.options.indexOf(option.getValue());
		if (option.variable == 'scrolltype') {
			var oOption:Option = getOptionByVariable('scrollspeed');
			if (oOption != null) {
				if (option.getValue() == 'constant') {
					oOption.displayFormat = '%v';
					oOption.maxValue = 6;
				}
				else {
					oOption.displayFormat = '%vx';
					oOption.maxValue = 3;
					if (oOption.getValue() > 3) oOption.setValue(3);
				}
				oOption.change();
				updateTextFrom(oOption);
			}
		}
		option.change();
		updateTextFrom(option);
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}
	
	function changeSelection(option:Int = 0, playSound:Bool = true, moveCamera:Bool = false) {
		if (option < 0 || option > optionsArray.length - 1) return;
		// can't use null-safe field access?
		if (grpBackgrounds.members[curSelected] != null) grpBackgrounds.members[curSelected].alpha = 0.3;
		curSelected = option;
		curOption = optionsArray[curSelected];
		if (grpBackgrounds.members[curSelected] != null) {
			grpBackgrounds.members[curSelected].alpha = 0.6;
			if (moveCamera) {
				if (grpBackgrounds.members[curSelected].y + grpBackgrounds.members[curSelected].height > camOptions.scroll.y + camOptions.height) {
					camOptions.scroll.y = grpBackgrounds.members[curSelected].y + grpBackgrounds.members[curSelected].height - camOptions.height + 20;
				}
				else if (grpBackgrounds.members[curSelected].y < camOptions.scroll.y) {
					camOptions.scroll.y = grpBackgrounds.members[curSelected].y - 20;
				}
				#if mobile prevMouseY = FlxMath.bound(camOptions.scroll.y, 0, grpBackgrounds.height - camOptions.height + 50); #end
			}
		}
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
		updateKeyIcons();
	}

	function updateKeyIcons() {
		var removeOffset:Float = 0;
		for (num => icon in keyIcons.group.keyValueIterator()) {
			if (num < 2) continue; // Ignore Select and Back
			if (num == 2) { // Confirm
				switch(curOption.type) {
					case KEYBIND:
						icon.visible = true;
					case SUBSTATE(cl):
						icon.visible = true;
					default:
						if (!curOption.disallowed) {
							icon.visible = false;
							removeOffset = icon.width + 15;
						}
						else icon.visible = true;
				}
			}
			else {
				if (num == 5) { // Customize Option
					icon.visible = curOption.customizable;
				}
				icon.x = Std.int(keyIcons.members[num - 1].x + keyIcons.members[num - 1].width + 15);
				if (num == 3) icon.x -= removeOffset;
			}
		}
	}

	function checkDisallowedSong(option:Option, song:String):Bool {
		if (option == null) return false;
		if (!storyMode) {
			if (option.disallowedSongs?.contains(song)) return true;
		}
		else {
			// i don't know if we would want this implementation of checking the song instead of the week for story mode
			// but we aren't using the story mode for the demo so...
			// oh well, it's a problem for future melodie
			var week:WeekData = WeekData.weeksLoaded.get(song);
			if (week == null) return false;
			for (weekSong in week.songs) {
				if (option.disallowedSongs?.contains(weekSong[0])) return true;
			}
		}
		return false;
	}

	function getDisallowedString(option:Option):String {
		if (option == null) return '';
		var str:String = '';
		if (option.disallowStoryMode && option.disallowFreeplay)
			// only for debug, this shouldn't actually happen
			str = 'Story Mode and Freeplay.';
		else if (option.disallowStoryMode && storyMode)
			str = Language.getPhrase('Story Mode');
		else if (option.disallowFreeplay && !storyMode)
			str = Language.getPhrase('Freeplay');
		else if (songOrWeek != null && songOrWeek.length > 0)
			str = (storyMode ? WeekData.weeksLoaded.get(songOrWeek).weekName : songOrWeek);
		else
			str = 'Missing song or week. This should not happen.';

		return Language.getPhrase('setting_locked', 'This option cannot be changed on {1}.', [str]) + '\n\n' + Language.getPhrase('setting_locked_default', '{1} will be defaulted to {2}.', [option.name, option.defaultValue]);
	}
}