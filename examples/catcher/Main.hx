import c64.*;
import haxe64.Types;

/** A falling star. Instances come from a fixed pool of 6. **/
@:pool(6)
class Star {
	public var x:Int;
	public var y:Int;
	public var speed:U8;
	public var slot:U8;

	public function new(slot:Int) {
		this.slot = slot;
		reset();
	}

	public function reset() {
		x = 30 + Std.random(280);
		y = 30 + Std.random(40);
		speed = 1 + Std.random(3);
	}

	public function update():Bool {
		y += speed;
		Sprite.setPos(slot, x, y);
		return y > 245;
	}
}

class Main {
	static final PLAYER = 0;
	static final PLAYER_SHAPE = 13; // block 13 = $0340
	static final STAR_SHAPE = 14;   // block 14 = $0380

	static var playerShape:Array<U8> = [
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0xC0, 0x00, 0x03, 0xC0, 0x00, 0x03, 0xC0, 0x00, 0x03,
		0xFF, 0xFF, 0xFF, 0x7F, 0xFF, 0xFE, 0x3F, 0xFF, 0xFC, 0x1F, 0xFF, 0xF8,
		0x0F, 0xFF, 0xF0, 0x00
	];

	static var starShape:Array<U8> = [
		0x00, 0x18, 0x00, 0x00, 0x18, 0x00, 0x00, 0x3C, 0x00, 0x00, 0x3C, 0x00,
		0x7F, 0xFF, 0xFE, 0x3F, 0xFF, 0xFC, 0x0F, 0xFF, 0xF0, 0x07, 0xFF, 0xE0,
		0x07, 0xFF, 0xE0, 0x0F, 0xE7, 0xF0, 0x0F, 0x81, 0xF0, 0x1E, 0x00, 0x78,
		0x18, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00
	];

	@:size(6) static var stars:Array<Star>;
	static var px = 160;
	static var score = 0;
	static var lives:U8 = 3;
	static var beep:U8 = 0;

	static function main() {
		setup();
		while (lives > 0) {
			Vic.waitFrame();
			updatePlayer();
			updateStars();
			updateSound();
		}
		Screen.setTextColor(Color.RED);
		Screen.print(15, 12, "GAME OVER");
		Sid.noteOff(0, Sid.TRIANGLE);
		while (true) Vic.waitFrame();
	}

	static function setup() {
		Vic.border = Color.DARK_GREY;
		Vic.background = Color.BLACK;
		Screen.setTextColor(Color.WHITE);
		Screen.clear();
		Screen.print(1, 0, "SCORE");
		Screen.print(30, 0, "LIVES");
		drawHud();

		Sprite.load(PLAYER_SHAPE, playerShape);
		Sprite.load(STAR_SHAPE, starShape);

		Sprite.setShape(PLAYER, PLAYER_SHAPE);
		Sprite.setColor(PLAYER, Color.LIGHT_BLUE);
		Sprite.setPos(PLAYER, px, 220);
		Sprite.enable(PLAYER, true);

		for (i in 1...7) {
			var s = new Star(i);
			stars[i - 1] = s;
			Sprite.setShape(i, STAR_SHAPE);
			Sprite.setColor(i, Color.YELLOW);
			Sprite.enable(i, true);
		}

		Sid.volume(15);
		Sid.setEnvelope(0, 0, 9, 0, 0);
	}

	static function updatePlayer() {
		if (Joy.left() && px > 24) px -= 3;
		if (Joy.right() && px < 320) px += 3;
		Sprite.setX(PLAYER, px);
	}

	static function updateStars() {
		var hits = Vic.spriteCollision; // reading clears the register
		for (i in 0...6) {
			var s = stars[i];
			var bit = 2 << i;
			if ((hits & 1) != 0 && (hits & bit) != 0) {
				score += 10;
				drawHud();
				playBeep(0x2000);
				s.reset();
			} else if (s.update()) {
				lives--;
				drawHud();
				playBeep(0x0800);
				s.reset();
			}
		}
	}

	static function playBeep(freq:Int) {
		Sid.setFreq(0, freq);
		Sid.noteOn(0, Sid.TRIANGLE);
		beep = 6;
	}

	static function updateSound() {
		if (beep > 0) {
			beep--;
			if (beep == 0) Sid.noteOff(0, Sid.TRIANGLE);
		}
	}

	static function drawHud() {
		Screen.setTextColor(Color.YELLOW);
		Screen.printNum(7, 0, score, 5);
		Screen.printNum(36, 0, lives, 1);
	}
}
