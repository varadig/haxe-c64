package flixel;

import c64.*;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKeyboard;

/**
	Runs the game (Flixel: FlxGame). `new FlxGame(new PlayState())` never returns.
	Each frame (50 Hz): sprites from the last frame go to the VIC, input, sound, state switch,
	`state.update()`, camera, then `state.draw()`.
**/
@:pool(1)
class FlxGame {
	public function new(initialState:FlxState) {
		FlxG.init();
		FlxG.switchState(initialState);
		#if flixel64_profile
		// CIA1 timer B as a free-running cycle counter
		Mem.poke(0xDC06, 0xFF);
		Mem.poke(0xDC07, 0xFF);
		Mem.poke(0xDC0F, 0x11);
		var sum = 0;
		var n = 0;
		#end
		while (true) {
			Vic.waitFrame();
			#if flixel64_profile
			var t0:Int = untyped __c__("(int16_t)(*(volatile uint8_t*)0xDC06 | (*(volatile uint8_t*)0xDC07 << 8))");
			#end
			FlxG.commitSprites();
			FlxG.camera.updateEffects();
			FlxKeys.scan();
			FlxSound.update();
			FlxG.doSwitch();
			FlxG.state.update();
			FlxG.camera.updateFollow();
			FlxG.beginDraw();
			FlxG.state.draw();
			FlxG.endDraw();
			FlxG.frame++;
			#if flixel64_profile
			var t1:Int = untyped __c__("(int16_t)(*(volatile uint8_t*)0xDC06 | (*(volatile uint8_t*)0xDC07 << 8))");
			// average cycles per frame (in units of 16 cycles to stay in 16 bits) over 16 frames, top-right corner
			sum += ((t0 - t1) >> 4) & 0x0FFF;
			n++;
			if (n == 16) {
				untyped __c__("h64_text_color = 1; h64_screen_print_num(34, 0, (int16_t)((uint16_t)({0}) >> 4) * 16, 5)", sum);
				sum = 0;
				n = 0;
			}
			#end
		}
	}
}
