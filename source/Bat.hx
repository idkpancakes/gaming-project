package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import haxe.Log;

enum DEnemy
{
	BEE;
	BAT;
	PLANT;
}

class Bat extends Enemy
{
	var enType:DEnemy;

	public function new(x:Float = 0, y:Float = 0, type:DEnemy)
	{
		super(x, y);

		enType = type;

		switch (enType)
		{
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

			case PLANT:
				loadGraphic(AssetPaths.plantManTexture__png, true, 104, 107);
				solid = true;
				animation.add("idle", [0], 4, true);
				animation.add("gettingUp", [0, 2, 3, 1], 4, true);
		}
	}

	public function attack(player:Player, enemy:Bat)
	{
		inRange(player, enemy);
		if (this.inCombat && enType == BEE || enType == BAT)
		{
			animation.play("flapping");
		}
		else if (this.inCombat && enType == PLANT)
		{
			enemy.cancelTween();
			animation.play("gettingUp");
		}
	}
}
