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
	var shift:Int = 4;
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
		shift = tileSize == 16 ? 4 : 3;
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
		return map[4 + ty * widthInTiles + tx];
	}

	public function setTile(tx:Int, ty:Int, t:Int) {
		if (tx < 0 || ty < 0 || tx >= widthInTiles || ty >= heightInTiles) return;
		map[4 + ty * widthInTiles + tx] = t;
		drawTileAt(tx, ty);
	}

	/** Tile index under a pixel position. **/
	public inline function getTileAtPixel(px:Int, py:Int):Int {
		return getTile(px >> shift, py >> shift);
	}

	public inline function solidAt(px:Int, py:Int):Bool {
		return getTile(px >> shift, py >> shift) >= collideIndex;
	}

	/** Any solid tile inside the rectangle? **/
	public function overlapsSolid(px:Int, py:Int, w:Int, h:Int):Bool {
		var x0 = px >> shift, x1 = (px + w - 1) >> shift;
		var y0 = py >> shift, y1 = (py + h - 1) >> shift;
		for (ty in y0...y1 + 1) for (tx in x0...x1 + 1) if (getTile(tx, ty) >= collideIndex) return true;
		return false;
	}

	public function overlapsObject(o:FlxObject):Bool {
		return overlapsSolid(o.x, o.y, o.width, o.height);
	}

	/** Pushes the object out of solid tiles (x first, then y) and sets its `touching` flags. **/
	public function collideObject(o:FlxObject):Bool {
		var hit = false;
		var w = o.width, h = o.height;
		if (o.x != o.lastX && overlapsSolid(o.x, o.lastY, w, h)) {
			if (o.x > o.lastX) {
				o.x = (((o.x + w - 1) >> shift) << shift) - w;
				o.touching = o.touching | FlxDirectionFlags.RIGHT;
			} else {
				o.x = ((o.x >> shift) + 1) << shift;
				o.touching = o.touching | FlxDirectionFlags.LEFT;
			}
			o.vx = 0;
			o.rx = 0;
			hit = true;
		}
		if (overlapsSolid(o.x, o.y, w, h)) {
			if (o.y >= o.lastY) {
				o.y = (((o.y + h - 1) >> shift) << shift) - h;
				o.touching = o.touching | FlxDirectionFlags.FLOOR;
			} else {
				o.y = ((o.y >> shift) + 1) << shift;
				o.touching = o.touching | FlxDirectionFlags.CEILING;
			}
			o.vy = 0;
			o.ry = 0;
			hit = true;
		} else if (o.vy >= 0 && ((o.y + h) & ((1 << shift) - 1)) == 0 && overlapsSolid(o.x, o.y + h, w, 1)) {
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
			var ty = wy >> (shift - 3);
			var sub = charsPer == 4 ? (wy & 1) * 2 : 0;
			for (c in 0...40) {
				var wx = cx0 + c;
				var t = getTile(wx >> (shift - 3), ty);
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
