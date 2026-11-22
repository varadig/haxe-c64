package haxe64;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Build-time sprite shapes from ASCII art (runs as a macro, costs nothing at runtime):

	```haxe
	static var ship:Array<U8> = SpriteArt.make([
		"..........####..........",
		".........######.........",
	]);
	```
	Up to 21 rows of up to 24 characters; `.` and space are transparent, anything else is a set pixel.
	The result is a 63-byte array literal.
**/
class SpriteArt {
	public static macro function make(rows:Expr):Expr {
		var lines:Array<String> = switch rows.expr {
			case EArrayDecl(values): [for (v in values) switch v.expr {
					case EConst(CString(s, _)): s;
					case _: Context.error("SpriteArt.make: rows must be string literals", v.pos);
				}];
			case _: Context.error("SpriteArt.make: expected an array of strings", rows.pos);
		}
		if (lines.length > 21) Context.error('SpriteArt.make: ${lines.length} rows, max is 21', rows.pos);
		var bytes:Array<Expr> = [];
		for (y in 0...21) {
			var line = y < lines.length ? lines[y] : "";
			if (line.length > 24) Context.error('SpriteArt.make: row $y is ${line.length} pixels wide, max is 24', rows.pos);
			for (b in 0...3) {
				var v = 0;
				for (bit in 0...8) {
					var x = b * 8 + bit;
					var c = x < line.length ? line.charAt(x) : ".";
					if (c != "." && c != " ") v |= 0x80 >> bit;
				}
				bytes.push(macro $v{v});
			}
		}
		return {expr: EArrayDecl(bytes), pos: rows.pos};
	}
}
