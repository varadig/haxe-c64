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
		while (true) {
			Vic.waitFrame();
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
		}
	}
}
