package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Log;

enum WeaponType
{
	GUN;
	CHAINSAW;
	BOW;
	EMPTY;
}

class Weapons extends FlxSprite
{
	var damage:Int;

	public var graphicPath:String;

	public var type:WeaponType;

	public function new(x:Float, y:Float, type:WeaponType)
	{
		super(x, y);
		this.type = type;

		switch (type)
		{
			case GUN:
				loadGraphic(AssetPaths.MachineGuns__png);
			case CHAINSAW:
				loadGraphic(AssetPaths.chainsaw__png);
			case BOW:
				loadGraphic(AssetPaths.bowAndArrow__png);
			case EMPTY:
				null;
		}
	}
}
