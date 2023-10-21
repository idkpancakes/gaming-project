package;

import Enemy.ArrowType;
import Enemy.DEnemy;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
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

		thorn = new Projectiles(x, y, ArrowType.THORN);
	}

	public function attack(player:Player, enemy:DungeonEnemy)
	{
		if (inRange(player, enemy))
		{
			animation.play("flapping");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);
		}
		else if (inRange(player, enemy) && bType == PLANT)
		{
			animation.play("gettingUp");
			onSight = FlxTween.tween(enemy, {x: player.getPosition().x, y: player.getPosition().y}, 2);
		}
	}

	public function bossAttack(player:Player, enemy:Enemy)
	{
		if (bossInRange(player, enemy))
		{
			if (thornTimer != null)
			{
				return;
			}
			thornTimer = new Timer(750);
			thornTimer.run = function()
			{
				var rand = FlxG.random.int(0, Math.floor(this.height));
				var thorn = new Projectiles(x, y + rand, ArrowType.STINGER);
				thorns.add(thorn);
				// thorn.solid = true;

				var playerPos = player.getMidpoint();
				var thornPos = thorn.getMidpoint();

				var vector = playerPos.subtractNew(thornPos);
				vector = vector.normalize();

				thorn.angle = thornPos.degreesFrom(playerPos);
				thorn.velocity.x = vector.x * 200;
				thorn.velocity.y = vector.y * 200;
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
		thorns.kill();
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
