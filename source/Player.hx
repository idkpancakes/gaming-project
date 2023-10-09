package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	// var weapon:Weapons;
	// static inline var SPEED:Float = 100;
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		makeGraphic(8, 8, FlxColor.RED);
		// loadGraphic(AssetPaths.mainCharacterTexture__png, true, 22, 42);
		solid = true;

		// scale.x = 2;
		// scale.y = 2;
		// drag.x = drag.y = 800;

		// setFacingFlip(LEFT, false, false);
		// setFacingFlip(RIGHT, true, false);

		// animation.add("standingLeft", [0], 5, true);
		// animation.add("standingRight", [9], 5, true);
		// animation.add("standingUP", [18], 5, true);
		// animation.add("standingDown", [21], 5, true);

		// animation.add("runLeft", [1, 2], 5, true);
		// animation.add("runRight", [10, 11], 5, true);

		// animation.add("runUp", [18, 19], 5, true);
		// animation.add("crouchUp", [20], 5, true);
		// animation.add("runDown", [21, 22], 5, true);

		// animation.add("attackLeft", [4, 5], 5, true);
		// animation.add("attackRight", [13, 14], 5, true);

		// animation.add("hitLeft", [6], 5, true);
		// animation.add("hitRight", [15], 5, true);

		// animation.add("crouchLeft", [7], 5, true);
		// animation.add("crouchRight", [16], 5, true);

		// animation.add("deadLeft", [8], 5, true);
		// animation.add("deadRight", [17], 5, true);
	}

	public function charMovement()
	{
		if (FlxG.keys.pressed.D) // moving sprite to the right when D is pressed
		{
			// sprite.animation.play("runLeft");
			velocity.x = 32;
		}
		if (FlxG.keys.justReleased.D) // stopping movement once it is released
		{
			// sprite.animation.play("standingLeft");
			velocity.x = 0;
		}
		if (FlxG.keys.pressed.A) // moving sprite move left when A is pressed
		{
			// sprite.animation.play("runLeft");
			velocity.x = -32;
		}
		if (FlxG.keys.justReleased.A) // stopping movement once A is released
		{
			// sprite.animation.play("standingLeft");
			velocity.x = 0;
		}

		if (FlxG.keys.pressed.W) // moving sprite up when W is pressed
		{
			// sprite.animation.play("runUp");
			velocity.y = -32;
		}
		if (FlxG.keys.justReleased.W) // stopping movement once it is released
		{
			// sprite.animation.play("standingUP");
			velocity.y = 0;
		}
		if (FlxG.keys.pressed.S) // moving sprite down when S is pressed
		{
			// sprite.animation.play("runDown");
			velocity.y = 32;
		}
		if (FlxG.keys.justReleased.S) // stopping movement once A is released
		{
			// sprite.animation.play("standingDown");
			velocity.y = 0;
		}

		if (velocity.x > 0)
			facing = RIGHT;
		else
			facing = LEFT;
	}
}
