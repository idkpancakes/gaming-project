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
	var inCombat:Bool = false;
	var range:Int = 200;

	var onSight:FlxTween;

	public function inRange(player:Player, enemy:FlxSprite):Bool
	{
		var distanceX:Float = player.x - enemy.x;
		var distanceY:Float = player.y - enemy.y;

		var total = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

		if (total <= 250)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public function cancelTween()
	{
		onSight.cancel();
	}
}