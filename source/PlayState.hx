package;

import cpp.abi.Abi;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.path.FlxPath;
import flixel.path.FlxPathfinder;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;
import openfl.errors.ArgumentError;

enum abstract TileType(Int) to Int
{
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;
}

class PlayState extends FlxState
{
	public static final SCALE_FACTOR = 0.25;

	final WIDTH:Int = 128;
	final HEIGHT:Int = 128;

	override public function create()
	{
		super.create();

		var dungeonCSV = DungeonGeneration.generateDungeon(WIDTH, HEIGHT, 8);
		var tileMap = new FlxTilemap();

		// var caveData:String = FlxCaveGenerator.generateCaveString(WIDTH, WIDTH, 15, 0.45);

		tileMap.loadMapFromCSV(dungeonCSV, AssetPaths.black_white_tiles__png);

		// Scale up our tilemap for display
		tileMap.scale.set(SCALE_FACTOR, SCALE_FACTOR);
		tileMap.screenCenter();

		add(tileMap);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

/**
 * This class should handle building, placing, connecting and generating the dungeons, then it should return an CSV that can represent the level it has created
 * 
 * right now it builds our own rooms but lets experiement with the CaveGen and use their irregularly sized rooms and then I can try the algo I made. 
 */
class DungeonGeneration extends FlxDiagonalPathfinder
{
	static public var dungeonMap:Array<Int> = new Array();

	static public var tileMap = new FlxTilemap();

	static public var width:Int;
	static public var height:Int;

	static public var roomList:Array<FlxRect> = new Array();

	static public function generateDungeon(?_width:Int = 32, ?_height:Int = 32, ?roomCount:Int = 4)
	{
		// setup the dungeon array with
		dungeonMap = [for (i in 0..._height * _width) TileType.WALL];

		width = _width;
		height = _height;

		for (i in 0...roomCount)
			buildRoom();
		connectRooms();

		Log.trace(tileMap.toString());

		return FlxStringUtil.arrayToCSV(tileMap.getData(), _width);
	}

	static function buildRoom()
	{
		// declare our room rect
		var room:FlxRect;

		var roomHeight:Int, roomWidth:Int;
		var startPointX:Int, startPointY:Int;

		var failCount:Int = 0;

		// no built in error checking to prevent infinite loops - >
		do
		{
			failCount++;

			Log.trace("room_build_attempt #: " + failCount);

			roomHeight = FlxG.random.int(4, 8);
			roomWidth = FlxG.random.int(4, 8);

			// pick a start point that wont go out of bounds (I used 1,1 to maintain a border)
			startPointX = FlxG.random.int(1, width - roomWidth);
			startPointY = FlxG.random.int(1, height - roomHeight);

			room = new FlxRect(startPointX, startPointY, roomWidth, roomHeight);
		}
		while (isValidRoom(room) == false);

			// first attempt at chooisng a random side of the room and marking it as a door
			// please work .. it'd jus tbe super cool of you to work
		var r1DoorIndex:Int = -1;
		switch (FlxG.random.int(1, 4))
		{
			// TOP
			case 1:
				r1DoorIndex = _2DToFlatIndex(FlxPoint.weak(room.left + Math.floor(room.width / 2), room.top));

			// BOTTOM -- ..it's
			case 2:
				r1DoorIndex = _2DToFlatIndex(FlxPoint.weak(room.x + Math.floor(room.width / 2), room.bottom - 1));

			// LEFT
			case 3:
				r1DoorIndex = _2DToFlatIndex(FlxPoint.weak(room.left, room.top + Math.floor(room.height / 2)));

			// RIGHT
			case 4:
				r1DoorIndex = _2DToFlatIndex(FlxPoint.weak(room.right - 1, room.top + Math.floor(room.height / 2)));
		}

		// update the csv/tilemap array
		for (i in 0...roomHeight)
			for (j in 0...roomWidth)
				dungeonMap[_2DToFlatIndex(FlxPoint.weak(startPointX + j, startPointY + i))] = TileType.ROOM;

		// mark the chosen index as the room and push it to the list
		dungeonMap[r1DoorIndex] = TileType.DOOR;
		roomList.push(room);
	}

	static function isValidRoom(rect:FlxRect):Bool
	{
		for (point in 0...height * width)
			if (dungeonMap[point] == TileType.ROOM && rect.containsPoint(flatTo2DIndex(point)))
				return false;
		return true;
	}

	static function connectRooms()
	{
		tileMap.loadMapFromCSV(FlxStringUtil.arrayToCSV(dungeonMap, width), AssetPaths.black_white_tiles__png);

		// setup collision properties! we really only want room to be impassable for the purposes of
		tileMap.setTileProperties(WALL, NONE);
		tileMap.setTileProperties(HALL, NONE);
		tileMap.setTileProperties(DOOR, NONE);
		tileMap.setTileProperties(ROOM, ANY);

		// // itterate through every pair of possible rooms
		for (door1 in tileMap.getTileInstances(DOOR))
		{
			for (door2 in tileMap.getTileInstances(DOOR).filter(x -> x != door1))
			{
				// We use NONE for simplicication because we actually want each and every point, even if it's in a straight line (greedy algo)
				var points = tileMap.findPath(tileMap.getTileCoordsByIndex(door1, false), tileMap.getTileCoordsByIndex(door2, false), NONE, NONE);

				// ignore failed paths, fuck it
				if (points == null)
					points = [];

				// hey it would just be awesome if this didn't fail to find the path, like just really great
				for (i in 1...(points.length - 1))
				{
					tileMap.setTile(Math.floor(points[i].x / 8), Math.floor(points[i].y / 8), TileType.HALL);
				}
			}
		}
	}

	// helper methods to go from flat to 2d index because haxe will require different formats for the same class!!! there's no consistency! setTile and getTileIndexByCords for example
	static function flatTo2DIndex(flatIndex:Int):FlxPoint
	{
		return FlxPoint.get(flatIndex % width, Math.floor(flatIndex / width));
	}

	static function _2DToFlatIndex(pointIndex:FlxPoint):Int
	{
		return Math.floor(pointIndex.x + (pointIndex.y * width));
	}

	static public function getTileMap():FlxTilemap
	{
		return tileMap;
	}
}

/**
 * it's dangerous to go alone! take this!
 * 
 *	       .
 *	      ":"
 *	    ___:____     |"\/"|
 *	  ,'        `.    \  /
 * 	 |  O        \___/  |
 * 	~^~^~^~^~^~^~^~^~^~^~^~^~
 * 
 * todo list
 * - null error on pathfinding (failed to find path)
 *  - pathfinding is linear and requires weights based on tiletype
 * - at this point drunkards walk it
 * - switch to a celluar automta and make it cave like?
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
 * 
 *
 */
