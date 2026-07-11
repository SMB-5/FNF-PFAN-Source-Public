import backend.ClientPrefs;
import flixel.FlxSprite;

function onCreate()
	{
		var fog:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/fog'));
        fog.scrollFactor.set(0.7, 0.7);
        fog.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(fog);

		var ladder:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/ladder'));
        ladder.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(ladder);

		var floor:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/floor'));
		game.addBehindGF(floor);

		if(!ClientPrefs.data.lowQuality) {
			var lights:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/lights'));
            lights.scrollFactor.set(0.9, 0.9);
            lights.antialiasing = ClientPrefs.data.antialiasing;
			game.addBehindGF(lights);
		}

		var platforms:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/platforms'));
        platforms.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(platforms);
	}

	function onCreatePost()
	{
		if(!ClientPrefs.data.lowQuality) {
			var light:FlxSprite = new FlxSprite(-600, 0, Paths.image('persona/stages/tv-world/light'));
			add(light);
		}
	}