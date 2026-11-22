package c64;

import haxe64.Types;

/**
	Hardware sprites 0-7.
	Sprite shapes are 63 bytes (24x21 pixels). `Sprite.load(block, data)` copies a shape to
	address block*64; blocks 13, 14, 15 ($0340-$03FF, the tape buffer) are always free.
**/
class Sprite {
	public static inline function enable(n:Int, on:Bool) {
		if (on) Vic.spriteEnable = Vic.spriteEnable | (1 << n) else Vic.spriteEnable = Vic.spriteEnable & ~(1 << n);
	}

	public static inline function setX(n:Int, x:Int) {
		Mem.poke(0xD000 + n * 2, x & 255);
		if (x > 255) Vic.spriteXMsb = Vic.spriteXMsb | (1 << n) else Vic.spriteXMsb = Vic.spriteXMsb & ~(1 << n);
	}

	public static inline function setY(n:Int, y:Int) {
		Mem.poke(0xD001 + n * 2, y);
	}

	public static inline function setPos(n:Int, x:Int, y:Int) {
		setX(n, x);
		setY(n, y);
	}

	public static inline function setColor(n:Int, color:Int) {
		Mem.poke(0xD027 + n, color);
	}

	/** Which 64-byte block (in the current VIC bank) holds this sprite's shape. **/
	public static inline function setShape(n:Int, block:Int) {
		Mem.poke(0x07F8 + n, block);
	}

	public static inline function setMulticolor(n:Int, on:Bool) {
		if (on) Vic.spriteMulticolor = Vic.spriteMulticolor | (1 << n) else Vic.spriteMulticolor = Vic.spriteMulticolor & ~(1 << n);
	}

	public static inline function setExpand(n:Int, x:Bool, y:Bool) {
		if (x) Vic.spriteExpandX = Vic.spriteExpandX | (1 << n) else Vic.spriteExpandX = Vic.spriteExpandX & ~(1 << n);
		if (y) Vic.spriteExpandY = Vic.spriteExpandY | (1 << n) else Vic.spriteExpandY = Vic.spriteExpandY & ~(1 << n);
	}

	/** Copy a 63-byte shape into 64-byte block `block`. **/
	public static inline function load(block:Int, data:Array<U8>) {
		Mem.copy(block * 64, data, 63);
	}
}
