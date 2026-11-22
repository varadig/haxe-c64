import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuState extends FlxState {
	var blink:FlxText;

	override public function create():Void {
		FlxG.camera.bgColor = FlxColor.BLACK;
		FlxG.camera.borderColor = FlxColor.BLUE;
		var title = new FlxText(96, 64, 0, "FLIXEL64 DEMO");
		title.color = FlxColor.YELLOW;
		add(title);
		add(new FlxText(56, 88, 0, "A HAXEFLIXEL-LIKE API FOR C64"));
		var t = new FlxText(48, 120, 0, "ARROWS / JOYSTICK  MOVE");
		t.color = FlxColor.LIGHT_BLUE;
		add(t);
		var t2 = new FlxText(48, 128, 0, "SPACE / UP / FIRE  JUMP");
		t2.color = FlxColor.LIGHT_BLUE;
		add(t2);
		blink = new FlxText(80, 168, 0, "PRESS SPACE OR FIRE");
		add(blink);
	}

	override public function update():Void {
		super.update();
		blink.visible = (FlxG.frame & 32) != 0;
		if (!blink.visible) blink.text = "                   "; else blink.text = "PRESS SPACE OR FIRE";
		if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.FIRE || FlxG.keys.justPressed.ENTER) {
			FlxG.sound.play(flixel.system.FlxSound.FlxSfx.SELECT);
			FlxG.switchState(new PlayState());
		}
	}
}
