package entities;

import ceramic.Quad;

class Character extends Quad {
	public var speed:Float;

	public function new() {
		super();
		x = 400;
		y = 400;
		speed = 200;
		width = 50;
		height = 50;
		texture = Project.assets.imageAsset(Images.CROSS).texture;
	}

	public function update(delta:Float) {
		// Here, you can add code that will be executed at every frame
		if (Project.inputMap.pressed(LEFT))
			x -= speed * delta;
		if (Project.inputMap.pressed(RIGHT))
			x += speed * delta;
		if (Project.inputMap.pressed(UP))
			y -= speed * delta;
		if (Project.inputMap.pressed(DOWN))
			y += speed * delta;
	}
}
