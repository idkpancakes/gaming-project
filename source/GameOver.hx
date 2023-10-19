package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class GameOver extends FlxSubState
{
	var restartButton:FlxButton;
	var retryButton:FlxButton;
	var death:FlxText;
	var player:Player;

	override public function create()
	{
		death = new FlxText(250, 50, "You Died");
		death.setFormat(null, 30, FlxColor.PURPLE);
		add(death);

		restartButton = new FlxButton(0, 0, "Restart", clickRestart);
		restartButton.screenCenter();
		restartButton.scale.x = 2;
		restartButton.scale.y = 2;
		add(restartButton);

		retryButton = new FlxButton(restartButton.getPosition().x, restartButton.getPosition().y + 70, "Retry", clickRetry);
		retryButton.scale.x = 2;
		retryButton.scale.y = 2;
		add(retryButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function clickRestart()
	{
		Player.setDungeonHealth(3);
		FlxG.switchState(new MenuState());
	}

	public function clickRetry()
	{
		close();
		Player.setDungeonHealth(3);
	}
}
