package;

import Enemy.DEnemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import haxe.Timer;

class Boss extends Enemy
{
	// var bType:BossType;
	var thorn:Projectiles;
	var thornTimer:Timer;
	var thornMax:Int = 10;
	var thornCount:Int = 0;

	public var thorns:FlxTypedGroup<Projectiles> = new FlxTypedGroup<Projectiles>();

	public function new(x:Float, y:Float, type:DEnemy)
	{
		super(x, y, type);

		thorns = new FlxTypedGroup<Projectiles>();

		thorn = new Projectiles(x, y, THORN);
	}

	public function attack(player:Player, enemy:Enemy)
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
		thornTimer.stop();
	}
}
