import backend.ClientPrefs;
import flixel.FlxSprite;

function onCreate()
	{
		var bg:FlxSprite = new FlxSprite(-600, -300, Paths.image('persona/stages/dorm/dorm'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
		addBehindGF(bg);
	}