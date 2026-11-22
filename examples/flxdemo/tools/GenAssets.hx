import haxe.io.Bytes;

/** Draws the demo's PNG assets (run: haxe -lib format -cp tools --run GenAssets). **/
class GenAssets {
	// C64 colors (VICE palette)
	static final COLORS = [
		"." => -1, "0" => 0x000000, "1" => 0xFFFFFF, "2" => 0x68372B, "3" => 0x70A4B2, "4" => 0x6F3D86, "5" => 0x588D43, "6" => 0x352879,
		"7" => 0xB8C76F, "8" => 0x6F4F25, "9" => 0x433900, "a" => 0x9A6759, "b" => 0x444444, "c" => 0x6C6C6C, "d" => 0x9AD284, "e" => 0x6C5EB5,
		"f" => 0x959595
	];

	static function save(path:String, frames:Array<Array<String>>) {
		var fw = frames[0][0].length, fh = frames[0].length;
		var w = fw * frames.length, h = fh;
		var b = Bytes.alloc(w * h * 4);
		for (f in 0...frames.length) for (y in 0...fh) for (x in 0...fw) {
			var c = COLORS.get(frames[f][y].charAt(x));
			var o = (y * w + f * fw + x) * 4;
			if (c == null || c < 0) {
				b.set(o, 0);
				b.set(o + 1, 0);
				b.set(o + 2, 0);
				b.set(o + 3, 0);
			} else {
				b.set(o, 255);
				b.set(o + 1, (c >> 16) & 255);
				b.set(o + 2, (c >> 8) & 255);
				b.set(o + 3, c & 255);
			}
		}
		var out = sys.io.File.write(path, true);
		new format.png.Writer(out).write(format.png.Tools.build32ARGB(w, h, b));
		out.close();
	}

	static function main() {
		// player: 12 x 21 multicolor (1 pixel = 1 wide C64 pixel); 0 = black outline (mc0), 1 = white (mc1), e = own color
		var head = [
			"....0000....", "...0eeee0...", "..0e1ee1e0..", "..0e0ee0e0..", "..0eeeeee0..", "...0e11e0...", "....0000....",
		];
		var body = ["...0eeee0...", "..0eeeeee0..", ".0e0eeee0e0.", ".0e0eeee0e0.", "..0.eeee.0..", "...0eeee0...", "...0e00e0..."];
		var standLegs = ["...0e00e0...", "...0e00e0...", "...0e00e0...", "..00e00e00..", "..000..000..", "............", "............"];
		var run1 = ["..0e0..0e0..", ".0e0....0e0.", ".0e0....0e0.", "00e0.....000", "000.........", "............", "............"];
		var run2 = ["....0ee0....", "....0ee0....", "...0e00e0...", "...0e0.0e0..", "..000..000..", "............", "............"];
		var jump = [".0e0....0e0.", ".0e0....0e0.", "..00....00..", "............", "............", "............", "............"];
		save("assets/player.png", [head.concat(body).concat(standLegs), head.concat(body).concat(run1), head.concat(body).concat(run2), head.concat(body).concat(jump)]);

		// coin: 6 x 8 (fat pixels), yellow with white shine; 2 frames
		save("assets/coin.png", [
			["..77..", ".7117.", "771777", "717777", "777777", "777777", ".7777.", "..77.."],
			["..77..", "..77..", ".7117.", ".7177.", ".7777.", ".7777.", "..77..", "..77.."]
		]);

		// enemy: 12 x 12 red crab; 2 frames
		var crabTop = ["..0......0..", "...0....0...", "..00000000..", ".0222222220.", "0220122101220", "022222222220"];
		var cA = ["............", "....0000....", "...022220...", "..02122120..", ".0222222220.", ".0222222220.", "..02222220..", "..0.0..0.0..", ".0..0..0..0.", "............", "............", "............"];
		var cB = ["............", "....0000....", "...022220...", "..02122120..", ".0222222220.", ".0222222220.", "..02222220..", "...0.00.0...", "..0..00..0..", "............", "............", "............"];
		save("assets/enemy.png", [cA, cB]);

		// tiles 16 x 16: 0 empty, 1 grass top, 2 dirt, 3 brick, 4 stone
		var empty = [for (_ in 0...16) "................"];
		var grass = [
			"5555555555555555", "5d55d555d55d555d", "d5dd5dd5d5dd5dd5", "5995599559955995", "9999999999999999", "9989999899998999", "9999999999999999",
			"9999989999999989", "9899999999899999", "9999999999999999", "9999899998999999", "9999999999999899", "9989999999999999", "9999999989999999",
			"9999989999999999", "9999999999999999"
		];
		var dirt = [for (y in 0...16) [for (x in 0...16) ((x * 7 + y * 13) % 17 == 0) ? "8" : "9"].join("")];
		var brick = [for (y in 0...16) [for (x in 0...16) (y % 8 == 7 || (x + (y >= 8 ? 8 : 0)) % 16 == 15) ? "9" : "2"].join("")];
		var stone = [for (y in 0...16) [for (x in 0...16) (x == 0 || y == 0) ? "c" : ((x == 15 || y == 15) ? "b" : "b")].join("")];
		save("assets/tiles.png", [empty, grass, dirt, brick, stone]);
	}
}
