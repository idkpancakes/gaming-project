package;

import CaveDungeonGeneration.CaveDungeonGeneration;
import Enemy.DEnemy.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import haxe.Log;
import haxe.ds.BalancedTree;

enum abstract TileType(Int) to Int
{
	var VOID = 0;
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;
}

enum abstract FinalTiles(Int) to Int
{
	var ROOM = 9;
	var WALL_UP = 17;
	var WALL_DOWN = 1;
	var WALL_LEFT = 10;
	var WALL_RIGHT = 8;
	var WALL_UP_LEFT = 3;
	var WALL_UP_RIGHT = 4;
	var WALL_DOWN_LEFT = 11;
	var WALL_DOWN_RIGHT = 12;
	var VOID = 100;
	var TORCH = 27;
	var FIRE = 28;
	var CHEST = 40;
	var HEART = 45;
	var FLOOR_0 = 14;
	var FLOOR_1 = 15;
	var FLOOR_2 = 22;
}

// enum abstract FinalTiles(Int) to Int
// {
// 	var ROOM = 9;
// 	// var WALL_UP = 1;
// 	// var WALL_DOWN = 7;
// 	// var WALL_LEFT = 3;
// 	// var WALL_RIGHT = 5;
// 	// var WALL_UP_LEFT = 0;
// 	// var WALL_UP_RIGHT = 2;
// 	// var WALL_DOWN_LEFT = 6;
// 	// var WALL_DOWN_RIGHT = 8;
// 	// var VOID = 9;
// 	//
// 	var WALL_UP = 17;
// 	var WALL_DOWN = 1; //
// 	var WALL_LEFT = 10;
// 	var WALL_RIGHT = 8;
// 	var WALL_UP_LEFT = 3;
// 	var WALL_UP_RIGHT = 4;
// 	var WALL_DOWN_LEFT = 11;
// 	var WALL_DOWN_RIGHT = 12;
// 	var VOID = 100;
// 	var TORCH = 27;
// 	var FIRE = 28;
// 	var CHEST = 40;
// 	var HEART = 45;
// 	var FLOOR_0 = 14;
// 	var FLOOR_1 = 15;
// 	var FLOOR_2 = 22;
// }

class TestState extends FlxState
{
	final WIDTH:Int = 32;
	final HEIGHT:Int = 32;

	var player:Player;

	var combatState:CombatState;

	var bat1:DungeonEnemy;
	var wep:Weapons;

	var cam:FlxCamera;
	var hudCam:FlxCamera;

	var tileMap:FlxTilemap;

	public var hud:OverheadUI;

	var plantMan:DungeonEnemy;
	var tileSet = AssetPaths.biggerBoy__png;

	var enemyGroup:FlxTypedGroup<DungeonEnemy>;

	static public var thorns:Enemy;

	var levels:Array<FlxTilemap> = new Array();

	override public function create()
	{
		enemyGroup = new FlxTypedGroup<DungeonEnemy>();

		var backGround = new FlxSprite();
		backGround.loadGraphic(AssetPaths.bg_resized__png);
		add(backGround);

		buildLevels();
		loadLevel();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// DEBUG!
		if (FlxG.keys.justPressed.L)
		{
			loadLevel();
		}

		hud.updateHUD();
		openPauseMenu();

		if (player.isDead())
		{
			gameOver();
		}

		player.charMovement(player);
		FlxG.collide(player, tileMap);

		if (FlxG.overlap(player, wep) && FlxG.keys.justPressed.SPACE)
		{
			player.weapon = wep;
			hud.setWeapon(wep);
		}

		plantMan.attack(player, plantMan);
		FlxG.overlap(player, plantMan, combatStateSwitch);

		// -10 points
		for (enemy in enemyGroup)
		{
			enemy.attack(player, enemy);
			FlxG.overlap(player, enemy, combatStateSwitch);
		}
	}

	function combatStateSwitch(player:Player, enemy:DungeonEnemy)
	{
		var combatState = new CombatState(player.clone(), enemy);
		combatState.closeCallback = function()
		{
			enemy.kill();
			enemyGroup.remove(enemy);

			FlxG.cameras.remove(cam);
			cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			FlxG.cameras.add(cam);
			cam.target = player;
		}

		openSubState(combatState);
	}

	function buildLevels()
	{
		for (i in 0...5)
		{
			var _tileMap = new FlxTilemap();
			var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(WIDTH, HEIGHT, 15, .45, tileSet);
			_tileMap.loadMapFromCSV(caveDungeonCSV, tileSet, 48, 48);

			_tileMap.screenCenter();

			_tileMap.setTileProperties(FinalTiles.WALL_UP, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_DOWN, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_LEFT, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_RIGHT, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_UP_LEFT, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_UP_RIGHT, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_DOWN_LEFT, ANY);
			_tileMap.setTileProperties(FinalTiles.WALL_DOWN_RIGHT, ANY);

			_tileMap.setTileProperties(FinalTiles.VOID, ANY);
			_tileMap.setTileProperties(FinalTiles.TORCH, NONE);
			_tileMap.setTileProperties(FinalTiles.FIRE, NONE);
			_tileMap.setTileProperties(FinalTiles.CHEST, NONE);
			_tileMap.setTileProperties(FinalTiles.HEART, NONE);
			_tileMap.setTileProperties(FinalTiles.FLOOR_0, NONE);
			_tileMap.setTileProperties(FinalTiles.FLOOR_1, NONE);
			_tileMap.setTileProperties(FinalTiles.FLOOR_2, NONE);
			_tileMap.setTileProperties(FinalTiles.ROOM, NONE);

			levels.push(_tileMap);
		}

		Log.trace(levels);
	}

	function loadLevel()
	{
		if (levels.length == 0)
			return;

		remove(tileMap);
		remove(hud);
		remove(plantMan); // kill this
		remove(player);

		tileMap = levels.pop();
		tileMap.follow();
		add(tileMap);

		if (player == null)
			player = new Player();

		var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)), false);
		player.setPosition(startPoint.x, startPoint.y);
		player.setDungeonHealth(3);
		player.setCombatHealth(Std.int(10 + 4 * Math.abs(levels.length - 5))); // debug

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.target = player;
		add(player);

		hud = new OverheadUI();
		add(hud);
		hud.setPosition(cam.scroll.x, cam.scroll.y);

		plantMan = new DungeonEnemy(player.x + 300, player.y, BEE);
		add(plantMan);

		cam.target = player;
		placeEnemies();
	}

	// handles the game over state/effect
	function gameOver()
	{
		openSubState(new GameOver());
	}

	public function openPauseMenu()
	{
		if (FlxG.keys.pressed.P)
		{
			openSubState(new PauseMenu());
		}
	}

	function placeEnemies(?density:Float = 0.05)
	{
		remove(enemyGroup);
		enemyGroup = new FlxTypedGroup<DungeonEnemy>();
		var batTemplate:DungeonEnemy = new DungeonEnemy(0, 0, BAT);
		batTemplate.bType = BAT;

		var batGroup = CaveDungeonGeneration.placeEnemies(tileMap, density, batTemplate);

		for (bat in batGroup)
			enemyGroup.add(bat);

		add(enemyGroup);
	}
}
/**
	*JERRY
	*       _.---._    /\\
	*    ./'       "--`\//
	*  ./              o \
	* /./\  )______   \__ \
	*./  / /\ \   | \ \  \ \
	*   / /  \ \  | |\ \  \7
	*    "     "    "  "        VK <--- sad
**/
