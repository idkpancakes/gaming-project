package;

import CaveDungeonGeneration.CaveDungeonGeneration;
import DungeonGenerator.DungeonGeneration;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import haxe.Log;
import openfl.display.BitmapData;

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

class PlayState extends FlxState
{
	final WIDTH:Int = 32;
	final HEIGHT:Int = 32;
	var tileMap = new FlxTilemap();

	var player = new FlxSprite();
	var backGround = new FlxSprite();

	var shaderCam:FlxCamera;
	var bgBuffer:BitmapData;

	var shader:Shader;

	var shaders:Array<Shader>;

	var lightSources:FlxSpriteGroup;

	override public function create()
	{
		super.create();

		backGround = new FlxSprite();
		backGround.loadGraphic(AssetPaths.bg_resized__png);
		add(backGround);

		tileMap = new FlxTilemap();

		var caveDungeonCSV = CaveDungeonGeneration.generateDungeon(WIDTH, HEIGHT);
		tileMap.loadMapFromCSV(caveDungeonCSV, AssetPaths.tile_set_expanded__png, 8, 8);

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

		add(tileMap);

		// build our light sources
		lightSources = new FlxSpriteGroup();

		var torches = CaveDungeonGeneration.placeEntities(tileMap, 0.01, AssetPaths.torch__png);
		torches.forEach(t -> lightSources.add(t));

		add(lightSources);

		createCams();
	}

	function createCams()
	{
		// FlxG.camera draws the actual world. In this case, that means the background and the gem
		// Note, the shader also draws this cam, so in the end this camera is completely covered by shaderCam
		var bgCam = FlxG.camera;
		bgCam.bgColor = 0xffffff;

		// player.camera = bgCam;
		// lightSources.forEach(light -> light.camera = bgCam);

		backGround.camera = bgCam;
		FlxG.cameras.setDefaultDrawTarget(bgCam, false);

		/* shaderCam draws the foreground elements (except the gem), then passes that as input to
		 * the shader along with the bg camera, the fg is used to cast shadows on the bg
		 * In this case that means everything except the gem, ui and background
		 */
		shaderCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(shaderCam);
		shaderCam.bgColor = 0x0;

		shaders = [for (light in lightSources) new Shader()];

		// shader = new Shader();

		// add the bg camera as an image to the shader so we can add color effects to it
		bgCam.buffer = new BitmapData(bgCam.width, bgCam.height);

		// shader.bgImage.input = bgCam.buffer;

		for (shader in shaders)
		{
			shader.bgImage.input = bgCam.buffer;
		}

		var filters:Array<openfl.filters.BitmapFilter> = [for (shader in shaders) new openfl.filters.ShaderFilter(shader)];
		shaderCam.setFilters(filters);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		inline function random(mean:Float)
			return FlxG.random.floatNormal(mean, mean / 8);

		for (i in 0...lightSources.length)
		{
			var light = lightSources.members[i];
			shaders[i].setOrigin((light.x) / FlxG.width, (light.y) / FlxG.height);
			// shaders[i].setOrigin((light.x + random(light.origin.x)) / FlxG.width, (light.y + random(light.origin.y)) / FlxG.height);
		}
	}

	override function draw()
	{
		super.draw();

		// draw the camera's canvas to it's buffer so it shows up in the shader
		drawCameraBuffer(FlxG.camera);
	}

	static function drawCameraBuffer(camera:FlxCamera)
	{
		final buffer = camera.buffer;
		if (FlxG.renderTile)
		{
			@:privateAccess
			camera.render();

			buffer.fillRect(buffer.rect, 0x00000000);
			buffer.draw(camera.canvas);
		}
		return buffer;
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
