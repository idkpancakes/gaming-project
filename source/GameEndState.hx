package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class GameEndState extends FlxState
{
	var storyText:FlxText;
	var endText:FlxText;
	var background:FlxSprite;

	var back:FlxButton;

	override public function create()
	{
		endText = new FlxText(10, 50, 600, "The Swarm Defeated!");
		endText.setFormat(null, 30, FlxColor.RED, FlxTextAlign.CENTER);

		storyText = new FlxText(90, 100, 400,
			"With the demise of the Bee Empire, the world slowy returned to normal as the last remaining hummans started to rebuild. 
                                            However, a father was still cursed to roam the earth alone");

		storyText.setFormat(null, 20, FlxColor.GREEN, FlxTextAlign.CENTER);
		background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.end_screen_bg__png);
		// background.alpha = 0.5;

		back = new FlxButton(10, 470, "Back", switchToMenu);

		add(background);
		add(storyText);

		back = new FlxButton(10, 300, "Back", switchToMenu);
		add(back);
		add(endText);

		storyText = new FlxText("");
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function switchToMenu()
	{
		FlxG.switchState(new MenuState());
	}
}
