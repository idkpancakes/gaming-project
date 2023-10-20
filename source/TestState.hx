package;

import CaveDungeonGeneration.CaveDungeonGeneration;
import Enemy.DEnemy.*;
import MagicAttack.MagicType;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
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

	var scroll:MagicAttack;

	var bat1:DungeonEnemy;
	var wep:Weapons;

	var cam:FlxCamera;
	var hudCam:FlxCamera;

	var tileMap:FlxTilemap;

	public var hud:OverheadUI;

	var plantMan:DungeonEnemy;
	var tileSet = AssetPaths.biggerBoy__png;

	var enemyGroup:FlxTypedGroup<DungeonEnemy>;
	var key:FlxSprite;

	static public var thorns:Enemy;

	var levels:Array<FlxTilemap> = new Array();

	var levelID = -1;

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
		if (FlxG.keys.justPressed.L || FlxG.overlap(player, key))
		{
			loadLevel();
		}

		for (enemy in enemyGroup)
		{
			if (enemy.bType == MINI || enemy.bType == FINAL)
			{
				enemy.bossAttack(player, enemy);

				for (thorn in enemy.getThorns())
				{
					if (FlxG.overlap(thorn, player))
					{
						thorn.kill();
						player.setDungeonHealth(player.getDungeonHealth() - 1);
					}
				}
			}
			else
			{
				enemy.attack(player, enemy);
			}

			FlxG.collide(enemy, tileMap);
			FlxG.overlap(player, enemy, combatStateSwitch);
		}

		hud.playerHealth = player.getDungeonHealth();
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

		if (FlxG.overlap(player, scroll) && FlxG.keys.justPressed.SPACE)
		{
			player.magic = scroll;
			hud.setMagic(scroll);
		}
	}

	function combatStateSwitch(player:Player, enemy:DungeonEnemy)
	{
		Log.trace(player.clone().magic);

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
		for (i in 0...4)
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

		var _tileMap = new FlxTilemap();
		_tileMap.loadMapFromCSV(AssetPaths.plantRoom__csv, tileSet, 48, 48);

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
		_tileMap.setTileProperties(6, NONE);
		_tileMap.setTileProperties(7, NONE);

		levels.insert(2, _tileMap);

		Log.trace(levels);
	}

	function loadLevel()
	{
		if (levelID >= levels.length)
		{
			return;
		}

		remove(tileMap);
		remove(hud);
		remove(plantMan); // kill this
		remove(player);
		remove(key);

		levelID++;

		tileMap = levels[levelID];
		tileMap.follow();
		add(tileMap);

		if (player == null)
			player = new Player();

		key = new FlxSprite();
		key.loadGraphic(AssetPaths.level_key__png, 20, 20, false);

		var roomTiles = tileMap.getTileInstances(FinalTiles.ROOM);
		var pos = tileMap.getTileCoordsByIndex(FlxG.random.getObject(roomTiles), false);

		key.setPosition(pos.x, pos.y);
		add(key);

		placeEnemies();
		placePlayer();

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.target = player;
		add(player);

		hud = new OverheadUI();
		add(hud);
		hud.setPosition(cam.scroll.x, cam.scroll.y);

		cam.target = player;
	}

	function placePlayer()
	{
		var invalidPlacement = true;

		player.setDungeonHealth(3);
		player.setCombatHealth(10 + 5 * levelID); // debug

		// hard code placment for boss
		if (levelID == 2)
		{
			player.setPosition(5, 180);
			return;
		}

		while (invalidPlacement)
		{
			var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)), false);
			player.setPosition(startPoint.x, startPoint.y);

			invalidPlacement = false;

			for (enemy in enemyGroup)
				if (enemy.inRange(player, enemy))
					invalidPlacement = true;
		}
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
		enemyGroup.kill();
		remove(enemyGroup);
		remove(wep);
		remove(scroll);

		enemyGroup = new FlxTypedGroup<DungeonEnemy>();

		var roomTiles = tileMap.getTileInstances(FinalTiles.ROOM);
		var randomPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)), false);

		switch (levelID)
		{
			// Bat level
			case 0:
				var batTemplate:DungeonEnemy = new DungeonEnemy(0, 0, BAT);
				enemyGroup = CaveDungeonGeneration.placeEnemies(tileMap, 0.02, batTemplate);

				wep = new Weapons(randomPoint.x, randomPoint.y, BOW);
				add(wep);

			// Bat Plant Level
			case 1:
				var batTemplate:DungeonEnemy = new DungeonEnemy(0, 0, BAT);
				var plantTemplate:DungeonEnemy = new DungeonEnemy(0, 0, PLANT);

				enemyGroup = CaveDungeonGeneration.placeEnemies(tileMap, 0.02, batTemplate);

				for (plant in CaveDungeonGeneration.placeEnemies(tileMap, 0.02, plantTemplate))
				{
					enemyGroup.add(plant);
				}

				scroll = new MagicAttack(randomPoint.x, randomPoint.y, FlxG.random.getObject([MagicType.FIRE, MagicType.WATER]));
				add(scroll);

			// Plant Boss Level
			case 2:
				// mini boss type
				var plantMiniBoss = new DungeonEnemy(0, 0, MINI);

				// change to a constant, consult cassandra
				plantMiniBoss.setPosition(450, 150);

				add(plantMiniBoss.getThorns());
				remove(key);

				enemyGroup.add(plantMiniBoss);

			// Plant Bee Level
			case 3:
				var plantTemplate:DungeonEnemy = new DungeonEnemy(0, 0, PLANT);
				var beeTemplate:DungeonEnemy = new DungeonEnemy(0, 0, BEE);

				enemyGroup = CaveDungeonGeneration.placeEnemies(tileMap, 0.02, plantTemplate);

				for (bee in CaveDungeonGeneration.placeEnemies(tileMap, 0.02, beeTemplate))
				{
					enemyGroup.add(bee);
				}

				wep = new Weapons(randomPoint.x, randomPoint.y, GUN);
				add(wep);

			// Bee Boss Level
			case 4:
				var beeBoss = new DungeonEnemy(0, 0, FINAL);

				// change to a constant, consult cassandra
				var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)), false);
				beeBoss.setPosition(startPoint.x, startPoint.y);
				enemyGroup.add(beeBoss);
		}

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
