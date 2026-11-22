package c64;

/** SID sound chip ($D400). 3 voices (0-2). **/
class Sid {
	public static inline final TRIANGLE = 16;
	public static inline final SAW = 32;
	public static inline final PULSE = 64;
	public static inline final NOISE = 128;

	public static inline function volume(v:Int) {
		Mem.poke(0xD418, v & 15);
	}

	/** Frequency register value (16 bit). For PAL: reg = Hz * 17.03 **/
	public static inline function setFreq(voice:Int, freq:Int) {
		Mem.poke(0xD400 + voice * 7, freq & 255);
		Mem.poke(0xD401 + voice * 7, (freq >> 8) & 255);
	}

	public static inline function setPulseWidth(voice:Int, pw:Int) {
		Mem.poke(0xD402 + voice * 7, pw & 255);
		Mem.poke(0xD403 + voice * 7, (pw >> 8) & 15);
	}

	/** attack/decay/sustain/release are 0-15. **/
	public static inline function setEnvelope(voice:Int, attack:Int, decay:Int, sustain:Int, release:Int) {
		Mem.poke(0xD405 + voice * 7, (attack << 4) | decay);
		Mem.poke(0xD406 + voice * 7, (sustain << 4) | release);
	}

	/** Start a note (gate on) with a waveform. **/
	public static inline function noteOn(voice:Int, waveform:Int) {
		Mem.poke(0xD404 + voice * 7, waveform | 1);
	}

	/** Release the note (gate off). **/
	public static inline function noteOff(voice:Int, waveform:Int) {
		Mem.poke(0xD404 + voice * 7, waveform);
	}
}
