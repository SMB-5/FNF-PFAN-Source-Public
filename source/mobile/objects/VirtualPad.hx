package mobile.objects;

import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import mobile.backend.MobileData;
import mobile.input.MobileInputID;
import mobile.input.MobileInputManager;
import mobile.objects.TouchButton;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 *
 * @author Ka Wing Chin
 * @modification melodiekit
 */
class VirtualPad extends MobileInputManager
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT, MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN, MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.UP, MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT, MobileInputID.NOTE_RIGHT]);
	public var buttonA:TouchButton = new TouchButton(0, 0, [MobileInputID.A]);
	public var buttonB:TouchButton = new TouchButton(0, 0, [MobileInputID.B]);
	public var buttonC:TouchButton = new TouchButton(0, 0, [MobileInputID.C]);
	public var buttonY:TouchButton = new TouchButton(0, 0, [MobileInputID.Y]);
	public var buttonX:TouchButton = new TouchButton(0, 0, [MobileInputID.X]);

	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(?DPad:FlxDPadMode, ?Action:FlxActionMode)
	{
		super();
		scrollFactor.set();

		if (DPad == null)
			DPad = LEFT_FULL;
		if (Action == null)
			Action = A_B_C;

		var storedKeys:Map<String, MobileInputID> = [];
		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) storedKeys.set(button, spr.IDs);
		}

		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 248, 132, 127, "up"));
				add(buttonDown = createButton(0, FlxG.height - 124, 132, 127, "down"));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 133, 132, 127, "left"));
				add(buttonRight = createButton(127, FlxG.height - 133, 132, 127, "right"));
			case LEFT_FULL:
				add(buttonUp = createButton(98, FlxG.height - 315, 132, 127, "up"));
				add(buttonLeft = createButton(0, FlxG.height - 220, 132, 127, "left"));
				add(buttonRight = createButton(196, FlxG.height - 220, 132, 127, "right"));
				add(buttonDown = createButton(98, FlxG.height - 124, 132, 127, "down"));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 225, FlxG.height - 316, 132, 127, "up"));
				add(buttonLeft = createButton(FlxG.width - 328, FlxG.height - 220, 132, 127, "left"));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 220, 132, 127, "right"));
				add(buttonDown = createButton(FlxG.width - 225, FlxG.height - 124, 132, 127, "down"));
			case CUSTOM:
				add(buttonUp = createButton(98, FlxG.height - 315, 132, 127, "up"));
				add(buttonLeft = createButton(0, FlxG.height - 220, 132, 127, "left"));
				add(buttonRight = createButton(196, FlxG.height - 220, 132, 127, "right"));
				add(buttonDown = createButton(98, FlxG.height - 124, 132, 127, "down"));
				MobileData.loadCustomPad(this);
			case NONE:
		}

		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a"));
			case A_B:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a"));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b"));
			case A_B_C:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a"));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b"));
				add(buttonC = createButton(FlxG.width - 396, FlxG.height - 127, 132, 127, "c"));
			case A_B_X_Y:
				add(buttonY = createButton(FlxG.width - 264, FlxG.height - 254, 132, 127, "y"));
				add(buttonX = createButton(FlxG.width - 132, FlxG.height - 254, 132, 127, "x"));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b"));
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a"));
			case NONE:
		}

		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) spr.IDs = storedKeys.get(button);
		}
		updateTrackedButtons();
	}

	override public function destroy():Void
	{
		super.destroy();

		buttonA = null;
		buttonB = null;
		buttonC = null;
		buttonY = null;
		buttonX = null;
		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;
	}

	/**
	 * @param   X          The x-position of the button.
	 * @param   Y          The y-position of the button.
	 * @param   Width      The width of the button.
	 * @param   Height     The height of the button.
	 * @param   Graphic    The image of the button. It must contains 3 frames (`NORMAL`, `HIGHLIGHT`, `PRESSED`).
	 * @return  The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String):TouchButton
	{
		var button = new TouchButton(X, Y);
		button.frames = FlxTileFrames.fromFrame(Paths.getSparrowAtlas('virtualpad').getByName(Graphic), FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();

		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		button.onDown.callback = function() {
			onPressed.dispatch(button);
		}

		button.onOut.callback = button.onUp.callback = function() {
			onReleased.dispatch(button);
		}

		return button;
	}
}

enum FlxDPadMode
{
	NONE;
	UP_DOWN;
	LEFT_RIGHT;
	LEFT_FULL;
	RIGHT_FULL;
	CUSTOM;
}

enum FlxActionMode
{
	NONE;
	A;
	A_B;
	A_B_C;
	A_B_X_Y;
}