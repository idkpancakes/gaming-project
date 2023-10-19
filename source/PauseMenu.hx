package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxSlider;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PauseMenu extends FlxSubState
{
	var title:FlxText;
	var volumeText:FlxText;
	var resolutionText:FlxText;
	var fullScreenText:FlxText;
	var back:FlxButton;

	var volumeSlider:FlxSlider;
	var resolutionArray = [1, 2, 3, 4];

	var checkBox:FlxButtonPlus;
	var leftButton:FlxButtonPlus;
	var rightButton:FlxButtonPlus;

	var volume:Int = 0;

	public function new()
	{
		super(0x33000000);
	}

	override public function create()
	{
		title = new FlxText(250, 50, "Options");
		title.setFormat(null, 30, FlxColor.PURPLE);
		add(title);

		volumeText = new FlxText(50, 150, "Volume:");
		volumeText.setFormat(null, 20, FlxColor.RED);
		add(volumeText);

		volumeSlider = new FlxSlider(FlxG.sound, "volume", 200, 150, 0, 100, 300, 50, 10, FlxColor.RED, FlxColor.PURPLE);
		volumeSlider.nameLabel.visible = false;
		volumeSlider.y -= (volumeSlider.handle.height / 2);
		volumeSlider.hoverAlpha = 1;

		add(volumeSlider);

		fullScreenText = new FlxText(50, 230, "FullScreen");
		fullScreenText.setFormat(null, 20, FlxColor.RED);
		add(fullScreenText);

		checkBox = new FlxButtonPlus(200, 230, 25, 25);
		add(checkBox);

		resolutionText = new FlxText(50, 300, "Resolution:");
		resolutionText.setFormat(null, 20, FlxColor.RED);

		leftButton = new FlxButtonPlus(200, 300, "<", 25, 25);
		add(leftButton);
		rightButton = new FlxButtonPlus(350, 300, ">", 25, 25);
		add(rightButton);

		add(resolutionText);

		back = new FlxButton(10, 400, "Back", close);
		add(back);

		super.create();
	}

	// override public function update(elapsed:Float)
	// {
	// 	super.update(elapsed);
	// }

	private function closeSub():Void
	{
		close();
		FlxG.switchState(_parentState);
	}
}
