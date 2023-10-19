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
}

class Enemy extends FlxSprite
{
	var inCombat:Bool = false;
	var range:Int = 200;

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

			case FINAL:
				loadGraphic(AssetPaths.QueenBeeTexture__png, true, 185, 160);
				animation.add("idle", [0, 1, 2, 3], 5, true);

				animation.play("idle");

			case BAT:
				loadGraphic(AssetPaths.batFlappingTexture__png, true, 33, 30);
				solid = true;

				animation.add("idle", [0]);
				animation.play("idle");
				animation.add("flapping", [4, 1, 2, 3, 2, 1], 6, true);
				animation.add("flapRight", [8, 5, 6, 7, 6, 5], 6, true);

			case BEE:
				loadGraphic(AssetPaths.beeFlapTexture__png, true, 42, 43);
				solid = true;
				animation.add("idle", [0, 1, 2, 3, 4], 4, true);
				animation.play("idle");
				animation.add("flaping", [0, 1, 2, 3], 4, true);
		}

		scale.set(0.5, 0.5);
		updateHitbox();
	}

	public function inRange(player:Player, enemy:Enemy)
	{
		var distanceX:Float = player.x - enemy.x;
		var distanceY:Float = player.y - enemy.y;

		var total = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

		if (total <= 250)
		{
			this.inCombat = true;
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			if (FlxG.collide(player, enemy))
			{
				FlxG.switchState(new CombatState(player, enemy));
			}
		}
	}
}
