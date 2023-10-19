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

class RulesState extends FlxSubState
{
	var rules:FlxText;
	var backStory:FlxText;
	var controls:FlxText;
	var keyPic:FlxSprite;
	var background:FlxSprite;
	var back:FlxButton;

	override public function create()
	{
		background = new FlxSprite(0, 0);
		background.loadGraphic(AssetPaths.backGround__png);
		background.alpha = 1;
		add(background);

		rules = new FlxText(250, 10, "Rules");
		rules.setFormat(null, 30, FlxColor.PURPLE);
		add(rules);

		backStory = new FlxText(0, 75, 600, "You play as a father, losing himself on path of vengence.
										After the deaths of his family, a father will go on a quest to defeat the monsters that have taken the people he loves most.
											You must aid him by traversing dangerous dungeons and fighting frightful monsters.");

		backStory.setFormat(null, 12, FlxColor.RED, FlxTextAlign.CENTER);
		add(backStory);

		controls = new FlxText(225, 250, 400, "To control the father you must use the WASD keys 
											Dungeon View: when not in combat you are free to traverse the dungeon but you must be on the look out for roaming enemies and traps
											Combat View: once an enemy makes contact with you, you enter a combat state where a turn based battle will begin");
		controls.setFormat(null, 12, FlxColor.RED);
		add(controls);

		keyPic = new FlxSprite(40, 200);
		keyPic.loadGraphic(AssetPaths.WASDKeys__png);
		keyPic.scale.set(0.75, 0.75);
		add(keyPic);

		back = new FlxButton(10, 400, "Back", backToMenu);
		add(back);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function backToMenu()
	{
		close();
	}
}
