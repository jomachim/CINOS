package eng;

class GC {
	static var _active = true;
	static public var memCounts:Array<Float> = [];

	public static inline function enable() {
		#if hl
		hl.Gc.enable(true);
		_active = true;
		#end
	}

	public static inline function disable() {
		#if hl
		hl.Gc.enable(false);
		_active = false;
		#end
	}

	public static inline function run() {
		#if hl
		hl.Gc.enable(true);
		hl.Gc.major();
		hl.Gc.enable(_active);
		#end
	}

	public static inline function dump() {
		#if hl
		hl.Gc.dumpMemory();
		#end
	}

	public static inline function getCurrentMem():Float {
		#if hl
		var _ = 0., v = 0.;
		@:privateAccess hl.Gc._stats(_, _, v);
		return Math.floor(v * 0.000001);
		#else
		return 0;
		#end
	}

	public static inline function getAllocationCount():Float {
		#if hl
		var _ = 0., v = 0.;
		@:privateAccess hl.Gc._stats(_, v, _);
		return v;
		#else
		return 0;
		#end
	}

	public static inline function getTotalAllocated():Float {
		#if hl
		var _ = 0., v = 0.;
		@:privateAccess hl.Gc._stats(v, _, _);
		return v;
		#else
		return 0;
		#end
	}

	public static function captureMemory() {
		memCounts.unshift(getCurrentMem());

		if (memCounts.length > Const.SAMPLE_MAX) {
			memCounts.pop();
		}
	}
}
