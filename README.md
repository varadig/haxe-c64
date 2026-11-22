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
| `inline` | inlined by Haxe - the hardware API is built from inline functions, so it costs nothing |
| `trace(x)` | prints an `Int`/`String`/`Bool` |
| `Std.int(a / b)`, `Std.random(n)` | integer division, xorshift random |

Not supported (compile error): `Float`, `Dynamic`, anonymous structures, closures/local functions,
inheritance/interfaces, generics, `try/catch`, string concatenation, enums with arguments.

### Talking to the hardware

```haxe
import c64.*;
import haxe64.Types;

Vic.border = Color.RED;               // register as a variable
Sprite.setPos(0, x, y);               // inline helpers over Mem.poke
if (Joy.fire()) Sid.noteOn(0, Sid.NOISE);
Vic.waitFrame();                      // once per game loop
```

Packages: `c64.Mem`, `Vic`, `Sprite`, `Screen`, `Joy`, `Sid`, `Keyboard`, `Color`.

Escape hatches:

- `@:c("C template {0} {1}")` on an `extern` field: the call/field becomes that C expression.
- `untyped __c__("C code {0}", arg)` inline C.
- `@:address(0xC000) static var buf:Array<U8>;` - an array at a fixed address.
- `@:align(64)` on a static array, `@:noinline` on functions.

## Examples

- `examples/hello` - text + frame counter
- `examples/catcher` - a small game: joystick (port 2) moves a sprite, catch the falling stars, SID beeps, sprite collisions, object pool

## Roadmap

raster interrupts / music player hook, inheritance without virtuals, `@:zp` zero-page variables,
custom charsets and sprite data placement, direct 6502 asm output for hot paths, d64 disk images.
