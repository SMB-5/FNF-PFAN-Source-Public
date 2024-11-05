package objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.Metadata;

using StringTools;
using flixel.util.FlxSpriteUtil;

class SongCard extends FlxSpriteGroup 
{
    var text:FlxText;
    var bg:FlxSprite;
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

        text = new FlxText(x + padding, y + padding).setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.antialiasing = ClientPrefs.data.antialiasing;
        text.text = toString();
        
        bg = new FlxSprite().makeGraphic(Std.int(text.width + (padding * 2)), Std.int(text.height + (padding * 2)), FlxColor.BLACK);
        bg.alpha = 0.8;

        add(bg);
        add(text);
    }

    override function toString():String
    {
        return '${data.card.name}\n\nSong: ${data.credits.music}\nChart: ${data.credits.chart}';
    }

    public function display() {
        var initX:Float = this.x;

        FlxTween.tween(this, {x: initX + this.width}, 0.65, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
            FlxTween.tween(this, {x: initX}, 0.65, {ease: FlxEase.cubeInOut, startDelay: data.card.duration, onComplete: function(twn:FlxTween) {
                this.destroy();
            }});
        }});
    }
}