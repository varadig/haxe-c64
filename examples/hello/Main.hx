import c64.*;

class Main {
	static function main() {
		Vic.border = Color.BLUE;
		Vic.background = Color.BLACK;
		Screen.setTextColor(Color.LIGHT_GREEN);
		Screen.clear();
		Screen.print(11, 10, "HELLO FROM HAXE!");
		Screen.setTextColor(Color.GREY);
		Screen.print(9, 12, "COMPILED WITH HAXE64");
		var frame = 0;
		while (true) {
			Vic.waitFrame();
			frame++;
			Screen.setTextColor(Color.WHITE);
			Screen.printNum(17, 14, frame, 5);
		}
	}
}
