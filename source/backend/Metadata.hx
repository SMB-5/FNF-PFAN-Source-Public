package backend;

import haxe.Json;
import lime.utils.Assets;

#if sys
import sys.io.File;
#end

typedef MetadataFile = {
    var card:MetadataCard;
    var credits:MetadataCredits;
}

typedef MetadataCard = {
    var name:Null<String>;
    var expandBeat:Null<Int>;
    var duration:Null<Int>;
    var font:Null<String>;
    var fontSize:Null<Int>;
}

typedef MetadataCredits = {
    var music:Null<String>;
    var chart:Null<String>;
    var art:Null<String>;
    var code:Null<String>;
    var va:Null<String>;
}

class Metadata
{
    public static function get(song:String):MetadataFile
    {
        try {
            var path:String = Paths.formatToSongPath(PlayState.SONG.song) + '/metadata';

            #if sys
            var rawJson = File.getContent(Paths.json(path)).trim();
            #else
            var rawJson = Assets.getText(Paths.json(path)).trim();
            #end

            return cast Json.parse(rawJson);
        }
        catch(e) {
            return null;
        }
    }
}