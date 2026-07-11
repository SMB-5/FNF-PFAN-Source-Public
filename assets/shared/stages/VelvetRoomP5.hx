import backend.ClientPrefs;
import flixel.FlxSprite;

function onCreate()
	{
		var room:FlxSprite = new FlxSprite(-600, -300, Paths.image('persona/stages/velvet-room-p5/Room'));
        room.scrollFactor.set(0.8, 0.8);
        room.antialiasing = ClientPrefs.data.antialiasing;
		game.addBehindGF(room);

		if(!ClientPrefs.data.lowQuality) {
			var deskshadow:FlxSprite = new FlxSprite(-600, -300, Paths.image('persona/stages/velvet-room-p5/Shadow-Desk'));
            deskshadow.scrollFactor.set(0.9, 0.9);
            deskshadow.antialiasing = ClientPrefs.data.antialiasing;
			game.addBehindGF(deskshadow);
		}

		var desk:FlxSprite = new FlxSprite(-600, -300, Paths.image('persona/stages/velvet-room-p5/Desk'));
        desk.scrollFactor.set(0.9, 0.9);
		game.addBehindGF(desk);
	}

	function onCreatePost()
	{
		if(!ClientPrefs.data.lowQuality) {
			var overlay:FlxSprite = new FlxSprite(-500, -300, Paths.image('persona/stages/velvet-room-p5/Velvet_Room_Overlay'));
			add(overlay);

			var light:FlxSprite = new FlxSprite(-500, -300, Paths.image('persona/stages/velvet-room-p5/Velvet_Room_Overlay_2'));
			add(light);
		}
	}