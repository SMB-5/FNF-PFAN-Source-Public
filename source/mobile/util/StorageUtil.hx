package mobile.util;

#if android
import extension.androidtools.Permissions;
import extension.androidtools.Settings;
import extension.androidtools.os.Environment;
import extension.androidtools.os.Build.VERSION;
import extension.androidtools.os.Build.VERSION_CODES;
#end

class StorageUtil
{
	public static var externalFolder:String = '.PersonaDEMO';

	public static function getExternalDir() {
		return haxe.io.Path.addTrailingSlash('/storage/emulated/0/$externalFolder');
	}

	#if android
	public static function requestPermissions() {
		if (VERSION.SDK_INT < VERSION_CODES.R) {
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}
		else if (!Environment.isExternalStorageManager()) {
			Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if (!Environment.isExternalStorageManager() || VERSION.SDK_INT < VERSION_CODES.R && !StorageUtil.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')) {
			FlxG.stage.window.alert('Make sure that you have accepted all necessary permissions, expect a crash otherwise.', 'Notice!');
		}
	}

	public static function setupExternalStorage() {
		try {
			if (!FileSystem.exists(StorageUtil.getExternalDir()) || !FileSystem.isDirectory(StorageUtil.getExternalDir())) {
				FileSystem.createDirectory(StorageUtil.getExternalDir());
			}
		}
		catch(e:Dynamic) {
			FlxG.stage.window.alert('Failed to create storage.\nPlease manually create directory ${StorageUtil.getExternalDir()}.', 'Error!');
			lime.system.System.exit(1);
		}

		try {
			if (!FileSystem.exists(StorageUtil.getExternalDir() + 'mods/') || !FileSystem.isDirectory(StorageUtil.getExternalDir() + 'mods/')) {
				FileSystem.createDirectory(StorageUtil.getExternalDir() + 'mods/');
			}
		}
		catch(e:Dynamic) {
			FlxG.stage.window.alert('Failed to create storage.\nPlease manually create directory ' + StorageUtil.getExternalDir() + 'mods/.', 'Error!');
			lime.system.System.exit(1);
		}
	}

	// remaking the function because the original function is broken on 2.2.2 lol
	public static inline function getGrantedPermissions():Array<String>
	{
		final getGrantedPermissionsJNI:Null<Dynamic> = extension.androidtools.jni.JNICache.createStaticMethod('org/haxe/extension/Tools', 'getGrantedPermissions', '()[Ljava/lang/String;');

		return getGrantedPermissionsJNI != null ? getGrantedPermissionsJNI() : [];
	}
	#end
}