import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WinState extends FlxState {
	override public function create():Void {
		FlxG.camera.bgColor = FlxColor.BLACK;
		FlxG.camera.borderColor = FlxColor.GREEN;
		var t = new FlxText(104, 88, 0, "YOU GOT THEM ALL!");
		t.color = FlxColor.YELLOW;
		add(t);
		add(new FlxText(88, 120, 0, "PRESS SPACE TO RESTART"));
	}

	override public function update():Void {
		super.update();
		if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.FIRE) FlxG.switchState(new MenuState());
	}
}
