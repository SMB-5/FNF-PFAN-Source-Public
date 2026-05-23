package substates;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;

class PersonaCardSubstate extends MusicBeatSubstate
{
    var bg:FlxSprite;
    var cardBG:FlxSprite;
    var titleBG:FlxSprite;
    var Prompt:String;
    var promptText:FlxText;
    var titleText:FlxText;
    var cardText:FlxText;

    public function new(Prompt:String)
    {
        super();
        this.Prompt = Prompt;
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
		add(cardBG);

        titleBG = new FlxSprite().makeGraphic(750, 40, FlxColor.WHITE);
		add(titleBG);

        //titleBG.screenCenter(X);

        titleBG.x = 0;
        titleBG.alpha = 0;

        //cardBG.screenCenter(X);
        cardBG.screenCenter(Y);

        cardBG.x = 0;
        cardBG.alpha = 0;

        promptText = new FlxText(20, 130, FlxG.width,"",32);
		promptText.setFormat("p5hatty-1.ttf", 48, FlxColor.WHITE, LEFT);
		add(promptText);

        promptText.alpha = 0;

        titleText = new FlxText(0, 200, FlxG.width,"",32);
		titleText.setFormat("p5hatty-1.ttf", 32, FlxColor.BLACK, CENTER);
		add(titleText);

        //titleText.screenCenter(X);

        titleText.x = -200;
        titleText.alpha = 0;

        titleBG.y = titleText.y - 10;

        cardText = new FlxText(0, 270, cardBG.width - 50,"",32);
		cardText.setFormat("p5hatty-1.ttf", 32, FlxColor.WHITE, LEFT);
		add(cardText);

        cardText.alpha = 0;

        //cardText.screenCenter(X);

        FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
        FlxTween.tween(cardBG, {x: 210, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(titleBG, {x: 260, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(promptText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(titleText, {x: 0, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(cardText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});

        super.create();

        if (Prompt == "WarningDemo")
        {
            promptText.text = "INFORMATION";
            titleText.text = "Before You Start The Demo";
            cardText.text = "This Mod is still in active development so a lot of things present might be changed, removed or unfinished.\n\nThis Demo serves as a tiny glimpse into what we want to do for the Mod and does not represent the Final Mod.\n\nPlease also note that this Mod contains Flashing Lights which can be disabled at Anytime in the Config Menu.";
        }
        else if (Prompt == "LockedDemo")
        {
            promptText.text = "INFORMATION";
            titleText.text = "Not Available in the Demo";
            cardText.text = "This Menu will be Available in the First Release of the Full Mod.";
        }
        else
        {
            promptText.text = "SYSTEM";
            titleText.text = "Error";
            cardText.text = "The Prompt you're looking for wasn't found.";
        }
    }

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT) 
        {
		    FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxTween.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
            FlxTween.tween(cardBG, {x: 410, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(titleBG, {x: 460, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(promptText, {x: 420, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(titleText, {x: 400, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
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