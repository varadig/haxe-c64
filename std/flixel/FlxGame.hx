package flixel;

import c64.*;
import haxe64.Types;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKeyboard;

/**
	Runs the game (Flixel: FlxGame). `new FlxGame(new PlayState())` never returns.
	Each frame (50 Hz): sprites from the last frame go to the VIC, input, sound, state switch,
	`state.update()`, camera, then `state.draw()`.
**/
@:pool(1)
class FlxGame {
	#if flixel64_profile
	@:size(6) static var acc:Array<U16>;

	static inline function timer():Int {
		return untyped __c__("(int16_t)(*(volatile uint8_t*)0xDC06 | (*(volatile uint8_t*)0xDC07 << 8))");
	}
	#end

	public function new(initialState:FlxState) {
		FlxG.init();
		FlxG.switchState(initialState);
		#if flixel64_profile
		// CIA1 timer B as a free-running cycle counter
		Mem.poke(0xDC06, 0xFF);
		Mem.poke(0xDC07, 0xFF);
		Mem.poke(0xDC0F, 0x11);
		var n = 0;
		#end
		while (true) {
			Vic.waitFrame();
			#if flixel64_profile
			var t0:Int = timer();
			#end
			FlxG.commitSprites();
			FlxG.camera.updateEffects();
			#if flixel64_profile
			var t1:Int = timer();
			#end
			FlxKeys.scan();
			#if flixel64_profile
			var t2:Int = timer();
			#end
			FlxSound.update();
			FlxG.doSwitch();
			#if flixel64_profile
			var t3:Int = timer();
			#end
			FlxG.state.update();
			FlxG.camera.updateFollow();
			#if flixel64_profile
			var t4:Int = timer();
			#end
			FlxG.beginDraw();
			FlxG.state.draw();
			FlxG.endDraw();
			FlxG.frame++;
			#if flixel64_profile
			var t5:Int = timer();
			// CPU use in percent of a PAL frame (19656 cycles), averaged over 16 frames: total and per phase
			// (SPR sprites to VIC, KEY keyboard, SND sound + state switch, UPD state.update, DRW draw). Over 100% the game drops frames.
			acc[0] += ((t0 - t5) >> 4) & 0x0FFF;
			acc[1] += ((t0 - t1) >> 4) & 0x0FFF;
			acc[2] += ((t1 - t2) >> 4) & 0x0FFF;
			acc[3] += ((t2 - t3) >> 4) & 0x0FFF;
			acc[4] += ((t3 - t4) >> 4) & 0x0FFF;
			acc[5] += ((t4 - t5) >> 4) & 0x0FFF;
			n++;
			if (n == 16) {
				untyped __c__("h64_text_color = 1; h64_screen_print(31, 0, \"CPU\"); h64_screen_print_num(35, 0, h64_pct({0}[0]), 3); h64_screen_print(38, 0, \"%\")", acc);
				untyped __c__("h64_screen_print(0, 0, \"SPR   KEY   SND   UPD   DRW\"); for (uint8_t i = 1; i < 6; i++) h64_screen_print_num((i - 1) * 6 + 3, 0, h64_pct({0}[i]), 3)", acc);
				for (i in 0...6) acc[i] = 0;
				n = 0;
			}
			#end
		}
	}
}
