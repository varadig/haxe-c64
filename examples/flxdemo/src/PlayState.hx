import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.system.FlxSound.FlxSfx;
import flixel.util.FlxColor;

class PlayState extends FlxState {
	static var score = 0;
	static var dieTest = 0;
	var dieTimer = 0;

	var map:FlxTilemap;
	var player:Player;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var scoreText:FlxText;

	override public function create():Void {
		score = 0;
		FlxG.camera.bgColor = FlxColor.BLUE;
		FlxG.camera.borderColor = FlxColor.BLUE;
		FlxG.camera.setViewRows(24); // the last row is the HUD

		map = new FlxTilemap();
		map.loadMapFromCSV(Assets.LEVEL, Assets.TILES, 16, 16);
		add(map);

		coins = new FlxTypedGroup<Coin>(12);
		var spots = [56, 120, 184, 360, 408, 600, 648, 760, 840, 904];
		var heights = [80, 140, 140, 48, 48, 64, 64, 32, 80, 80];
		for (i in 0...10) coins.add(new Coin(spots[i], heights[i]));
		add(coins);

		enemies = new FlxTypedGroup<Enemy>(4);
		enemies.add(new Enemy(240, 140));
		enemies.add(new Enemy(560, 140));
		enemies.add(new Enemy(800, 140));
		add(enemies);

		player = new Player(40, 120);
		add(player);
		FlxG.camera.follow(player);

		scoreText = new FlxText(8, 192, 0, "SCORE 0");
		scoreText.color = FlxColor.WHITE;
		add(scoreText);
		var hint = new FlxText(176, 192, 0, "COLLECT ALL COINS");
		hint.color = FlxColor.YELLOW;
		add(hint);
	}

	override public function update():Void {
		super.update();
		FlxG.collide(map, player);
		FlxG.collide(map, enemies);
		FlxG.overlap(player, coins, takeCoin);
		FlxG.overlap(player, enemies, touchEnemy);
		if (player.y > 220) die();
		#if test_die
		// test: die twice (state switch + destroy + recreate), then keep playing
		dieTimer++;
		if (dieTimer == 100 && dieTest < 2) {
			dieTest++;
			die();
		}
		#end
		if (coins.countLiving() == 0) {
			FlxG.sound.play(FlxSfx.POWERUP);
			FlxG.switchState(new WinState());
		}
	}

	static function takeCoin(p:Player, c:Coin):Void {
		c.kill();
		score += 10;
		FlxG.sound.play(FlxSfx.COIN);
		var s:PlayState = cast FlxG.state;
		s.scoreText.text = "SCORE " + score;
	}

	static function touchEnemy(p:Player, e:Enemy):Void {
		// stomp: falling and the feet are on the enemy's upper half
		if (p.velocity.y > 0 && p.y + p.height < e.y + 8) {
			e.kill();
			p.velocity.y = -160;
			score += 25;
			FlxG.sound.play(FlxSfx.HIT);
			FlxG.camera.shake(8);
			var s:PlayState = cast FlxG.state;
			s.scoreText.text = "SCORE " + score;
		} else {
			var s:PlayState = cast FlxG.state;
			s.die();
		}
	}

	function die() {
		FlxG.sound.play(FlxSfx.EXPLOSION);
		FlxG.camera.flash(FlxColor.RED, 10);
		FlxG.switchState(new PlayState());
	}
}
