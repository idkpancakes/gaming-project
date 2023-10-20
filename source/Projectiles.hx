package;

import Enemy.ArrowType;
import Enemy.DEnemy;
import flixel.FlxSprite;
import haxe.Timer;

class Projectiles extends Enemy
{
	var pType:ArrowType;

	public function new(x:Float, y:Float, type:ArrowType)
	{
		super(x, y, PROJECTILE);
		pType = type;

		var graphic = if (pType == THORN) AssetPaths.Thorns__png else if (pType == STINGER) AssetPaths.Thorns__png else AssetPaths.Arrows_pack__png;
		loadGraphic(graphic);

		scale.set(1.5, 1.5);
	}
}
