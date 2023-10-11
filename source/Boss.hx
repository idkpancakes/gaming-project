package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import haxe.Timer;
import js.html.AbortController;

enum BossType
{
	MINI;
	FINAL;
}

class Boss extends Enemy
{
	var bType:BossType;
	var thorn:Projectiles;
	var thornTimer:Timer;
	var thornMax:Int = 10;
	var thornCount:Int = 0;

	var thorns:FlxTypedGroup<Projectiles>;

	public function new(x:Float, y:Float, type:BossType)
	{
		super(x, y);
		bType = type;
		var graphic = if (bType == MINI) AssetPaths.CarnivorousPlantIdle__png else AssetPaths.QueenBeeTexture__png;
		loadGraphic(graphic);

		scale.set(0.5, 0.5);
		updateHitbox();

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
}
