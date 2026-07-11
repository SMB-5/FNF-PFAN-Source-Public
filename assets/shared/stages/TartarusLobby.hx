import backend.ClientPrefs;
import flixel.FlxSprite;

function onCreate()
	{
		var buildings:FlxSprite = new FlxSprite(-740, -350, Paths.image('persona/stages/tartarus-lobby/1'));
        buildings.scrollFactor.set(0.4, 0.4);
        buildings.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(buildings);

		var pillars:FlxSprite = new FlxSprite(-440, -450, Paths.image('persona/stages/tartarus-lobby/2'));
        pillars.scrollFactor.set(0.6, 0.6);
        pillars.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(pillars);

		var fg:FlxSprite = new FlxSprite(-540, -350, Paths.image('persona/stages/tartarus-lobby/3'));
        fg.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(fg);

        if(!ClientPrefs.data.lowQuality) {
			//var shadows:BGSprite = new BGSprite('persona/stages/tartarus-lobby/4', -540, -350);
			//add(shadows);
		}
	}

function onCreatePost()
	{
		if(!ClientPrefs.data.lowQuality) {
			var light:FlxSprite = new FlxSprite(-540, -350, Paths.image('persona/stages/tartarus-lobby/5'));
			add(light);

			var vig:FlxSprite = new FlxSprite().loadGraphic(Paths.image('persona/stages/tartarus-lobby/6'));
            vig.scrollFactor.set(0, 0);
			add(vig);
			vig.cameras = [camHUD];

			var lvig:FlxSprite = new FlxSprite().loadGraphic(Paths.image('persona/stages/tartarus-lobby/7'));
            lvig.scrollFactor.set(0, 0);
			add(lvig);
			lvig.cameras = [camHUD];
		}
	}