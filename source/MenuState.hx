package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var playButton:FlxButton;
	var rulesButton:FlxButton;
	var storyText:FlxText;
	var background:FlxSprite;
	var skip:FlxButton;

	override public function create()
	{
		super.create();

		background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.backGround__png);
		background.alpha = 0.5;
		add(background);

		skip = new FlxButton(400, 400, "Skip", skipText);
		add(skip);

		storyText = new FlxText(0, FlxG.height, FlxG.width, "The year was xxxx, it has been xxxx years since they have taken over. \n
									Over the years humanity has fallen from their place at the top, while they have gained more and more control\n 
									In the beginning we tried to fight back but with their quick evolution we were no match\n");

		storyText.setFormat(null, 30, FlxColor.PURPLE, FlxTextAlign.CENTER);
		// storyText.y -= storyText.height;
		add(storyText);

		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.screenCenter();
		playButton.scale.x = 2;
		playButton.scale.y = 2;

		rulesButton = new FlxButton(playButton.getPosition().x, playButton.getPosition().y + 70, "Rules", clickRules);
		rulesButton.scale.x = 2;
		rulesButton.scale.y = 2;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		scrollText();
	}

	public function skipText()
	{
		remove(storyText);
		add(playButton);
		add(rulesButton);
		remove(skip);
	}

	public function scrollText()
	{
		if (storyText.y + storyText.height < 0)
		{
			add(playButton);
			add(rulesButton);
		}
		else
		{
			storyText.y -= 0.5;
		}
	}

	public function clickPlay()
	{
		FlxG.switchState(new TestState());
	}

	public function clickRules()
	{
		FlxG.switchState(new RulesState());
	}
}
