package flixel.text;

import c64.*;
import haxe64.Types;
import flixel.FlxG;
import flixel.FlxObject;

/**
	Text on the character screen (Flixel: FlxText). Position in pixels, rounded to 8 x 8 cells; always fixed on the screen.
	`text = "SCORE " + score` works (the string is copied, max 40 characters).
	With multicolor tiles on screen use colors 0-7 for text.
**/
@:pool(8)
class FlxText extends FlxObject {
	@:size(41) var buf:Array<U8>;
	var len:Int = 0;
	var shownLen:Int = 0;
	var dirty:Bool = true;
	var epoch:U16 = 0;
	public var color(default, set):Int = 1;
	public var text(get, set):String;

	public function new(x:Int = 0, y:Int = 0, fieldWidth:Int = 0, ?text:String, size:Int = 8) {
		super(x, y, fieldWidth > 0 ? fieldWidth : 8, 8);
		moves = false;
		scrollFactor = 0;
		if (text != null) set_text(text);
	}

	function get_text():String {
		return untyped __c__("(const char*)({0})", buf);
	}

	function set_text(t:String):String {
		var i = 0;
		while (i < 40) {
			var c:U8 = untyped __c__("(uint8_t)({0})[{1}]", t, i);
			if (c == 0) break;
			buf[i] = c;
			i++;
		}
		buf[i] = 0;
		len = i;
		dirty = true;
		return t;
	}

	function set_color(c:Int):Int {
		color = c;
		dirty = true;
		return c;
	}

	override public function draw():Void {
		FlxG.addText(this);
	}

	/** Writes the characters if the text changed or the screen was redrawn. **/
	public function render() {
		if (!dirty && epoch == FlxG.screenEpoch) return;
		dirty = false;
		epoch = FlxG.screenEpoch;
		var col = x >> 3;
		var row = y >> 3;
		if (row < 0 || row > 24) return;
		var off = row * 40 + col;
		for (i in 0...len) {
			if (col + i >= 40) break;
			var c:U8 = buf[i];
			untyped __c__("h64_screen[{0}] = h64_ascii_to_screen({1})", off + i, c);
			Mem.poke(0xD800 + off + i, color);
		}
		// erase what is left of a longer previous text
		var i = len;
		while (i < shownLen && col + i < 40) {
			untyped __c__("h64_screen[{0}] = 32", off + i);
			i++;
		}
		shownLen = len;
	}

	override public function kill():Void {
		super.kill();
		set_text("");
		var save = len;
		render();
	}
}
