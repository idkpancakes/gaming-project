package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	public static var virtualPad(default, null):{buttonUp:{pressed:Bool}, buttonRight:{pressed:Bool}, buttonLeft:{pressed:Bool}, buttonDown:{pressed:Bool}};

	var gameName:FlxText;

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}