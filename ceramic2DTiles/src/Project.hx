package;

import ceramic.Entity;
import ceramic.Color;
import ceramic.InitSettings;
import ceramic.Assets;
import ceramic.InputMap;

enum abstract PlayerInput(Int) {
	var RIGHT;
	var LEFT;
	var DOWN;
	var UP;
	var JUMP;
	var ROTATE_CLOCKWISE;
	var ROTATE_COUNTER_CLOCKWISE;
}

class Project extends Entity {
	public static var inputMap:InputMap<PlayerInput>;
	public static var assets:Assets = new Assets();

	public static var cellWidth:Int = 16;
	public static var cellHeight:Int = 16;

	function new(settings:InitSettings) {
		super();

		settings.antialiasing = 2;
		settings.background = Color.BLACK;
		settings.targetWidth = 1280;
		settings.targetHeight = 800;
		settings.scaling = FIT;
		settings.resizable = true;

		app.onceReady(this, ready);

		assets.add(Images.CROSS);
	}

	function ready() {
		inputMap = new InputMap<PlayerInput>();
		bindInputs();
		assets.load();

		// Set MainScene as the current scene (see MainScene.hx)
		app.scenes.main = new MainScene();
	}

	function bindInputs() {
		// Bind keyboard
		//
		inputMap.bindKeyCode(RIGHT, RIGHT);
		inputMap.bindKeyCode(LEFT, LEFT);
		inputMap.bindKeyCode(DOWN, DOWN);
		inputMap.bindKeyCode(UP, UP);
		inputMap.bindKeyCode(JUMP, SPACE);
		inputMap.bindKeyCode(ROTATE_COUNTER_CLOCKWISE, LCTRL);
		inputMap.bindKeyCode(ROTATE_CLOCKWISE, KP_0);
		// We use scan code for these so that it
		// will work with non-qwerty layouts as well
		inputMap.bindScanCode(RIGHT, KEY_D);
		inputMap.bindScanCode(LEFT, KEY_A);
		inputMap.bindScanCode(DOWN, KEY_S);
		inputMap.bindScanCode(UP, KEY_W);
		inputMap.bindScanCode(ROTATE_COUNTER_CLOCKWISE, KEY_Q);
		inputMap.bindScanCode(ROTATE_CLOCKWISE, KEY_E);

		// Bind gamepad
		//
		inputMap.bindGamepadAxisToButton(RIGHT, LEFT_X, 0.25);
		inputMap.bindGamepadAxisToButton(LEFT, LEFT_X, -0.25);
		inputMap.bindGamepadAxisToButton(DOWN, LEFT_Y, 0.25);
		inputMap.bindGamepadAxisToButton(UP, LEFT_Y, -0.25);
		inputMap.bindGamepadButton(RIGHT, DPAD_RIGHT);
		inputMap.bindGamepadButton(LEFT, DPAD_LEFT);
		inputMap.bindGamepadButton(DOWN, DPAD_DOWN);
		inputMap.bindGamepadButton(UP, DPAD_UP);
		inputMap.bindGamepadButton(JUMP, A);
		inputMap.bindGamepadButton(ROTATE_COUNTER_CLOCKWISE, L1);
		inputMap.bindGamepadButton(ROTATE_CLOCKWISE, R1);
	}
}
