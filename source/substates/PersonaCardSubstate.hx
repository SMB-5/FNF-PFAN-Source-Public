package substates;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;

class PersonaCardSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var cardBG:FlxSprite;
	var titleBG:FlxSprite;
	var prompt:String;
	var promptText:FlxText;
	var titleText:FlxText;
	var cardText:FlxText;
	var acceptIcon:KeyIcon;
	var backButton:BackButton;

	public function new(prompt:String)
	{
		super();
		this.prompt = prompt;
	}

	override public function create():Void
	{
		FlxG.sound.play(Paths.sound('persona/deck_ui_toast'), 1.0);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		cardBG = new FlxSprite().makeGraphic(853, 480, FlxColor.GRAY);
		cardBG.screenCenter(Y);
		cardBG.alpha = 0;
		add(cardBG);

		titleBG = new FlxSprite().makeGraphic(750, 40, FlxColor.WHITE);
		titleBG.alpha = 0;
		add(titleBG);

		promptText = new FlxText(20, 130, FlxG.width,"",32);
		promptText.setFormat("barmeno-bold.ttf", 42, FlxColor.WHITE, LEFT);
		promptText.alpha = 0;
		add(promptText);

		titleText = new FlxText(-200, 195, FlxG.width,"",32);
		titleText.setFormat("barmeno-bold.ttf", 26, FlxColor.BLACK, CENTER);
		titleText.alpha = 0;
		add(titleText);

		titleBG.y = titleText.y - 5;

		cardText = new FlxText(0, 250, cardBG.width - 50,"",32);
		cardText.setFormat("Barmeno Regular.ttf", 26, FlxColor.WHITE, LEFT);
		cardText.alpha = 0;
		add(cardText);

		#if !mobile
		acceptIcon = new KeyIcon(20, cardBG.y + 440, 'accept', 0, 'ui_close');
		acceptIcon.iconText.font = Paths.font('barmeno-bold.ttf');
		acceptIcon.iconText.y -= 2.5;
		acceptIcon.alpha = 0;
		add(acceptIcon);
		#end

		backButton = new BackButton();
		backButton.alpha = 0;
		FlxTween.tween(backButton, {alpha: 0.7}, 0.3, {ease: FlxEase.quartInOut});
		add(backButton);

		FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(cardBG, {x: 210, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(titleBG, {x: 260, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(promptText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(titleText, {x: 0, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(cardText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		#if !mobile
		FlxTween.tween(acceptIcon, {x: 920, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		#end

		super.create();

		if (prompt == "WarningDemo")
		{
			promptText.text = Language.getPhrase("popup_info", "INFORMATION");
			titleText.text = Language.getPhrase("demo_title", "Before You Start The Demo");
			cardText.text = Language.getPhrase("demo_text", "This Mod is still in active development so a lot of things present might be changed, removed or unfinished.\n\nThis Demo serves as a tiny glimpse into what we want to do for the Mod and does not represent the Final Mod.\n\nPlease also note that this Mod contains Flashing Lights which can be disabled at Anytime in the Config Menu.");
		}
		else if (prompt == "LockedDemo")
		{
			promptText.text = Language.getPhrase("popup_info", "INFORMATION");
			titleText.text = Language.getPhrase("demolock_title", "Not Available in the Demo");
			cardText.text = Language.getPhrase("demolock_text", "This Menu will be Available in the First Release of the Full Mod.");
		}
		else
		{
			promptText.text = Language.getPhrase("popup_system", "SYSTEM");
			titleText.text = Language.getPhrase("error_title", "Error");
			cardText.text = "The Prompt you're looking for wasn't found.";
		}
	}

	var exiting:Bool = false;
	override function update(elapsed:Float)
	{
		if (!exiting && (controls.ACCEPT || backButton.initiallyPressed || TouchUtil.justReleased && !TouchUtil.overlaps(backButton) && !TouchUtil.overlaps(cardBG)) #if android || FlxG.android.justReleased.BACK #end)
		{
			exiting = true;
			FlxG.sound.play(Paths.sound('confirmMenu')); 
			FlxTween.tween(backButton, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(cardBG, {x: 410, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(titleBG, {x: 460, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(promptText, {x: 420, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(titleText, {x: 400, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			#if !mobile
			FlxTween.tween(acceptIcon, {x: 1220, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			#end
			FlxTween.tween(cardText, {x: 420, alpha: 0}, 0.3, {ease: FlxEase.expoOut,
			onComplete: function(twn:FlxTween)
			{
				close();
				return;
			}});
		}

		super.update(elapsed);
	}
}