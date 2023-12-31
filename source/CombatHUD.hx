package;

import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

enum Outcome
{
	NONE;
	ESCAPE;
	VICTORY;
	DEFEAT;
	FINISHED;
}

enum Choice // this is where you make differt moves, ie punch, mage hit idk
{
	FIGHT; // this will have to be changed there is no option other then to fight
	MAGIC;
}

class CombatHUD extends FlxTypedGroup<FlxSprite>
{
	// These public variables will be used after combat has finished to help tell us what happened.
	public var player:Player;
	public var enemy:Enemy;
	public var playerHealth(default, null):Int;
	public var outcome(default, null):Outcome;

	// These are the sprites that we will use to show the combat hud interface
	var background:FlxSprite;
	var playerSprite:Player;
	var enemySprite:Enemy;

	// These variables will be used to track the enemy and player Sprite's health
	var enemyHealth:Int;
	var enemyMaxHealth:Int;
	var enemyHealthBar:FlxBar;
	var playerHealthBar:FlxBar;
	var playerMaxHealth:Int;

	var displayMove:FlxText;

	var damages:Array<FlxText>;

	var pointer:FlxSprite;
	var selected:Choice;
	var choices:Map<Choice, FlxText>;

	var results:FlxText;

	var alpha:Float = 0;
	var wait:Bool = true;

	var fledSound:FlxSound;
	var hurtSound:FlxSound;
	var loseSound:FlxSound;
	var missSound:FlxSound;
	var selectSound:FlxSound;
	var winSound:FlxSound;
	var combatSound:FlxSound;

	var screen:FlxSprite;

	var random:FlxRandom;

	var cam:FlxCamera;
	var center:FlxSprite;

	public function new(player:Player, enemy:Enemy)
	{
		super();

		screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 4, -1, 4);
		var waveSprite = new FlxEffectSprite(screen, [waveEffect]);
		add(waveSprite);

		background = new FlxSprite().loadGraphic(AssetPaths.combatBack__png);

		add(background);

		playerSprite = new Player();
		playerSprite.loadGraphic(AssetPaths.combatMainCharacterTexture__png, true, 67, 67);

		playerSprite.animation.add("idle", [0, 1, 2, 1, 0], 3, true);
		playerSprite.animation.play("idle");
		playerSprite.setPosition(200, 200);
		playerSprite.scale.set(1.5, 1.5);
		add(playerSprite);

		enemySprite = new Enemy(400, 100, enemy.bType);
		enemySprite.setPosition(400, 100);

		if (enemy.bType == MINI)
			enemySprite.scale.set(.9, .9);
		else
			enemySprite.scale.set(1.5, 2);
		add(enemySprite);

		center = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		center.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		center.alpha = 0;

		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.target = center;

		playerHealthBar = new FlxBar(playerSprite.x - 50, playerSprite.y - 60, LEFT_TO_RIGHT, 100, 10);
		playerHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
		add(playerHealthBar);

		enemyHealthBar = new FlxBar(playerSprite.x + 200, playerSprite.y - 150, LEFT_TO_RIGHT, 100, 10);
		enemyHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
		add(enemyHealthBar);

		var moveBox = new FlxSprite(0, 300);
		moveBox.makeGraphic(640, 300, FlxColor.BLACK);
		moveBox.alpha = 0.5;
		add(moveBox);

		var divider = new FlxSprite(0, 300);
		divider.makeGraphic(640, 10, FlxColor.WHITE);
		divider.alpha = 0.5;
		add(divider);

		// create  choices and add them to the group.
		choices = new Map();
		choices[FIGHT] = new FlxText(50, 350, 85, "FIGHT", 22);
		choices[MAGIC] = new FlxText(50, 400, 85, "MAGIC", 22);

		add(choices[FIGHT]);

		pointer = new FlxSprite(background.x + 10, choices[FIGHT].y + (choices[FIGHT].height / 2) - 8, AssetPaths.pointer__png);
		pointer.visible = false;
		add(pointer);

		add(choices[MAGIC]);
		pointer = new FlxSprite(background.x + 10, choices[MAGIC].y + (choices[MAGIC].height / 2) - 8, AssetPaths.pointer__png);
		pointer.visible = false;
		add(pointer);

		displayMove = new FlxText(150, 350, " Attack", 22);
		displayMove.visible = false;
		add(displayMove);

		damages = new Array<FlxText>();
		damages.push(new FlxText(0, 0, 70));
		damages.push(new FlxText(0, 0, 70));
		for (d in damages)
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(SHADOW, FlxColor.RED);
			d.setFormat(null, 20, FlxColor.WHITE, FlxTextAlign.CENTER);

			d.visible = false;
			add(d);
		}

		// create  results text object
		results = new FlxText(background.x + 2, background.y + 9, 116, "", 18);
		results.alignment = CENTER;
		results.color = FlxColor.YELLOW;
		results.setBorderStyle(SHADOW, FlxColor.GRAY);
		results.visible = false;
		add(results);

		// mark this object as not active and not visible
		active = false;
		visible = false;

		fledSound = FlxG.sound.load(AssetPaths.debug_sound__wav);
		hurtSound = FlxG.sound.load(AssetPaths.debug_sound__wav);
		loseSound = FlxG.sound.load(AssetPaths.MissionFailure__wav);
		missSound = FlxG.sound.load(AssetPaths.debug_sound__wav);
		selectSound = FlxG.sound.load(AssetPaths.Selection__wav);
		winSound = FlxG.sound.load(AssetPaths.Victory__wav);
		combatSound = FlxG.sound.load(AssetPaths.Gunshot__wav);
	}

	public function initCombat(player:Player, enemy:Enemy)
	{
		screen.drawFrame();
		var screenPixels = screen.framePixels;

		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));

		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(),
			new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));

		combatSound.play();
		this.playerHealth = player.getCombatHealth(); // we set playerHealth variable to the value that was passed to us
		this.enemy = enemy; // set our enemySprite object to the one passed to us

		this.player = new Player(player.x, player.y);
		this.player.weapon = player.weapon;
		this.player.magic = player.magic;

		// set up player and enemy health
		playerMaxHealth = playerHealth;
		enemyMaxHealth = enemyHealth = Std.int(enemy.getHealth()); // each enemySprite will have health based on their type
		playerHealthBar.value = 100;
		enemyHealthBar.value = 100;

		wait = true;
		results.text = "";
		pointer.visible = false;
		results.visible = false;
		outcome = NONE;
		selected = FIGHT; // fight
		movePointer();

		visible = true; // make hud visible

		// do a numeric tween to fade in combat hud
		FlxTween.num(0, 1, .66, {ease: FlxEase.circOut, onComplete: finishFadeIn}, updateAlpha);
	}

	function updateAlpha(alpha:Float) // sets transparncy of sprites
	{
		this.alpha = alpha;
		forEach(function(sprite) sprite.alpha = alpha);
	}

	// COOL FADES
	function finishFadeIn(_)
	{
		active = true;
		wait = false;
		pointer.visible = true;
		selectSound.play();
	}

	function finishFadeOut(_)
	{
		active = false;
		visible = false;
		outcome = FINISHED;
	}

	override public function update(elapsed:Float)
	{
		if (!wait) // if wait. don't do
		{
			updateKeyboardInput();
		}
		super.update(elapsed);
	}

	function updateKeyboardInput()
	{
		// setup some simple flags to see which keys are pressed.
		var up:Bool = false;
		var down:Bool = false;
		var fire:Bool = false;

		// check to see any keys are pressed and set the cooresponding flags.
		if (FlxG.keys.anyJustReleased([SPACE, X, ENTER]))
		{
			fire = true;
		}
		else if (FlxG.keys.anyJustReleased([W, UP]))
		{
			up = true;
		}
		else if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			down = true;
		}

		// based on which flags are set, do the specified action
		if (fire)
		{
			selectSound.play();
			makeChoice(); // when the playerSprite chooses either option, we call this function to process their selection
		}
		if (up || down)
		{
			// if the playerSprite presses up or down, we move the cursor up or down (with wrapping)
			selected = if (selected == FIGHT) MAGIC else FIGHT;
			selectSound.play();
			movePointer();
		}
	}

	// pointer placement
	function movePointer()
	{
		pointer.y = choices[selected].y + (choices[selected].height / 2) - 8;
	}

	// PLAYER CHOICE
	function makeChoice()
	{
		pointer.visible = false; // hide our pointer
		switch (selected) // check which item was selected when the playerSprite picked it
		{
			case FIGHT:
				// if FIGHT was picked...
				// ...the playerSprite attacks the enemySprite first
				// they have an 85% chance to hit the enemySprite
				if (FlxG.random.bool(85))
				{
					var damage = player.weapon.getDamage();

					// if they hit, deal damage to the enemySprite depennding on weapon equiped
					damages[1].text = damage + "";
					displayMove.text = "Fight Selected";
					FlxTween.tween(enemySprite, {x: enemySprite.x + 4}, 0.1, {
						onComplete: function(_)
						{
							FlxTween.tween(enemySprite, {x: enemySprite.x - 4}, 0.1);
						}
					});

					hurtSound.play();
					enemyHealth -= damage;
					enemyHealthBar.value = (enemyHealth / enemyMaxHealth) * 100; // change the enemySprite's health bar
				}
				else // if miss attack
				{
					// change our damage text to show that we missed!
					damages[1].text = "MISS!";
					missSound.play();
				}

				// position the damage text over the enemySprite, and set it's alpha to 0 but it's visible to true (so that it gets draw called on it)
				damages[1].x = enemySprite.x + 2 - (damages[1].width / 2);
				damages[1].y = enemySprite.y + 4 - (damages[1].height / 2);
				damages[1].alpha = 0;
				damages[1].visible = true;

				// if the enemySprite is still alive, it will swing back!
				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				// setup 2 tweens to allow the damage indicators to fade in and float up from the sprites
				FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);

			case MAGIC:
				// if MAGIC  35% hit chance
				if (FlxG.random.bool(35))
				{
					// magic has a chance of not hitting or dealing big damage but low hit rate
					var mDamage = player.magic.getMagDamage();
					displayMove.text = "Magic Selected";
					mDamage = mDamage * FlxG.random.int(0, 10);

					damages[1].text = mDamage + "";
					FlxTween.tween(enemySprite, {x: enemySprite.x + 4}, 0.1, {
						onComplete: function(_)
						{
							FlxTween.tween(enemySprite, {x: enemySprite.x - 4}, 0.1);
						}
					});
					hurtSound.play();
					enemyHealth -= mDamage;
					enemyHealthBar.value = (enemyHealth / enemyMaxHealth) * 100; // change the enemySprite's health bar
				}
				else
				{
					// change our damage text to show that we missed!
					damages[1].text = "MISS!";
					missSound.play();
				}

				// position the damage text over the enemySprite, and set it's alpha to 0 but it's visible to true (so that it gets draw called on it)
				damages[1].x = enemySprite.x + 2 - (damages[1].width / 2);
				damages[1].y = enemySprite.y + 4 - (damages[1].height / 2);
				damages[1].alpha = 0;
				damages[1].visible = true;

				// if the enemySprite is still alive, it will swing back!
				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				// setup 2 tweens to allow the damage indicators to fade in and float up from the sprites
				FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
		}

		// regardless of what happens wait
		wait = true;
	}

	function enemyAttack()
	{
		// enemy has 70% chance of hit
		if (FlxG.random.bool(70))
		{
			// if hit damage to the playerSprite
			FlxG.camera.flash(FlxColor.RED, .2);
			FlxG.camera.shake(0.01, 0.2);
			hurtSound.play();
			damages[0].text = enemy.getAtkDamage() + "";

			playerHealth = playerHealth - enemy.getAtkDamage();

			playerHealthBar.value = (playerHealth / playerMaxHealth) * 100;
		}
		else
		{
			// if misses
			damages[0].text = "MISS!";
			missSound.play();
		}

		// setup the combat text to show up over the playerSprite and fade in/raise up
		damages[0].x = playerSprite.x + 2 - (damages[0].width / 2);
		damages[0].y = playerSprite.y + 4 - (damages[0].height / 2);
		damages[0].alpha = 0;
		damages[0].visible = true;
	}

	// functions that assit with tweening of damage on screen
	// moves counter up
	function updateDamageY(damageY:Float)
	{
		damages[0].y = damages[1].y = damageY;
	}

	// used to adjust damage counter transparency
	function updateDamageAlpha(damageAlpha:Float)
	{
		damages[0].alpha = damages[1].alpha = damageAlpha;
	}

	// makes damage counter disappear
	function doneDamageIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
	}

	/**
	 * This function is triggered when our results text has finished fading in. If we're not defeated, we will fade out the entire hud after a short delay
	 */
	function doneResultsIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1}, updateAlpha);
	}

	function doneDamageOut(_)
	{
		damages[0].visible = false;
		damages[1].visible = false;
		damages[0].text = "";
		damages[1].text = "";

		if (playerHealth <= 0)
		{
			// if the playerSprite's health is 0, we show the defeat message on the screen and fade it in
			outcome = DEFEAT;
			loseSound.play();
			results.text = "DEFEAT!"; // rename for the story type of the game
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else if (enemyHealth <= 0)
		{
			// if the enemySprite's health is 0, we show the victory message
			outcome = VICTORY;
			winSound.play();
			results.text = "VICTORY!"; // rename for the story type of the game
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else
		{
			// both are still alive, so we reset and have the playerSprite pick their next action
			wait = false;
			pointer.visible = true;
		}
	}
}
