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

	var title:FlxText;

	var options:FlxButton;

	override public function create()
	{
		super.create();

		background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.backGround__png);
		background.alpha = 0.5;
		add(background);

		skip = new FlxButton(500, 400, "Skip", skipText);
		add(skip);

		storyText = new FlxText(0, FlxG.height, FlxG.width, "The year was xxxx, it has been 17 years since they have taken over. \n
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

		options = new FlxButton(rulesButton.getPosition().x, rulesButton.getPosition().y + 70, "Options", clickOptions);
		options.scale.x = 2;
		options.scale.y = 2;

		title = new FlxText(10, 50, 600, "A World Overtaken: Man Versus Swarm");
		title.setFormat(null, 30, FlxColor.RED, FlxTextAlign.CENTER);
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
		add(title);
		add(options);
		remove(skip);
	}

	public function scrollText()
	{
		if (storyText.y + storyText.height < 0)
		{
			add(playButton);
			add(rulesButton);
			add(options);
			add(title);
			remove(skip);
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
		openSubState(new RulesState());
	}

	public function clickOptions()
	{
		openSubState(new PauseMenu());
	}
}
