package;

import flixel.FlxSprite;

class Player extends FlxSprite
{
	// static inline var SPEED:Float = 100;
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.mainCharacterTexture__png, true, 22, 42);
		solid = true;
		// drag.x = drag.y = 800;

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);

		animation.add("standingLeft", [0], 5, true);
		animation.add("standingRight", [9], 5, true);
		animation.add("standingUP", [18], 5, true);
		animation.add("standingDown", [21], 5, true);

		animation.add("runLeft", [1, 2], 5, true);
		animation.add("runRight", [10, 11], 5, true);

		animation.add("runUp", [18, 19], 5, true);
		animation.add("crouchUp", [20], 5, true);
		animation.add("runDown", [21, 22], 5, true);

		animation.add("attackLeft", [4, 5], 5, true);
		animation.add("attackRight", [13, 14], 5, true);

		animation.add("hitLeft", [6], 5, true);
		animation.add("hitRight", [15], 5, true);

		animation.add("crouchLeft", [7], 5, true);
		animation.add("crouchRight", [16], 5, true);

		animation.add("deadLeft", [8], 5, true);
		animation.add("deadRight", [17], 5, true);
	}
}
