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

enum abstract TileType(Int) to Int
{
	var VOID = 0;
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;

	var TOP_WALL = 5;
	var TOP_RIGHT_Wall = 6;

	var RIGHT_WALL = 7;

	var BOTTOM_RIGHT_WALL = 8;
	var BOTTOM_WALL = 9;
	var BOTTOM_LEFT_WALL = 10;

	var LEFT_WALL = 11;
	var TOP_LEFT_WALL = 12;
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

		// final WIDTH:Int = Math.floor(FlxG.width / 8);
		// final HEIGHT:Int = Math.floor(FlxG.height / 8);

		tileMap = new FlxTilemap();

		var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(WIDTH, HEIGHT);
		// var standardDungeonCSV = DungeonGeneration.generateDungeon(WIDTH, HEIGHT);
		Log.trace("final: " + caveDungeonCSV);
		tileMap.loadMapFromCSV(caveDungeonCSV, AssetPaths.black_white_tiles__png);
		// tileMap.loadMapFromCSV(standardDungeonCSV, AssetPaths.black_white_tiles__png);

		// Scale up our tilemap for display -- murders fps
		tileMap.screenCenter();

		tileMap.setTileProperties(TileType.VOID, NONE);
		tileMap.setTileProperties(TileType.WALL, NONE);
		tileMap.setTileProperties(TileType.ROOM, NONE);
		tileMap.setTileProperties(TileType.HALL, NONE);
		tileMap.setTileProperties(TileType.DOOR, NONE);

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
