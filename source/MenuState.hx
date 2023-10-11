package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
	var playButton:FlxButton;
	var storyText:FlxText;

	override public function create()
	{
		super.create();

		storyText = new FlxText(0, 0, FlxG.width - 40);
		storyText.text = "There once was a bee! and it did things and stuff and stuff and things and things.";
		storyText.screenCenter();

		add(storyText);

		playButton = new FlxButton(250, 250, "Play", clickPlay);
		add(playButton);
	}

	override public function update(elapsed:Float)
	{
		storyText.y--;
		super.update(elapsed);
	}

	public function clickPlay()
	{
		FlxG.switchState(new TestState());
	}
}
