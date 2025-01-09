package states.freeplay;

import haxe.Json;
using states.freeplay.FunkinTools;

class FreeplayMetaJSON {
    public function new() {}
    public var songRating:Int = 0;
}

class FreeplayMeta {
    public static function getMeta(songId:String):FreeplayMetaJSON {
        var meta_file = Paths.getTextFromFile('data/${Paths.formatToSongPath(songId)}/metadata.json');
        if(meta_file != null){
            return getMetaFile(meta_file);
        }
        else {
            return new FreeplayMetaJSON();
        }
    }
    private static function getMetaFile(rawJson:String):FreeplayMetaJSON {

        try {
            if(rawJson != null && rawJson.length > 0) {
                return new FreeplayMetaJSON().mergeWithJson(Json.parse(rawJson));
            }
        }
        catch(x){
            trace("Malfolded json? tf did you do to it?");
            trace(x.message);
        }
		
		return null;
	}
}