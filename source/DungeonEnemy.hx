package;

import Enemy.DEnemy;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import haxe.Log;

class DungeonEnemy extends Enemy
{
	// var enType:DEnemy;
	public function new(x:Float = 0, y:Float = 0, type:DEnemy)
	{
		super(x, y, type);
	}

	public function attack(player:Player, enemy:DungeonEnemy)
	{
		if (inRange(player, enemy) && bType == BEE || bType == BAT)
		{
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			if (FlxG.collide(player, enemy))
			{
				FlxG.switchState(new CombatState(player, enemy));
			}
			animation.play("flapping");
		}
		else if (inRange(player, enemy) && bType == PLANT)
		{
			animation.play("gettingUp");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			if (FlxG.collide(player, enemy))
			{
				FlxG.switchState(new CombatState(player, enemy));
			}
		}
	}
}
