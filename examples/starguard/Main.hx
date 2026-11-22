import c64.*;
import haxe64.Types;
import haxe64.SpriteArt;

/**
	STAR GUARD - a small shoot'em up for the C64, written in Haxe.

	Controls: joystick in port 2, or keyboard A / D = left / right, SPACE = fire.
**/
enum GameState {
	Title;
	Playing;
	GameOver;
}

/** An alien ship. 6 of them live in a fixed pool, each owns one hardware sprite (2-7). **/
@:pool(6)
class Alien {
	public var x:Int;
	public var y:Int;
	public var dx:Int;
	public var sprite:U8;
	public var dying:U8; // > 0 while the explosion is playing

	public function new(sprite:Int) {
		this.sprite = sprite;
		spawn(1);
	}

	public function spawn(level:Int) {
		x = 30 + Std.random(280);
		y = 64 + Std.random(40);
		dx = Std.random(2) == 0 ? -level : level;
		dying = 0;
		Sprite.setColor(sprite, colorFor(sprite));
	}

	static function colorFor(n:Int):Int {
		return switch n {
			case 2: Color.LIGHT_GREEN;
			case 3: Color.CYAN;
			case 4: Color.LIGHT_RED;
			case 5: Color.YELLOW;
			case 6: Color.PURPLE;
			case _: Color.ORANGE;
		}
	}

	/** Returns true when the alien got past the player. **/
	public function update(level:Int):Bool {
		if (dying > 0) {
			dying--;
			Sprite.setColor(sprite, (dying & 2) != 0 ? Color.WHITE : Color.RED);
			if (dying == 0) spawn(level);
			Sprite.setPos(sprite, x, y);
			return false;
		}
		x += dx;
		if (x < 24 || x > 320) {
			dx = -dx;
			x += dx;
			y += 10;
		}
		Sprite.setPos(sprite, x, y);
		return y > 222;
	}

	public function explode() {
		dying = 16;
	}
}

class Main {
	static inline final SHIP = 0;
	static inline final BULLET = 1;
	static inline final SHIP_SHAPE = 13; // $0340
	static inline final BULLET_SHAPE = 14; // $0380
	static inline final ALIEN_SHAPE = 15; // $03C0
	static inline final SHIP_Y = 224;

	static final shipShape:Array<U8> = SpriteArt.make([
		"...........##...........",
		"...........##...........",
		"..........####..........",
		"..........####..........",
		".........##..##.........",
		".........######.........",
		"....#....######....#....",
		"....#...########...#....",
		"....#..##########..#....",
		"...###.###.##.###.###...",
		"...###################..",
		"..#####################.",
		"..####...######...####..",
		"..###.....####.....###..",
		"...#.......##.......#...",
	]);

	static final bulletShape:Array<U8> = SpriteArt.make([
		"...........##...........",
		"...........##...........",
		"..........####..........",
		"...........##...........",
		"...........##...........",
		"...........##...........",
		"...........##...........",
	]);

	static final alienShape:Array<U8> = SpriteArt.make([
		"",
		".....##..........##.....",
		"......##........##......",
		".....##############.....",
		"....####..####..####....",
		"...##################...",
		"...##.############.##...",
		"...##.##........##.##...",
		"......####....####......",
		"",
	]);

	@:size(6) static var aliens:Array<Alien>;

	static var state:GameState = Title;
	static var shipX = 172;
	static var bulletActive = false;
	static var bulletX = 0;
	static var bulletY = 0;
	static var score = 0;
	static var lives:U8 = 3;
	static var level:U8 = 1;
	static var kills:U8 = 0;
	static var fireHeld = false;
	static var shotSound:U8 = 0;
	static var flash:U8 = 0;

	static function flashBorder(color:Int) {
		Vic.border = color;
		flash = 8;
	}

	static function main() {
		initHardware();
		for (i in 0...6) aliens[i] = new Alien(i + 2);
		showTitle();
		while (true) {
			Vic.waitFrame();
			switch state {
				case Title:
					if (firePressed()) startGame();
				case Playing:
					updateShip();
					updateBullet();
					updateAliens();
					updateSound();
				case GameOver:
					updateSound();
					if (firePressed()) showTitle();
			}
		}
	}

	// ------------------------------------------------------------------ setup

	static function initHardware() {
		Vic.border = Color.BLACK;
		Vic.background = Color.BLACK;
		Sprite.load(SHIP_SHAPE, shipShape);
		Sprite.load(BULLET_SHAPE, bulletShape);
		Sprite.load(ALIEN_SHAPE, alienShape);

		Sprite.setShape(SHIP, SHIP_SHAPE);
		Sprite.setColor(SHIP, Color.LIGHT_BLUE);
		Sprite.setShape(BULLET, BULLET_SHAPE);
		Sprite.setColor(BULLET, Color.WHITE);
		for (i in 2...8) Sprite.setShape(i, ALIEN_SHAPE);

		Sid.volume(15);
		Sid.setEnvelope(0, 0, 6, 0, 0); // shot
		Sid.setPulseWidth(0, 0x0800);
		Sid.setEnvelope(1, 0, 10, 0, 0); // explosion
	}

	/** Random background stars; rows top..bottom are kept free for text. **/
	static function drawStars(keepFreeTop:Int, keepFreeBottom:Int) {
		for (i in 0...60) {
			var x = Std.random(40);
			var y = 2 + Std.random(23);
			if (y >= keepFreeTop && y <= keepFreeBottom) continue;
			Screen.put(x, y, Std.random(4) == 0 ? 42 : 46, Std.random(2) == 0 ? Color.DARK_GREY : Color.GREY);
		}
	}

	static function showTitle() {
		state = Title;
		Vic.spriteEnable = 0;
		Screen.setTextColor(Color.WHITE);
		Screen.clear();
		drawStars(5, 20);
		Screen.setTextColor(Color.YELLOW);
		Screen.print(15, 7, "STAR GUARD");
		Screen.setTextColor(Color.LIGHT_BLUE);
		Screen.print(11, 9, "WRITTEN IN HAXE");
		Screen.setTextColor(Color.GREY);
		Screen.print(8, 13, "JOYSTICK PORT 2  OR");
		Screen.print(8, 14, "A / D = MOVE  SPACE = FIRE");
		Screen.setTextColor(Color.WHITE);
		Screen.print(10, 18, "PRESS FIRE TO START");
	}

	static function startGame() {
		state = Playing;
		score = 0;
		lives = 3;
		level = 1;
		kills = 0;
		shipX = 172;
		bulletActive = false;
		Screen.setTextColor(Color.WHITE);
		Screen.clear();
		drawStars(0, 0);
		Screen.setTextColor(Color.GREY);
		Screen.print(0, 0, "SCORE");
		Screen.print(16, 0, "LEVEL");
		Screen.print(31, 0, "LIVES");
		drawHud();
		for (i in 0...6) aliens[i].spawn(level);
		Sprite.setPos(SHIP, shipX, SHIP_Y);
		Vic.spriteEnable = 0xFD; // everything but the bullet
	}

	static function gameOver() {
		state = GameOver;
		Vic.spriteEnable = 0;
		Screen.setTextColor(Color.RED);
		Screen.print(15, 11, "GAME OVER");
		Screen.setTextColor(Color.WHITE);
		Screen.print(10, 14, "PRESS FIRE TO RETRY");
		explosionSound();
	}

	// ------------------------------------------------------------------ input

	#if autoplay
	// build with -D autoplay: the game plays itself (for headless testing)
	static var autoFrame = 0;

	static function left():Bool return (autoFrame & 64) != 0;

	static function right():Bool return (autoFrame & 64) == 0;

	static function fireDown():Bool return ((++autoFrame) & 8) != 0;
	#else
	static inline function left():Bool {
		return Joy.left() || Keyboard.isDown(Keyboard.A);
	}

	static inline function right():Bool {
		return Joy.right() || Keyboard.isDown(Keyboard.D);
	}

	static inline function fireDown():Bool {
		return Joy.fire() || Keyboard.isDown(Keyboard.SPACE);
	}
	#end

	/** True only on the frame the button goes down. **/
	static function firePressed():Bool {
		var down = fireDown();
		var pressed = down && !fireHeld;
		fireHeld = down;
		return pressed;
	}

	// ------------------------------------------------------------------ game

	static function updateShip() {
		if (left() && shipX > 26) shipX -= 3;
		if (right() && shipX < 318) shipX += 3;
		Sprite.setX(SHIP, shipX);
		if (firePressed() && !bulletActive) {
			bulletActive = true;
			bulletX = shipX;
			bulletY = SHIP_Y - 16;
			Sprite.setPos(BULLET, bulletX, bulletY);
			Sprite.enable(BULLET, true);
			shotSound = 8;
			Sid.setFreq(0, 0x3000);
			Sid.noteOn(0, Sid.PULSE);
		}
	}

	static function updateBullet() {
		if (!bulletActive) return;
		bulletY -= 7;
		if (bulletY < 40) {
			bulletActive = false;
			Sprite.enable(BULLET, false);
			return;
		}
		Sprite.setY(BULLET, bulletY);
	}

	static inline function abs(v:Int):Int {
		return v < 0 ? -v : v;
	}

	static function updateAliens() {
		for (i in 0...6) {
			var a = aliens[i];
			if (a.update(level)) {
				loseLife();
				a.spawn(level);
				continue;
			}
			if (a.dying > 0) continue;
			// bullet hit? (alien body is ~16x8 px around the sprite center)
			if (bulletActive && abs(bulletX - a.x) < 12 && abs((bulletY + 2) - (a.y + 5)) < 8) {
				bulletActive = false;
				Sprite.enable(BULLET, false);
				a.explode();
				explosionSound();
				addScore(10 * level);
			}
			// alien rams the ship
			if (abs(a.x - shipX) < 18 && abs(a.y - SHIP_Y) < 14) {
				a.explode();
				explosionSound();
				loseLife();
			}
		}
	}

	static function addScore(points:Int) {
		score += points;
		kills++;
		if (kills >= 12 && level < 4) {
			kills = 0;
			level++;
			flashBorder(Color.GREEN);
		}
		drawHud();
	}

	static function loseLife() {
		if (lives > 0) lives--;
		flashBorder(Color.RED);
		drawHud();
		if (lives == 0) gameOver();
	}

	static function drawHud() {
		Screen.setTextColor(Color.WHITE);
		Screen.printNum(6, 0, score, 5);
		Screen.printNum(22, 0, level, 1);
		Screen.printNum(37, 0, lives, 1);
	}

	// ------------------------------------------------------------------ sound

	static function explosionSound() {
		Sid.setFreq(1, 0x0600);
		Sid.noteOff(1, Sid.NOISE);
		Sid.noteOn(1, Sid.NOISE);
	}

	static function updateSound() {
		if (shotSound > 0) {
			shotSound--;
			Sid.setFreq(0, 0x1000 + shotSound * 0x0400); // falling pitch
			if (shotSound == 0) Sid.noteOff(0, Sid.PULSE);
		}
		if (flash > 0) {
			flash--;
			if (flash == 0) Vic.border = Color.BLACK;
		}
	}
}
