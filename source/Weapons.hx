package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Log;

enum WeaponType
{
	GUN;
	CHAINSAW;
	BOW;
	SWORD;
	MAGIC;
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
				graphicPath = AssetPaths.MachineGuns__png;
				damage = 11;
			case CHAINSAW:
				loadGraphic(AssetPaths.chainsaw__png);
				graphicPath = AssetPaths.chainsaw__png;
				damage = 6;
			case BOW:
				loadGraphic(AssetPaths.bowAndArrow__png);
				graphicPath = AssetPaths.bowAndArrow__png;
				damage = 2;
			case SWORD:
				loadGraphic(AssetPaths.sword__png);
				graphicPath = AssetPaths.sword__png;
				damage = 8;
			case MAGIC:
				loadGraphic(AssetPaths.magicScroll__png);
				damage = 5;
			case EMPTY:
				damage = 1;
				null;
		}
	}

	public function getDamage()
	{
		return damage;
	}
}
