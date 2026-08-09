package substates;

class PersonaPrompt extends MusicBeatSubstate
{
	var camUI:FlxCamera;

	var prompt:String;
	var translationValues:Array<Dynamic>;
	var promptBG:FlxSprite;
	var promptTxt:FlxText;
	var yesButton:FlxSprite;
	var yesTxt:FlxText;
	var noButton:FlxSprite;
	var noTxt:FlxText;
	var yesFunc:Void->Void;
	var noFunc:Void->Void;
	var yesTimer:Float = 0;
	var noTimer:Float = 0;
	var canPressYes:Bool = true;
	var canPressNo:Bool = true;
	var yesBorder:FlxSprite;
	var noBorder:FlxSprite;
	var yesTimerTxt:FlxText;
	var noTimerTxt:FlxText;
	var textOffset:Float = -30;

	var selector:FlxSprite;
	var curSelected:Int = 0;
	var curButton:FlxSprite;

	public function new(prompt:String, yesFunc:Void->Void = null, noFunc:Void->Void = null, yesTimer:Null<Float> = null, noTimer:Null<Float> = null, translationValues:Array<Dynamic> = null) {
		super();
		this.prompt = prompt;
		this.translationValues = translationValues;
		this.yesFunc = yesFunc;
		this.noFunc = noFunc;
		if (yesTimer != null) {
			this.canPressYes = false;
			this.yesTimer = yesTimer;
		}
		if (noTimer != null) {
			this.canPressNo = false;
			this.noTimer = noTimer;
		}
	}

	override function create() {
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		cameras = [camUI];

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.3;
		add(bg);

		promptTxt = new FlxText(0, 0, FlxG.width - 150, Language.getPhrase(prompt, 'No Prompt Found', translationValues), 24);
		@:privateAccess
		promptTxt._defaultFormat.leading = 6;
		promptTxt.font = Paths.font('Fontsona3FES.ttf');
		promptTxt.screenCenter();
		promptTxt.x = (FlxG.width - promptTxt.textField.textWidth) / 2;
		promptTxt.y += textOffset;
		add(promptTxt);

		promptBG = new FlxSprite().makeGraphic(Std.int(Math.max(400, promptTxt.textField.textWidth + 100)), Std.int(Math.max(128, promptTxt.height + 100)), 0xFF454545);
		promptBG.setPosition(promptTxt.x - (promptBG.width - promptTxt.textField.textWidth) / 2, promptTxt.y - textOffset / 1.5 - (promptBG.height - promptTxt.height) / 2);
		promptBG.drawRect(0, 0, promptBG.width, promptBG.height, 0, {thickness: 5, color: 0xFFFFFFFF});
		insert(members.indexOf(promptTxt), promptBG);

		yesButton = new FlxSprite().makeGraphic(100, 35, 0xFF333333);
		yesButton.setPosition(promptBG.getMidpoint().x - yesButton.width / 2 - 100, promptBG.y + promptBG.height - yesButton.height - 20);
		yesButton.drawRect(0, 0, yesButton.width, yesButton.height, 0, {thickness: 5, color: 0xFFFFFFFF});
		insert(members.indexOf(promptTxt), yesButton);

		noButton = new FlxSprite().makeGraphic(100, 35, 0xFF333333);
		noButton.setPosition(promptBG.getMidpoint().x - noButton.width / 2 + 100, promptBG.y + promptBG.height - noButton.height - 20);
		noButton.drawRect(0, 0, noButton.width, noButton.height, 0, {thickness: 5, color: 0xFFFFFFFF});
		insert(members.indexOf(promptTxt), noButton);

		yesTxt = new FlxText(0, 0, 0, Language.getPhrase('Yes'), 18);
		yesTxt.font = Paths.font('Fontsona3FES.ttf');
		yesTxt.setPosition(yesButton.getMidpoint().x - yesTxt.width / 2, yesButton.getMidpoint().y - yesTxt.height / 2);
		insert(members.indexOf(yesButton) + 1, yesTxt);

		noTxt = new FlxText(0, 0, 0, Language.getPhrase('No'), 18);
		noTxt.font = Paths.font('Fontsona3FES.ttf');
		noTxt.setPosition(noButton.getMidpoint().x - noTxt.width / 2, noButton.getMidpoint().y - noTxt.height / 2);
		insert(members.indexOf(noButton) + 1, noTxt);

		if (!canPressYes) {
			yesBorder = new FlxSprite(yesButton.x + 2.5, noButton.y + 2.5).makeGraphic(Std.int(yesButton.width - 5), Std.int(yesButton.height - 5), 0xFF000000);
			insert(members.indexOf(yesTxt) + 1, yesBorder);

			yesTimerTxt = new FlxText(0, 0, 0, Std.string(yesTimer), 18);
			yesTimerTxt.font = Paths.font('Fontsona3FES.ttf');
			yesTimerTxt.setPosition(yesButton.getMidpoint().x - yesTimerTxt.width / 2, yesButton.getMidpoint().y - yesTimerTxt.height / 2);
			insert(members.indexOf(yesBorder) + 1, yesTimerTxt);
		}

		if (!canPressNo) {
			noBorder = new FlxSprite(noButton.x + 2.5, noButton.y + 2.5).makeGraphic(Std.int(noButton.width - 5), Std.int(noButton.height - 5), 0xFF000000);
			insert(members.indexOf(noTxt) + 1, noBorder);

			noTimerTxt = new FlxText(0, 0, 0, Std.string(noTimer), 18);
			noTimerTxt.font = Paths.font('Fontsona3FES.ttf');
			noTimerTxt.setPosition(noButton.getMidpoint().x - noTimerTxt.width / 2, noButton.getMidpoint().y - noTimerTxt.height / 2);
			insert(members.indexOf(noBorder) + 1, noTimerTxt);
		}

		selector = new FlxSprite().makeGraphic(110, 45, 0);
		selector.drawRect(0, 0, selector.width, selector.height, 0, {thickness: 5, color: 0xFFFFFF00});
		add(selector);

		#if !mobile
		var movementIcon:KeyIcon = new KeyIcon(12, FlxG.height - 44, 'dpad_left_right', 1, 'ui_select', 0.15, 24);
		add(movementIcon);

		var acceptIcon:KeyIcon = new KeyIcon(movementIcon.x + movementIcon.width + 10, FlxG.height - 44, 'accept', 0, 'ui_confirm', 0.15, 24);
		add(acceptIcon);

		var backIcon:KeyIcon = new KeyIcon(acceptIcon.x + acceptIcon.width + 10, FlxG.height - 44, 'back', 0, 'ui_close', 0.15, 24);
		add(backIcon);
		#end

		changeSelection(0);

		super.create();
	}

	override function update(elapsed:Float) {
		yesTimer = Math.max(yesTimer - elapsed, 0);
		noTimer = Math.max(noTimer - elapsed, 0);
		updateTimers();

		if (controls.BACK #if android || FlxG.android.justReleased.BACK #end) {
			pressNo();
		}

		if (TouchUtil.overlaps(yesButton, camUI) || TouchUtil.overlaps(noButton, camUI)) {
			var ID:Int = TouchUtil.overlaps(yesButton, camUI) ? 0 : 1;
			#if mobile if (TouchUtil.justPressed) #end
			{
				if (curSelected != ID) {
					changeSelection(ID);
				}
				else #if !mobile if (TouchUtil.justPressed) #end {
					if (canPressYes && curSelected == 0) {
						pressYes();
					}
					else if (canPressNo && curSelected == 1) {
						pressNo();
					}
				}
			}
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			changeSelection(curSelected + (controls.UI_LEFT_P ? -1 : 1));
		}
		if (controls.ACCEPT) {
			if (canPressYes && curSelected == 0) {
				pressYes();
			}
			else if (canPressNo && curSelected == 1) {
				pressNo();
			}
		}
		super.update(elapsed);
	}

	override function destroy() {
		FlxG.cameras.remove(camUI);
		super.destroy();
	}

	public function pressYes() {
		FlxG.sound.play(Paths.sound('scrollMenu'));
		if (yesFunc != null) yesFunc();
		close();
	}

	public function pressNo() {
		FlxG.sound.play(Paths.sound('cancelMenu'));
		if (noFunc != null) noFunc();
		close();
	}

	public function updateTimers() {
		if (yesTimer > 0) {
			if (yesTimerTxt != null) {
				yesTimerTxt.text = Std.string(FlxMath.roundDecimal(yesTimer, 1));
				yesTimerTxt.setPosition(yesButton.getMidpoint().x - yesTimerTxt.width / 2, yesButton.getMidpoint().y - yesTimerTxt.height / 2);
			}
		}
		else if (!canPressYes) {
			canPressYes = true;
			if (yesBorder != null) yesBorder.visible = yesTimerTxt.visible = false;
		}

		if (noTimer > 0) {
			if (noTimerTxt != null) {
				noTimerTxt.text = Std.string(FlxMath.roundDecimal(noTimer, 1));
				noTimerTxt.setPosition(noButton.getMidpoint().x - noTimerTxt.width / 2, noButton.getMidpoint().y - noTimerTxt.height / 2);
			}
		}
		else if (!canPressNo) {
			canPressNo = true;
			if (noBorder != null) noBorder.visible = noTimerTxt.visible = false;
		}
	}

	public function changeSelection(option:Int) {
		curSelected = FlxMath.wrap(option, 0, 1);
		curButton = curSelected == 0 ? yesButton : noButton;
		selector.setPosition(curButton.x - 5, curButton.y - 5);
	}
}