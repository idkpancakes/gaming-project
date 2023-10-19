package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxSlider;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PauseMenu extends FlxSubState
{
	// FIX CAMERA
	var title:FlxText;
	var volumeText:FlxText;
	var resolutionText:FlxText;
	var fullScreenText:FlxText;
	var back:FlxButton;

	var volumeSlider:FlxSlider;

	var resolutionOptionArray:Array<String> = ["640 x 480", "720 x 480", "1280 x 720", "1920 x 1080"];

	var resolutionValueArray:Array<FlxPoint> = [
		FlxPoint.get(640, 480),
		FlxPoint.get(720, 480),
		FlxPoint.get(1280, 720),
		FlxPoint.get(1920, 1080)
	];

	var fullscreenCheckBox:FlxButtonPlus;
	var leftButton:FlxButtonPlus;
	var rightButton:FlxButtonPlus;
	var resolutionOptionDisplay:FlxText;

	var center:FlxSprite;

	var volume:Int = 0;

	var menuCam:FlxCamera;

	public function new()
	{
		super(0xFFFFFF);
	}

	override public function create()
	{
		var background = new FlxSprite();
		background.loadGraphic(AssetPaths.backGround__png);
		background.alpha = 1;
		add(background);

		title = new FlxText(250, 50, "Options");
		title.setFormat(null, 30, FlxColor.PURPLE);

		volumeText = new FlxText(50, 150, "Volume:");
		volumeText.setFormat(null, 20, FlxColor.RED);

		volumeSlider = new FlxSlider(this, "volume", 200, 150, 0, 100, 300, 50, 10, FlxColor.RED, FlxColor.PURPLE);
		volumeSlider.nameLabel.visible = false;
		volumeSlider.y -= (volumeSlider.handle.height / 2);
		volumeSlider.hoverAlpha = 1;

		fullScreenText = new FlxText(50, 230, "FullScreen");
		fullScreenText.setFormat(null, 20, FlxColor.RED);

		fullscreenCheckBox = new FlxButtonPlus(200, 230, 25, 25);
		fullscreenCheckBox.loadButtonGraphic(new FlxSprite().makeGraphic(25, 25, FlxColor.GRAY), new FlxSprite().makeGraphic(25, 25, FlxColor.GRAY));

		fullscreenCheckBox.onClickCallback = function()
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		};

		resolutionText = new FlxText(50, 300, "Resolution:");
		resolutionText.setFormat(null, 20, FlxColor.RED);

		leftButton = new FlxButtonPlus(200, 300, "<", 25, 25);
		leftButton.onClickCallback = cycleResolution.bind(-1);

		rightButton = new FlxButtonPlus(350, 300, ">", 25, 25);
		rightButton.onClickCallback = cycleResolution.bind(1);

		resolutionOptionDisplay = new FlxText(leftButton.x + 15, leftButton.y, rightButton.x - leftButton.x, resolutionOptionArray[0], 16);
		resolutionOptionDisplay.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.CENTER);

		add(title);
		add(volumeText);
		add(volumeSlider);
		add(fullScreenText);
		add(fullscreenCheckBox);
		add(leftButton);
		add(rightButton);
		add(resolutionText);
		add(resolutionOptionDisplay);

		back = new FlxButton(10, 400, "Back", closeSub);
		add(back);

		center = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		center.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		center.alpha = 0;

		menuCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(menuCam);
		menuCam.target = center;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	private function cycleResolution(change:Int)
	{
		FlxG.fullscreen = false;

		var index:Int = resolutionOptionArray.indexOf(resolutionOptionDisplay.text);
		index = Std.int(Math.max((index + change) % resolutionOptionArray.length, 0));

		resolutionOptionDisplay.text = resolutionOptionArray[index];

		var newRes:FlxPoint = resolutionValueArray[index];
		FlxG.resizeWindow(Std.int(newRes.x), Std.int(newRes.y));
	}

	private function closeSub():Void
	{
		close();
	}
}
