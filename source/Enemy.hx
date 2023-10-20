package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;

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
	var stepSound:FlxSound;

	var onSight:FlxTween;

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

		//Step sound for enemy but only 50% of volume since there will be many enemies
		stepSound = FlxG.sound.load(AssetPaths.Footsteps__wav, 0.5);
		stepSound.proximity(x, y, FlxG.camera.target, FlxG.width * 0.6);
	}
}
