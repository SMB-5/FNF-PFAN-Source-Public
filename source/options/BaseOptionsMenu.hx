package options;

import flixel.math.FlxRect;
import flixel.ui.FlxBar;
import flixel.addons.display.shapes.FlxShapeCircle;
import backend.WeekData;
import options.Option;

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var x:Null<Float> = null;
	private var y:Null<Float> = null;
	private var width:Null<Int> = null;
	private var height:Null<Int> = null;
	private var offset:FlxRect = FlxRect.get(FlxMath.MIN_VALUE_INT, FlxMath.MIN_VALUE_INT, FlxMath.MIN_VALUE_INT, FlxMath.MIN_VALUE_INT);

	private var camBG:FlxCamera;
	private var camOptions:FlxCamera;
	private var camUI:FlxCamera;

	private var keyIcons:FlxTypedGroup<KeyIcon>;

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
	private var grpButtons:FlxTypedGroup<FlxSprite>;
	private var grpPreview:FlxTypedGroup<FlxSprite>;
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

		camBG = new FlxCamera();
		camBG.bgColor.alpha = 0;
		FlxG.cameras.add(camBG, false);

		if (offset.x == FlxMath.MIN_VALUE_INT) {
			offset.x = -80;
		}
		if (offset.y == FlxMath.MIN_VALUE_INT) {
			offset.y = #if !mobile -20 #else 0 #end;
		}
		if (offset.width == FlxMath.MIN_VALUE_INT) {
			offset.width = -200;
		}
		if (offset.height == FlxMath.MIN_VALUE_INT) {
			offset.height = #if !mobile -90 #else -70 #end;
		}

		if (width == null) width = FlxG.width;
		if (height == null) height = FlxG.height;
		camOptions = new FlxCamera(0, 0, Std.int(width + offset.width), Std.int(height + offset.height));
		camOptions.bgColor.alpha = 0;
		if (x == null) x = (FlxG.width - camOptions.width) / 2;
		if (y == null) y = (FlxG.height - camOptions.height) / 2;
		camOptions.x = x + offset.x;
		camOptions.y = y + offset.y;
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

		grpButtons = new FlxTypedGroup<FlxSprite>();
		add(grpButtons);

		grpPreview = new FlxTypedGroup<FlxSprite>();
		add(grpPreview);

		grpLocked = new FlxTypedGroup<FlxSprite>();
		add(grpLocked);

		grpLockedDesc = new FlxTypedGroup<FlxSprite>();
		add(grpLockedDesc);

		grpDesc = new FlxTypedGroup<FlxSprite>();
		add(grpDesc);

		keyIcons = new FlxTypedGroup<KeyIcon>();
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

			var info:FlxShapeCircle = new FlxShapeCircle(30, 0, 17, {thickness: 5, color: 0xAF000000}, FlxColor.GRAY);
			info.y = optionBG.getMidpoint().y - info.height / 2;
			info.ID = i;
			grpInfos.add(info);

			var infoTxt:FlxText = new FlxText(info.x + 12, 0, 0, 'i', 28);
			infoTxt.font = Paths.font('Fontsona3FES.ttf');
			infoTxt.y = info.getMidpoint().y - infoTxt.height / 2;
			infoTxt.color = 0xFF000000;
			infoTxt.alpha = 0.6;
			grpInfos.add(infoTxt);

			var option:FlxText = new FlxText(optionBG.x + 55, 0, 0, Language.getPhrase('setting_' + optionsArray[i].name, optionsArray[i].name), 32);
			option.font = Paths.font('Fontsona3FES.ttf');
			option.ID = i;
			if (option.width > 500) {
				option.scale.x = option.scale.y = 500 / option.width;
				option.updateHitbox();
			}
			option.y = optionBG.getMidpoint().y - option.height / 2;
			grpOptions.add(option);

			var offset:Float = 0;

			var reset:FlxSprite = new FlxSprite(option.x + option.width + 10, 0, Paths.image('resetButton'));
			reset.setGraphicSize(40, 40);
			reset.updateHitbox();
			reset.y = option.getMidpoint().y - reset.height / 2;
			reset.color = FlxColor.GRAY;
			reset.ID = i;
			grpReset.add(reset);
			offset = reset.x + reset.width + 10;

			if (optionsArray[i].customizable) {
				var setting:FlxSprite = new FlxSprite(reset.x + reset.width + 7, 0, Paths.image('settingButton'));
				setting.scale.set(0.8, 0.8);
				setting.updateHitbox();
				setting.y = option.getMidpoint().y - setting.height / 2;
				setting.alpha = 0.8;
				setting.color = FlxColor.GRAY;
				setting.ID = i;
				grpSettings.add(setting);
				offset = setting.x + setting.width + 10;
			}

			if (optionsArray[i].onPreview != null) {
				var preview:FlxSprite = new FlxSprite(offset, 0, Paths.image('previewButton'));
				preview.setGraphicSize(50, 50);
				preview.updateHitbox();
				preview.y = option.getMidpoint().y - preview.height / 2;
				preview.color = FlxColor.GRAY;
				preview.ID = i;
				grpPreview.add(preview);
			}

			switch(optionsArray[i].type) {
				case STRING, INT, FLOAT, BOOL, PERCENT:
					var leftArrow:FlxText = new FlxText(optionBG.x + optionBG.width - 325, optionBG.y + 5, 40, '<', 40);
					leftArrow.font = Paths.font('Fontsona3FES.ttf');
					leftArrow.ID = i;
					grpArrows.add(leftArrow);

					var rightArrow:FlxText = new FlxText(optionBG.x + optionBG.width - 50, optionBG.y + 5, 40, '>', 40);
					rightArrow.font = Paths.font('Fontsona3FES.ttf');
					rightArrow.ID = i;
					grpArrows.add(rightArrow);

					var curValue:String = optionsArray[i].type != BOOL ? Std.string(optionsArray[i].getValue()) : optionsArray[i].getValue() == true ? 'ON' : 'OFF';
					var curOption:FlxText = new FlxText(0, 0, 0, curValue, 28);
					curOption.font = Paths.font('Fontsona3FES.ttf');
					if (curOption.width > 200) {
						curOption.scale.x = curOption.scale.y = 200 / curOption.width;
						curOption.updateHitbox();
					}
					curOption.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - curOption.width) / 2;
					curOption.y = optionBG.getMidpoint().y - curOption.textField.textHeight / 2;
					curOption.ID = i;
					grpValues.add(curOption);
					optionsArray[i].child = curOption;

					if (optionsArray[i].type == STRING) {
						lineArray[i] = [];
						var offsetX:Float = 0;
						for (k in 0...optionsArray[i].options.length) {
							var line:FlxSprite = new FlxSprite(0, curOption.y + 40).makeGraphic(20, 5, 0xFFFFFFFF);
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
					else if (optionsArray[i].type == PERCENT) {
						barArray[i] = [];
						curOption.y -= 7;

						var bar:FlxBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 170, 10, null, '', optionsArray[i].minValue, optionsArray[i].maxValue * 100);
						bar.createFilledBar(0xFF000000, 0xFFFFFFFF);
						bar.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - bar.width) / 2;
						bar.y = optionBG.getMidpoint().y - bar.height / 2 + 20;
						bar.drawRect(0, 0, bar.width, bar.height, 0, {thickness: 1, color: 0xFFFFFFFF});
						bar.percent = optionsArray[i].getValue() * 100;
						bar.ID = i;
						add(bar);
						barArray[i].push(bar);

						var barCircle:FlxShapeCircle = new FlxShapeCircle(bar.x - 5, bar.y - 2, 7, {thickness: 1}, 0xFFFFFFFF);
						barCircle.ID = i;
						add(barCircle);
						barArray[i].push(barCircle);
					}
				case BUTTON:
					var buttonBG:FlxSprite = new FlxSprite(optionBG.x + optionBG.width - 255, optionBG.y + 13).makeGraphic(175, 40, 0xFFFFFFFF);
					buttonBG.drawRect(0, 0, buttonBG.width, buttonBG.height, 0, {thickness: 5, color: 0xFF000000});
					buttonBG.ID = i;
					grpButtons.add(buttonBG);

					var buttonTxt:FlxText = new FlxText(0, buttonBG.y + 3, 0, Language.getPhrase(optionsArray[i].buttonText), 28);
					buttonTxt.font = Paths.font('Fontsona5Royal.ttf');
					if (buttonTxt.width > 150) {
						buttonTxt.scale.x = buttonTxt.scale.y = 150 / buttonTxt.width;
						buttonTxt.updateHitbox();
					}
					buttonTxt.x = buttonBG.getMidpoint().x - buttonTxt.width / 2;
					buttonTxt.color = 0xFF000000;
					grpButtons.add(buttonTxt);
				case _:
			}

			if (optionsArray[i].disallowed) {
				var lockedBG:FlxSprite = new FlxSprite(optionBG.x + 710, optionBG.y).makeGraphic(Std.int(optionBG.width - 710), Std.int(optionBG.height), 0xFF000000);
				lockedBG.ID = i;
				grpLocked.add(lockedBG);

				var locked:FlxText = new FlxText(0, 0, 0, Language.getPhrase('Locked').toUpperCase(), 36);
				locked.font = Paths.font('Fontsona3FES.ttf');
				if (locked.width > 300) {
					locked.scale.x = locked.scale.y = 300 / locked.width;
					locked.updateHitbox();
				}
				locked.x = lockedBG.getMidpoint().x - locked.width / 2;
				locked.y = lockedBG.getMidpoint().y - locked.height / 2;
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
		// The X positions are updated in the updateKeyIcons function, these won't affect the X position
		// This reminder is for me. Thanks past me!
		var movementIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, 'dpad', 1, 'ui_select', 0.1, 24);
		keyIcons.add(movementIcon);

		var backIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, 'back', 0, 'ui_back', 0.1, 24);
		keyIcons.add(backIcon);

		var acceptIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, 'accept', 0, 'ui_confirm', 0.1, 24);
		keyIcons.add(acceptIcon);

		var infoIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, controls.controllerMode ? 'X' : 'F1', 0, 'ui_view_description', 0.1, 24);
		keyIcons.add(infoIcon);

		var resetIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, 'reset', 0, 'ui_reset', 0.1, 24);
		keyIcons.add(resetIcon);

		var customizableIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, controls.controllerMode ? 'START' : 'TAB', 0, 'ui_customize_option', 0.1, 24);
		keyIcons.add(customizableIcon);

		var previewIcon:KeyIcon = new KeyIcon(0, FlxG.height - 24, controls.controllerMode ? 'Y' : 'P', 0, 'ui_preview', 0.1, 24);
		keyIcons.add(previewIcon);
		#end

		backButton = new BackButton();
		backButton.x += 50;
		backButton.camera = camUI;
		add(backButton);

		FlxTween.tween(camOptions, { height: height + offset.height }, 0.15, { startDelay: 0.25, onComplete: _->{
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
		camOptions.y = (FlxG.height - camOptions.height) / 2 + offset.y;
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
	override function tryUpdate(elapsed:Float) {
		optionHeader.y -= 140 * elapsed;
		optionHeader2.y -= 140 * elapsed;
		if (optionHeader.y <= -optionHeader.height) optionHeader.y = optionHeader.height + 400;
		if (optionHeader2.y <= -optionHeader2.height) optionHeader2.y = optionHeader.height + 400;
		super.tryUpdate(elapsed);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!enableInputs) return;

		scrollTimer += elapsed;

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
				case KEYBIND, BUTTON: go = false;
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
								case FLOAT:
									curOption.setValue(FlxMath.roundDecimal(Math.round(holdValueKey / curOption.changeValue) * curOption.changeValue, curOption.decimals));
								case PERCENT:
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
			customizeOption(curOption);
		}

		if ((FlxG.keys.justPressed.P || FlxG.gamepads.anyJustPressed(Y)) && curOption.onPreview != null) {
			previewOption(curOption);
		}

		if (controls.ACCEPT) {
			if (!curOption.disallowed) {
				switch(curOption.type) {
					case BUTTON:
						openOption(curOption);
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
					if (selectedOption.type == INT || selectedOption.type == FLOAT || selectedOption.type == PERCENT) {
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
					if (selectedOption.type == INT || selectedOption.type == FLOAT || selectedOption.type == PERCENT) {
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
								case INT, FLOAT, PERCENT:
									if (selectedOption.type == INT) {
										holdValue = Math.round(holdValue);
									}
									else if (selectedOption.type == FLOAT) {
										holdValue = FlxMath.roundDecimal(Math.round(holdValue / selectedOption.changeValue) * selectedOption.changeValue, selectedOption.decimals);
									}
									else {
										holdValueKey = FlxMath.roundDecimal(holdValueKey, selectedOption.decimals);
									}
									selectedOption.setValue(holdValue);
		
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
									selectedOption.setValue(FlxMath.roundDecimal(Math.round(holdValue / selectedOption.changeValue) * selectedOption.changeValue, selectedOption.decimals));
								case PERCENT:
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
				customizeOption(selectedOption);
			}
		}

		for (button in grpButtons) {
			if (button is FlxText) continue;
			var selectedOption:Option = optionsArray[button.ID];
			if (selectedOption.disallowed) continue;
			switch(selectedOption.type) {
				case BUTTON if (!swiping && TouchUtil.justReleased && TouchUtil.overlaps(button, camOptions)):
					openOption(selectedOption);
				default:
			}
		}

		for (preview in grpPreview) {
			if (preview is FlxText) continue;
			var selectedOption:Option = optionsArray[preview.ID];
			if (!swiping && TouchUtil.justReleased && TouchUtil.overlaps(preview, camOptions)) {
				previewOption(selectedOption);
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

	override function destroy() {
		FlxG.cameras.remove(camBG);
		FlxG.cameras.remove(camOptions);
		FlxG.cameras.remove(camUI);
		super.destroy();
	}

	override function openSubState(sub:flixel.FlxSubState) {
		keyIcons.visible = backButton.visible = false;
		super.openSubState(sub);
	}

	override function closeSubState() {
		keyIcons.visible = backButton.visible = true;
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
			case KEYBIND, BUTTON:
			case BOOL:
				var leftArrow:FlxSprite = grpArrows.members[option.child.ID];
				var rightArrow:FlxSprite = grpArrows.members[option.child.ID + 1];
				option.text = option.getValue() == true ? 'ON' : 'OFF';
				option.child.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - option.child.width) / 2;
			default:
				var text:String = option.displayFormat;
				var val:Dynamic = option.getValue();
				if (option.type == PERCENT) val = Math.floor(val * 100);
				var def:Dynamic = option.defaultValue;
				option.child.scale.set(1, 1);
				option.child.updateHitbox();
				option.text = text.replace('%v', val).replace('%d', def);

				if (option.type == PERCENT) {
					cast(barArray[option.child.ID][0], FlxBar).percent = val;
				}
				if (grpArrows.members[option.child.ID] == null || grpArrows.members[option.child.ID + 1] == null) return; // ?????????????

				var leftArrow:FlxSprite = grpArrows.members[option.child.ID];
				var rightArrow:FlxSprite = grpArrows.members[option.child.ID + 1];
				option.child.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - option.child.width) / 2;

				if (option.type == STRING) {
					if (option.child.width > 200) {
						option.child.scale.x = option.child.scale.y = 200 / option.child.width;
						option.child.updateHitbox();
					}
					option.child.x = leftArrow.x + leftArrow.width + (rightArrow.x - rightArrow.width - leftArrow.x - option.child.width) / 2;
					option.child.y = grpBackgrounds.members[option.child.ID].getMidpoint().y - option.child.height / 2;
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

	function customizeOption(option:Option) {
		openSubState(Type.createInstance(option.customizationClass, []));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function openOption(option:Option) {
		option.open();
		FlxG.sound.play(Paths.sound('scrollMenu'));
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

	function previewOption(option:Option) {
		option.preview();
		if (option.playPreviewSound) FlxG.sound.play(Paths.sound('scrollMenu'));
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
		var offset:Float = 20;
		for (num => icon in keyIcons) {
			switch(num) {
				case 2: // Confirm
					switch(curOption.type) {
						case KEYBIND:
							icon.visible = true;
						case BUTTON:
							icon.visible = true;
						default:
							icon.visible = curOption.disallowed;
					}
				case 5: // Customize Option
					icon.visible = curOption.customizable;
				case 6: // Preview
					icon.visible = curOption.onPreview != null;
			}
			if (icon.visible) {
				icon.x = offset;
				offset = icon.x + icon.width + 10;
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