package flixel.group;

import flixel.FlxBasic;
import haxe64.Types;

/**
	A list of objects updated and drawn together (Flixel: FlxTypedGroup<T>). At most 32 members.
	`@:generic`: every member type gets its own specialised class (no generics at runtime).
**/
@:generic
@:pool(4)
class FlxTypedGroup<T:FlxBasic> extends FlxGroupBase {
	/** The members (some entries may be null after remove). **/
	public var members(get, never):Array<T>;

	inline function get_members():Array<T> return cast _m;
	public var maxSize:Int = 32;

	public function new(maxSize:Int = 32) {
		super();
		this.maxSize = maxSize > 32 ? 32 : maxSize;
	}

	override public function memberAt(i:Int):FlxBasic {
		return members[i];
	}

	public function add(o:T):T {
		for (i in 0...length) if (members[i] == o) return o;
		if (o.flxKind == 2) nestedGroups++;
		// reuse a removed slot
		for (i in 0...length) if (members[i] == null) {
			members[i] = o;
			return o;
		}
		if (length >= maxSize) return o;
		members[length] = o;
		length++;
		return o;
	}

	public function remove(o:T):T {
		for (i in 0...length) if (members[i] == o) {
			members[i] = null;
			if (o.flxKind == 2) nestedGroups--;
		}
		return o;
	}

	override public function update():Void {
		var n:U8 = length;
		var i:U8 = 0;
		while (i < n) {
			var m = _m[i];
			i++;
			if (m != null && m.exists && m.active) m.update();
		}
	}

	override public function draw():Void {
		var n:U8 = length;
		var i:U8 = 0;
		while (i < n) {
			var m = _m[i];
			i++;
			if (m != null && m.exists && m.visible) m.draw();
		}
	}

	override public function kill():Void {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && m.exists) m.kill();
		}
		super.kill();
	}

	override public function destroy():Void {
		for (i in 0...length) {
			var m = members[i];
			if (m != null) m.destroy();
			members[i] = null;
		}
		length = 0;
		super.destroy();
	}

	public function forEach(fn:T->Void) {
		for (i in 0...length) {
			var m = members[i];
			if (m != null) fn(m);
		}
	}

	public function forEachAlive(fn:T->Void) {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && m.exists && m.alive) fn(m);
		}
	}

	public function forEachExists(fn:T->Void) {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && m.exists) fn(m);
		}
	}

	public function getFirstAlive():T {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && m.exists && m.alive) return m;
		}
		return null;
	}

	public function getFirstDead():T {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && !m.alive) return m;
		}
		return null;
	}

	public function getFirstAvailable():T {
		for (i in 0...length) {
			var m = members[i];
			if (m != null && !m.exists) return m;
		}
		return null;
	}

	/** A dead member brought back to life, or a new one from `factory` (Flixel: recycle). **/
	public function recycle(factory:Void->T):T {
		var m = getFirstAvailable();
		if (m != null) {
			m.revive();
			return m;
		}
		if (length >= maxSize) return null;
		return add(factory());
	}

	public function countLiving():Int {
		var n = 0;
		for (i in 0...length) {
			var m = members[i];
			if (m != null && m.exists && m.alive) n++;
		}
		return n;
	}

	public function countDead():Int {
		var n = 0;
		for (i in 0...length) {
			var m = members[i];
			if (m != null && !m.alive) n++;
		}
		return n;
	}
}

/** A group of anything (Flixel: FlxGroup). **/
@:pool(4)
class FlxGroup extends FlxTypedGroup<FlxBasic> {}
