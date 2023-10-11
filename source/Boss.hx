package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

enum BossType
{
	MINI;
	FINAL;
}

class Boss extends Enemy
{
	var bType:BossType;
	var thorn:Projectiles;
	var thornT:FlxTween;

	public function new(x:Float, y:Float, type:BossType)
	{
		super(x, y);
		bType = type;
		var graphic = if (bType == MINI) AssetPaths.CarnivorousPlantIdle__png else AssetPaths.QueenBeeTexture__png;
		loadGraphic(graphic);

		scale.set(0.5, 0.5);
		updateHitbox();

		thorn = new Projectiles(x, y, THORN);
	}

	public function attack(player:Player, enemy:Enemy)
	{
		thorn.attack(player, thorn);
	}

	public function getThorn():FlxSprite
	{
		return thorn;
	}
}
