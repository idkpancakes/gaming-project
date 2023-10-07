package;

import CaveDungeonGeneration.CaveDungeonGeneration;
import DungeonGenerator.DungeonGeneration;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;

// update this to the actual index just for wall up down and left.
enum abstract TileType(Int) to Int
{
	var VOID = 0;
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;
}

/**
 * assumign we're just straight using the tileset from the download pack
 */
enum abstract FinalTiles(Int) to Int
{
	var ROOM = 6;

	// var WALL_UP = 1;
	// var WALL_DOWN = 7;
	// var WALL_LEFT = 3;
	// var WALL_RIGHT = 5;
	// var WALL_UP_LEFT = 0;
	// var WALL_UP_RIGHT = 2;
	// var WALL_DOWN_LEFT = 6;
	// var WALL_DOWN_RIGHT = 8;
	// var VOID = 9;
	var WALL_UP = 11;
	var WALL_DOWN = 1;
	var WALL_LEFT = 7;
	var WALL_RIGHT = 5;

	var WALL_UP_LEFT = 3;
	var WALL_UP_RIGHT = 4;
	var WALL_DOWN_LEFT = 8;
	var WALL_DOWN_RIGHT = 9;
	var VOID = 14;
}

class PlayState extends FlxState
{
	public static final SCALE_FACTOR = 0.25;

	final WIDTH:Int = 32;
	final HEIGHT:Int = 32;
	var tileMap = new FlxTilemap();

	override public function create()
	{
		super.create();

		// match height to game window -- slow because of level gen innefficencies
		// final WIDTH:Int = Math.floor(FlxG.width / 8);
		// final HEIGHT:Int = Math.floor(FlxG.height / 8);

		var backGround = new FlxSprite();
		backGround.loadGraphic(AssetPaths.bg_resized__png);
		add(backGround);

		tileMap = new FlxTilemap();

		var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(WIDTH, HEIGHT);
		Log.trace("final: " + caveDungeonCSV);

		tileMap.loadMapFromCSV(caveDungeonCSV, AssetPaths.tile_set_8x8__png, 8, 8);

		// tileMap.loadMapFromCSV(caveDungeonCSV, AssetPaths.black_white_tiles__png);
		// tileMap.loadMapFromCSV(standardDungeonCSV, AssetPaths.black_white_tiles__png);

		tileMap.screenCenter();
		// tileMap.scale.set(0.25, 0.25);
		// tileMap.setTileProperties(TileType.VOID, NONE);
		// tileMap.setTileProperties(TileType.WALL, NONE);
		// tileMap.setTileProperties(TileType.ROOM, NONE);
		// tileMap.setTileProperties(TileType.HALL, NONE);
		// tileMap.setTileProperties(TileType.DOOR, NONE);

		add(tileMap);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function colorRoomDebug()
	{
		var canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);

		for (room in CaveDungeonGeneration.getRoomList())
		{
			var color = FlxG.random.color();
			for (index in room)
			{
				var pos = tileMap.getTileCoordsByIndex(index);
				FlxSpriteUtil.drawRect(canvas, pos.x, pos.y, tileMap.scaledTileWidth, tileMap.scaledTileHeight, color);
			}
		}

		add(canvas);
		remove(tileMap);
	}
}
/**
 * it's dangerous to go alone! take this!
 * 
 *	       .
 *	      ":"
 *	    ___:____     |"\/"|
 *	  ,'        `.    \  /
 * 	 |  O         \___/  |
 * 	~^~^~^~^~^~^~^~^~^~^~^~^~
 * 
 * todo list
 * 
 *  - pathfinding is linear and requires weights based on tiletype
 * - at this point drunkards walk it
 * - camera follow a player (ask Cassandra for some sprites?) as they navigate the world
 * - get an actual tilemap
 * 
 * 
 * 
 * feature list:
 * - enemy placement, 
 * - ladder/exit placement
 * - item placement
 * 
 *
 */
/**
 * *
 */
