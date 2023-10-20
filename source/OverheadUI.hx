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
	var weapon:Weapons = new Weapons(0, 0, EMPTY);

	public var playerHealth:Int = 3;

	var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 30};

	public function new()
	{
		super();

		background = new FlxSprite().makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		background.drawRect(0, 0, FlxG.width, 1, FlxColor.WHITE);

		healthCounter = new FlxText(16, 2, 0, "3 / 3", 16);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);

		weaponLogo = new FlxSprite(360, 5).makeGraphic(32, 32, FlxColor.WHITE);

		add(background);
		add(healthCounter);
		add(weaponLogo);
		scrollFactor.set(0, 0);
	}

	public function updateHUD()
	{
		remove(weaponLogo);
		healthCounter.text = playerHealth + " / 3";
		weaponLogo.loadGraphic(weapon.graphicPath);

		add(weaponLogo);
	}

	public function setWeapon(weapon_:Weapons)
	{
		weapon = weapon_;
		updateHUD();
	}
}
