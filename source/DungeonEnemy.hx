package;

import Enemy.DEnemy;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.path.FlxPath;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import haxe.Log;
import haxe.Timer;

class DungeonEnemy extends Enemy
{
	// var bType:BossType;
	var thorn:Projectiles;
	var thornTimer:Timer;
	var thornMax:Int = 10;
	var thornCount:Int = 0;

	public var thorns:FlxTypedGroup<Projectiles> = new FlxTypedGroup<Projectiles>();

	// var enType:DEnemy;
	public function new(x:Float = 0, y:Float = 0, type:DEnemy)
	{
		super(x, y, type);

		thorns = new FlxTypedGroup<Projectiles>();

		thorn = new Projectiles(x, y, THORN);
	}

	public function attack(player:Player, enemy:DungeonEnemy)
	{
		if (inRange(player, enemy))
		{
			animation.play("flapping");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			// var _path = new FlxPath();
			// var pathPoints = tileMap.findPath(enemy.getPosition(), player.getPosition(), RAY, NORMAL);

			// if (pathPoints == null)
			// 	return;

			// enemy.path = _path;
			// path.start(pathPoints, 50, FORWARD);

			// if (FlxG.overlap(player, enemy))

			// {
			// 	FlxG.switchState(new CombatState(player, new Enemy(0, 0, this.bType)));
			// }
		}
		else if (inRange(player, enemy) && bType == PLANT)
		{
			animation.play("gettingUp");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);

			// var _path = new FlxPath();
			// var pathPoints = tileMap.findPath(enemy.getPosition(), player.getPosition(), RAY, NORMAL);

			// if (enemy.path != null)
			// 	enemy.path.cancel();
			// enemy.path = _path;
			// path.start(pathPoints, 50, FORWARD);

			// if (FlxG.overlap(player, enemy))
			// {
			// 	FlxG.switchState(new CombatState(player, new Enemy(0, 0, this.bType)));
			// }
		}
	}

	public function bossAttack(player:Player, enemy:Enemy)
	{
		if (thornTimer != null)
		{
			return;
		}
		thornTimer = new Timer(1000);
		thornTimer.run = function()
		{
			var rand = FlxG.random.int(0, Math.floor(this.height));
			var thorn = new Projectiles(x, y + rand, THORN);
			thorns.add(thorn);
			// thorn.solid = true;
			thorn.velocity.x = -200;
			thornCount++;

			if (thornCount >= thornMax)
			{
				thornTimer.stop();
			}
		}
	}

	public function getThorns():FlxTypedGroup<Projectiles>
	{
		return thorns;
	}

	override public function destroy()
	{
		super.destroy();

		if (thornTimer != null)
			thornTimer.stop();
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
