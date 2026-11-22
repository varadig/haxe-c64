package c64;

import haxe64.Types;

/** Keyboard via the KERNAL. **/
extern class Keyboard {
	/** PETSCII code of the next key in the buffer, 0 if none. **/
	@:c("cbm_k_getin()") static function getKey():U8;
}
