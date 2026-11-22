import flixel.FlxSprite;

@:pool(12)
class Coin extends FlxSprite {
	public function new(x:Int, y:Int) {
		super(x, y, Assets.COIN);
		moves = false;
		animation.add("spin", [0, 1], 4);
		animation.play("spin");
	}
}
