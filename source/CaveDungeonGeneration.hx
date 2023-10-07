import PlayState.FinalTiles;
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
 */
typedef Neighbor =
{
	index:Int,
	dir:FlxDirectionFlags
}

typedef Bitmask =
{
	index:Int,
	dirBits:Array<FlxDirectionFlags>
}

class CaveDungeonGeneration
{
	static public var tileMap:FlxTilemap = new FlxTilemap();

	static var roomList:Array<Array<Int>> = new Array();

	static public var width:Int = 0;
	static public var height:Int = 0;

	static public function generateDungeon(?_width:Int = 32, ?_height:Int = 32, ?smoothingItterations:Int = 15, ?wallRatio:Float = .45)
	{
		// setup the width, height vals
		width = _width;
		height = _height;

		tileMap = new FlxTilemap();
		roomList = new Array();

		var caveData:String = FlxCaveGenerator.generateCaveString(_width, _height, smoothingItterations, wallRatio);

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
		result = connectRooms(result);

		result = prettifyRooms(result);
		return result;
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

		return FlxStringUtil.arrayToCSV(tileData, width);
	}

	static function connectRooms(caveCSV:String)
	{
		tileMap.loadMapFromCSV(caveCSV, AssetPaths.black_white_tiles__png);

		// setup collision properties! we really only want room to be impassable for the purposes of
		tileMap.setTileProperties(TileType.WALL, NONE);
		tileMap.setTileProperties(TileType.DOOR, NONE);
		tileMap.setTileProperties(TileType.ROOM, NONE);

		// not allowed ot use existing paths
		tileMap.setTileProperties(TileType.HALL, ANY);

		var roomListCopy = [].concat(roomList);

		// This will produce less paths but does not promise all rooms will be connected actually if they are all connected its just luck

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

		// cast all hall types to ROOM.
		return FlxStringUtil.arrayToCSV(tileMap.getData().map(x -> return x == TileType.HALL ? TileType.ROOM : x), width);
	}

	static function prettifyRooms(caveCSV:String)
	{
		tileMap.loadMapFromCSV(caveCSV, AssetPaths.black_white_tiles__png);

		var data:Array<Int> = FlxStringUtil.toIntArray(caveCSV);

		var wallTiles = tileMap.getTileInstances(TileType.WALL);

		var bitmaskData:Array<Bitmask> = new Array();

		for (tileIndex in wallTiles)
		{
			// just get the neighboring room tiles
			var neighbors = getNeighbors(data, tileIndex).filter(n -> tileMap.getTileByIndex(n.index) == TileType.ROOM);

			// if no valid neighbors skip -- after this point we only have "edge" tiles -- orthognal
			if (neighbors.length == 0)
				continue;

			// var dirList:Array<FlxDirectionFlags> = [for (n in neighbors) n.dir];
			var bitmask:Bitmask = {index: tileIndex, dirBits: [for (n in neighbors) n.dir]};
			bitmaskData.push(bitmask);
		}

		// it works!!!
		Log.trace("bitmaskData: " + bitmaskData);

		// alright now we jsut need to modify the tiles based on the bitmask data. -- Time to make a conversion enum
		/**
		 * there are two concepts that make this possible:
		 * 
		 *  1) the sum of any two distinct 4 bit strings is also distinct 
		 * 	2) ?
		 * 
		 * 	
		 */

		data = tileMap.getData();

		// clear all old walls
		data = data.map(d -> d = d == TileType.WALL ? FinalTiles.VOID : d);

		// apply the mask!
		for (mask in bitmaskData)
			data[mask.index] = convertDirToTileType(mask.dirBits);

		// conver to new room tile
		data = data.map(d -> d = d == TileType.ROOM ? FinalTiles.ROOM : d);

		return FlxStringUtil.arrayToCSV(data, width);
	}

	static function convertDirToTileType(dirs:Array<Int>)
	{
		var dirVal = 0;
		for (dir in dirs)
			dirVal += dir;

		// cases for each combo of directions, although bitwise opperands would have worked -- fuck that though
		switch (dirVal)
		{
			// UP
			case 0x0100:
				return FinalTiles.WALL_UP;

			// DOWN
			case 0x1000:
				return FinalTiles.WALL_DOWN;

			// LEFT
			case 0x0001:
				return FinalTiles.WALL_LEFT;

			// RIGHT
			case 0x0010:
				return FinalTiles.WALL_RIGHT;

			// UP_LEFT
			case 0x0101:
				return FinalTiles.WALL_UP_LEFT;

			// UP_RIGHT
			case 0x0110:
				return FinalTiles.WALL_UP_RIGHT;

			// DOWN_LEFT
			case 0x1001:
				return FinalTiles.WALL_DOWN_LEFT;

			// DOWN_RIGHT
			case 0x1010:
				return FinalTiles.WALL_DOWN_RIGHT;
		}

		return FinalTiles.ROOM;
	}

	/**
	 * function to get the neighbors of a given tile in a matrix
	 * @param data Array to check 
	 * @param from index of the tile you wish to get the neighbors of
	 */
	static function getNeighbors(data:Array<Int>, from:Int):Array<Neighbor>
	{
		var neighbors = [];
		var inBound = getInBoundDirections(data, from);

		var up = inBound.has(UP);
		var down = inBound.has(DOWN);
		var left = inBound.has(LEFT);
		var right = inBound.has(RIGHT);

		function addIf(condition:Bool, to:Int, dir:FlxDirectionFlags)
		{
			if (condition)
				neighbors.push({index: to, dir: dir});
			return condition;
		}

		var columns = width;

		// orthoginals
		up = addIf(up, from - columns, UP);
		down = addIf(down, from + columns, DOWN);
		left = addIf(left, from - 1, LEFT);
		right = addIf(right, from + 1, RIGHT);

		return neighbors;
	}

	/**
	 * Get valid directions from a given index in a flattened 2D array
	 * @param data
	 * @param from
	 */
	static function getInBoundDirections(data:Array<Int>, from:Int,)
	{
		var _2dIndex = flatTo2DIndex(from);

		// left, right, up, down -- math should be correct
		return FlxDirectionFlags.fromBools(_2dIndex.x<width, _2dIndex.x>0, _2dIndex.y > 0, _2dIndex.y < height);
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
/**
 * bitmasking is pretty much what im attempting to do with the map gen, look into it
 * 
 */
