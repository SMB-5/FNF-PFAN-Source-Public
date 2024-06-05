package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.io.File;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

class FreeplayCategoryState extends MusicBeatState {

    var storymode: FlxSprite;
    var freeplay: FlxSprite;
    var joke: FlxSprite;
    var bg: FlxSprite;
    public static var selectedItem: Int = 1;
    public static var mode: String = "freeplay";
    var allowInputs: Bool = true;

    override public function create(): Void {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        var background: FlxSprite = new FlxSprite(0, 0);
        background.makeGraphic(1280, 720, 0xFF0000FF);
        add(background);

        storymode = new FlxSprite(0, 0).loadGraphic(Paths.image('persona/menus/freeplay/category/storymode'));
        storymode.screenCenter(Y);
        storymode.x = 150;
        add(storymode);

        if(ClientPrefs.data.modBeaten)
        {
        freeplay = new FlxSprite(50, 0).loadGraphic(Paths.image('persona/menus/freeplay/category/freeplay'));
        }
        else
        {
        freeplay = new FlxSprite(50, 0).loadGraphic(Paths.image('persona/menus/freeplay/category/locked'));    
        }
        freeplay.screenCenter(XY);
        freeplay.x = (FlxG.width - freeplay.width) / 2;
        add(freeplay);

        if(ClientPrefs.data.modBeaten)
        {
        joke = new FlxSprite(0, 0).loadGraphic(Paths.image('persona/menus/freeplay/category/covers'));
        }
        else
        {
        joke = new FlxSprite(0, 0).loadGraphic(Paths.image('persona/menus/freeplay/category/locked'));    
        }
        joke.screenCenter(Y);
        joke.x = freeplay.x + freeplay.width + 50;
        add(joke);

        updateSelection();

        super.create();
    }

    override public function update(elapsed: Float): Void {
        super.update(elapsed);

        // Check for left and right key presses
        if (allowInputs) {
            if (controls.UI_LEFT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                selectedItem--;
                if (selectedItem < 1) selectedItem = 3; // Wrap around to the last item
                updateSelection();
            } else if (controls.UI_RIGHT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                selectedItem++;
                if (selectedItem > 3) selectedItem = 1; // Wrap around to the first item
                updateSelection();
            }

            // Check for Enter key press
            if (FlxG.keys.justPressed.ENTER) {
                // Perform an action based on the selectedItem value
                switch (selectedItem) {
                    case 1: // Story Mode
                        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                        MusicBeatState.switchState(new FreeplayState());
                        FreeplayState.mode = "story";
                        trace("Story Mode selected");
                    case 2: // Free Play
                    if(ClientPrefs.data.modBeaten)
                    {
                        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                        MusicBeatState.switchState(new FreeplayState());
                        FreeplayState.mode = "freeplay";
                        trace("Free Play selected");
                    }
                    else
                    {
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                    }
                    case 3: // joke
                    if(ClientPrefs.data.modBeaten)
                    {
                        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                        MusicBeatState.switchState(new FreeplayState());
                        FreeplayState.mode = "joke";
                        trace("joke selected");
                    }
                    else
                    {
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                    }
                }
            }
        }

        if (controls.BACK && allowInputs) {
            allowInputs = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
    }

    private function updateSelection(): Void {
        storymode.alpha = 0.7;
        freeplay.alpha = 0.7;
        joke.alpha = 0.7;

        switch (selectedItem) {
            case 1:
                storymode.alpha = 1.0;
            case 2:
                freeplay.alpha = 1.0;
            case 3:
                joke.alpha = 1.0;
        }
    }
}
