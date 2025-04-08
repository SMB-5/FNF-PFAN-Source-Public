package states.editors;

import substates.results.*;

import flixel.text.FlxText;

class ResultsTestState extends MusicBeatState
{
	var options:Array<String> = [
		'Test P3',
		'Test P4',
        'Test P5'
	];

    public static var debug:Bool = true;

    private var grpTexts:FlxTypedGroup<Alphabet>;
    private var curSelected = 0;

    override function create()
    {
        debug = true;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	    add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

        for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
		}

        changeSelection();

	    super.create();
    }

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

        if (controls.BACK)
		{
            debug = false;
			MusicBeatState.switchState(new MasterEditorMenu());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

        if (controls.ACCEPT)
		{
			switch(options[curSelected]) {
				case 'Test P3':
					openSubState(new P3Results());
				case 'Test P4':
					openSubState(new P4Results());
			}
		}
        var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
	}
}