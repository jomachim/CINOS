/**
	The Const class is a place for you to store various values that should be available everywhere in your code. Example: `Const.FPS`
**/
class Const {
	public static var SAMPLE_MAX(get, never):Int;

	static inline function get_SAMPLE_MAX()
		return 300;

	#if !macro
	/** Default engine framerate (60) **/
	public static var FPS(get, never):Int;

	static inline function get_FPS()
		return Std.int(hxd.System.getDefaultFrameRate());

	/**
		"Fixed" updates framerate. 30fps is a good value here, as it's almost guaranteed to work on any decent setup, and it's more than enough to run any gameplay related physics.
	**/
	public static final FIXED_UPDATE_FPS = 30;

	/** Grid size in pixels **/
	public static final GRID = 16;

	public static final CYCLE_S = 10;

	/** "INFINITY", sort-of. More like a "big number" **/
	public static final INFINITY = 4294967295; // : Int = 0xfffFfff

	static var _nextUniqueId = 0;
	public static var timeAccumulator = 0.0;

	public static var CHRONO(get,never):Float;
		static function get_CHRONO(){
			timeAccumulator+=hxd.Timer.elapsedTime;
			return timeAccumulator*1000;
		}

	/** Unique value generator **/
	public static inline function makeUniqueId() {
		return _nextUniqueId++;
	}

	/** Viewport scaling **/
	public static var SCALE(get, never):Int;
		static function get_SCALE() {
		// can be replaced with another way to determine the game scaling
		if (Game.exists()) {
			if (Game.ME.level != null) {
				//var min=M.fmax(200,M.fmax(200,Game.ME.level.pxHei*Game.ME.level.pxWid/GRID/4));
				//return dn.heaps.Scaler.bestFit_i(Game.ME.level.pxHei,Game.ME.level.pxWid,1280,720);
				var bestWid=M.fmax(320,Game.ME.level.pxWid);
				var bestHei=M.fmax(320,Game.ME.level.pxHei);
				var bigger=M.fmax(bestWid,bestHei);
				var smaller=M.fmin(bestWid,bestHei);
				var best=M.fmax(320,smaller);
				return dn.heaps.Scaler.bestFit_i(best/(Game.ME.stageWid/GRID)*(320/GRID),best/(Game.ME.stageHei/GRID)*(320/GRID),Game.ME.stageWid,Game.ME.stageHei);
				//return dn.heaps.Scaler.bestFit_i(Game.ME.level.pxWid,Game.ME.level.pxHei,1280,720);
			}
			return dn.heaps.Scaler.bestFit_i(256,256);
		} else {
			return dn.heaps.Scaler.bestFit_i(128, 128);
			// return Std.int(dn.heaps.Scaler.fill_f(200,200));
		}
	}

	/** Specific scaling for top UI elements **/
	public static var UI_SCALE(get, never):Float;

	static inline function get_UI_SCALE() {
		// can be replaced with another way to determine the UI scaling
		// return SCALE * 0.75;
		return dn.heaps.Scaler.bestFit_i(356,356);
	}

	/** Current build information, including date, time, language & various other things **/
	public static var BUILD_INFO(get, never):String;

	static function get_BUILD_INFO()
		return dn.MacroTools.getBuildInfo();

	/** Game layers indexes **/
	static var _inc = 0;

	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;

	/**
		Simplified "constants database" using CastleDB and JSON files
		It will be filled with all values found in both following sources:

		- `res/const.json`, a basic JSON file,
		- `res/data.cdb`, the CastleDB file, from the sheet named "ConstDb".

		This allows super easy access to your game constants and settings. Example:

			Having `res/const.json`:
				{ "myValue":5, "someText":"hello" }

			You may use:
				Const.db.myValue; // equals to 5
				Const.db.someText; // equals to "hello"

		If the JSON changes on runtime, the `myValue` field is kept up-to-date, allowing testing without recompiling. IMPORTANT: this hot-reloading only works if the project was built using the `-debug` flag. In release builds, all values become constants and are fully embedded.
	**/
	public static var db = ConstDbBuilder.buildVar(["data.cdb", "const.json"]);
	#end
}
