package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CombatState extends FlxSubState
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

		combatHUD.initCombat(player, enemy);
		add(combatHUD);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (combatHUD.outcome.equals(CombatHUD.Outcome.FINISHED))
		{
			_parentState.openSubState(new GameOver());

			close();
		}
	}
}
