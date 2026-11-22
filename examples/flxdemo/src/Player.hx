import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound.FlxSfx;
import flixel.util.FlxDirectionFlags;

class Player extends FlxSprite {
	static inline final SPEED = 90;
	static inline final JUMP = 230;
	static inline final GRAVITY = 600;

	public function new(x:Int, y:Int) {
		super(x, y, Assets.PLAYER);
		// a slightly smaller hit box than the 24 x 21 picture
		width = 14;
		height = 16;
		offset.set(5, 5);
		acceleration.y = GRAVITY;
		maxVelocity.set(SPEED, 300);
		drag.x = 600;
		animation.add("idle", [0], 1);
		animation.add("run", [1, 0, 2, 0], 10);
		animation.add("jump", [3], 1);
	}

	override public function update():Void {
		acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) {
			acceleration.x = -800;
			flipX = true;
		}
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) {
			acceleration.x = 800;
			flipX = false;
		}
		var jump = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.FIRE || FlxG.keys.justPressed.W;
		if (jump && isTouching(FlxDirectionFlags.FLOOR)) {
			velocity.y = -JUMP;
			FlxG.sound.play(FlxSfx.JUMP);
		}
		// short hop when the jump key is released early
		if (velocity.y < -60 && !(FlxG.keys.pressed.SPACE || FlxG.keys.pressed.UP || FlxG.keys.pressed.FIRE || FlxG.keys.pressed.W)) velocity.y = -60;

		if (!isTouching(FlxDirectionFlags.FLOOR)) animation.play("jump");
		else if (velocity.x != 0) animation.play("run");
		else animation.play("idle");
		super.update();
	}
}
