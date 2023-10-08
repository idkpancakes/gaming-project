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

class Enemy extends FlxSprite
{
	var inCombat:Bool;
	var range:Int = 100;

	var onSight:FlxTween;

	public function inRange(player:Player, enemy:Enemy)
	{
		var distanceX:Float = player.x - enemy.x;
		var distanceY:Float = player.y - enemy.y;

		var total = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

		if (total <= enemy.range)
		{
			inCombat = true;
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			if (FlxG.collide(player, enemy))
			{
				var text = new flixel.text.FlxText(250, 250, FlxG.width, "Letsgo?", 64);
			}
		}
	}

	public function placeEnemy(tileMap:FlxTilemap)
	{
		var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)));
		this.x = startPoint.x;
		this.y = startPoint.y;
	}
}
