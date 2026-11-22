package flixel.tile;

import c64.*;
import haxe64.Types;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxDirectionFlags;

/**
	A tile map on the character screen (Flixel: FlxTilemap). Tiles are 8 x 8 (one character) or 16 x 16 (2 x 2).
	Map data: `FlxAssets.csv("assets/level.csv")`; tile graphics: `FlxAssets.tiles("assets/tiles.png", 16)`.
	Tiles below `drawIndex` are empty, tiles from `collideIndex` up are solid (like in Flixel).
	The camera scrolls screen by screen; the map is redrawn when the camera's scroll changes.
**/
@:pool(2)
class FlxTilemap extends FlxObject {
	public var widthInTiles:Int = 0;
	public var heightInTiles:Int = 0;
	public var tileSize:Int = 16;
	/** 16 x 16 tiles (else 8 x 8). All tile math uses constant shifts: variable shifts are slow on the 6502. **/
	var big:Bool = true;
	/** Offset of each map row in the data (no multiplication per lookup); maps up to 64 rows. **/
	@:size(64) var rowOff:Array<U16>;
	var map:Array<U8> = null;
	var gfx:Array<U8> = null;
	var charBase:Int = 64;
	var charsPer:Int = 4;
	var colorsAt:Int = 5;
	var mc:Bool = true;
	public var drawIndex:Int = 1;
	public var collideIndex:Int = 1;
	var drawnX:Int = -1;
	var drawnY:Int = -1;
	var drawnEpoch:U16 = 0;

	public function new() {
		super(0, 0, 0, 0);
		flxKind = 3;
		moves = false;
		immovable = true;
	}

	/** Flixel: loadMapFromCSV(mapData, tileGraphic, tileWidth, tileHeight, autoTile, startingIndex, drawIndex, collideIndex). **/
	public inline function loadMapFromCSV(mapData:Array<U8>, tileGraphic:Array<U8>, tileWidth:Int = 16, tileHeight:Int = 16, ?autoTile:Dynamic,
			startingIndex:Int = 0, drawIndex:Int = 1, collideIndex:Int = 1):FlxTilemap {
		return loadMap(mapData, tileGraphic, drawIndex, collideIndex);
	}

	public function loadMap(mapData:Array<U8>, tileGraphic:Array<U8>, drawIdx:Int, collideIdx:Int):FlxTilemap {
		map = mapData;
		gfx = tileGraphic;
		widthInTiles = mapData[0] | (mapData[1] << 8);
		heightInTiles = mapData[2] | (mapData[3] << 8);
		var count:Int = tileGraphic[0];
		tileSize = tileGraphic[1];
		big = tileSize == 16;
		for (r in 0...(heightInTiles < 64 ? heightInTiles : 64)) rowOff[r] = 4 + r * widthInTiles;
		charsPer = tileSize == 16 ? 4 : 1;
		mc = tileGraphic[2] != 0;
		colorsAt = 5;
		charBase = FlxG.uploadChars(tileGraphic, 5 + count, count * charsPer);
		width = widthInTiles * tileSize;
		height = heightInTiles * tileSize;
		drawIndex = drawIdx;
		collideIndex = collideIdx;
		if (mc) {
			Vic.background1 = tileGraphic[3];
			Vic.background2 = tileGraphic[4];
			Vic.control2 = Vic.control2 | 0x10;
		} else Vic.control2 = Vic.control2 & 0xEF;
		drawnX = -1;
		return this;
	}

	public function getTile(tx:Int, ty:Int):Int {
		if (tx < 0 || ty < 0 || tx >= widthInTiles || ty >= heightInTiles) return 0;
		return map[rowOff[ty] + tx];
	}

	inline function toTile(p:Int):Int {
		return big ? p >> 4 : p >> 3;
	}

	public function setTile(tx:Int, ty:Int, t:Int) {
		if (tx < 0 || ty < 0 || tx >= widthInTiles || ty >= heightInTiles) return;
		map[rowOff[ty] + tx] = t;
		drawTileAt(tx, ty);
	}

	/** Tile index under a pixel position. **/
	public inline function getTileAtPixel(px:Int, py:Int):Int {
		return getTile(toTile(px), toTile(py));
	}

	public inline function solidAt(px:Int, py:Int):Bool {
		return getTile(toTile(px), toTile(py)) >= collideIndex;
	}

	/** Any solid tile inside the rectangle? **/
	public function overlapsSolid(px:Int, py:Int, w:Int, h:Int):Bool {
		// two copies with constant shifts: a shift by a variable amount is a slow loop on the 6502
		return big ? solid16(px, py, w, h) : solid8(px, py, w, h);
	}

	@:noinline function solid16(px:Int, py:Int, w:Int, h:Int):Bool return solidRect(px, py, w, h, 4);

	@:noinline function solid8(px:Int, py:Int, w:Int, h:Int):Bool return solidRect(px, py, w, h, 3);

	inline function solidRect(px:Int, py:Int, w:Int, h:Int, s:Int):Bool {
		var x0 = px >> s, x1 = (px + w - 1) >> s;
		var y0 = py >> s, y1 = (py + h - 1) >> s;
		if (x0 < 0) x0 = 0;
		if (y0 < 0) y0 = 0;
		if (x1 >= widthInTiles) x1 = widthInTiles - 1;
		if (y1 >= heightInTiles) y1 = heightInTiles - 1;
		var ci = collideIndex;
		var found = false;
		var ty = y0;
		while (ty <= y1 && !found) {
			var row = rowOff[ty];
			var tx = x0;
			while (tx <= x1) {
				if (map[row + tx] >= ci) {
					found = true;
					break;
				}
				tx++;
			}
			ty++;
		}
		return found;
	}

	public function overlapsObject(o:FlxObject):Bool {
		return overlapsSolid(o.x, o.y, o.width, o.height);
	}

	/** Pushes the object out of solid tiles (x first, then y) and sets its `touching` flags. **/
	@:noinline public function collideObject(o:FlxObject):Bool {
		return big ? collide16(o) : collide8(o);
	}

	@:noinline function collide16(o:FlxObject):Bool return collideWith(o, 4);

	@:noinline function collide8(o:FlxObject):Bool return collideWith(o, 3);

	inline function collideWith(o:FlxObject, s:Int):Bool {
		var hit = false;
		var w = o.width, h = o.height;
		if (o.x != o.lastX && (s == 4 ? solid16(o.x, o.lastY, w, h) : solid8(o.x, o.lastY, w, h))) {
			if (o.x > o.lastX) {
				o.x = (((o.x + w - 1) >> s) << s) - w;
				o.touching = o.touching | FlxDirectionFlags.RIGHT;
			} else {
				o.x = ((o.x >> s) + 1) << s;
				o.touching = o.touching | FlxDirectionFlags.LEFT;
			}
			o.vx = 0;
			o.rx = 0;
			hit = true;
		}
		if (s == 4 ? solid16(o.x, o.y, w, h) : solid8(o.x, o.y, w, h)) {
			if (o.y >= o.lastY) {
				o.y = (((o.y + h - 1) >> s) << s) - h;
				o.touching = o.touching | FlxDirectionFlags.FLOOR;
			} else {
				o.y = ((o.y >> s) + 1) << s;
				o.touching = o.touching | FlxDirectionFlags.CEILING;
			}
			o.vy = 0;
			o.ry = 0;
			hit = true;
		} else if (o.vy >= 0 && ((o.y + h) & ((1 << s) - 1)) == 0 && (s == 4 ? solid16(o.x, o.y + h, w, 1) : solid8(o.x, o.y + h, w, 1))) {
			// standing exactly on a tile: still on the floor (gravity moves only every few frames)
			o.touching = o.touching | FlxDirectionFlags.FLOOR;
			hit = true;
		}
		return hit;
	}

	override public function draw():Void {
		var cam = FlxG.camera;
		if (cam.scrollX != drawnX || cam.scrollY != drawnY || drawnEpoch != FlxG.screenEpoch) redraw();
	}

	/** Redraws the visible part of the map. **/
	public function redraw() {
		var cam = FlxG.camera;
		drawnX = cam.scrollX;
		drawnY = cam.scrollY;
		var rows = cam.viewRows;
		var cx0 = cam.scrollX >> 3, cy0 = cam.scrollY >> 3;
		for (r in 0...rows) {
			var off = r * 40;
			var wy = cy0 + r;
			var ty = big ? wy >> 1 : wy;
			var sub = charsPer == 4 ? (wy & 1) * 2 : 0;
			for (c in 0...40) {
				var wx = cx0 + c;
				var t = getTile(big ? wx >> 1 : wx, ty);
				if (t < drawIndex) {
					Mem.poke(FlxG.SCREEN + off + c, 32);
				} else {
					var ch = charBase + t * charsPer + (charsPer == 4 ? sub + (wx & 1) : 0);
					Mem.poke(FlxG.SCREEN + off + c, ch);
					var col:Int = gfx[colorsAt + t];
					Mem.poke(0xD800 + off + c, mc ? col | 8 : col);
				}
			}
		}
		FlxG.screenEpoch++;
		drawnEpoch = FlxG.screenEpoch;
	}

	function drawTileAt(tx:Int, ty:Int) {
		var cam = FlxG.camera;
		var per = charsPer == 4 ? 2 : 1;
		for (sy in 0...per) for (sx in 0...per) {
			var c = tx * per + sx - (cam.scrollX >> 3);
			var r = ty * per + sy - (cam.scrollY >> 3);
			if (c < 0 || c >= 40 || r < 0 || r >= cam.viewRows) continue;
			var t = getTile(tx, ty);
			var off = r * 40 + c;
			if (t < drawIndex) Mem.poke(FlxG.SCREEN + off, 32); else {
				Mem.poke(FlxG.SCREEN + off, charBase + t * charsPer + (charsPer == 4 ? sy * 2 + sx : 0));
				var col:Int = gfx[colorsAt + t];
				Mem.poke(0xD800 + off, mc ? col | 8 : col);
			}
		}
	}
}
