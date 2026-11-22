package c64;

import haxe64.Types;

/** Raw memory access. **/
extern class Mem {
	@:c("H64_PEEK({0})") static function peek(addr:Int):U8;
	@:c("H64_POKE({0}, {1})") static function poke(addr:Int, value:Int):Void;
	@:c("memset((void*)(uint16_t)({0}), {2}, (uint16_t)({1}))") static function fill(addr:Int, length:Int, value:Int):Void;
	@:c("memcpy((void*)(uint16_t)({0}), (const void*)({1}), (uint16_t)({2}))") static function copy(dest:Int, src:Array<U8>, length:Int):Void;
	/** Copy bytes into the RAM under the I/O area ($D000-$DFFF), e.g. a charset the VIC reads in bank 3. **/
	@:c("h64_copy_under_io((uint16_t)({0}), (const void*)({1}), (uint16_t)({2}))") static function copyUnderIO(dest:Int, src:Array<U8>, length:Int):Void;
	/** Copy part of the character ROM (offset from $D000) into RAM. **/
	@:c("h64_copy_charrom((uint16_t)({0}), (uint16_t)({1}), (uint16_t)({2}))") static function copyCharRom(dest:Int, offset:Int, length:Int):Void;
	/** Address of an array (e.g. to compute sprite pointers). **/
	@:c("((uint16_t)({0}))") static function addressOf(a:Array<U8>):U16;
}
