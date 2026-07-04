package objects;

import flixel.input.keyboard.FlxKey;

class KeyIcon extends FlxSpriteGroup
{
	public static var defaultTranslations:Map<String, String> = ['ui_select' => 'Select', 'ui_confirm' => 'Confirm', 'ui_close' => 'Close', 'ui_back' => 'Back', 'ui_gmodifiers' => 'Modifiers', 'ui_reset' => 'reset', 'ui_change_character' => 'Change Character', 
	'ui_music_player' => 'Preview'];

	public var icons:Array<FlxSprite> = [];
	public var iconText:FlxText;

	public function new(x:Float = 0, y:Float = 0, bindName:String = 'blank', bindIndex:Int = 0, translationText:String = 'blank', iconScale:Float = 0.15, textSize:Int = 24) {
		super(x, y);
		var keyBind:FlxKey = NONE;
		if (bindName != 'movement') {
			if (ClientPrefs.keyBinds.get(bindName) != null) keyBind = ClientPrefs.keyBinds.get(bindName)[bindIndex];
			if (keyBind == NONE && !FileSystem.exists(Paths.getSharedPath('images/' + getIconPath() + bindName.toUpperCase() + '.png'))) bindName = 'blank';
		}
		switch(bindName.toLowerCase()) {
			case 'movement':
				var left:String = ClientPrefs.keyBinds.get('ui_left')[bindIndex].toString();
				var down:String = ClientPrefs.keyBinds.get('ui_down')[bindIndex].toString();
				var up:String = ClientPrefs.keyBinds.get('ui_up')[bindIndex].toString();
				var right:String = ClientPrefs.keyBinds.get('ui_right')[bindIndex].toString();

				var iconLeft:FlxSprite = new FlxSprite(17, 0, Paths.image(getIconPath() + left));
				iconLeft.scale.set(iconScale, iconScale);
				iconLeft.updateHitbox();
				iconLeft.antialiasing = true;
				add(iconLeft);
				icons.push(iconLeft);

				var iconDown:FlxSprite = new FlxSprite(iconLeft.x + iconLeft.width + 10, 0, Paths.image(getIconPath() + down));
				iconDown.scale.set(iconScale, iconScale);
				iconDown.updateHitbox();
				iconDown.antialiasing = true;
				add(iconDown);
				icons.push(iconDown);

				var iconUp:FlxSprite = new FlxSprite(0, -40, Paths.image(getIconPath() + up));
				iconUp.scale.set(iconScale, iconScale);
				iconUp.updateHitbox();
				iconUp.x = iconDown.x + (iconDown.width - iconUp.width) / 2;
				iconUp.antialiasing = true;
				add(iconUp);
				icons.push(iconUp);

				var iconRight:FlxSprite = new FlxSprite(iconDown.x + iconDown.width + 10, 0, Paths.image(getIconPath() + right));
				iconRight.scale.set(iconScale, iconScale);
				iconRight.updateHitbox();
				iconRight.antialiasing = true;
				add(iconRight);
				icons.push(iconRight);

				iconText = new FlxText(iconRight.x + iconRight.width + 10, 5, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'), 24);
				iconText.setFormat("VCR OSD Mono", textSize, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
			case 'blank':
				var icon:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath() + 'keyboard-button-blank'));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + 10, 5, 0, 'NO BUTTON FOUND', 24);
				iconText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
			default:
				var icon:FlxSprite = new FlxSprite(0, 0, Paths.image(getIconPath() + (keyBind == NONE ? bindName.toUpperCase() : keyBind.toString())));
				icon.scale.set(iconScale, iconScale);
				icon.updateHitbox();
				icon.antialiasing = true;
				add(icon);
				icons.push(icon);

				iconText = new FlxText(width + 10, 5, 0, Language.getPhrase(translationText, defaultTranslations.get(translationText) ?? 'NO TRANSLATION FOUND'), 24);
				iconText.setFormat("VCR OSD Mono", textSize, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
				add(iconText);
		}
	}

	public static function getIconPath():String {
		return 'persona/ui/button-icons/keyboard/';
	}
}