package flixel.system;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

/**
	Compile-time asset conversion (runs as macros; needs `-lib format` for PNG reading).

	```haxe
	static final PLAYER = FlxAssets.sprite("assets/player.png", 12, 21);   // frames of 12 x 21 (multicolor: 1 PNG pixel = 1 wide C64 pixel)
	static final TILES = FlxAssets.tiles("assets/tiles.png", 16);          // 16 x 16 tiles -> 2 x 2 characters
	static final LEVEL = FlxAssets.csv("assets/level.csv");                // Flixel CSV map
	```

	Colors: every PNG pixel is mapped to the nearest of the 16 C64 colors (alpha < 128 = transparent).
	Multicolor sprites share two colors (defines `flixel64_mc0`, `flixel64_mc1`, default black and white);
	all other colors of a sprite sheet become its own color (the most frequent one).
**/
class FlxAssets {
	#if macro
	static final PALETTE = [
		0x000000, 0xFFFFFF, 0x68372B, 0x70A4B2, 0x6F3D86, 0x588D43, 0x352879, 0xB8C76F, 0x6F4F25, 0x433900, 0x9A6759, 0x444444, 0x6C6C6C, 0x9AD284,
		0x6C5EB5, 0x959595
	];

	static function nearest(r:Int, g:Int, b:Int):Int {
		var best = 0, bd = 1 << 30;
		for (i in 0...16) {
			var p = PALETTE[i];
			var dr = ((p >> 16) & 255) - r, dg = ((p >> 8) & 255) - g, db = (p & 255) - b;
			var d = dr * dr * 3 + dg * dg * 4 + db * db * 2;
			if (d < bd) {
				bd = d;
				best = i;
			}
		}
		return best;
	}

	/** PNG -> width, height and C64 color indices (-1 = transparent). **/
	static function loadPng(path:String, pos:Position):{w:Int, h:Int, px:Array<Int>} {
		if (!sys.FileSystem.exists(path)) Context.error('FlxAssets: file not found: $path (paths are relative to the build directory)', pos);
		var input = sys.io.File.read(path, true);
		var data = new format.png.Reader(input).read();
		input.close();
		var head = format.png.Tools.getHeader(data);
		var bgra = format.png.Tools.extract32(data);
		var px = [];
		for (i in 0...head.width * head.height) {
			var b = bgra.get(i * 4), g = bgra.get(i * 4 + 1), r = bgra.get(i * 4 + 2), a = bgra.get(i * 4 + 3);
			px.push(a < 128 ? -1 : nearest(r, g, b));
		}
		Context.registerModuleDependency(Context.getLocalModule(), path);
		return {w: head.width, h: head.height, px: px};
	}

	static function intDefine(name:String, def:Int):Int {
		var v = Context.definedValue(name);
		return v == null ? def : Std.parseInt(v);
	}

	static function bytesExpr(bytes:Array<Int>, pos:Position):Expr {
		var arr = {expr: EArrayDecl([for (b in bytes) macro $v{b & 255}]), pos: pos};
		return macro($arr : Array<haxe64.Types.U8>);
	}
	#end

	/** A compile-time `-D name=value` as an Int (with a default). **/
	public static macro function define(name:String, def:Int):Expr {
		return macro $v{intDefine(name, def)};
	}

	/**
		Sprite sheet -> C64 sprite frames. Frames are `frameWidth` x `frameHeight` (max 24 x 21; multicolor: up to 12 wide = 1:1 fat pixels,
		13..24 wide = every 2 pixels become one). `flip`: also store mirrored frames for `flipX`.
		Result: [frames, flags (1 multicolor, 2 mirrored), color, width px, height px, 64 bytes per frame ...].
	**/
	public static macro function sprite(path:String, frameWidth:Int, frameHeight:Int, multicolor:Bool = true, flip:Bool = true):Expr {
		var pos = Context.currentPos();
		var img = loadPng(path, pos);
		if (frameHeight > 21) Context.error('FlxAssets.sprite: frame height $frameHeight > 21', pos);
		if (frameWidth > 24 || (multicolor && frameWidth > 24)) Context.error('FlxAssets.sprite: frame width $frameWidth > 24', pos);
		var cols = Std.int(img.w / frameWidth), rows = Std.int(img.h / frameHeight);
		var count = cols * rows;
		if (count == 0) Context.error('FlxAssets.sprite: image is smaller than one frame', pos);
		var mc0 = intDefine("flixel64_mc0", 0), mc1 = intDefine("flixel64_mc1", 1);
		// the sprite's own color: most frequent color that is not a shared multicolor
		var freq = [for (_ in 0...16) 0];
		for (p in img.px) if (p >= 0 && (!multicolor || (p != mc0 && p != mc1))) freq[p]++;
		var own = 0;
		for (i in 1...16) if (freq[i] > freq[own]) own = i;
		if (freq[own] == 0) own = 1;

		function pixel(f:Int, x:Int, y:Int, mirror:Bool):Int {
			var fx = (f % cols) * frameWidth, fy = Std.int(f / cols) * frameHeight;
			var xx = mirror ? frameWidth - 1 - x : x;
			if (xx < 0 || xx >= frameWidth || y >= frameHeight) return -1;
			return img.px[(fy + y) * img.w + fx + xx];
		}
		function frameBytes(f:Int, mirror:Bool):Array<Int> {
			var out = [];
			for (y in 0...21) for (b in 0...3) {
				var v = 0;
				if (multicolor) {
					for (k in 0...4) {
						var mx = b * 4 + k;
						var p = -1;
						if (frameWidth <= 12) p = pixel(f, mx, y, mirror); else {
							p = pixel(f, mx * 2, y, mirror);
							if (p < 0) p = pixel(f, mx * 2 + 1, y, mirror);
						}
						var bits = p < 0 ? 0 : (p == mc0 ? 1 : (p == mc1 ? 3 : 2));
						v = (v << 2) | bits;
					}
				} else {
					for (k in 0...8) v = (v << 1) | (pixel(f, b * 8 + k, y, mirror) >= 0 ? 1 : 0);
				}
				out.push(v);
			}
			out.push(0);
			return out;
		}
		var w = multicolor && frameWidth <= 12 ? frameWidth * 2 : frameWidth;
		var bytes = [count, (multicolor ? 1 : 0) | (flip ? 2 : 0), own, w, frameHeight];
		for (f in 0...count) bytes = bytes.concat(frameBytes(f, false));
		if (flip) for (f in 0...count) bytes = bytes.concat(frameBytes(f, true));
		return bytesExpr(bytes, pos);
	}

	/**
		Tile set -> characters. Tiles are `tileSize` (8 or 16) square, read left to right, top to bottom; tile 0 is usually empty.
		Multicolor: black / transparent is the background, the two most used other colors are shared (`$D022`, `$D023`),
		the rest of each tile uses its own color (0-7). Hires: one color per tile.
		Result: [count, tileSize, multicolor, d022, d023, color per tile ..., 8 bytes per character ...].
	**/
	public static macro function tiles(path:String, tileSize:Int = 16, multicolor:Bool = true):Expr {
		var pos = Context.currentPos();
		if (tileSize != 8 && tileSize != 16) Context.error("FlxAssets.tiles: tileSize must be 8 or 16", pos);
		var img = loadPng(path, pos);
		var cols = Std.int(img.w / tileSize), rows = Std.int(img.h / tileSize);
		var count = cols * rows;
		var per = tileSize == 16 ? 4 : 1;
		if (count * per > 192) Context.error('FlxAssets.tiles: $count tiles need ${count * per} characters, max is 192', pos);
		function px(t:Int, x:Int, y:Int):Int {
			var p = img.px[(Std.int(t / cols) * tileSize + y) * img.w + (t % cols) * tileSize + x];
			return p == 0 ? -1 : p; // black = background
		}
		var freq = [for (_ in 0...16) 0];
		for (t in 0...count) for (y in 0...tileSize) for (x in 0...tileSize) {
			var p = px(t, x, y);
			if (p >= 0) freq[p]++;
		}
		var order = [for (i in 1...16) i];
		order.sort((a, b) -> freq[b] - freq[a]);
		var d022 = order[0], d023 = order[1];
		var colors = [], data = [];
		for (t in 0...count) {
			var tf = [for (_ in 0...16) 0];
			for (y in 0...tileSize) for (x in 0...tileSize) {
				var p = px(t, x, y);
				if (p >= 0 && (!multicolor || (p != d022 && p != d023))) tf[p]++;
			}
			var own = -1;
			for (i in 0...16) if (tf[i] > 0 && (own < 0 || tf[i] > tf[own])) own = i;
			if (own < 0) own = multicolor ? 7 : 1;
			if (multicolor && own > 7) {
				// color RAM of multicolor characters can only hold 0-7: take the closest of those
				var p = PALETTE[own];
				var best = 1, bd = 1 << 30;
				for (i in 1...8) {
					var q = PALETTE[i];
					var dr = ((p >> 16) & 255) - ((q >> 16) & 255), dg = ((p >> 8) & 255) - ((q >> 8) & 255), db = (p & 255) - (q & 255);
					var d = dr * dr + dg * dg + db * db;
					if (d < bd) {
						bd = d;
						best = i;
					}
				}
				own = best;
			}
			colors.push(own);
			var cy = 0;
			while (cy < tileSize) {
				var cx = 0;
				while (cx < tileSize) {
					for (y in 0...8) {
						var v = 0;
						if (multicolor) {
							for (k in 0...4) {
								var p = px(t, cx + k * 2, cy + y);
								if (p < 0) p = px(t, cx + k * 2 + 1, cy + y);
								v = (v << 2) | (p < 0 ? 0 : (p == d022 ? 1 : (p == d023 ? 2 : 3)));
							}
						} else {
							for (k in 0...8) v = (v << 1) | (px(t, cx + k, cy + y) >= 0 ? 1 : 0);
						}
						data.push(v);
					}
					cx += 8;
				}
				cy += 8;
			}
		}
		return bytesExpr([count, tileSize, multicolor ? 1 : 0, d022, d023].concat(colors).concat(data), pos);
	}

	/** Flixel CSV map -> [width lo, width hi, height lo, height hi, tile per byte ...]. **/
	public static macro function csv(path:String):Expr {
		var pos = Context.currentPos();
		if (!sys.FileSystem.exists(path)) Context.error('FlxAssets: file not found: $path', pos);
		Context.registerModuleDependency(Context.getLocalModule(), path);
		var lines = [for (l in sys.io.File.getContent(path).split("\n")) if (StringTools.trim(l) != "") StringTools.trim(l)];
		var rows = [for (l in lines) [for (v in l.split(",")) if (StringTools.trim(v) != "") Std.parseInt(StringTools.trim(v))]];
		var w = rows[0].length, h = rows.length;
		var bytes = [w & 255, w >> 8, h & 255, h >> 8];
		for (r in rows) {
			if (r.length != w) Context.error('FlxAssets.csv: all rows must have $w values', pos);
			for (v in r) bytes.push(v < 0 ? 0 : v);
		}
		return bytesExpr(bytes, pos);
	}
}
