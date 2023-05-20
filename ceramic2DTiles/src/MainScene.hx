package;

import entities.LevelView;
import ceramic.Camera;
import entities.Character;
import ceramic.Scene;

using ceramic.TilemapPlugin;
using ceramic.VisualTransition;

class MainScene extends Scene {
	var ldtkName = Tilemaps.LEVEL;
	var levelView:LevelView = null;
	var player:Character;
	var camera:Camera;

	@observe var speed:Float = 2.5;
	@observe var playerWorldX:Float = 50;
	@observe var playerWorldY:Float = 50;

	override function preload() {
		assets.watchDirectory();
		assets.add(ldtkName);
		assets.add(Images.CROSS);
	}

	override function create() {
		// Called when scene has finished preloading

		player = new Character();

		autorun(() -> {
			var ldtkData = assets.ldtk(ldtkName);
			var level = ldtkData.worlds[0].levels[0];

			level.ensureLoaded(() -> {
				levelView = new LevelView(level.ceramicTilemap.tilesets[0]);
				levelView.depth = 1;
				if (levelView.parent == null)
					add(levelView);
				if (player.parent != levelView)
					levelView.add(player);

				initCamera();
				player.depth = 99999999999;
			});
		});
	}

	override function update(delta:Float) {
		if (player != null)
			player.update(delta, levelView.orientation);

		if (levelView != null)
			levelView.update(delta, player, levelView.orientation);

		if (Project.inputMap.justPressed(ROTATE_CLOCKWISE)) {
			levelView.orientation = switch levelView.orientation {
				case North: West;
				case South: East;
				case West: South;
				case East: North;
			};
			levelView.redraw(levelView.orientation);
		}
		if (Project.inputMap.justPressed(ROTATE_COUNTER_CLOCKWISE)) {
			levelView.orientation = switch levelView.orientation {
				case North: East;
				case South: West;
				case West: North;
				case East: South;
			};
			levelView.redraw(levelView.orientation);
		}
	}

	function initCamera() {
		// Configure camera
		camera = new Camera();

		// We tweak some camera settings to make it work
		// better with our low-res pixel art display
		// camera.movementThreshold = 25;
		camera.trackSpeedX = 200;
		camera.trackSpeedY = 200;
		camera.trackCurve = 0.3;
		camera.clampToContentBounds = false;
		camera.deadZoneX = 0;
		camera.deadZoneY = 0;
		// camera.brakeNearBounds(0, 0);

		// We update the camera after everything else has been updated
		// so that we are sure it won't be based on some intermediate state
		app.onPostUpdate(this, updateCamera);

		// Update the camera once right away
		// (we use a very big delta so that it starts at a stable position)
		updateCamera(99999);
	}

	function updateCamera(delta:Float) {
		// Tell the camera what is the size of the viewport
		camera.viewportWidth = width;
		camera.viewportHeight = height;

		// // Tell the camera what is the size and position of the content
		camera.contentX = 0;
		camera.contentY = 0;
		camera.contentWidth = screen.width;
		camera.contentHeight = screen.height;

		// Tell the camera what position to target (the player's position)
		camera.followTarget = true;
		camera.targetX = player.x;
		camera.targetY = player.y;

		// Then, let the camera handle these infos
		// so that it updates itself accordingly
		camera.update(delta);

		// Now that the camera has updated,
		// set the content position from the computed data
		levelView.x = camera.contentTranslateX;
		levelView.y = camera.contentTranslateY;
	}

	override function resize(width:Float, height:Float) {
		// Called everytime the scene size has changed
	}

	override function destroy() {
		// Perform any cleanup before final destroy

		super.destroy();
	}
}
