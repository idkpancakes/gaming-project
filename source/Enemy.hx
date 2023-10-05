package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class Enemy extends FlxSprite
{
	var inCombat:Bool;
	var range:Int = 200;

	var onSight:FlxTween;

	public function inRange(player:Player, enemy:Enemy):Float
	{
		var distanceX:Float = player.x - enemy.x;
		var distanceY:Float = player.y - enemy.y;

		var total = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
		return total;

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
}
