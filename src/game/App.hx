import h2d.filter.Bloom;
/**
	"App" class takes care of all the top-level stuff in the whole application. Any other Process, including Game instance, should be a child of App.
**/
import h2d.Tile;
import h3d.shader.ScreenShader;
import sample.ColorFilter;
import h3d.Vector;
import hxd.Save;
import eng.GC;

class App extends dn.Process {
	public static var ME:App;

	/** 2D scene **/
	public var scene(default, null):h2d.Scene;

	public var mousePos:Vector;

	/** Used to create "ControllerAccess" instances that will grant controller usage (keyboard or gamepad) **/
	public var controller:Controller<GameAction>;

	public var controllerB:Controller<GameAction>;

	/** Controller Access created for Main & Boot **/
	public var ca:ControllerAccess<GameAction>;

	public var ca2:ControllerAccess<GameAction>;

	public var pads:Array<hxd.Pad> = [];

	/** If TRUE, game is paused, and a Contrast filter is applied **/
	public var screenshotMode(default, null) = true;

	public static var windowInst:hxd.Window;

	// saves
	public var pseudo:String = "kariboo84";
	public var savegames:hxd.Save;
	public var simpleShader:sample.SimpleShader;
	public var fog:sample.FogFilter;
	public var fadeToBlack:sample.FadeToBlackShader;
	public var crt:dn.heaps.filter.Crt;
	public var disp:h2d.filter.Displacement;
	public var colorFilter:ColorFilter;
	public var bloom:h2d.filter.Bloom;
	public var colorShader:h3d.shader.ScreenShader;
	public var filterGroup:h2d.filter.Group;
	public var currentSavedGame = null;
	public var options = {
		volume: 1,
		gain: 0.15,
		difficulty: 1,
		shaders: false
	};
	public var colorTexture:h3d.mat.Texture;

	public function new(s:h2d.Scene) {
		super();
		ME = this;
		scene = s;
		createRoot(scene);
		windowInst = hxd.Window.getInstance();
		windowInst.vsync = true;
		windowInst.addEventTarget(onWindowEvent);

		initEngine();
		initAssets();
		initController();
		//scene.rotation=22/180*Math.PI;
		// Create console (open with [²] key)
		new ui.Console(Assets.fontPixelMono, scene); // init debug console

		// Optional screen that shows a "Click to start/continue" message when the game client looses focus
		if (dn.heaps.GameFocusHelper.isUseful())
			new dn.heaps.GameFocusHelper(scene, Assets.fontPixel);

		#if debug
		Console.ME.enableStats();
		GC.enable();
		#end

		resetFilters();

		startTitleScreen();
		// startGame();
	}

	public function resetFilters() {
		disp = null;
		simpleShader = null;
		fadeToBlack = null;
		colorFilter = null;
		filterGroup = null;
		fog=null;
		bloom = new h2d.filter.Bloom(0.125, 0.125, 8, 0.125, 3);
		disp = new h2d.filter.Displacement(Assets.normdisp.tile, 8, 8, true); // Tile.fromColor(0x00ff00,engine.width,engine.height)
		simpleShader = new sample.SimpleShader(1.8);
		simpleShader.shader.multiplier = 2.5;
		fog = new sample.FogFilter();
		fadeToBlack = new sample.FadeToBlackShader(1.0);
		fadeToBlack.shader.threshold = 0.5;
		crt = new dn.heaps.filter.Crt();
		/*colorFilter=new ColorFilter();
			colorFilter.shader.passed=rnd(0.0,1.0);
			colorFilter=new h3d.filter.Shader<ColorFilter>(new ColorFilter(),"texture"); */
		if (options.shaders == true) {
			filterGroup = new h2d.filter.Group([crt, simpleShader]); // colorFilter,fog ,bloom
			root.getScene().filter = filterGroup;
		} else {
			root.getScene().filter = new h2d.filter.Group([simpleShader]);
		}
	}

	override function onResize() {
		super.onResize();
		resetFilters();
	}

	function onWindowEvent(ev:hxd.Event) {
		switch ev.kind {
			case EPush:
			case ERelease:
			case EMove:
				onMouseMove(ev);
			case EOver:
				onMouseEnter(ev);
			case EOut:
				onMouseLeave(ev);
			case EWheel:
			case EFocus:
				onWindowFocus(ev);
			case EFocusLost:
				onWindowBlur(ev);
			case EKeyDown:
			case EKeyUp:
			case EReleaseOutside:
			case ETextInput:
			case ECheck:
		}
	}

	function onMouseMove(e:hxd.Event) {
		mousePos = new h3d.Vector(e.relX, e.relY, e.relZ);
		
		// trace(Std.string(mousePos));
	}

	function onMouseEnter(e:hxd.Event) {}

	function onMouseLeave(e:hxd.Event) {}

	function onWindowFocus(e:hxd.Event) {}

	function onWindowBlur(e:hxd.Event) {}

	#if hl
	public static function onCrash(err:Dynamic) {
		var title = L.untranslated("Fatal error");
		var msg = L.untranslated('I\'m really sorry but the game crashed! Error: ${Std.string(err)}');
		var flags:haxe.EnumFlags<hl.UI.DialogFlags> = new haxe.EnumFlags();
		flags.set(IsError);

		var log = [Std.string(err)];
		try {
			log.push("BUILD: " + Const.BUILD_INFO);
			log.push("EXCEPTION:");
			log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));

			log.push("CALL:");
			log.push(haxe.CallStack.toString(haxe.CallStack.callStack()));

			sys.io.File.saveContent("crash.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		} catch (_) {
			sys.io.File.saveContent("crash2.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		}

		hxd.System.exit();
	}
	#end

	/** start splash screen**/
	public function startTitleScreen() {
		if (Game.exists()) {
			// Kill previous game instance first
			Game.ME.destroy();

			dn.Process.updateAll(1); // ensure all garbage collection is done
			root.removeChildren();
			_createTitleScreenInstance();
			hxd.Timer.skip();
		} else {
			if (page.TitleScreen.exists()) {
				page.TitleScreen.ME.destroy();

				dn.Process.updateAll(1);
				root.removeChildren();
			}
			// Fresh start
			delayer.nextFrame(() -> {
				_createTitleScreenInstance();
				hxd.Timer.skip();
			});
		}
	}

	/** Start game process **/
	public function startGame() {
		if (Game.exists()) {
			// Kill previous game instance first

			Game.ME.destroy();
			root.removeChildren();
			dn.Process.updateAll(1); // ensure all garbage collection is done
			_createGameInstance();
			hxd.Timer.skip();
		} else {
			// Fresh start
			delayer.nextFrame(() -> {
				_createGameInstance();
				hxd.Timer.skip();
			});
		}
	}

	final function _createGameInstance() {
		new Game(); // <---- Uncomment this to start an empty Game instance
		// new sample.SampleGame(); // <---- Uncomment this to start the Sample Game instance
	}

	final function _createTitleScreenInstance() {
		new page.TitleScreen();
	}

	public function anyInputHasFocus() {
		return Console.ME.isActive() || cd.has("consoleRecentlyActive");
	}

	/**
		Set "screenshot" mode.
		If enabled, the game will be adapted to be more suitable for screenshots: more color contrast, no UI etc.
	**/
	public function setScreenshotMode(v:Bool) {
		screenshotMode = v;

		if (screenshotMode) {
			var f = new h2d.filter.ColorMatrix();
			f.matrix.colorContrast(0.2);
			root.filter = f;
			if (Game.exists()) {
				Game.ME.hud.root.visible = false;
				Game.ME.pause();
			}
		} else {
			if (Game.exists()) {
				Game.ME.hud.root.visible = true;
				Game.ME.resume();
			}
			root.filter = null;
		}
	}

	/** Toggle current game pause state **/
	public inline function toggleGamePause()
		setGamePause(!isGamePaused());

	/** Return TRUE if current game is paused **/
	public inline function isGamePaused()
		return Game.exists() && Game.ME.isPaused();

	/** Set current game pause state **/
	public function setGamePause(pauseState:Bool) {
		if (Game.exists())
			if (pauseState)
				Game.ME.pause();
			else
				Game.ME.resume();
	}

	/**
		Initialize low-level engine stuff, before anything else
	**/
	function initEngine() {
		// Engine settings
		engine.backgroundColor = 0xff << 24 | 0x111133;
		#if (hl && !debug)
		engine.fullScreen = true;
		#end

		#if (hl && !debug)
		hl.UI.closeConsole();
		hl.Api.setErrorHandler(onCrash);
		#end

		// Heaps resource management
		#if (hl && debug)
		hxd.Res.initLocal();
		hxd.res.Resource.LIVE_UPDATE = true;
		#else
		hxd.Res.initEmbed();
		#end

		// Sound manager (force manager init on startup to avoid a freeze on first sound playback)
		hxd.snd.Manager.get();
		hxd.Timer.skip(); // needed to ignore heavy Sound manager init frame

		// Framerate
		hxd.Timer.smoothFactor = 0;
		hxd.Timer.wantedFPS = Const.FPS;
		dn.Process.FIXED_UPDATE_FPS = Const.FIXED_UPDATE_FPS;
	}

	/**
		Init app assets
	**/
	function initAssets() {
		// Init game assets
		Assets.init();

		// Init lang data
		Lang.init("en");

		// Bind DB hot-reloading callback
		Const.db.onReload = onDbReload;
	}

	/** Init game controller and default key bindings **/
	function initController() {
		trace('pad init');
		controller = dn.heaps.input.Controller.createFromAbstractEnum(GameAction);
		controllerB = dn.heaps.input.Controller.createFromAbstractEnum(GameAction);
		ca = controller.createAccess();
		// ca.createDebugger(App.ME);
		ca.lockCondition = () -> return destroyed || anyInputHasFocus();

		ca2 = controller.createAccess();
		// ca2.createDebugger(App.ME);
		ca2.lockCondition = () -> return destroyed || anyInputHasFocus();

		initControllerBindings();

		/*controller.onConnect = (p) -> {
			trace(p);
			pads.push(ca.input.pad);
			trace("pad A connected " + ca.input.pad.name);
			trace('controller to string :' + controller.toString());
			trace(pads);
		};
		controllerB.onConnect = (p) -> {
			pads.push(ca.input.pad);
			trace(pads);
			trace("pad B connected " + ca.input.pad.name);
			trace('controllerB to string :' + controllerB.toString());
		};*/
	}

	public function initControllerBindings() {
		controller.removeBindings();

		// Gamepad bindings
		controller.bindPadLStick4(MoveLeft, MoveRight, MoveUp, MoveDown);

		controller.bindPad(Jump, A);
		controller.bindPad(Dash, B);
		controller.bindPad(Fire, X);
		controller.bindPad(Lazer, Y);
		controller.bindPadCombo(Action, [RT, X]);

		controller.bindPad(Lock, RT);
		controller.bindPadCombo(Extra, [LT, LB]);
		controller.bindPad(InventoryScreen, LSTICK_PUSH);
		controller.bindPad(InventoryScreen, RSTICK_PUSH);
		controller.bindPad(Restart, SELECT);
		controller.bindPad(Pause, START);

		controller.bindPad(MoveLeft, DPAD_LEFT);
		controller.bindPad(MoveRight, DPAD_RIGHT);
		controller.bindPad(MoveUp, DPAD_UP);
		controller.bindPad(MoveDown, DPAD_DOWN);

		/*controller.bindPad(MenuUp, [DPAD_UP, LSTICK_UP]);
			controller.bindPad(MenuDown, [DPAD_DOWN, LSTICK_DOWN]);
			controller.bindPad(MenuOk, [A, X]);
			controller.bindPad(MenuCancel, B); */

		// Keyboard bindings
		controller.bindKeyboard(MoveLeft, [K.LEFT, K.Q]);
		controller.bindKeyboard(MoveRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(MoveUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(MoveDown, [K.DOWN, K.S]);
		controller.bindKeyboard(Jump, K.SPACE);
		controller.bindKeyboard(Dash, K.ALT);
		controller.bindKeyboard(Fire, K.E);
		controller.bindKeyboard(Lazer, K.F);
		controller.bindKeyboard(Action, K.A);
		controller.bindKeyboard(Lock, K.SHIFT);
		controller.bindKeyboard(Restart, K.R);
		controller.bindKeyboard(ScreenshotMode, K.F9);
		controller.bindKeyboard(Pause, K.P);
		controller.bindKeyboard(Pause, K.PAUSE_BREAK);

		controller.bindKeyboard(MenuUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(MenuDown, [K.DOWN, K.S]);
		controller.bindKeyboard(MenuOk, [K.SPACE, K.ENTER, K.F]);
		controller.bindKeyboard(MenuCancel, K.ESCAPE);

		// Debug controls
		#if debug
		controller.bindPad(DebugTurbo, LT);
		controller.bindPad(DebugSlowMo, LB);
		controller.bindPad(DebugDroneZoomIn, RSTICK_UP);
		controller.bindPad(DebugDroneZoomOut, RSTICK_DOWN);

		controller.bindKeyboard(DebugDroneZoomIn, K.PGUP);
		controller.bindKeyboard(DebugDroneZoomOut, K.PGDOWN);
		controller.bindKeyboard(DebugTurbo, [K.END, K.NUMPAD_ADD]);
		controller.bindKeyboard(DebugSlowMo, [K.HOME, K.NUMPAD_SUB]);
		controller.bindPadCombo(ToggleDebugDrone, [LSTICK_PUSH, RSTICK_PUSH]);
		controller.bindKeyboardCombo(ToggleDebugDrone, [K.D, K.CTRL, K.SHIFT]);
		#end
		/**
		 * controllerB
		 */
		controllerB.removeBindings();

		// Gamepad bindings
		controllerB.bindPadLStick4(MoveLeft, MoveRight, MoveUp, MoveDown);

		controllerB.bindPad(Jump, A);
		controllerB.bindPad(Dash, B);
		controllerB.bindPad(Fire, X);
		controllerB.bindPad(Lazer, Y);
		controllerB.bindPadCombo(Action, [RT, X]);

		controllerB.bindPad(Lock, RT);
		controllerB.bindPadCombo(Extra, [LT, LB]);
		controllerB.bindPad(InventoryScreen, LSTICK_PUSH);
		controllerB.bindPad(InventoryScreen, RSTICK_PUSH);
		controllerB.bindPad(Restart, SELECT);
		controllerB.bindPad(Pause, START);

		controllerB.bindPad(MoveLeft, DPAD_LEFT);
		controllerB.bindPad(MoveRight, DPAD_RIGHT);
		controllerB.bindPad(MoveUp, DPAD_UP);
		controllerB.bindPad(MoveDown, DPAD_DOWN);

		/*controllerB.bindPad(MenuUp, [DPAD_UP, LSTICK_UP]);
			controllerB.bindPad(MenuDown, [DPAD_DOWN, LSTICK_DOWN]);
			controllerB.bindPad(MenuOk, [A, X]);
			controllerB.bindPad(MenuCancel, B); */

		// Keyboard bindings
		controllerB.bindKeyboard(MoveLeft, [K.LEFT, K.Q]);
		controllerB.bindKeyboard(MoveRight, [K.RIGHT, K.D]);
		controllerB.bindKeyboard(MoveUp, [K.UP, K.Z, K.W]);
		controllerB.bindKeyboard(MoveDown, [K.DOWN, K.S]);
		controllerB.bindKeyboard(Jump, K.SPACE);
		controllerB.bindKeyboard(Dash, K.ALT);
		controllerB.bindKeyboard(Fire, K.E);
		controllerB.bindKeyboard(Lazer, K.F);
		controllerB.bindKeyboard(Action, K.A);
		controllerB.bindKeyboard(Lock, K.SHIFT);
		controllerB.bindKeyboard(Restart, K.R);
		controllerB.bindKeyboard(ScreenshotMode, K.F9);
		controllerB.bindKeyboard(Pause, K.P);
		controllerB.bindKeyboard(Pause, K.PAUSE_BREAK);

		controllerB.bindKeyboard(MenuUp, [K.UP, K.Z, K.W]);
		controllerB.bindKeyboard(MenuDown, [K.DOWN, K.S]);
		controllerB.bindKeyboard(MenuOk, [K.SPACE, K.ENTER, K.F]);
		controllerB.bindKeyboard(MenuCancel, K.ESCAPE);

		// Debug controls
		#if debug
		controllerB.bindPad(DebugTurbo, LT);
		controllerB.bindPad(DebugSlowMo, LB);
		controllerB.bindPad(DebugDroneZoomIn, RSTICK_UP);
		controllerB.bindPad(DebugDroneZoomOut, RSTICK_DOWN);

		controllerB.bindKeyboard(DebugDroneZoomIn, K.PGUP);
		controllerB.bindKeyboard(DebugDroneZoomOut, K.PGDOWN);
		controllerB.bindKeyboard(DebugTurbo, [K.END, K.NUMPAD_ADD]);
		controllerB.bindKeyboard(DebugSlowMo, [K.HOME, K.NUMPAD_SUB]);
		controllerB.bindPadCombo(ToggleDebugDrone, [LSTICK_PUSH, RSTICK_PUSH]);
		controllerB.bindKeyboardCombo(ToggleDebugDrone, [K.D, K.CTRL, K.SHIFT]);
		#end
	}

	/** Return TRUE if an App instance exists **/
	public static inline function exists()
		return ME != null && !ME.destroyed;

	/** Close & exit the app **/
	public function exit() {
		destroy();
	}

	override function onDispose() {
		super.onDispose();

		hxd.Window.getInstance().removeEventTarget(onWindowEvent);

		#if hl
		hxd.System.exit();
		#end
	}

	/** Called when Const.db values are hot-reloaded **/
	public function onDbReload() {
		if (Game.exists())
			Game.ME.onDbReload();
	}

	override function update() {
		Assets.update(tmod);

		super.update();
		// disp.normalMap.scrollDiscrete(0.1, 0.2);
		fog.updateTime(0.016,0,0.01);
		if (!cd.has('pad')) {
			cd.setS('pad', 2);
			for (p in App.ME.pads) {
				if (p.index > 0) {
					trace("***new challenger joins the game !*** " + p.name);
				} else if (p.index == 0 && !p.connected==true) {
					trace("First controller is connected and waits" + p.name);
				}
			}
		}

		if (ca2.isPressed(Pause)) {
			engine.fullScreen = !engine.fullScreen;
			toggleGamePause();
		}
		if (ca.isPressed(ScreenshotMode))
			setScreenshotMode(!screenshotMode);

		if (ca.isPressed(Pause))
			toggleGamePause();

		if (isGamePaused() && ca.isPressed(MenuCancel))
			setGamePause(false);

		if (ui.Console.ME.isActive())
			cd.setF("consoleRecentlyActive", 2);

		if (ca.isKeyboardDown(K.CTRL) && ca.isKeyboardPressed(K.ENTER)) {
			engine.fullScreen = !engine.fullScreen;
		}
		// Mem track reporting
		#if debug
		if (ca.isKeyboardDown(K.SHIFT) && ca.isKeyboardPressed(K.ENTER)) {
			Console.ME.runCommand("/cls");
			dn.debug.MemTrack.report((v) -> Console.ME.log(v, Yellow));
		}
		#end
	}
}
