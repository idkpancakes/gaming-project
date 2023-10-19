package;

import Enemy.DEnemy;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import haxe.Log;

class Bat extends Enemy
{
	// var enType:DEnemy;
	public function new(x:Float = 0, y:Float = 0, type:DEnemy)
	{
		super(x, y, type);
	}

	public function attack(player:Player, enemy:Bat)
	{
		inRange(player, enemy);
		if (this.inCombat)
		{
			animation.play("flapping");
		}
	}
}
