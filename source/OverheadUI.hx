package;

import Weapons.WeaponType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxBasePreloader;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class OverheadUI extends FlxSpriteGroup
{
	var background:FlxSprite;
	var healthCounter:FlxText;
	var healthIcon:FlxSprite;
	var weaponLogo:FlxSprite;
	var weaponText:FlxText;
	var scrollText:FlxText;
	var magicLogo:FlxSprite;

	public var levelID:Int;

	var lvlCounter:FlxText;
	var magic:MagicAttack = new MagicAttack(0, 0, NOSCROLL);
	var weapon:Weapons = new Weapons(0, 0, FIST);

	var keyLogo:FlxSprite;

	var keyCounter:FlxText;

	public var playerHealth:Int = 3;

	var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 30};

	public function new()
	{
		super();

		background = new FlxSprite().makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		background.drawRect(0, 0, FlxG.width, 1, FlxColor.WHITE);
		healthCounter = new FlxText(16, 2, 0, "3 / 3", 16);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		lvlCounter = new FlxText(520, 2, 0, "5 / 5", 16);
		lvlCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		keyCounter = new FlxText(430, 2, 0, ": 0 / 1", 16);
		keyCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		keyLogo = new FlxSprite(400, 2);
		keyLogo.loadGraphic(AssetPaths.level_key__png);
		keyLogo.scale.set(2, 2);

		weaponText = new FlxText(150, 5, "Weapon: ", 12);
		weaponText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		scrollText = new FlxText(280, 5, "Scroll:", 12);
		scrollText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		weaponLogo = new FlxSprite(230, 5).makeGraphic(32, 32, FlxColor.TRANSPARENT);
		magicLogo = new FlxSprite(340, -10).makeGraphic(32, 32, FlxColor.TRANSPARENT);

		add(background);
		add(healthCounter);
		add(weaponText);
		add(weaponLogo);
		add(magicLogo);
		add(lvlCounter);
		add(scrollText);
		add(keyCounter);
		add(keyLogo);

		scrollFactor.set(0, 0);
	}

	public function updateHUD()
	{
		remove(weaponLogo);
		healthCounter.text = playerHealth + " / 3";
		weaponLogo.loadGraphic(weapon.graphicPath);
		magicLogo.loadGraphic(magic.mGraphicPath);

		// lvlCounter.text = levelID + "";

		weaponText.text = weapon.type + "";
		scrollText.text = magic.type + "";
		magicLogo.scale.set(0.5, 0.5);

		add(magicLogo);
		add(weaponLogo);
	}

	public function setWeapon(weapon_:Weapons)
	{
		weapon = weapon_;
		updateHUD();
	}

	public function setMagic(magic_:MagicAttack)
	{
		magic = magic_;
		updateHUD();
	}
}
