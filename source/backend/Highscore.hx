package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songScoresOpponent:Map<String, Int> = new Map<String, Int>();
	public static var songRatingOpponent:Map<String, Float> = new Map<String, Float>();

	public static function resetSong(song:String, diff:Int = 0, ?opponent:Bool = false):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0, opponent);
		setRating(daSong, 0, opponent);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, ?opponent:Bool = false):Void
	{
		var daSong:String = formatSong(song, diff);
		var scores:Map<String, Int> = !opponent ? songScores : songScoresOpponent;

		if (scores.exists(daSong))
		{
			if (scores.get(daSong) < score)
			{
				setScore(daSong, score, opponent);
				if(rating >= 0) setRating(daSong, rating, opponent);
			}
		}
		else
		{
			setScore(daSong, score, opponent);
			if(rating >= 0) setRating(daSong, rating, opponent);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int, ?opponent:Bool = false):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var scores:Map<String, Int> = !opponent ? songScores : songScoresOpponent;
		scores.set(song, score);
		if (!opponent) FlxG.save.data.songScores = scores;
		else FlxG.save.data.songScoresOpponent = scores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float, ?opponent:Bool = false):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var ratings:Map<String, Float> = !opponent ? songRating : songRatingOpponent;
		ratings.set(song, rating);
		if (!opponent) FlxG.save.data.songRating = ratings;
		else FlxG.save.data.songRatingOpponent = ratings;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
	}

	public static function getScore(song:String, diff:Int, ?opponent:Bool = false):Int
	{
		var scores:Map<String, Int> = !opponent ? songScores : songScoresOpponent;
		var daSong:String = formatSong(song, diff);
		if (!scores.exists(daSong))
			setScore(daSong, 0, opponent);

		return scores.get(daSong);
	}

	public static function getRating(song:String, diff:Int, ?opponent:Bool = false):Float
	{
		var rating:Map<String, Float> = !opponent ? songRating : songRatingOpponent;
		var daSong:String = formatSong(song, diff);
		if (!rating.exists(daSong))
			setRating(daSong, 0, opponent);

		return rating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;

		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songRating != null)
			songRating = FlxG.save.data.songRating;

		if (FlxG.save.data.songScoresOpponent != null)
			songScoresOpponent = FlxG.save.data.songScoresOpponent;

		if (FlxG.save.data.songRatingOpponent != null)
			songRatingOpponent = FlxG.save.data.songRatingOpponent;
	}
}