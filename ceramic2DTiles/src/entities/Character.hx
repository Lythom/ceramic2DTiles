package entities;

import vox2D.Orientation;
import ceramic.Quad;

class Character extends Quad {
	public var worldX:Float = 0;
	public var worldY:Float = 0;

	public var speed:Float;

	public function new() {
		super();
		x = 0;
		y = 0;
		speed = 200;
		width = 50;
		height = 50;
		texture = Project.assets.imageAsset(Images.CROSS).texture;
	}

	public function update(delta:Float, orientation:Orientation) {
		// Here, you can add code that will be executed at every frame
		var dX:Float = 0;
		var dY:Float = 0;
		if (Project.inputMap.pressed(LEFT))
			worldX -= speed * delta;
		if (Project.inputMap.pressed(RIGHT))
			worldX += speed * delta;
		if (Project.inputMap.pressed(UP))
			worldY -= speed * delta;
		if (Project.inputMap.pressed(DOWN))
			worldY += speed * delta;

		x = OrientationHelper.worldToViewX(orientation, worldX, worldY);
		y = OrientationHelper.worldToViewY(orientation, worldX, worldY) - 3 * Project.cellHeight * 0.6;
	}
}
