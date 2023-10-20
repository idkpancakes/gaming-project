package;

import Weapons.WeaponType;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	public var weapon:Weapons = new Weapons(0, 0, WeaponType.EMPTY);

	var dungeonHealth = 3;
	var combatHealth = 10;

	// static inline var SPEED:Float = 100;
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.mainCharacterTexture__png, true, 67, 67);
		solid = true;

		scale.set(0.65, 0.65);
		updateHitbox();
		// drag.x = drag.y = 800;

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);

		animation.add("d_idle", [0]);
		animation.add("lr_idle", [5]);
		animation.add("u_idle", [11]);
		animation.add("d_walk", [1, 2, 3, 4], 4);
		animation.add("lr_walk", [5, 6, 7, 8, 9, 10], 6);
		animation.add("u_walk", [12, 13, 14, 15], 4);
	}

	public function charMovement(player:FlxSprite)
	{
		player.velocity.set(0, 0);

		if (FlxG.keys.pressed.D) // moving sprite to the right when D is pressed
		{
			player.animation.play("lr_walk");
			player.velocity.x = 100;
		}
		if (FlxG.keys.justReleased.D) // stopping movement once it is released
		{
			player.animation.play("lr_idle");
			player.velocity.x = 0;
		}
		if (FlxG.keys.pressed.A) // moving sprite move left when A is pressed
		{
			player.animation.play("lr_walk");
			player.velocity.x = -100;
		}
		if (FlxG.keys.justReleased.A) // stopping movement once A is released
		{
			player.animation.play("lr_idle");
			player.velocity.x = 0;
		}

		if (FlxG.keys.pressed.W) // moving sprite up when W is pressed
		{
			player.animation.play("u_walk");
			player.velocity.y = -100;
		}
		if (FlxG.keys.justReleased.W) // stopping movement once it is released
		{
			player.animation.play("u_idle");
			player.velocity.y = 0;
		}
		if (FlxG.keys.pressed.S) // moving sprite down when S is pressed
		{
			player.animation.play("d_walk");
			player.velocity.y = 200;
		}
		if (FlxG.keys.justReleased.S) // stopping movement once A is released
		{
			player.animation.play("d_idle");
			player.velocity.y = 0;
		}

		if (player.velocity.x > 0)
			player.facing = RIGHT;
		else
			player.facing = LEFT;
	}

	public function getDungeonHealth():Int
	{
		return dungeonHealth;
	}

	public function setDungeonHealth(newHealth:Int)
	{
		dungeonHealth = newHealth;
	}

	public function getCombatHealth():Int
	{
		return combatHealth;
	}

	public function setCombatHealth(newHealth:Int)
	{
		combatHealth = newHealth;
	}

	public function isDead():Bool
	{
		return dungeonHealth <= 0 || combatHealth <= 0;
	}

	override public function clone()
	{
		var _player = new Player(this.x, this.y);
		_player.weapon = this.weapon;
		_player.combatHealth = this.combatHealth;
		_player.dungeonHealth = this.dungeonHealth;

		return _player;
	}
}
