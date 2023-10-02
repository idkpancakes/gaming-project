package;

import DungeonGenerator.CaveDungeonGeneration;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;

class PlayState extends FlxState
{
	public static final SCALE_FACTOR = 1;

	final WIDTH:Int = 32;
	final HEIGHT:Int = 32;
	var tileMap = new FlxTilemap();

	override public function create()
	{
		super.create();

		tileMap = new FlxTilemap();

		var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(WIDTH, HEIGHT);

		tileMap.loadMapFromCSV(caveDungeonCSV, AssetPaths.black_white_tiles__png);

		// Scale up our tilemap for display
		tileMap.scale.set(SCALE_FACTOR, SCALE_FACTOR);
		tileMap.screenCenter();

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
	* Alright! So Im switching to cave generation for irregularly sized rooms, then Im going to try the algo I thought of to define the regions/space of those rooms. 
	* At that point I'll be able to use the same code to connect the rooms up and we'll have a cave like level! 
	* 
	* Here's my first shot at the process for defining a room given a tilemap CSV
	* 
	* Empty means not a wall -> a room tile in this case
	* 
	* Pick a random "empty" point, push it to the stack
	*	
	*	while stack is not empty
			pop point from stack called P, mark as visited

			add P to a current RoomObject, 
			add all of Ps empty neighbors to RoomObject and push them onto the stack. 
			

		repeat process until stack is empty, you now have a list of points within your room region. now you get another Point that is not present in any exisiting RoomObject and repeat.
		You'll end up with several room objects that contain all the points within them. You now have your different regions! 
	*	
 */
