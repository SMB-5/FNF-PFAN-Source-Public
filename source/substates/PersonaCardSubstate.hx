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
	#if mobile
	var backButton:BackButton;
	#end

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
		promptText.setFormat("p5hatty-1.ttf", 48, FlxColor.WHITE, LEFT);
		promptText.alpha = 0;
		add(promptText);

		titleText = new FlxText(-200, 200, FlxG.width,"",32);
		titleText.setFormat("p5hatty-1.ttf", 32, FlxColor.BLACK, CENTER);
		titleText.alpha = 0;
		add(titleText);

		titleBG.y = titleText.y - 10;

		cardText = new FlxText(0, 270, cardBG.width - 50,"",32);
		cardText.setFormat("p5hatty-1.ttf", 32, FlxColor.WHITE, LEFT);
		cardText.alpha = 0;
		add(cardText);

		acceptIcon = new KeyIcon(20, cardBG.y + 440, 'accept', 1, 'ui_close');
		acceptIcon.alpha = 0;
		add(acceptIcon);

		#if mobile
		backButton = new BackButton();
		add(backButton);
		#end

		FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(cardBG, {x: 210, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(titleBG, {x: 260, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(promptText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(titleText, {x: 0, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(cardText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
		FlxTween.tween(acceptIcon, {x: 920, alpha: 1}, 0.3, {ease: FlxEase.expoOut});

		super.create();

		if (prompt == "WarningDemo")
		{
			promptText.text = Language.getPhrase("prompt_info");
			titleText.text = Language.getPhrase("demo_title");
			cardText.text = Language.getPhrase("demo_text");
		}
		else if (prompt == "LockedDemo")
		{
			promptText.text = Language.getPhrase("prompt_info");
			titleText.text = Language.getPhrase("demolock_title");
			cardText.text = Language.getPhrase("demolock_text");
		}
		else
		{
			promptText.text = Language.getPhrase("prompt_system");
			titleText.text = Language.getPhrase("error_title");
			cardText.text = "The Prompt you're looking for wasn't found.";
		}
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT #if android || FlxG.android.justReleased.BACK #end #if mobile || backButton.justPressed || TouchUtil.justReleased && !TouchUtil.overlaps(cardBG) #end)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(cardBG, {x: 410, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(titleBG, {x: 460, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(promptText, {x: 420, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(titleText, {x: 400, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
			FlxTween.tween(acceptIcon, {x: 1220, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
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