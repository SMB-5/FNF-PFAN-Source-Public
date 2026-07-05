package objects;

import backend.Metadata;
import backend.WeekData;

import mobile.backend.MobileData;

class SongCard extends FlxSpriteGroup 
{
	var text:FlxText;
	var bg:FlxSprite;
	var bg2:FlxSprite;
	var text2:FlxText;
	var logo:FlxSprite;
	var padding:Float = 10;
	public var data:MetadataFile;

	public function new(x:Float, y:Float, meta:MetadataFile) 
	{
		super(x, y);

		data = meta;

		//var font:Null<String> = data.card.font;
		//if (font == null) font = 'vcr.ttf';

		//var size:Null<Int> = data.card.fontSize;
		//if (size == null) size = 24;

		text = new FlxText(x + padding, y + padding).setFormat(Paths.font('Fontsona4Golden.ttf'), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.text = toString();
		text.y = 500;
		if(ClientPrefs.data.downScroll #if mobile || MobileData.baseGame #end) text.y = 150;

		bg = new FlxSprite().makeGraphic(Std.int(text.width + (200)), Std.int(text.height + (padding * 2)), FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1], PlayState.instance.dad.healthColorArray[2]));
		bg.alpha = 1;
		bg.y = text.y - 10;

		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('funkinthieves-mask'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.alpha = 1;
		logo.scale.set(0.15, 0.15);
		logo.x = text.width - 380;
		logo.y = text.y - 390;

		text2 = new FlxText(x + padding, y + padding).setFormat(Paths.font('Fontsona4Golden.ttf'), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.antialiasing = ClientPrefs.data.antialiasing;
		text2.text = WeekData.getCurrentWeek().weekName;
		text2.y = 590;
		if(ClientPrefs.data.downScroll #if mobile || MobileData.baseGame #end) text2.y = 110;

		bg2 = new FlxSprite().makeGraphic(Std.int(text2.width + (50)), Std.int(text.height - 30), FlxColor.BLACK);
		bg2.alpha = 1;
		bg2.y = text2.y - 10;

		add(bg2);
		add(bg);
		add(logo);
		add(text);
		add(text2);
	}

	override function toString():String
	{
		return '${data.card.name}\n\nBy: ${data.credits.music}';
	}

	public function display()
	{
		var initX:Float = this.x;

		FlxTween.tween(this, {x: initX + this.width}, 0.65, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
			FlxTween.tween(this, {x: initX}, 0.65, {ease: FlxEase.cubeInOut, startDelay: data.card.duration, onComplete: function(twn:FlxTween) {
				this.destroy();
			}});
		}});
	}
}