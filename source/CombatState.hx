package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CombatState extends FlxState
{
	var player:Player;
	var enemy:Enemy;

	var bat:DungeonEnemy;

	var text:FlxText;
	var combatHUD:CombatHUD;

	override public function new(player:Player, enemy:Enemy)
	{
		super();

		this.player = player;
		this.enemy = enemy;
	}

	override public function create()
	{
		super.create();

		combatHUD = new CombatHUD(player, enemy);

		combatHUD.initCombat(player.getDungeonHealth(), enemy);
		add(combatHUD);
		// text = new flixel.text.FlxText(250, 250, FlxG.width, "Letsgo?", 64);
		// add(text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
