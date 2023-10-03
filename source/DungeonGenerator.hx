import PlayState.TileType;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.path.FlxPath;
import flixel.path.FlxPathfinder;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;
import haxe.ds.GenericStack;
import openfl.display.Tile;

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

		roomCount = Math.floor(Math.sqrt(width));

		for (i in 0...roomCount)
			buildRoom();
		// connectRooms();
		connectRoomsSparse();

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

			// BOTTO
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
				var points = tileMap.findPath(tileMap.getTileCoordsByIndex(door1, false), tileMap.getTileCoordsByIndex(door2, false), NONE, NORMAL);

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

	static function connectRoomsSparse()
	{
		tileMap.loadMapFromCSV(FlxStringUtil.arrayToCSV(dungeonMap, width), AssetPaths.black_white_tiles__png);

		// setup collision properties! we really only want room to be impassable for the purposes of
		tileMap.setTileProperties(WALL, NONE);
		tileMap.setTileProperties(DOOR, NONE);
		tileMap.setTileProperties(ROOM, NONE);

		// not allowed ot use existing paths
		tileMap.setTileProperties(HALL, ANY);

		var roomListCopy = [].concat(tileMap.getTileInstances(DOOR));

		// This will produce less paths but does not promise all rooms will be connected
		while (roomListCopy.length > 1)
		{
			var room1 = FlxG.random.getObject(roomListCopy);
			roomListCopy.remove(room1);

			var room2 = FlxG.random.getObject(roomListCopy);

			// We use NONE for simplicication because we actually want each and every point, even if it's in a straight line (greedy algo)
			var points = tileMap.findPath(tileMap.getTileCoordsByIndex(room1, false), tileMap.getTileCoordsByIndex(room2, false), NONE,
				FlxTilemapDiagonalPolicy.NONE);

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
/*	
 * TODO: 
 *  - pick a random cell in two rooms, and then connect them with flx pathfinding, carving walls along the way
 * 
 *  * Alright! So Im switching to cave generation for irregularly sized rooms, then Im going to try the algo I thought of to define the regions/space of those rooms. 
 * At that point I'll be able to use the same code to connect the rooms up and we'll have a cave like level! 
 * 
 *  That parts done! ended up using a brute force method, see the DungeonGen file for more info, theres a lot of improvements that could be made but its functional
 *
 */
