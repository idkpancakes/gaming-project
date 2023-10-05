package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class Bat extends Enemy
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.batFlappingTexture__png, true, 33, 30);
		solid = true;

		animation.add("idle", [0]);
		animation.add("flapLeft", [4, 1, 2, 3, 2, 1], 6, true);
		animation.add("flapRight", [8, 5, 6, 7, 6, 5], 6, true);
	}

	public function attack(player:Player, enemy:Enemy)
	{
		inRange(player, enemy);

		animation.play("flapLeft");
	}
}
