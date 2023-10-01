package;

import cpp.abi.Abi;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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

		var map = new DungeonGeneration(WIDTH, HEIGHT, 48);
		var tileMap = new FlxTilemap();

		var gridCSV = FlxStringUtil.arrayToCSV(map.dungeonMap, WIDTH);
		tileMap.loadMapFromCSV(gridCSV, AssetPaths.black_white_tiles__png);

		// setup collision properties! we really only want room to be impassable for the purposes of
		tileMap.setTileProperties(WALL, NONE);
		tileMap.setTileProperties(HALL, NONE);
		tileMap.setTileProperties(DOOR, NONE);
		tileMap.setTileProperties(ROOM, ANY);

		// this connects each door with eveyr other door, it also randomly fails to connect a door even when a clear path is visible. its 5:13am and I have no idea why it's happening,
		// theres no collidable objects!!

		// // itterate through every pair of possible rooms
		// for (door1 in tileMap.getTileInstances(DOOR))
		// {
		// 	for (door2 in tileMap.getTileInstances(DOOR).filter(x -> x != door1))
		// 	{
		// 		// We use NONE for simplicication because we actually want each and every point, even if it's in a straight line (greedy algo)
		// 		var points = tileMap.findPath(tileMap.getTileCoordsByIndex(door1, false), tileMap.getTileCoordsByIndex(door2, false), NONE, NONE);

		// 		/**
		// 		 * the typed pathfinder has some kind of findpath by indicies function which would skip all the conversion we have to do.
		//  * but it requires you to make a FlxPathFinder factorY? and your own data typed class? what! the helper methods are all there but the documentation has no ifno,
		//    *it even has built in A* hueristics! but it just says no when you try to use it.
		//
		//
		// 		 */

		// 		for (i in 1...(points.length - 1))
		// 		{
		// 			tileMap.setTile(Math.floor(points[i].x / 8), Math.floor(points[i].y / 8), TileType.HALL);
		// 			Log.trace(points[i]);
		// 		}
		// 	}
		// }

		tileMap.scale.set(SCALE_FACTOR, SCALE_FACTOR);
		tileMap.screenCenter();

		add(tileMap);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

class DungeonGeneration
{
	public var dungeonMap:Array<Int> = new Array();

	public var width:Int;
	public var height:Int;

	public var roomList:Array<FlxRect> = new Array();

	public function new(?width:Int = 32, ?height:Int = 32, ?roomCount:Int = 4)
	{
		// setup the dungeon array with
		dungeonMap = [for (i in 0...height * width) TileType.WALL];

		this.width = width;
		this.height = height;

		for (i in 0...roomCount)
			buildRoom();
	}

	function buildRoom()
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

	// ...
	function isValidRoom(rect:FlxRect):Bool
	{
		for (point in 0...height * width)
			if (dungeonMap[point] == TileType.ROOM && rect.containsPoint(flatTo2DIndex(point)))
				return false;
		return true;
	}

	// helper methods to go from flat to 2d index because haxe will require different formats for the same class!!! there's no consistency! setTile and getTileIndexByCords for example
	function flatTo2DIndex(flatIndex:Int):FlxPoint
	{
		return FlxPoint.get(flatIndex % width, Math.floor(flatIndex / width));
	}

	function _2DToFlatIndex(pointIndex:FlxPoint):Int
	{
		return Math.floor(pointIndex.x + (pointIndex.y * width));
	}
}
/**
	* it's dangerous to go alone! take this!
	* 
				.
			  ":"
			___:____     |"\/"|
		 ,'        `.    \  /
		 |  O        \___/  |
		~^~^~^~^~^~^~^~^~^~^~^~^~
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
	* \(o-o)/
 */
