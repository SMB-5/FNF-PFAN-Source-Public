package states.freeplay;

import states.freeplay.*;

import flixel.FlxSprite;

class Shit extends FlxSpriteGroup
{

public var songId(default, null):String = '';
var difficultyStars:DifficultyStars;
public var difficultyRating(default, null):Int = 0;

public function new()
{
    var meta = FreeplayMeta.getMeta(songId);
    
    difficultyRating = meta.songRating;

	difficultyStars = new DifficultyStars(0, 0);
    difficultyStars.visible = true;
    add(difficultyStars);
}

public function Create()
{
	// Set difficulty star count.
	setDifficultyStars(songs[curSelected].songName?.difficultyRating);

    showStars();
}

public function setDifficultyStars(?difficulty:Int):Void
  {
    if (difficulty == null) return;
    difficultyStars.difficulty = difficulty;
  }
  
    /**
   * Make the album stars visible.
   */
public function showStars():Void
  {
    difficultyStars.visible = true; // true;
    difficultyStars.flameCheck();
  }

}