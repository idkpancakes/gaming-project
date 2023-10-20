package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Log;

enum WeaponType
{
	GUN;
	CHAINSAW;
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
		graphicPath = if (type == GUN) AssetPaths.MachineGuns__png else if (type == CHAINSAW) AssetPaths.chainsaw__png else null;
		loadGraphic(graphicPath);
	}
}
