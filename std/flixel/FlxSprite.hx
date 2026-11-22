package flixel;

import haxe64.Types;

/**
	A hardware sprite (Flixel: FlxSprite). Up to 8 are visible at once (the first 8 drawn each frame).
	Graphics come from `FlxAssets.sprite("assets/x.png", w, h)` (converted at compile time),
	or `makeGraphic(w, h, color)` for a solid block.
**/
class FlxSprite extends FlxObject {
	/** Graphic: first 64-byte sprite block, frame count, flipped copies (0 = none). **/
	public var block:U8 = 0;
	public var numFrames:U8 = 1;
	public var mirrorAt:U8 = 0;
	public var multicolor:Bool = false;
	public var frame:U8 = 0;
	public var flipX:Bool = false;
	public var color:U8 = 1;
	public var offX:Int = 0;
	public var offY:Int = 0;

	// animation (up to 4 per sprite)
	@:size(4) public var animName:Array<String>;
	@:size(4) public var animFrames:Array<Array<Int>>;
	@:size(4) public var animLen:Array<U8>;
	@:size(4) public var animFps:Array<U8>;
	@:size(4) public var animLoop:Array<Bool>;
	public var animCount:U8 = 0;
	public var curAnim:Int = -1;
	public var animPos:U8 = 0;
	public var animTimer:Int = 0;
	public var animDone:Bool = false;

	public var animation(get, never):FlxAnimationController;
	public var offset(get, never):FlxOffset;

	inline function get_animation():FlxAnimationController return cast this;

	inline function get_offset():FlxOffset return cast this;

	public function new(x:Int = 0, y:Int = 0, ?graphic:Array<U8>) {
		super(x, y, 8, 8);
		if (graphic != null) loadGraphic(graphic);
	}

	/** Use a converted graphic (FlxAssets.sprite). Uploads it to sprite memory the first time. **/
	public function loadGraphic(graphic:Array<U8>):FlxSprite {
		block = FlxG.uploadSprite(graphic);
		numFrames = graphic[0];
		mirrorAt = (graphic[1] & 2) != 0 ? numFrames : 0;
		multicolor = (graphic[1] & 1) != 0;
		color = graphic[2];
		width = graphic[3];
		height = graphic[4];
		frame = 0;
		return this;
	}

	/** A solid rectangle (max 24 x 21) in one color. **/
	public function makeGraphic(w:Int, h:Int, c:Int):FlxSprite {
		block = FlxG.makeBlock(w, h);
		numFrames = 1;
		mirrorAt = 0;
		multicolor = false;
		color = c;
		width = w;
		height = h;
		return this;
	}

	override public function update():Void {
		super.update();
		if (curAnim >= 0 && !animDone) {
			animTimer += animFps[curAnim];
			while (animTimer >= 50) {
				animTimer -= 50;
				animPos++;
				if (animPos >= animLen[curAnim]) {
					if (animLoop[curAnim]) animPos = 0; else {
						animPos = animLen[curAnim] - 1;
						animDone = true;
					}
				}
			}
			var frames = animFrames[curAnim];
			frame = frames[animPos];
		}
	}

	override public function draw():Void {
		FlxG.addSprite(this);
	}

	public function addAnim(name:String, frames:Array<Int>, len:Int, fps:Int, loop:Bool) {
		if (animCount >= 4) return;
		animName[animCount] = name;
		animFrames[animCount] = frames;
		animLen[animCount] = len;
		animFps[animCount] = fps;
		animLoop[animCount] = loop;
		animCount++;
	}

	public function playAnim(name:String, force:Bool) {
		for (i in 0...animCount) {
			if (animName[i] == name) {
				if (i == curAnim && !force && !animDone) return;
				curAnim = i;
				animPos = 0;
				animTimer = 0;
				animDone = false;
				var frames = animFrames[i];
				frame = frames[0];
				return;
			}
		}
	}
}

/** `sprite.animation.add("run", [1, 2, 3], 10)` / `.play("run")` **/
abstract FlxAnimationController(FlxSprite) {
	public var name(get, never):String;
	public var finished(get, never):Bool;
	public var frameIndex(get, set):Int;

	inline function get_name():String return this.curAnim < 0 ? "" : this.animName[this.curAnim];

	inline function get_finished():Bool return this.animDone;

	inline function get_frameIndex():Int return this.frame;

	inline function set_frameIndex(f:Int):Int {
		this.curAnim = -1;
		return this.frame = f;
	}

	public inline function add(name:String, frames:Array<Int>, fps:Int = 10, loop:Bool = true) {
		this.addAnim(name, frames, frames.length, fps, loop);
	}

	public inline function play(name:String, force:Bool = false) {
		this.playAnim(name, force);
	}

	public inline function stop() {
		this.animDone = true;
	}
}

abstract FlxOffset(FlxSprite) {
	public var x(get, set):Int;
	public var y(get, set):Int;

	inline function get_x() return this.offX;

	inline function set_x(v:Int) return this.offX = v;

	inline function get_y() return this.offY;

	inline function set_y(v:Int) return this.offY = v;

	public inline function set(x:Int = 0, y:Int = 0) {
		this.offX = x;
		this.offY = y;
	}
}
