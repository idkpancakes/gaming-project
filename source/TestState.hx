package;

import CaveDungeonGeneration.CaveDungeonGeneration;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
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
	var player:Player;

	var bat1:Bat;
	var wep:Weapons;

	var cam:FlxCamera;
	var hudCam:FlxCamera;

	var tileMap:FlxTilemap;
	var batGroup:FlxTypedGroup<Bat>;

	public var hud:OverheadUI;

	var plantMan:Bat;

	static public var thorns:Enemy;

	public var hud:OverheadUI;

	override public function create()
	{
		var backGround = new FlxSprite();
		backGround.loadGraphic(AssetPaths.bg_resized__png);
		add(backGround);

		tileMap = new FlxTilemap();

		// var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(32, 32);
		tileMap.loadMapFromCSV(AssetPaths.emptyMap__csv, AssetPaths.biggerBoy__png, 48, 48);

		tileMap.screenCenter();

		tileMap.setTileProperties(FinalTiles.WALL_UP, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_DOWN, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_LEFT, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_RIGHT, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_UP_LEFT, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_UP_RIGHT, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_DOWN_LEFT, ANY);
		tileMap.setTileProperties(FinalTiles.WALL_DOWN_RIGHT, ANY);

		tileMap.setTileProperties(FinalTiles.VOID, ANY);
		tileMap.setTileProperties(FinalTiles.TORCH, NONE);
		tileMap.setTileProperties(FinalTiles.FIRE, NONE);
		tileMap.setTileProperties(FinalTiles.CHEST, NONE);
		tileMap.setTileProperties(FinalTiles.HEART, NONE);
		tileMap.setTileProperties(FinalTiles.FLOOR_0, NONE);
		tileMap.setTileProperties(FinalTiles.FLOOR_1, NONE);
		tileMap.setTileProperties(FinalTiles.FLOOR_2, NONE);
		tileMap.setTileProperties(FinalTiles.ROOM, NONE);

		tileMap.follow();

		add(tileMap);
		hud = new OverheadUI();
		add(hud);

		var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)), false);
		player = new Player(startPoint.x, startPoint.y);

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.target = player;
		add(player);

		plantMan = new Bat(startPoint.x + 300, startPoint.y, BEE);
		add(plantMan);

		hud.setPosition(cam.scroll.x, cam.scroll.y);

		wep = new Weapons(startPoint.x + 20, startPoint.y + 20, GUN);
		add(wep);

		//	add(plantMan.getThorns());

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		hud.updateHUD();
		openPauseMenu();

		if (player.isDead())
		{
			gameOver();
		}

		player.charMovement(player);
		FlxG.collide(player, tileMap);
		FlxG.collide(batGroup, tileMap);

		if (FlxG.overlap(player, wep) && FlxG.keys.justPressed.SPACE)
		{
			hud.setWeapon(wep);
		}

		plantMan.attack(player, plantMan);

		FlxG.overlap(player, plantMan, switching);

		// for (thorn in plantMan.getThorns())
		// {
		// 	if (FlxG.overlap(player, thorn))
		// 	{
		// 		Player.setDungeonHealth(Player.getDungeonHealth() - 1);
		// 		thorn.kill();
		// 	}
		// }
	}

	// handles the game over state/effect
	function gameOver()
	{
		openSubState(new GameOver());
	}

	public function switching(player:Player, enemy:Enemy)
	{
		FlxG.switchState(new CombatState());
	}

	public function openPauseMenu()
	{
		if (FlxG.keys.pressed.P)
		{
			openSubState(new PauseMenu());
		}
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
	*    "     "    "  "        VK
**/
