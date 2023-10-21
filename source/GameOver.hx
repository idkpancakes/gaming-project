package;

import flixel.FlxCamera;
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

	var center:FlxSprite;

	var menuCam:FlxCamera;

	override public function create()
	{
		super.create();

		restartButton = new FlxButton(0, 0, "Restart", clickRestart);
		restartButton.screenCenter();
		restartButton.scale.x = 2;
		restartButton.scale.y = 2;
		add(restartButton);

		retryButton = new FlxButton(restartButton.getPosition().x, restartButton.getPosition().y + 70, "Retry", clickRetry);
		retryButton.scale.x = 2;
		retryButton.scale.y = 2;
		add(retryButton);

		death = new FlxText(restartButton.getPosition().x - 40, restartButton.getPosition().y - 70, "You Died");
		death.setFormat(null, 30, FlxColor.PURPLE);
		add(death);

		center = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		center.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		center.alpha = 0;

		menuCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(menuCam);
		menuCam.target = center;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function clickRestart()
	{
		FlxG.switchState(new MenuState());
	}

	public function clickRetry()
	{
		close();
	}
}
