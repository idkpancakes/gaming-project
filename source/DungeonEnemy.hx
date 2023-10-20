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
		if (inRange(player, enemy))
		{
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			// if (FlxG.overlap(player, enemy))
			// {
			// 	FlxG.switchState(new CombatState(player, new Enemy(0, 0, this.bType)));
			// }
			animation.play("flapping");
		}
		else if (inRange(player, enemy) && bType == PLANT)
		{
			animation.play("gettingUp");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			// if (FlxG.overlap(player, enemy))
			// {
			// 	FlxG.switchState(new CombatState(player, new Enemy(0, 0, this.bType)));
			// }
		}
	}

	public function getType()
	{
		return bType;
	}

	override public function clone()
	{
		return new DungeonEnemy(this.x, this.y, this.bType);
	}
}
