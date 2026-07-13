package states;

#if android
import mobile.util.StorageUtil;
#end

import haxe.io.Path;

import openfl.utils.Assets;
import openfl.utils.ByteArray;

import flixel.ui.FlxBar;

class CopyState extends MusicBeatState
{
	public static var saveExtensions:Array<String> = ['txt', 'json', 'xml'];
	public static var assetFolders:Array<String> = ['assets/', 'mods/']; // Folders to copy
	public static var ignoreFolders:Array<String> = ['embed']; // Don't include a slash at the end when putting folders in here
	public static var filesToAdd:Array<String> = [];
	public static var recopyAssets:Bool = false; // Recopy all assets when the mod is updated, does not recopy mods folder for obvious reasons

	public var bg:FlxSprite;
	public var progressBar:FlxBar;
	public var progressText:FlxText;
	public var filesCopied:Int = 0;
	public var filesTotal:Int = 0;
	public var failedFiles:Array<String> = [];
	public var failedStack:Array<String> = [];

	override function create() {
		if (recopyAssets) {
			if (FileSystem.exists('assets') && FileSystem.isDirectory('assets')) CoolUtil.deleteDirectory('assets');
			else recopyAssets = false;
		}

		if (!findNewFiles()) {
			MusicBeatState.switchState(new states.TitleState());
			return;
		}

		var msg:String = 'Found new files that are necessary to start the game.';
		if (recopyAssets) msg = 'Mod was updated, recopying all files to ensure the game\'s condition.';

		FlxG.stage.window.alert('$msg Press OK to start the copying process.', 'Notice!');

		filesTotal = filesToAdd.length;

		bg = new FlxSprite(0, 0, Paths.image('title-bg'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		progressBar = new FlxBar(0, FlxG.height - 30, LEFT_TO_RIGHT, FlxG.width, 30);
		add(progressBar);

		progressText = new FlxText(0, progressBar.y + 7, FlxG.width, '', 16);
		progressText.setFormat(Paths.font('vcr.ttf'), 16, 0xFFFFFFFF, CENTER, OUTLINE);
		add(progressText);

		sys.thread.Thread.create(startCopyProcess);

		recopyAssets = false;
		super.create();
	}

	public static function findNewFiles():Bool {
		filesToAdd = Assets.list().filter(file->{
			var startsWith:Bool = false;
			for (folder in assetFolders) {
				if (file.startsWith(folder)) startsWith = true;
			}
			if (!startsWith) return false;
			for (folder in file.split('/')) {
				if (ignoreFolders.contains(folder)) return false;
			}
			if (#if android file.startsWith('mods/') && !FileSystem.exists(StorageUtil.getExternalDir() + file) || #end !FileSystem.exists(file)) return true;

			// reminder: ONLY USED IN DEVELOPMENT, REMOVE WHEN RELEASING MOD
			// this loads too slow to be used in release builds and is unnecessary - melodiekit
			else if (!compareAssetBytes(file, saveExtensions.contains(Path.extension(file).toLowerCase()))) return true;
			return false;
		});
		trace('files found: $filesToAdd');
		return filesToAdd.length > 0;
	}

	function startCopyProcess() {
		for (file in filesToAdd) {
			var name:String = Path.withoutDirectory(file);
			var dir:String = Path.directory(file);
			#if android
			if (file.startsWith('mods/')) dir = StorageUtil.getExternalDir() + dir;
			#end
			try {
				if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) {
					FileSystem.createDirectory(dir);
				}
				if (saveExtensions.contains(Path.extension(file).toLowerCase())) {
					File.saveContent(Path.join([dir, name]), Assets.getText(file));
				}
				else File.saveBytes(Path.join([dir, name]), getBytes(file));
			}
			catch(e:Dynamic) {
				failedFiles.push(file);
				failedStack.push('$file $e');
				trace('failed to copy file $file\n$e');
			}
			filesCopied++;
			progressText.text = filesCopied == filesTotal ? 'Completed!' : '$filesCopied/$filesTotal';
			progressBar.percent = (filesCopied / filesTotal) * 100;
		}
		if (failedFiles.length > 0) {
			FlxG.stage.window.alert(failedFiles.join('\n'), 'Failed to copy ${failedFiles.length} files');
			CoolUtil.saveCrash(failedStack.join('\n'), 'CopyState');
		}
		FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = ()->MusicBeatState.switchState(new states.TitleState());
	}

	static function getBytes(file:String, embedded:Bool = true) {
		switch(Path.extension(file).toLowerCase()) {
			case 'ttf', 'otf': return ByteArray.fromFile(file);
			default: return embedded ? Assets.getBytes(file) : File.getBytes(file);
		}
	}

	static function compareAssetBytes(file:String, text:Bool = false):Bool {
		if (text) {
			if (Assets.getText(file).trim().length == 0 && File.getContent(file).trim().length == 0) return true;
			return Assets.getText(file) == File.getContent(file);
		}

		var byte1 = getBytes(file);
		var byte2 = ByteArray.fromBytes(getBytes(file, false));

		if (byte1 == null || byte2 == null || byte1.length != byte2.length) return false;

		return cast (byte1, haxe.io.Bytes).compare(byte2) == 0;
	}
}