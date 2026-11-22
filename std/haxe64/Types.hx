package haxe64;

/** Unsigned 8-bit integer (C `uint8_t`) - the fastest type on the 6502. Arithmetic promotes to Int, assignment truncates. **/
@:coreType @:notNull @:ctype("uint8_t")
abstract U8 from Int to Int {
	@:op(++A) static function preInc(a:U8):U8;
	@:op(A++) static function postInc(a:U8):U8;
	@:op(--A) static function preDec(a:U8):U8;
	@:op(A--) static function postDec(a:U8):U8;
	@:op(A > B) static function gt(a:U8, b:U8):Bool;
	@:op(A >= B) static function gte(a:U8, b:U8):Bool;
	@:op(A < B) static function lt(a:U8, b:U8):Bool;
	@:op(A <= B) static function lte(a:U8, b:U8):Bool;
	// arithmetic between two U8s gives an Int (like C's integer promotion)
	@:op(A + B) static function add(a:U8, b:U8):Int;
	@:op(A - B) static function sub(a:U8, b:U8):Int;
	@:op(A * B) static function mul(a:U8, b:U8):Int;
	@:op(A & B) static function and(a:U8, b:U8):Int;
	@:op(A | B) static function or(a:U8, b:U8):Int;
	@:op(A ^ B) static function xor(a:U8, b:U8):Int;
}

/** Signed 8-bit integer (C `int8_t`). **/
@:coreType @:notNull @:ctype("int8_t")
abstract I8 from Int to Int {
	@:op(++A) static function preInc(a:I8):I8;
	@:op(A++) static function postInc(a:I8):I8;
	@:op(--A) static function preDec(a:I8):I8;
	@:op(A--) static function postDec(a:I8):I8;
	@:op(A > B) static function gt(a:I8, b:I8):Bool;
	@:op(A >= B) static function gte(a:I8, b:I8):Bool;
	@:op(A < B) static function lt(a:I8, b:I8):Bool;
	@:op(A <= B) static function lte(a:I8, b:I8):Bool;
	// arithmetic between two I8s gives an Int (like C's integer promotion)
	@:op(A + B) static function add(a:I8, b:I8):Int;
	@:op(A - B) static function sub(a:I8, b:I8):Int;
	@:op(A * B) static function mul(a:I8, b:I8):Int;
	@:op(A & B) static function and(a:I8, b:I8):Int;
	@:op(A | B) static function or(a:I8, b:I8):Int;
	@:op(A ^ B) static function xor(a:I8, b:I8):Int;
}

/** Unsigned 16-bit integer (C `uint16_t`), e.g. memory addresses. `Int` itself is a signed 16-bit integer. **/
@:coreType @:notNull @:ctype("uint16_t")
abstract U16 from Int to Int {
	@:op(++A) static function preInc(a:U16):U16;
	@:op(A++) static function postInc(a:U16):U16;
	@:op(--A) static function preDec(a:U16):U16;
	@:op(A--) static function postDec(a:U16):U16;
	@:op(A > B) static function gt(a:U16, b:U16):Bool;
	@:op(A >= B) static function gte(a:U16, b:U16):Bool;
	@:op(A < B) static function lt(a:U16, b:U16):Bool;
	@:op(A <= B) static function lte(a:U16, b:U16):Bool;
	// arithmetic between two U16s gives an Int (like C's integer promotion)
	@:op(A + B) static function add(a:U16, b:U16):Int;
	@:op(A - B) static function sub(a:U16, b:U16):Int;
	@:op(A * B) static function mul(a:U16, b:U16):Int;
	@:op(A & B) static function and(a:U16, b:U16):Int;
	@:op(A | B) static function or(a:U16, b:U16):Int;
	@:op(A ^ B) static function xor(a:U16, b:U16):Int;
}
