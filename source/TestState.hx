package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;

enum abstract TileType(Int) to Int
{
	var VOID = 0;
	var WALL = 1;
	var ROOM = 2;
	var HALL = 3;
	var DOOR = 4;
}

class TestState extends FlxState
{
	var player:Player;

	var bat:Bat;
	var cam:FlxCamera;

	var tileMap:FlxTilemap;

	override public function create()
	{
		bat = new Bat(300, 450);
		add(bat);

		tileMap = new FlxTilemap();

		tileMap.loadMapFromCSV(AssetPaths.map__csv, AssetPaths.bigBoy__png);
		// tileMap.setTileProperties(TileType.VOID, NONE);
		tileMap.setTileProperties(TileType.WALL, ANY);
		tileMap.setTileProperties(TileType.ROOM, NONE);
		tileMap.follow();
		// tileMap.scale.x = 6;
		// tileMap.scale.y = 6;

		// tileMap.up

		add(tileMap);

		tileMap.screenCenter();

		var startPoint = tileMap.getTileCoordsByIndex(FlxG.random.getObject(tileMap.getTileInstances(ROOM)));
		player = new Player(startPoint.x, startPoint.y);

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.reset(cam);
		cam.target = player;
		add(player);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		charMovement(player);
		FlxG.collide(player, tileMap);

		bat.attack(player, bat);
	}

	public function charMovement(sprite:Player)
	{
		if (FlxG.keys.pressed.D) // moving sprite to the right when D is pressed
		{
			sprite.animation.play("runLeft");
			sprite.velocity.x = 50;
		}
		if (FlxG.keys.justReleased.D) // stopping movement once it is released
		{
			sprite.animation.play("standingLeft");
			sprite.velocity.x = 0;
		}
		if (FlxG.keys.pressed.A) // moving sprite move left when A is pressed
		{
			sprite.animation.play("runLeft");
			sprite.velocity.x = -50;
		}
		if (FlxG.keys.justReleased.A) // stopping movement once A is released
		{
			sprite.animation.play("standingLeft");
			sprite.velocity.x = 0;
		}

		if (FlxG.keys.pressed.W) // moving sprite up when W is pressed
		{
			sprite.animation.play("runUp");
			sprite.velocity.y = -50;
		}
		if (FlxG.keys.justReleased.W) // stopping movement once it is released
		{
			sprite.animation.play("standingUP");
			sprite.velocity.y = 0;
		}
		if (FlxG.keys.pressed.S) // moving sprite down when S is pressed
		{
			sprite.animation.play("runDown");
			sprite.velocity.y = 50;
		}
		if (FlxG.keys.justReleased.S) // stopping movement once A is released
		{
			sprite.animation.play("standingDown");
			sprite.velocity.y = 0;
		}

		if (sprite.velocity.x > 0)
			sprite.facing = RIGHT;
		else
			sprite.facing = LEFT;
	}
}
