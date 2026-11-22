package c64;

import haxe64.Types;

/** VIC-II video chip registers ($D000). **/
extern class Vic {
	@:c("H64_PEEK(0xD020)") static var border:U8;
	@:c("H64_PEEK(0xD021)") static var background:U8;
	@:c("H64_PEEK(0xD022)") static var background1:U8;
	@:c("H64_PEEK(0xD023)") static var background2:U8;
	/** Current raster line (low 8 bits). **/
	@:c("H64_PEEK(0xD012)") static var raster:U8;
	@:c("H64_PEEK(0xD011)") static var control1:U8;
	@:c("H64_PEEK(0xD016)") static var control2:U8;
	@:c("H64_PEEK(0xD018)") static var memorySetup:U8;
	/** Sprite enable bits. **/
	@:c("H64_PEEK(0xD015)") static var spriteEnable:U8;
	@:c("H64_PEEK(0xD010)") static var spriteXMsb:U8;
	@:c("H64_PEEK(0xD017)") static var spriteExpandY:U8;
	@:c("H64_PEEK(0xD01D)") static var spriteExpandX:U8;
	@:c("H64_PEEK(0xD01C)") static var spriteMulticolor:U8;
	@:c("H64_PEEK(0xD01B)") static var spritePriority:U8;
	@:c("H64_PEEK(0xD025)") static var spriteMulticolor0:U8;
	@:c("H64_PEEK(0xD026)") static var spriteMulticolor1:U8;
	/** Sprite-sprite collisions (reading clears it). **/
	@:c("H64_PEEK(0xD01E)") static var spriteCollision:U8;
	/** Sprite-background collisions (reading clears it). **/
	@:c("H64_PEEK(0xD01F)") static var spriteBgCollision:U8;

	/** Wait for the next frame (raster line 251) - call once per game loop. **/
	@:c("h64_wait_frame()") static function waitFrame():Void;
}
