package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if(texture == null && ClientPrefs.splashType == 'Psych') {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

        //I will give you permission to kill me okay? I'm sorry
		if(ClientPrefs.splashType == 'Psych New') {
			texture = 'noteSplashes-psychnew';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'Diamond') {
			texture = 'noteSplashes-diamond';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'Electric') {
			texture = 'noteSplashes-electric';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'Sparkles') {
			texture = 'noteSplashes-sparkles';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'Vanilla') {
			texture = 'noteSplashes-vanilla';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		if(ClientPrefs.splashType == 'Forever') {
			texture = 'noteSplashes-forever';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		if (ClientPrefs.splashType == 'Psych')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Psych New')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue" + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green" + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple" + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red" + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Diamond')
		{
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash diamond blue" + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash diamond green" + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash diamond purple" + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash diamond red" + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Electric')
		{
		for (i in 1...3) {
		animation.addByPrefix('note1', 'note splash electric blue', 24, false);
		animation.addByPrefix('note2', 'note splash electric green', 24, false);
		animation.addByPrefix('note0', 'note splash electric purple', 24, false);
		animation.addByPrefix('note3', 'note splash electric red', 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Sparkles')
		{
		for (i in 1...3) {
		animation.addByPrefix('note1', 'note splash sparkle blue', 24, false);
		animation.addByPrefix('note2', 'note splash sparkle green', 24, false);
		animation.addByPrefix('note0', 'note splash sparkle purple', 24, false);
		animation.addByPrefix('note3', 'note splash sparkle red', 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Vanilla')
		{
		for (i in 1...3) {
		animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
		animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
		animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
		animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
		if (ClientPrefs.splashType == 'Forever')
		{
		for (i in 1...3) {
		animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
		animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
		animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
		animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}