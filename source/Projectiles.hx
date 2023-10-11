package;

import flixel.FlxSprite;

enum ArrowType
{
	THORN;
	STINGER;
	ARROW;
}

class Projectiles extends Enemy
{
	var pType:ArrowType;

	public function new(x:Float, y:Float, type:ArrowType)
	{
		super(x, y);
		pType = type;

		var graphic = if (pType == THORN) AssetPaths.Thorns__png else if (pType == STINGER) AssetPaths.Thorns__png else AssetPaths.Arrows_pack__png;
		loadGraphic(graphic);

		scale.set(2, 2);

		visible = false;
	}

	public function attack(player:Player, enemy:Enemy)
	{
		visible = true;
		inRange(player, enemy);
	}
}
