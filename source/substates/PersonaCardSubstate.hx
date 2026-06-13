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
    var acceptIcon:FlxSprite;
    var confirmText:FlxText;
    var stopText:FlxText;

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

        var acceptKeyName:String = Std.string(ClientPrefs.keyBinds.get('accept')[1]);

        acceptIcon = new FlxSprite(20, FlxG.height - 44).loadGraphic(Paths.image('persona/ui/button-icons/keyboard/' + acceptKeyName));
		acceptIcon.setGraphicSize(Std.int(acceptIcon.width * 0.15));
		acceptIcon.updateHitbox();
		acceptIcon.antialiasing = true;
		add(acceptIcon);

        acceptIcon.alpha = 0;
        acceptIcon.y = cardBG.y + 440;

		confirmText = new FlxText(0, FlxG.height - 39, 0, Language.getPhrase("ui_close"), 24);
		confirmText.setFormat("p5hatty-1.ttf", 32, FlxColor.WHITE, RIGHT);
		add(confirmText);

        stopText = new FlxText(50, FlxG.height - 39, 0, "I", 24);
		stopText.setFormat("p5hatty-1.ttf", 32, FlxColor.WHITE, RIGHT);
		add(stopText);
        stopText.alpha = 0;
        stopText.y = acceptIcon.y + 5;

        acceptIcon.x = confirmText.x - 70;
        confirmText.y = acceptIcon.y + 5;
        confirmText.alpha = 0;

        FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
        FlxTween.tween(cardBG, {x: 210, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(titleBG, {x: 260, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(promptText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(titleText, {x: 0, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(cardText, {x: 220, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(acceptIcon, {x: confirmText.x - 70, alpha: 1}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(stopText, {x: 1050, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
        FlxTween.tween(confirmText, {x: acceptIcon.x + acceptIcon.width + 10, alpha: 1}, 0.3, {ease: FlxEase.expoOut});

        super.create();

        if (Prompt == "WarningDemo")
        {
            promptText.text = Language.getPhrase("prompt_info");
            titleText.text = Language.getPhrase("demo_title");
            cardText.text = Language.getPhrase("demo_text");
        }
        else if (Prompt == "LockedDemo")
        {
            promptText.text = Language.getPhrase("prompt_info");
            titleText.text = Language.getPhrase("demolock_title");
            cardText.text = Language.getPhrase("demolock_text");
        }
        else
        {
            promptText.text = Language.getPhrase("prompt_system");
            titleText.text = Language.getPhrase("error_title");
            //cards are gonna be hardcoded and I assume most if not all of us devs are gonna be able to read english I think it's fine not to translate this error -SMB
            cardText.text = "The Prompt you're looking for wasn't found.";
        }
    }

	override function update(elapsed:Float)
	{
        //tweens don't move the text for some reason
        confirmText.x = stopText.x - 10 - confirmText.width;
        acceptIcon.x = confirmText.x - 70;
		if (controls.ACCEPT) 
        {
		    FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxTween.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
            FlxTween.tween(cardBG, {x: 410, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(titleBG, {x: 460, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(promptText, {x: 420, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(titleText, {x: 400, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(acceptIcon, {x: 1220, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(stopText, {x: 1250, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
            FlxTween.tween(confirmText, {x: acceptIcon.x + acceptIcon.width + 10, alpha: 0}, 0.3, {ease: FlxEase.expoOut});
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