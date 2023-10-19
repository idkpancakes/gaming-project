package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CombatState extends FlxState
{
	var player:Player;

	var bat:Bat;

	var text:FlxText;

	override public function create()
	{
		super.create();

		text = new flixel.text.FlxText(250, 250, FlxG.width, "Letsgo?", 64);
		add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
