package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;

enum abstract TileTypes(Int) to Int
{
	var VOID = 0;
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;
}

enum DEnemy
{
	MINI;
	FINAL;
	BEE;
	BAT;
	PLANT;
}

class Enemy extends FlxSprite
{
	var inCombat:Bool = false;
	var range:Int = 200;
	var enemyHealth:Int;

	var atkDamage:Int;

	public var bType:DEnemy;

	var onSight:FlxTween;

	public function new(x:Float, y:Float, type:DEnemy)
	{
		super(x, y);
		bType = type;

		switch (bType)
		{
			case MINI:
				loadGraphic(AssetPaths.CarnivorousPlantIdle__png);
				enemyHealth = 30;
				atkDamage = 8;

			case FINAL:
				loadGraphic(AssetPaths.QueenBeeTexture__png, true, 185, 160);
				animation.add("idle", [0, 1, 2, 3], 5, true);

				animation.play("idle");
				enemyHealth = 50;
				atkDamage = 10;

			case BAT:
				loadGraphic(AssetPaths.batFlappingTexture__png, true, 33, 30);
				solid = true;

				animation.add("idle", [0]);
				animation.play("idle");
				animation.add("flapping", [4, 1, 2, 3, 2, 1], 6, true);
				animation.add("flapRight", [8, 5, 6, 7, 6, 5], 6, true);
				enemyHealth = 6;
				atkDamage = 2;

			case BEE:
				loadGraphic(AssetPaths.beeFlapTexture__png, true, 40, 43);
				solid = true;
				animation.add("idle", [0, 1, 2, 3, 4], 4, true);
				animation.play("idle");
				animation.add("flaping", [0, 1, 2, 3], 4, true);
				enemyHealth = 15;
				atkDamage = 3;

			case PLANT:
				loadGraphic(AssetPaths.plantMove__png, true, 104, 107);
				solid = true;
				//	animation.add("idleGround", [3], 4, true);
				animation.add("gettingUp", [3, 4, 5, 6], 1, false);
				animation.add("move", [0, 1, 2], 1, true);
				enemyHealth = 15;
				atkDamage = 3;

				animation.finishCallback = function(name:String)
				{
					if (name != "gettingUp")
						return;
					animation.play("move");
				}
		}

		scale.set(0.5, 0.5);
		updateHitbox();
	}

	public function inRange(player:Player, enemy:FlxSprite):Bool
	{
		var distanceX:Float = player.x - enemy.x;
		var distanceY:Float = player.y - enemy.y;

		var total = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

		if (total <= 150)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public function getHealth()
	{
		return enemyHealth;
	}

	public function cancelTween()
	{
		onSight.cancel();
	}

	public function getAtkDamage()
	{
		return atkDamage;
	}
}
