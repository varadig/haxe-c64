import flixel.system.FlxAssets;

/** All graphics, converted from PNG / CSV at compile time. **/
class Assets {
	public static final PLAYER = FlxAssets.sprite("assets/player.png", 12, 21);
	public static final COIN = FlxAssets.sprite("assets/coin.png", 6, 8, true, false);
	public static final ENEMY = FlxAssets.sprite("assets/enemy.png", 12, 12);
	public static final TILES = FlxAssets.tiles("assets/tiles.png", 16);
	public static final LEVEL = FlxAssets.csv("assets/level.csv");
}
