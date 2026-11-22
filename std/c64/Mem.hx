package c64;

import haxe64.Types;

/** Raw memory access. **/
extern class Mem {
	@:c("H64_PEEK({0})") static function peek(addr:Int):U8;
	@:c("H64_POKE({0}, {1})") static function poke(addr:Int, value:Int):Void;
	@:c("memset((void*)(uint16_t)({0}), {2}, (uint16_t)({1}))") static function fill(addr:Int, length:Int, value:Int):Void;
	@:c("memcpy((void*)(uint16_t)({0}), (const void*)({1}), (uint16_t)({2}))") static function copy(dest:Int, src:Array<U8>, length:Int):Void;
	/** Address of an array (e.g. to compute sprite pointers). **/
	@:c("((uint16_t)({0}))") static function addressOf(a:Array<U8>):U16;
}
