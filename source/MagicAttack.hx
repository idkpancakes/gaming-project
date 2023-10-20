package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Log;

enum MagicType
{
	FIRE;
	WATER;
	NOSCROLL;
}

class MagicAttack extends FlxSprite
{
	var magDamage:Int;

	public var mGraphicPath:String;
	public var type:MagicType;

	public function new(x:Float, y:Float, type:MagicType)
	{
		super(x, y);
		this.type = type;

		switch (type)
		{
			case FIRE:
				loadGraphic(AssetPaths.magicScrollFire__png);
				mGraphicPath = AssetPaths.magicScrollFire__png;

				magDamage = 5;
			case WATER:
				loadGraphic(AssetPaths.magicScrollWater__png);
				mGraphicPath = AssetPaths.magicScrollWater__png;
				magDamage = 5;

			case NOSCROLL:
				magDamage = 0;
				null;
		}
		scale.set(0.5, 0.5);
	}

	public function getMagDamage()
	{
		return magDamage;
	}
}
