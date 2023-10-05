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
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;

/**
 * TODO
 * - Rooms aren't always connected, ensure connectivity
 * - After connections process csv and adjust the wall edges based on their neighbors:
 * - 1 wall to the right = rightFacingwall, 1 tile the right and up topRIght wall and so on
 * 
 * - 
 */
class CaveDungeonGeneration
{
	static public var tileMap:FlxTilemap = new FlxTilemap();

	static var roomList:Array<Array<Int>> = new Array();

	static public var width:Int;
	static public var height:Int;

	static public function generateDungeon(?_width:Int = 32, ?_height:Int = 32, ?smoothingItterations:Int = 15, ?wallRatio:Float = .45)
	{
		// setup the width, height vals
		width = _width;
		height = _height;

		tileMap = new FlxTilemap();
		roomList = new Array();

		var caveData:String = FlxCaveGenerator.generateCaveString(_width, _height, smoothingItterations, wallRatio);

		Log.trace(caveData);

		// caveData returns things a 0 or 1, where we actually use 0 as null tile 1 as wall and 2 as pathway. so just increment everything by one
		var tileMatrix = FlxStringUtil.toIntArray(caveData);

		// this can be replaced with tileMatrix.map somehow, unsure on syntax
		for (i in 0...tileMatrix.length)
		{
			tileMatrix[i] += 1;
		}

		caveData = FlxStringUtil.arrayToCSV(tileMatrix, _width);

		// getRoomsDepthFirstAttempt(caveData);
		var result = getRoomsBrute(caveData);
		return connectRooms(result);
	}

	// im starting to get how this is really inefficient, it requires you selecting two points that are within the same room before it'll remove all those points from the list.
	// it would work just as well if we select the closest neighbor thats a room tile. the flood fill will still compute the distances to the rest of the room.
	static function getRoomsBrute(caveCSV:String)
	{
		roomList = new Array();

		tileMap.loadMapFromCSV(caveCSV, AssetPaths.black_white_tiles__png);

		// define collision properties, must be done prior to computing pathfinding data
		// in this case we want ROOM to be passable and we c
		tileMap.setTileProperties(TileType.VOID, ANY);
		tileMap.setTileProperties(TileType.WALL, ANY);
		tileMap.setTileProperties(TileType.HALL, ANY);
		tileMap.setTileProperties(TileType.DOOR, ANY);
		tileMap.setTileProperties(TileType.ROOM, NONE);

		// I think this should make a deep copy.
		var roomTiles = [].concat(tileMap.getTileInstances(TileType.ROOM));

		var myPathfinder = new FlxDiagonalPathfinder(NONE);

		do
		{
			var currentRoom:Array<Int> = [];

			// get two random room tiles from the list of tiles
			var r1Tile = FlxG.random.getObject(roomTiles);

			// attempt at speeding things up, just grab the next roomtile and its LIKELY part of the room. Better chance then a yolo roll hoping we match up.
			var r2Tile = roomTiles[roomTiles.indexOf(r1Tile) + 1];
			// var r2Tile = FlxG.random.getObject(roomTiles);

			// compute pathfinding data -- such as distance and reachability between the two tiles, false means we keep computing even if we find a path between them.
			var pathfindingData = tileMap.computePathData(r1Tile, r2Tile, NONE, false);

			// if pathfindingData is null the points do not share a room, try again.
			if (pathfindingData == null)
				continue;

			// any distance thats not -1 is traversable from this point and is therefore part of the same "room/region"
			for (i in 0...pathfindingData.distances.length)
			{
				if (pathfindingData.distances[i] != -1)
				{
					// push tileIndex to the currentRoom list and remove the tile from avaliable pool
					currentRoom.push(i);
					roomTiles.remove(i);
				}
			}

			roomList.push(currentRoom);
			currentRoom = [];
		}
		while (roomTiles.length != 0);

		var tileData = tileMap.getData();

		// // debug to color rooms
		// for (room in roomList)
		// 	for (index in room)
		// 		tileData[index] = HALL;

		return FlxStringUtil.arrayToCSV(tileData, width);
	}

	static function connectRooms(caveCSV:String)
	{
		tileMap.loadMapFromCSV(caveCSV, AssetPaths.black_white_tiles__png);

		// setup collision properties! we really only want room to be impassable for the purposes of
		tileMap.setTileProperties(WALL, NONE);
		tileMap.setTileProperties(DOOR, NONE);
		tileMap.setTileProperties(ROOM, NONE);

		// not allowed ot use existing paths
		tileMap.setTileProperties(HALL, ANY);

		var roomListCopy = [].concat(roomList);

		// This will produce less paths but does not promise all rooms will be connected

		while (roomListCopy.length > 1)
		{
			var room1 = FlxG.random.getObject(roomListCopy);
			roomListCopy.remove(room1);

			var room2 = FlxG.random.getObject(roomListCopy.filter(x -> FlxArrayUtil.equals(x, room1) == false));

			var r1Point = FlxG.random.getObject(room1);
			var r2Point = FlxG.random.getObject(room2);

			// We use NONE for simplicication because we actually want each and every point, even if it's in a straight line (greedy algo)
			var points = tileMap.findPath(tileMap.getTileCoordsByIndex(r1Point, false), tileMap.getTileCoordsByIndex(r2Point, false), NONE,
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

		// // itterate through every pair of possible rooms (Non duplicate) -- this causes the maximum amount of paths, and looks off

		// for (room1 in roomList)
		// {
		// 	for (room2 in roomList.filter(x -> x != room1))
		// 	{
		// 		var r1Point = FlxG.random.getObject(room1);
		// 		var r2Point = FlxG.random.getObject(room2);

		// 		// We use NONE for simplicication because we actually want each and every point, even if it's in a straight line (greedy algo)
		// 		var points = tileMap.findPath(tileMap.getTileCoordsByIndex(r1Point, false), tileMap.getTileCoordsByIndex(r2Point, false), NONE,
		// 			FlxTilemapDiagonalPolicy.NONE);

		// 		// ignore failed paths, fuck it
		// 		if (points == null)
		// 			points = [];

		// 		// hey it would just be awesome if this didn't fail to find the path, like just really great
		// 		for (i in 1...(points.length - 1))
		// 		{
		// 			tileMap.setTile(Math.floor(points[i].x / 8), Math.floor(points[i].y / 8), TileType.HALL);
		// 		}
		// 	}
		// }

		// cast all hall types to ROOM.
		return FlxStringUtil.arrayToCSV(tileMap.getData().map(x -> return x == TileType.HALL ? TileType.ROOM : x), width);
	}

	static function prettifyRooms(caveCSV:String)
	{
		/**
		 * alright so the idea of this is to adjust the tiles based on their neighbouring room tiles. 
		 *  
		 * option 1: hacky but you can just compute the path data again and wait can I just compute the pathData
		 * 
		 */

		tileMap.loadMapFromCSV(caveCSV, AssetPaths.black_white_tiles__png);
	}

	// I need to reowrk this so it can be passed the arary rather than the pathfinder data
	static function getNeighbors(data:FlxPathfinderData, from:Int)
	{
		var neighbors = [];
		var inBound = getInBoundDirections(data, from);
		var up = inBound.has(UP);
		var down = inBound.has(DOWN);
		var left = inBound.has(LEFT);
		var right = inBound.has(RIGHT);

		inline function canGoHelper(to:Int, dir:FlxDirectionFlags)
		{
			return !data.isExcluded(to) && this.canGo(data, to, dir);
		}

		function addIf(condition:Bool, to:Int, dir:FlxDirectionFlags)
		{
			var condition = condition && canGoHelper(to, dir);
			if (condition)
				neighbors.push(to);

			return condition;
		}

		var columns = data.map.widthInTiles;

		// orthoginals
		up = addIf(up, from - columns, UP);
		down = addIf(down, from + columns, DOWN);
		left = addIf(left, from - 1, LEFT);
		right = addIf(right, from + 1, RIGHT);

		// // diagonals
		// if (diagonalPolicy != NONE)
		// {
		// 	// only allow diagonal when 2 orthoginals is possible
		// 	addIf(up && left, from - columns - 1, UP | LEFT);
		// 	addIf(up && right, from - columns + 1, UP | RIGHT);
		// 	addIf(down && left, from + columns - 1, DOWN | LEFT);
		// 	addIf(down && right, from + columns + 1, DOWN | RIGHT);
		// }

		return neighbors;
	}

	// given an CSV get the valid in bound directions
	function getInBoundDirections(data:FlxPathfinderData, from:Int)
	{
		var x = data.getX(from);
		var y = data.getY(from);
		return FlxDirectionFlags.fromBools(x > 0, x < data.map.widthInTiles - 1, y > 0, y < data.map.heightInTiles - 1);
	}

	/**
	 * [Description]
	 * @param flatIndex 
	 * @return FlxPoint
	 */
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

	static public function getRoomList()
	{
		return roomList;
	}
}
