# haxe64

A Haxe compiler target for the **Commodore 64**, aimed at writing games.

```
Haxe source ──(Haxe typer + inliner)──▶ typed AST ──(haxe64.Generator)──▶ C ──(llvm-mos)──▶ .prg
```

Haxe does the parsing, type checking, inlining and macros; the `haxe64.Generator` macro turns the typed AST
into one C file; [llvm-mos](https://llvm-mos.org) compiles it to well-optimized 6502 code.

## Setup

- Haxe 4.3+
- [llvm-mos-sdk](https://github.com/llvm-mos/llvm-mos-sdk/releases) in `~/.local/opt/llvm-mos` (or set `LLVM_MOS`)
- [VICE](https://vice-emu.sourceforge.io/) for running (`x64sc` on PATH, or set `VICE`)

## Usage

```sh
cd examples/catcher
../../bin/haxe64 -main Main -o build/catcher.prg        # build
../../bin/haxe64 -main Main -o build/catcher.prg --run  # build + start in VICE
```

Options: `-cp dir`, `-D define`, `--sim` (build for the llvm-mos simulator and run, used by tests), `--run`.

Tests: `tests/run.sh` (each `tests/<name>/Main.hx` runs in the 6502 simulator and its `trace` output is compared with `expected.txt`).

## The language (a C64-sized Haxe)

| Haxe | C64 |
|---|---|
| `Int` | **signed 16-bit** (`int16_t`), wraps around |
| `haxe64.Types.U8` / `I8` / `U16` | `uint8_t` / `int8_t` / `uint16_t` - use `U8` wherever you can, it is much faster |
| `Bool` | `bool` |
| `String` | constant strings only (`const char*`); `length`, `charCodeAt`, `==` |
| `Array<T>` | fixed-size C arrays: static/local array literals, or `@:size(N) static var a:Array<U8>;`. `.length` is known at compile time |
| `enum` | simple enums without arguments (`uint8_t`) |
| `class` | static functions/vars → C functions/globals. Instances come from a fixed **pool** per class (`@:pool(N)`, default 8); `new` takes a slot, `haxe64.Pool.free(obj)` gives it back |
| inheritance | `extends`, `override`, `super(...)`, `super.method()`; virtual calls dispatch with a `switch` on a 1-byte class id; `Std.isOfType`, `cast` |
| `Float` | **12.4 fixed point** in 16 bits: -2048..2047 in 1/16 steps; `Math.abs/min/max/floor/ceil/round/sqrt/sin/cos` |
| functions | static functions and non-capturing lambdas as values (C function pointers); default arguments |
| `String` | constants, `+` concatenation / `Std.string` (temporary 39-char strings - copy them if you keep them) |
| `@:generic` | generic classes are specialised by Haxe (e.g. `FlxTypedGroup<Coin>`) |
| `inline` | inlined by Haxe - the hardware API is built from inline functions, so it costs nothing |
| `trace(x)` | prints an `Int`/`String`/`Bool` |
| `Std.int(a / b)`, `Std.random(n)` | integer division, xorshift random |

Not supported (compile error): `Dynamic` field access, anonymous structures, closures that capture variables,
interfaces, non-`@:generic` type parameters, `try/catch`, enums with arguments.

### Talking to the hardware

```haxe
import c64.*;
import haxe64.Types;

Vic.border = Color.RED;               // register as a variable
Sprite.setPos(0, x, y);               // inline helpers over Mem.poke
if (Joy.fire()) Sid.noteOn(0, Sid.NOISE);
Vic.waitFrame();                      // once per game loop
```

Sprite shapes from ASCII art at compile time: `haxe64.SpriteArt.make(["..##..", ...])` (a macro).

Packages: `c64.Mem`, `Vic`, `Sprite`, `Screen`, `Joy`, `Sid`, `Keyboard`, `Color`.

Escape hatches:

- `@:c("C template {0} {1}")` on an `extern` field: the call/field becomes that C expression.
- `untyped __c__("C code {0}", arg)` inline C.
- `@:address(0xC000) static var buf:Array<U8>;` - an array at a fixed address.
- `@:align(64)` on a static array, `@:noinline` on functions.

## flixel64 - a HaxeFlixel-like API

`import flixel.*` gives a small, C64-sized HaxeFlixel: the same class names and the usual style of code.

```haxe
class Player extends FlxSprite {
	public function new(x:Int, y:Int) {
		super(x, y, Assets.PLAYER);          // FlxAssets.sprite("assets/player.png", 12, 21)
		acceleration.y = 600;                // px/s², integer
		maxVelocity.set(90, 300);
		drag.x = 600;
		animation.add("run", [1, 0, 2, 0], 10);
	}
	override public function update():Void {
		acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT) { acceleration.x = -800; flipX = true; }
		if (FlxG.keys.justPressed.SPACE && isTouching(FLOOR)) velocity.y = -230;
		super.update();
	}
}
// PlayState.update: FlxG.collide(map, player); FlxG.overlap(player, coins, takeCoin);
// Main: new FlxGame(new MenuState());
```

| Flixel | flixel64 |
|---|---|
| `FlxGame`, `FlxState` (`create` / `update`), `FlxG.switchState` | same; `update()` has no `elapsed` (50 Hz, motion is integrated internally) |
| `FlxSprite`: velocity, acceleration, drag, maxVelocity, offset, flipX, `animation.add/play`, `makeGraphic` | hardware sprites, 8 visible at once (off-screen ones do not count); positions are `Int` pixels |
| `FlxTypedGroup<T>`, `FlxGroup`: add, remove, forEach(Alive), recycle, countLiving, getFirst... | max 32 members |
| `FlxG.collide` / `FlxG.overlap` (objects, groups, tilemaps) with callback | callback parameters must be typed: `(p:Player, c:Coin) -> ...` |
| `FlxTilemap.loadMapFromCSV` | character tiles 8x8 or 16x16, `getTile/setTile`, solid from `collideIndex` |
| `FlxText` | character cells, fixed on screen (HUD), `text = "SCORE " + score` |
| `FlxG.keys.pressed / justPressed / justReleased`, `anyPressed` | C64 keyboard; LEFT/RIGHT/UP/DOWN = cursor keys **or joystick 2**, FIRE = joystick button |
| `FlxG.camera.follow` | screen-by-screen flips (`setViewRows` keeps HUD rows), `flash`, `shake`, `bgColor` |
| `FlxG.sound.play` | built-in SID effects: `FlxSfx.JUMP, COIN, HIT, EXPLOSION, SHOOT, POWERUP, LAND, BLIP, SELECT` |
| `FlxG.random.int / bool`, `FlxColor` (the 16 C64 colors), `FlxDirectionFlags` | |
| assets | `FlxAssets.sprite / tiles / csv` convert PNG / CSV **at compile time** (needs `haxelib install format`) |

`-D flixel64_autoplay` holds RIGHT and taps jump, for headless smoke tests in VICE.

## Examples

- `examples/hello` - text + frame counter
- `examples/flxdemo` - flixel64 platformer: menu, tilemap over 3 screens, animated player, coins, enemies (stomp), score, win state
- `examples/starguard` - shoot'em up: 6 pooled aliens, bullet, explosions, levels, title/game-over states,
  keyboard (A/D/SPACE) or joystick port 2. Build with `-D autoplay` to let it play itself (headless testing)
- `examples/catcher` - a small game: joystick (port 2) moves a sprite, catch the falling stars, SID beeps, sprite collisions, object pool

## Roadmap

raster interrupts / music player hook, inheritance without virtuals, `@:zp` zero-page variables,
custom charsets and sprite data placement, direct 6502 asm output for hot paths, d64 disk images.
