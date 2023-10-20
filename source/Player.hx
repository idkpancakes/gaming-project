package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;

class Player extends FlxSprite
{
	var weapon:Weapons;

	var dungeonHealth = 3;

	var stepSound:FlxSound; // Variable for sound effects

	static inline var SPEED:Float = 100;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.mainCharacter__png, true, 64, 64);

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		animation.add("d_idle", [26]);
		animation.add("lr_idle", [26]);
		animation.add("u_idle", [26]);
		animation.add("d_walk", [130, 131, 132, 133, 134, 135, 136, 137], 6);
		animation.add("lr_walk", [143, 144, 145, 146, 147, 148, 149], 6);
		animation.add("u_walk", [52, 53, 54, 55, 56, 57, 58], 6);

		drag.x = drag.y = 800;
		setSize(8, 8);
		offset.set(4, 8);

		stepSound = FlxG.sound.load(AssetPaths.Footsteps__wav);
	}

	override function update(elapsed:Float)
	{
		updateMovement();
		super.update(elapsed);
	}

	public function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// FlxG keyboard
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up || down || left || right)
		{
			var newAngle:Float = 0;
			if (up)
			{
				newAngle = -90;
				if (left)
					newAngle -= 45;
				else if (right)
					newAngle += 45;
				facing = UP;
			}
			else if (down)
			{
				newAngle = 90;
				if (left)
					newAngle += 45;
				else if (right)
					newAngle -= 45;
				facing = DOWN;
			}
			else if (left)
			{
				newAngle = 180;
				facing = RIGHT;
			}
			else if (right)
			{
				newAngle = 0;
				facing = LEFT;
			}

			// determine our velocity based on angle and speed
			velocity.setPolarDegrees(SPEED, newAngle);
		}

		var action = "idle";
		// check if the player is moving, and not walking into walls
		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			stepSound.play();
			action = "walk";
		}
		else
		{
			stepSound.stop();
		}

		switch (facing)
		{
			case LEFT, RIGHT:
				animation.play("lr_" + action);
			case UP:
				animation.play("u_" + action);
			case DOWN:
				animation.play("d_" + action);
			case _:
		}
	}

	public function getDungeonHealth():Int
	{
		return dungeonHealth;
	}

	public function setDungeonHealth(newHealth:Int)
	{
		dungeonHealth = newHealth;
	}

	public function isDead():Bool
	{
		return dungeonHealth <= 0;
	}
}
