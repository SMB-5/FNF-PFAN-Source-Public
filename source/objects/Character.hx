package objects;

import backend.animation.PsychAnimationController;

import flixel.util.typeLimit.OneOfThree;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.tweens.FlxEase;	
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;

import backend.Song;
import backend.Section;
import states.stages.objects.TankmenBG;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var vocals_file:String;
	@:optional var _editor_isPlayer:Null<Bool>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

    public var mostRecentRow:Int = 0;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var autoDance:Bool = true; //Character dances after holdTimer reaches its limit
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	public var ghost:FlxSprite;
	var ghostTween:FlxTween;

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;

	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		fixArrowRGB();
		this.isPlayer = isPlayer;
		autoDance = !isPlayer;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode them instead':

			default:
				var characterPath:String = 'characters/$curCharacter.json';

				var path:String = Paths.getPath(characterPath, TEXT, null, true);
				#if MODS_ALLOWED
				if (!FileSystem.exists(path))
				#else
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
					color = FlxColor.BLACK;
					alpha = 0.6;
				}

				try
				{
					#if MODS_ALLOWED
					loadCharacterFile(Json.parse(File.getContent(path)));
					#else
					loadCharacterFile(Json.parse(Assets.getText(path)));
					#end
				}
				catch(e:Dynamic)
				{
					trace('Error loading character file of "$character": $e');
				}
		}

		skipDance = false;
		hasMissAnimations = hasAnimation('singLEFTmiss') || hasAnimation('singDOWNmiss') || hasAnimation('singUPmiss') || hasAnimation('singRIGHTmiss');
		recalculateDanceIdle();
		dance();

		switch(curCharacter)
		{
			case 'shadow-makoto':
				var swap = new shaders.ColorSwap();
				swap.saturation = -1;
				shader = swap.shader;
				setColorTransform(1, 1, 1, alpha, -125, -125, -125, 0);
				if (ghost != null) {
					ghost.shader = swap.shader;
					ghost.setColorTransform(1, 1, 1, 0, -125, -125, -125, 0);
				}
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}
	}

		/**
	 * HOW TO NOTE COLOR v1.2 101 by the Super Funkin' Galaxy Team
	 * 
	 * multiple note color chars are done like this
	 * "charname" => [
	 * 	[left note main color, left note highlight color, left note outline color],
	 * 	[down note main color, down note highlight color, down note outline color],
	 * 	[up note main color, up note highlight color, up note outline color],
	 * 	[right note main color, right note highlight color, right note outline color]
	 * ],
	 * 
	 * singular note color chars are done like this
	 * "charname" => [note main color, note highlight color, note outline color],
	 * 
	 * now for example "char-pixel" has the same note color as "char" you can just do
	 * "char-pixel" => "char"
	 * it just does a redirection to the og chars color
	 */
	static var arrowColors:Map<String, OneOfThree<String, Array<Array<FlxColor>>, Array<FlxColor>>> = [		
		"shadow-makoto" => [
			[0xFF606060, 0xFFFFFFFF, 0xFF303030],
			[0xFF606060, 0xFFFFFFFF, 0xFF303030],
			[0xFF606060, 0xFFFFFFFF, 0xFF303030],
			[0xFF606060, 0xFFFFFFFF, 0xFF303030]
		],
	];

	public function fixArrowRGB()
		arrowRGB = getArrowRGB();

	public function getArrowRGB(?char:String):Array<Array<FlxColor>> {
		if (char == null) char = curCharacter;
		var toReturn:OneOfThree<String, Array<Array<FlxColor>>, Array<FlxColor>> = arrowColors.exists(char) ? arrowColors.get(char) : ClientPrefs.data.arrowRGB;
		if (toReturn is String)
			toReturn = arrowColors.exists(toReturn) ? arrowColors.get(toReturn) : ClientPrefs.data.arrowRGB;
		
		var getLengthFromAny:Array<Any>->Int = (shit:Array<Any>) -> {return shit.length;}; //fixes
		if (getLengthFromAny(toReturn) == 3)
			toReturn = [toReturn, toReturn, toReturn, toReturn];

		return toReturn;
	}

	public function loadCharacterFile(json:Dynamic)
	{
		isAnimateAtlas = false;

		#if flxanimate
		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT, null, true);
		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
			isAnimateAtlas = true;
		#end

		scale.set(1, 1);
		updateHitbox();

		if(!isAnimateAtlas)
		{
			var split:Array<String> = json.image.split(',');
			var charFrames:FlxAtlasFrames = Paths.getAtlas(split[0].trim());
			if(split.length > 1)
			{
				var original:FlxAtlasFrames = charFrames;
				charFrames = new FlxAtlasFrames(charFrames.parent);
				charFrames.addAtlas(original, true);
				for (i in 1...split.length)
				{
					var extraFrames:FlxAtlasFrames = Paths.getAtlas(split[i].trim());
					if(extraFrames != null)
						charFrames.addAtlas(extraFrames, true);
				}
			}
			frames = charFrames;
			ghost = new FlxSprite(x, y);
			ghost.frames = frames;
			ghost.antialiasing = true;
			ghost.blend = HARDLIGHT;
			ghost.alpha = 0;
		}
		#if flxanimate
		else
		{
			atlas = new FlxAnimate();
			atlas.showPivot = false;
			try
			{
				Paths.loadAnimateAtlas(atlas, json.image);
			}
			catch(e:Dynamic)
			{
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
			}
		}
		#end

		imageFile = json.image;
		jsonScale = json.scale;
		if(json.scale != 1) {
			scale.set(jsonScale, jsonScale);
			updateHitbox();
			ghost?.scale.set(jsonScale, jsonScale);
			ghost?.updateHitbox();
		}

		// positioning
		positionArray = json.position;
		cameraPosition = json.camera_position;

		// data
		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file != null ? json.vocals_file : '';
		originalFlipX = (json.flip_x == true);
		editorIsPlayer = json._editor_isPlayer;

		// antialiasing
		noAntialiasing = (json.no_antialiasing == true);
		antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

		// animations
		animationsArray = json.animations;
		if(animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; //Bruh
				var animIndices:Array<Int> = anim.indices;

				if(!isAnimateAtlas)
				{
					if(animIndices != null && animIndices.length > 0)
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					else
						animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				#if flxanimate
				else
				{
					if(animIndices != null && animIndices.length > 0)
						atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					else
						atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
				}
				#end

				if(anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else addOffset(anim.anim, 0, 0);
			}
		}
		ghost?.animation.copyFrom(animation);
		copyGhostValues();
		#if flxanimate
		if(isAnimateAtlas) copyAtlasValues();
		#end
		//trace('Loaded file to character ' + curCharacter);
	}

	override function update(elapsed:Float)
	{
		#if flxanimate if(isAnimateAtlas) atlas.update(elapsed); #end
		ghost?.update(elapsed);

		if(debugMode || (!isAnimateAtlas && animation.curAnim == null) || (isAnimateAtlas && (atlas.anim.curInstance == null || atlas.anim.curSymbol == null)))
		{
			super.update(elapsed);
			return;
		}

		if(heyTimer > 0)
		{
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;
			if(heyTimer <= 0)
			{
				var anim:String = getAnimationName();
				if(specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if(specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (getAnimationName().endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;

					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if(isAnimationFinished()) playAnim(getAnimationName(), false, false, animation.curAnim.frames.length - 3);
		}

		if (getAnimationName().startsWith('sing')) holdTimer += elapsed;
		else if (isPlayer) holdTimer = 0;

		if (autoDance && holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();
		if(isAnimationFinished() && hasAnimation('$name-loop'))
			playAnim('$name-loop');

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool
	{
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curInstance == null || atlas.anim.curSymbol == null);
	}

    var _lastPlayedAnimation:String;
	inline public function getAnimationName():String
	{
        return _lastPlayedAnimation;
	}

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return #if flxanimate !isAnimateAtlas ? #end animation.curAnim.finished #if flxanimate : atlas.anim.finished #end;
	}

	public function finishAnimation():Void
	{
		if(isAnimationNull()) return;

		if(!isAnimateAtlas) animation.curAnim.finish();
		#if flxanimate else atlas.anim.curFrame = atlas.anim.length - 1; #end
	}

	public function hasAnimation(anim:String):Bool
	{
		return animOffsets.exists(anim);
	}

	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return #if flxanimate !isAnimateAtlas ? #end animation.curAnim.paused #if flxanimate : atlas.anim.isPlaying #end;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		if(!isAnimateAtlas) animation.curAnim.paused = value;
		#if flxanimate
		else
		{
			if(value) atlas.anim.pause();
			else atlas.anim.resume();
		} 
		#end

		return value;
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(hasAnimation('idle' + idleSuffix)) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		if(!isAnimateAtlas) animation.play(AnimName, Force, Reversed, Frame);
		#if flxanimate else atlas.anim.play(AnimName, Force, Reversed, Frame); #end
		_lastPlayedAnimation = AnimName;

		if (hasAnimation(AnimName))
		{
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0], daOffset[1]);
		}
		//else offset.set(0, 0);

		if (curCharacter.startsWith('gf-') || curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;

			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function playGhostAnim(animName:String)
	{
		if(ghost == null) return;

		if(ghostTween != null)
			ghostTween.cancel();

		ghost.animation.play(animName, true);
		ghost.alpha = 0.8;
		if(animOffsets.exists(animName))
			ghost.offset.set(animOffsets.get(animName)[0], animOffsets.get(animName)[1]);

		ghost.color = FlxColor.fromRGB(healthColorArray[0] + 50, healthColorArray[1] + 50, healthColorArray[2] + 50);
		ghostTween = FlxTween.tween(ghost, {alpha: 0}, 0.75, {onComplete: (twn)->ghostTween = null});
	}

	function loadMappedAnims():Void
	{
		try
		{
			var noteData:Array<SwagSection> = Song.loadFromJson('picospeaker', Paths.formatToSongPath(PlayState.SONG.song)).notes;
			for (section in noteData) {
				for (songNotes in section.sectionNotes) {
					animationNotes.push(songNotes);
				}
			}
			TankmenBG.animationNotes = animationNotes;
			animationNotes.sort(sortAnims);
		}
		catch(e:Dynamic) {}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;
	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (hasAnimation('danceLeft' + idleSuffix) && hasAnimation('danceRight' + idleSuffix));

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	// Atlas support
	// special thanks ne_eo for the references, you're the goat!!
	@:allow(states.editors.CharacterEditorState)
	public var isAnimateAtlas(default, null):Bool = false;
	#if flxanimate
	public var atlas:FlxAnimate;
	#end
	public override function draw()
	{
		#if flxanimate
		if(isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		#end
		copyGhostValues();
		ghost?.draw();
		super.draw();
	}

	#if flxanimate
	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}
	#end

	public function copyGhostValues()
	{
		if(ghost == null) return;
		@:privateAccess
		{
			ghost.cameras = cameras;
			ghost.scrollFactor = scrollFactor;
			ghost.scale = scale;
			ghost.origin = origin;
			ghost.x = x;
			ghost.y = y;
			ghost.angle = angle;
			ghost.visible = visible;
			ghost.flipX = flipX;
			ghost.flipY = flipY;
		}
	}

	public function destroyAtlas() {
		#if flxanimate atlas = FlxDestroyUtil.destroy(atlas); #end
	}

	public override function destroy()
	{
		destroyAtlas();
		ghost = FlxDestroyUtil.destroy(ghost);
		super.destroy();
	}
}