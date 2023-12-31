package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MenuState));

		var save = new FlxSave();
		save.bind("characterCode");
		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}
		save.close();
	}
}
