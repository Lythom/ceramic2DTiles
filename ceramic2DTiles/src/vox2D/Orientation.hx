package vox2D;

enum Orientation {
	North;
	South;
	West;
	East;
}

class OrientationHelper {
	public static function worldToViewX(orientation:Orientation, xValue:Float, yValue:Float):Float {
		return switch orientation {
			case North: xValue;
			case South: -xValue;
			case West: yValue;
			case East: -yValue;
		}
	}

	public static function worldToViewY(orientation:Orientation, xValue:Float, yValue:Float):Float {
		return switch orientation {
			case North: yValue;
			case South: -yValue;
			case West: -xValue;
			case East: xValue;
		}
	}

	public static function viewToWorldX(orientation:Orientation, xValue:Float, yValue:Float):Float {
		return switch orientation {
			case North: xValue;
			case South: -xValue;
			case West: -yValue;
			case East: yValue;
		}
	}

	public static function viewToWorldY(orientation:Orientation, xValue:Float, yValue:Float):Float {
		return switch orientation {
			case North: yValue;
			case South: -yValue;
			case West: xValue;
			case East: -xValue;
		}
	}

	public static function getAngle(orientation:Orientation):Float {
		return switch orientation {
			case North: 0;
			case South: 180;
			case West: 90;
			case East: 270;
		}
	}
}
