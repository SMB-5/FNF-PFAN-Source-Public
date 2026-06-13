package backend;

import flixel.system.ui.FlxSoundTray;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import util.MathUtil;

/**
 * smb ur original code sucked so here it is
 * persona sound tray dx
 * enjoy chat
 * :D
 * -- notmagniill, march 14th 2025
*/

class PersonaSoundTray extends FlxSoundTray
{
    var graphicScale:Float = 0.30;
    var lerpYPos:Float = 0;
    var alphaTarget:Float = 0;

    var volumeMaxSound:String;

    public function new()
    {
        // Calls super, then removes everything from the sound tray and add better graphics.
        super();
        removeChildren();

        // Adds the background, or the image volumebox.png located in the soundtray folder in images
        var bg:Bitmap = new Bitmap(Assets.getBitmapData(Paths.imageString('soundtray/volumebox')));
        bg.scaleX = graphicScale;
        bg.scaleY = graphicScale;
        addChild(bg);

        y = -height;
        visible = false;

        // Makes a version of the bar with the transparency slightly lower (bars_10.png)
        var backingBar:Bitmap = new Bitmap(Assets.getBitmapData(Paths.imageString('soundtray/bars_10')));
        backingBar.x = 9;
        backingBar.y = 5;
        backingBar.scaleX = graphicScale;
        backingBar.scaleY = graphicScale;
        addChild(backingBar);
        backingBar.alpha = 0.4;

        // Clear the bars entirely, initialized in the super function we called.
        _bars = [];

        //1..11 due to the weird sprite behaviour. I don't know.
        for (i in 1...11)
        {
            var bar:Bitmap = new Bitmap(Assets.getBitmapData(Paths.imageString('soundtray/bars_' + i)));
            bar.x = 9;
            bar.y = 5;
            bar.scaleX = graphicScale;
            bar.scaleY = graphicScale;
            addChild(bar);
            _bars.push(bar);
        }

        y = -height;
        screenCenter();

        volumeUpSound = Paths.soundString('soundtray/Volup');
        volumeDownSound = Paths.soundString('soundtray/Voldown');
        volumeMaxSound = Paths.soundString('soundtray/VolMAX');
    }

    override public function update(MS:Float):Void
    {
        y = MathUtil.coolLerp(y, lerpYPos, 0.1);
        alpha = MathUtil.coolLerp(alpha, alphaTarget, 0.25);

        //Animates the sound tray
        if (_timer > 0)
        {
            _timer -= (MS / 1000);
            alphaTarget = 1;
        }
        else if (y >= -height)
        {
            lerpYPos = -height - 10;
            alphaTarget = 0;
        }
    
        if (y <= -height)
        {
            visible = false;
            active = false;
    
            #if FLX_SAVE
            // Save sound preferences
            if (FlxG.save.isBound)
            {
                FlxG.save.data.mute = FlxG.sound.muted;
                FlxG.save.data.volume = FlxG.sound.volume;
                FlxG.save.flush();
            }
            #end
        }
    }

    /**
     * Makes the little volume tray slide out.
     *
     * @param   up Whether the volume is increasing.
     */
    override public function show(up:Bool = false):Void
    {
        _timer = 1;
        lerpYPos = 10;
        visible = true;
        active = true;
        var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
    
        if (FlxG.sound.muted)
        {
            globalVolume = 0;
        }
    
        if (!silent)
        {
            var sound = up ? volumeUpSound : volumeDownSound;
    
            if (globalVolume == 10) 
            {
                sound = volumeMaxSound;
                // might make this an option later idk
                //FlxG.camera.shake(0.005, 0.35);
            }
    
            if (sound != null) FlxG.sound.load(sound).play();
        }
    
        for (i in 0..._bars.length)
        {
            if (i < globalVolume)
            {
                _bars[i].visible = true;
            }
            else
            {
                _bars[i].visible = false;
            }
        }
    }
}