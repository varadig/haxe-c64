import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;

@:pool(6)
class Enemy extends FlxSprite {
	public function new(x:Int, y:Int) {
		super(x, y, Assets.ENEMY);
		width = 20;
		height = 12;
		offset.set(2, 0);
		acceleration.y = 600;
		velocity.x = -30;
		animation.add("walk", [0, 1], 4);
		animation.play("walk");
	}

	override public function update():Void {
		// turn around at walls
		if (isTouching(FlxDirectionFlags.LEFT)) velocity.x = 30;
		if (isTouching(FlxDirectionFlags.RIGHT)) velocity.x = -30;
		if (velocity.x == 0) velocity.x = flipX ? 30 : -30;
		flipX = velocity.x > 0;
		super.update();
	}
}
