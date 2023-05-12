package page;

import hxd.res.Sound;
import hxd.Key;
import h2d.Scene;
import h3d.Vector;
import h3d.mat.Texture;
import h2d.filter.Shader;
import sample.NormalShader;
import h2d.Bitmap;
import haxe.Exception;
import sample.SimpleShader;
import h2d.Text;
import h2d.Interactive;
import dn.heaps.HParticle;

class TitleScreen extends AppChildProcess {
	public static var ME:TitleScreen;

	public var ca:ControllerAccess<GameAction>;

	var bgCol:h2d.Bitmap;
	var bg:h2d.Bitmap;
	var box:h2d.Bitmap;
	var logo:h2d.Bitmap;
	var titleHead:h2d.Bitmap;
	var cinos:h2d.Bitmap;
	var wallColors:h2d.Bitmap;
	var wallNormals:h2d.Bitmap;
	var wallGloss:h2d.Bitmap;

	var tex:h3d.mat.Texture;
	var tex1:h3d.mat.Texture;

	var head:dn.heaps.HParticle;
	var versionNumber:h2d.Text;
	var pressStart:h2d.Text;
	var cm:dn.Cinematic;

	// var optionsButtons:Array<Interactive>=[];
	var pool:dn.heaps.HParticle.ParticlePool;
	var fxAdd:h2d.SpriteBatch;
	var fxNormal:h2d.SpriteBatch;
	var upscale = 1.;

	public var appearSfx:dn.heaps.Sfx;
	public var zik:dn.heaps.Sfx;

	public var disp:h2d.filter.Displacement;
	public var norm:NormalShader;
	public var nothing:h2d.filter.Nothing;
	public var simpleShader:SimpleShader;
	public var glow:h2d.filter.Glow;

	var menuIndex:Int = 0;

	function showOptions() {
		trace("showing options");
	}

	var menuOptions:Array<Dynamic> = [
		{option: "Start New Game", cb: null},
		{option: "Load saved Game", cb: null},
		{option: "Options", cb: null},
		{option: "Reset", cb: null},
		{option: "Quit", cb: App.ME.exit}
	];
	var bts:Array<Interactive> = [];

	public var mcbs:Map<Int, Dynamic> = new Map();

	var citations:Array<String> = [];

	public static inline function exists() {
		return ME != null && !ME.destroyed;
	}

	public function new() {
		super();
		ME = this;
		if (Game.ME != null) {
			throw new Exception('jeu non détruit !');
			Game.ME = null;
		}

		fadeIn();

		pool = new dn.heaps.HParticle.ParticlePool(Assets.tiles.tile, 2048, Const.FPS);
		engine.backgroundColor = 0x000000;
		cm = new dn.Cinematic(Const.FPS);
		ca = App.ME.controller.createAccess();
		cd = new dn.Cooldown(getDefaultFrameRate());
		appearSfx = S.exp02();
		zik = S.intro();
		versionNumber = new h2d.Text(Assets.fontPixel);
		versionNumber.text="Version: "+Const.BUILD_INFO ;//"Version: 0.0.1";
		versionNumber.x=4;
		versionNumber.y=h()-24;
		root.add(versionNumber, Const.DP_UI);
		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex('0xEA9502'))); // hxd.Res.atlas.title.bg.toTile());
		root.add(bgCol, Const.DP_MAIN);

		//wallNormals = new Bitmap(hxd.Res.atlas.wallNormal.toTile());
		// wallNormals.blendMode=Add;
		// wallNormals.alpha=0.8;
		//wallNormals.setScale(0.5);
		//wallNormals.tile.setCenterRatio();
		//root.add(wallNormals, Const.DP_MAIN);

		//wallGloss = new Bitmap(hxd.Res.atlas.wallGloss.toTile());
		//wallGloss.tile.setCenterRatio();
		//wallGloss.setScale(1);
		// root.add(wallGloss,Const.DP_MAIN);

		//wallColors = new Bitmap(hxd.Res.atlas.wallColors.toTile());
		//wallColors.tile.setCenterRatio();
		// wallColors.setScale(0.5);
		//root.add(wallColors, Const.DP_MAIN);

		//bg = new h2d.Bitmap(hxd.Res.atlas.wallColors.toTile());
		//root.add(bg, Const.DP_MAIN);
		//bg.tile.setCenterRatio();
		//bg.setScale(0.5);

		//box = new h2d.Bitmap(hxd.Res.atlas.title.box.toTile());
		//box.tile.setCenterRatio();
		// root.add(box, Const.DP_MAIN);

		//logo = new h2d.Bitmap(hxd.Res.atlas.title.logo.toTile());
		//logo.tile.setCenterRatio();
		// root.add(logo, Const.DP_MAIN);

		titleHead = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.titleHead));
		titleHead.tile.setCenterRatio();
		root.add(titleHead, Const.DP_MAIN);

		cinos = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.cinos));
		cinos.tile.setCenterRatio();
		root.add(cinos, Const.DP_MAIN);

		fxNormal = new h2d.SpriteBatch(Assets.tiles.tile);
		root.add(fxNormal, Const.DP_FX_FRONT);
		fxNormal.hasRotationScale = true;

		fxAdd = new h2d.SpriteBatch(Assets.tiles.tile);
		root.add(fxAdd, Const.DP_FX_FRONT);
		fxAdd.blendMode = Add;
		fxAdd.hasRotationScale = true;

		pressStart = new h2d.Text(Assets.fontPixel);
		root.add(pressStart, Const.DP_FX_FRONT);
		citations = [
			"Put on the red light",
			"Press X+Y then Left, Left, Right, Right...wait..",
			"Make the right choice",
			"PRESS THE RED BUTTON NOW!",
			"Blinking Menu",
			"Use your mind to start the game",
			"Be the zen with you",
			"Be water, or better, vine.",
			"Be kind, press START",
			"How dare you ?",
			"Press a lemon before it's too late",
			"Still want to play ?",
			"I'd be you, i wont press START...",
			"Go to bed",
			"don't have you anything better to do ?",
			"leave before it's to late",
			"this game is too hard for you",
			"DONT PLAY VIDEO GAMES"
		];
		pressStart.text = citations[irnd(0, citations.length - 1)];

		nothing = new h2d.filter.Nothing(); // force rendering for pixel perfect
		simpleShader = new sample.SimpleShader(20.0);
		glow = new h2d.filter.Glow(0x2b2ba9, 0.8, 3, 1, 2);
		//norm = new NormalShader();
		//tex1 = new Texture(Std.int(wallColors.tile.width), Std.int(wallColors.tile.height), [Target]);
		//tex = new Texture(Std.int(wallColors.tile.width), Std.int(wallColors.tile.height), [Target]);
		//wallColors.drawTo(tex1); // .tile.getTexture()
		//wallNormals.drawTo(tex);
		//norm.mp = new Vector(0.5, 0.5, 0, 0);
		//norm.texture = tex1;
		//norm.normal = tex;

		//wallColors.addShader(norm);
		//titleHead.addShader(norm);

		run();
	}

	var ready = true;

	function run() {
		if(zik.isPlaying()){
			zik.stop();
			appearSfx = null;
			zik = null;
		}
		

		appearSfx = S.exp02();
		zik = S.intro();

		resetButtons();
		onResize();
		var s = upscale;
		pressStart.alpha = 0;
		//bg.scale(2);
		//wallNormals.scale(2);
		//bg.alpha = 0;
		// box.alpha = 0;
		// box.colorAdd = new h3d.Vector();
		// box.colorAdd.r = 0.5;
		// box.colorAdd.g = 1;
		// box.colorAdd.b = 1;
		// logo.colorAdd = new h3d.Vector();
		// logo.colorAdd.r = 0;
		// logo.colorAdd.g = -1;
		// logo.colorAdd.b = -1;
		// logo.alpha = 0;

		// zik.play(true,0.5);
		if(!zik.isPlaying())
			zik.playFadeIn(true, App.ME.options.volume*0.5, 2);
		cm.create({
			//700;
			//tw.createS(bg.scaleX, s, 1);
			//tw.createS(bg.scaleY, s, 1);
			//tw.createS(bg.alpha, 1, 1);
			//700;
			// box.alpha = 1;
			// box.scale(2);
			150 >> shake(0.4);
			150 >> appearSfx.play(App.ME.options.volume);
			// tw.createS(box.scaleX, s, 0.15);
			// tw.createS(box.scaleY, s, 0.15);
			// tw.createS(box.colorAdd.r, 0, 0.5);
			// tw.createS(box.colorAdd.g, 0, 0.2);
			// tw.createS(box.colorAdd.b, 0, 0.4);
			200;
			// tw.createS(logo.alpha, 1, 0.3);
			tw.createS(pressStart.alpha, 1, 1);
			50 >> initMenuOptions();
			200;
			ready = true;
			// tw.createS(logo.colorAdd.r, 0, 0.5);
			// tw.createS(logo.colorAdd.g, 0, 0.2);
			// tw.createS(logo.colorAdd.b, 0, 0.4);
		});
	}

	function shake(t) {
		cd.setS("shake", t);
	}

	function resetButtons() {
		pressStart.text = citations[irnd(0, citations.length - 1)];
		menuIndex = 0;
		mcbs.clear();
		for (i in 0...bts.length) {
			bts[i].removeChildren();
			root.removeChild(bts[i]);
		}
		bts = [];
	}

	function initMenuOptions() {
		resetButtons();
		// cd = new dn.Cooldown( getDefaultFrameRate() );
		hxd.Timer.skip();
		for (i in 0...menuOptions.length) {
			var m = menuOptions[i];
			m.index = i;
			if (m.cb == null) {
				switch (i) {
					case 0:
						mcbs.set(i, skip);

					case 1:
						mcbs.set(i, () -> {
							var savesPage = new SavesPage(this);
							ME.addChild(savesPage);
							ca.lock();
						});
					case 2:
						mcbs.set(i, () -> {
							var optionPage = new OptionPage(this);
							ME.addChild(optionPage);
							ca.lock();
						});
					case 3:
						mcbs.set(i, () -> {
							GameStats.clearAll();
							if(zik.isPlaying())
								zik.stopWithFadeOut(1);
							fadeOut(1, () -> {
								destroy();
								root.removeChildren();
								App.ME.startTitleScreen();
							});
						});
				}
				m.cb = mcbs.get(i);
			}
			var bt_txt = new Text(Assets.fontPixel);
			var twid = bt_txt.calcTextWidth(m.option);
			var bt = new Interactive(128 + twid, 32);
			bt.addChild(bt_txt);
			bt_txt.scale(2);
			bt_txt.textAlign = Align.Left;
			root.add(bt, Const.DP_UI);
			bt.filter = menuIndex != 0 ? nothing : glow;
			bt_txt.text = m.option;
			bt.x = w() * 0.7;
			bt.y = h() * 0.6 + 24 * i;

			bt.onRelease = (e) -> {
				if (m.cb != null)
					m.cb();
			}
			bt.onOver = (e) -> {
				hxd.Timer.skip();
				if (cd == null)
					return;
				cd.setS('select', 0.5);
				bt.filter = glow;
				menuIndex = m.index;
				tw.createMs(bt_txt.scaleX, 2.5, TLinear, 200);
				tw.createMs(bt_txt.scaleY, 2.5, TBackOut, 200);
			}
			bt.onOut = (e) -> {
				hxd.Timer.skip();
				if (cd == null)
					return;
				cd.setS('select', 0.5);
				tw.createMs(bt_txt.scaleX, 2, TLinear, 200);
				tw.createMs(bt_txt.scaleY, 2, TBackOut, 200);
			}
			bts.push(bt);
		}
	}

	override function preUpdate() {
		super.preUpdate();
		cm.update(tmod);
		pool.update(tmod);
	}

	override function onResize() {
		super.onResize();

		for (i in 0...bts.length) {
			var bt = bts[i];
			bt.x = w() * 0.7;
			bt.y = h() * 0.6 + 24 * i;
		}

		bgCol.scaleX = w();
		bgCol.scaleY = h();

		upscale = dn.heaps.Scaler.bestFit_i(titleHead.tile.height, titleHead.tile.height*2); // only height matters
		// box.setScale(upscale);
		//bg.setScale(upscale);
		//wallNormals.setScale(upscale);
		//wallColors.setScale(upscale);
		//wallGloss.setScale(upscale);
		// logo.setScale(upscale);
		titleHead.setScale(upscale);
		cinos.setScale(upscale);
		fxAdd.setScale(upscale);
		fxNormal.setScale(upscale);

		pressStart.setScale(upscale);
		pressStart.setPosition(Std.int(w() * 0.5 - pressStart.textWidth * 0.5 * pressStart.scaleX),
			Std.int(h() * 0.82 - pressStart.textHeight * 0.5 * pressStart.scaleY));

		// box.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		//bg.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		//wallNormals.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		//wallColors.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		//wallGloss.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		// logo.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.5));
		titleHead.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.25));
		cinos.setPosition(Std.int(w() * 0.5), Std.int(h() * 0.65));
	}

	inline function allocAdd(id:String, x:Float, y:Float):HParticle {
		return pool.alloc(fxAdd, Assets.tiles.getTile(id), x, y);
	}

	inline function allocNormal(id:String, x:Float, y:Float):HParticle {
		return pool.alloc(fxNormal, Assets.tiles.getTile(id), x, y);
	}

	override function postUpdate() {
		super.postUpdate();

		if (cd.has("shake")) {
			var r = cd.getRatio("shake");
			root.y = Math.sin(ftime * 10) * r * 2 * Const.SCALE;
		} else
			root.y = 0;

		pressStart.visible = Std.int(stime / 0.25) % 2 == 0;

		if (ready && !cd.hasSetS("fx", 0.03)) {
			var w = w() / upscale;
			var h = h() / upscale;
			// Black smoke
			for (i in 0...4) {
				var xr = rnd(0, 1);
				var p = allocNormal(R.pct(70) ? D.tiles.fxDirt : D.tiles.fxSmoke, w * xr, h + rnd(0, 10, true) - rnd(0, xr * 70));
				p.setFadeS(rnd(0.1, 0.35), 1, rnd(1, 2));
				p.colorize(Col.inlineHex('0x9892BF')); // Assets.dark()
				p.rotation = R.fullCircle();
				p.setScale(rnd(3, 4, true));
				// p.alpha=0.25;
				p.gy = -R.around(0.02);
				p.gx = rnd(0, 0.01);
				p.frict = R.aroundBO(0.9, 5);
				p.lifeS = rnd(1, 3);
			}
			for (i in 0...1) {
				var xr = rnd(0, 1);
				var p = allocAdd(D.tiles.fxSmoke, w * xr, h + 30 - rnd(0, 40, true) - rnd(0, xr * 50));
				p.setFadeS(rnd(0.04, 0.10), 1, rnd(1, 2));
				p.colorize(Col.inlineHex('0x403396')); // Assets.blue()
				// p.alpha=0.25;
				p.rotation = R.fullCircle();
				p.setScale(rnd(2, 3, true));
				p.gy = -R.around(0.01);
				p.gx = rnd(0, 0.01);
				p.frict = R.aroundBO(0.9, 5);
				p.lifeS = rnd(1, 2);
			}
			for (i in 0...4) {
				var p = allocAdd(D.tiles.leaf+irnd(0,2), rnd(0, w * 0.8), rnd(0, h * 0.7));
				p.setFadeS(rnd(0.2, 0.5), 1, rnd(1, 2));
				p.colorAnimS(Col.inlineHex("#ff6900"), Assets.dark(), rnd(1, 3));
				p.alphaFlicker = rnd(0.2, 0.5);
				p.setScale(rnd(0.25, 0.75));
				p.dr = rnd(0, 0.1, true);
				p.gx = rnd(0, 0.03);
				p.gy = rnd(-0.02, 0.08);
				p.dx = rnd(0, 1);
				// p.dy = rnd(0,1,true);
				p.frict = R.aroundBO(0.98, 5);
				p.lifeS = rnd(1, 2);
			}
		}
	}

	function skip() {
		S.__samsterbirdies__sword_draw_unsheathe(0.1);
		shake(0.1);
		// box.colorAdd.r = box.colorAdd.g = box.colorAdd.b = 1;
		// logo.colorAdd.r = logo.colorAdd.g = logo.colorAdd.b = 1;

		var s = 0.2 * upscale;
		createChildProcess((p) -> {
			// box.colorAdd.r *= 0.93;
			// box.colorAdd.g *= 0.7;
			// box.colorAdd.b *= 0.7;

			// logo.colorAdd.r *= 0.99;
			// logo.colorAdd.g *= 0.94;
			// logo.colorAdd.b *= 0.94;

			// box.setScale(upscale + s);
			// logo.setScale(upscale + s);
			s *= 0.9;
		});
		if(zik.isPlaying())
			zik.stopWithFadeOut(1);

		fadeOut(1, () -> {
			destroy();
			App.ME.startGame();
		});
	}

	/* public static inline function exists() {
		return ME!=null && !ME.destroyed;
	}*/
	override function onDispose() {
		super.onDispose();
		ca.dispose();
		zik.dispose();
		appearSfx.dispose();
		zik = null;
		appearSfx = null;
		disp=null;
		norm=null;
		nothing=null;
		simpleShader=null;
		glow=null;

		// tw=null;
		for (i in 0...bts.length) {
			bts[i] = null;
		}
		bts = null;
		mcbs = null;
	}

	override function update() {
		super.update();
		//wallColors.drawTo(tex1); // .tile.getTexture()
		// wallNormals.visible=true;
		//wallNormals.drawTo(tex);
		// wallNormals.visible=false;
		//norm.texture = tex1;
		//norm.normal = tex;
		//norm.mp = App.ME.mousePos == null ? new Vector(0, 0, 0, 0) : App.ME.mousePos;
		if (ca.isKeyboardDown(Key.T)) {
			//trace(Std.string(norm.mp));
		}
		if (ca.isDown(MoveDown) && !cd.has('select')) {
			cd.setS('select', 0.15);
			menuIndex++;
			if (menuIndex > menuOptions.length - 1) {
				menuIndex = 0;
			}
		}
		if (ca.isDown(MoveUp) && !cd.has('select')) {
			cd.setS('select', 0.15);
			menuIndex--;
			if (menuIndex < 0) {
				menuIndex = menuOptions.length - 1;
			}
		}
		if (cd.has("select")) {
			for (i in 0...bts.length) {
				if (i == menuIndex) {
					bts[i].filter = glow;
					tw.createMs(bts[i].getChildAt(0).scaleX, 2.5, TLinear, 200);
					tw.createMs(bts[i].getChildAt(0).scaleY, 2.5, TBackOut, 200);
				} else {
					bts[i].filter = nothing;
					tw.createMs(bts[i].getChildAt(0).scaleX, 2, TLinear, 200);
					tw.createMs(bts[i].getChildAt(0).scaleY, 2, TBackOut, 200);
				}
			}
		}

		if (ca.isKeyboardPressed(K.ESCAPE)) {
			App.ME.exit();
		} else if (ca.isPressed(Jump) || ca.isPressed(Pause)) { // ca.anyStandardContinuePressed()
			/*if (menuOptions[menuIndex].option == "Start New Game") {
				menuOptions[menuIndex].cd = skip;
			}*/
			if (menuOptions[menuIndex].cb != null) {
				menuOptions[menuIndex].cb();
				// ca.lock();
			}
			// skip();
		}

		#if debug
		if (ca.isKeyboardPressed(K.R))
			run();
		#end
	}
}
