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
}
