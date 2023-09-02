package page;

import h2d.Object;
import dn.legacy.Color;
import h2d.Interactive;
import h2d.Layers;
import h2d.ScaleGrid;
import dn.Process;
import h2d.Text;
import page.MenuItem;

class OptionPage extends dn.Process {
	public static var ME:OptionPage;

	var ca:ControllerAccess<GameAction>;
	var bgCol:h2d.Bitmap;
	var bg:h2d.Bitmap;
	var box:h2d.Bitmap;
	var logo:h2d.Bitmap;
	var upscale = 1.0;
	var pressStart:h2d.Text;
	var tx:h2d.Text;
	var txs:h2d.Text;
	var warning:h2d.Text;
	var cm:dn.Cinematic;
	var bg9:ScaleGrid;
	var racine:h2d.Layers;
	var saves:Array<Dynamic> = [];
	var bouton:MenuItem;
	var boutShad:MenuItem;
	var rect:h2d.Graphics;
	var menuIndex:Int = 0;
	var options:Array<MenuItem> = [];
	var ready:Bool;

	public function new(parent:Process) {
		super(parent);
		ME = this;
		ready = false;
		createRootInLayers(parent.root, Const.DP_UI);
		racine = new Layers(root);

		ca = App.ME.controller.createAccess();

		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex("#000000")));
		racine.add(bgCol, Const.DP_MAIN);
		pressStart = new Text(Assets.fontPixel, racine);
		warning = new Text(Assets.fontPixel, racine);
		warning.color = new h3d.Vector(1, 0, 0);
		warning.textAlign = Align.Center;
		warning.x = w() * 0.5;
		warning.y = h() * 0.5;
		pressStart.text = "OPTIONS";
		pressStart.textAlign = Align.Center;
		tw.createS(pressStart.x, w() * 0.5, 0.5);
		rect = new h2d.Graphics(racine);
		rect.beginFill(Black, 0.85);
		rect.drawRect(0, 0, w(), h());
		racine.under(rect);
		rect.x = -w();
		tw.createS(rect.x, 0, 0.5).end(() -> {
			ready = true;
		});

		bouton = new MenuItem(200, 24, rect);
		options.push(bouton);
		tx = new Text(Assets.fontPixel, bouton);
		bouton.backgroundColor = Col.inlineHex('0xB35710');
		tx.setScale(2);
		// bouton.addChild(tx);
		tx.text = App.ME.options.volume == 0 ? Std.string("VOLUME ON") : Std.string("VOLUME OFF");
		bouton.x = w() * 0.5 - 100;
		bouton.y = h() * 0.5 - 100;
		var cb = () -> {
			App.ME.options.volume = App.ME.options.volume == 0 ? 1 : 0;
			if (Game.exists()) {
				App.ME.options.volume == 0 ? Game.ME.muz.stopWithFadeOut(1) : Game.ME.muz.playFadeIn(true, App.ME.options.volume*0.25, 1);
			} else if (TitleScreen.exists()) {
				App.ME.options.volume == 0 ? TitleScreen.ME.zik.stopWithFadeOut(1) : TitleScreen.ME.zik.playFadeIn(true, App.ME.options.volume*0.25, 1);
			}
			tx.text = App.ME.options.volume == 0 ? Std.string("VOLUME ON") : Std.string("VOLUME OFF");
			// TitleScreen.ME.ca.unlock();
			// destroy();
		}
		bouton.onRelease = (e) -> {
			cb();
		}
		bouton.callBack = cb;
		bouton.onOver = (e) -> {
			cd.setS('select', 0.5);
			bouton.filter = TitleScreen.ME.glow;
			menuIndex = bouton.index;
			tw.createMs(bouton.getChildAt(0).scaleX, 2.5, TLinear, 200);
			tw.createMs(bouton.getChildAt(0).scaleY, 2.5, TBackOut, 200);
		}
		bouton.onOut = (e) -> {
			cd.setS('select', 0.5);
			// boutShad.filter =null;
			// menuIndex = -1;
			tw.createMs(bouton.getChildAt(0).scaleX, 2, TLinear, 200);
			tw.createMs(bouton.getChildAt(0).scaleY, 2, TBackOut, 200);
		}

		boutShad = new MenuItem(200, 24, rect);
		options.push(boutShad);
		txs = new Text(Assets.fontPixel, boutShad);
		boutShad.backgroundColor = Col.inlineHex('0xB35710');
		txs.setScale(2);
		// bouton.addChild(tx);
		txs.text = App.ME.options.shaders == false ? Std.string("SHADERS ON") : Std.string("SHADERS OFF");
		boutShad.x = w() * 0.5 - 100;
		boutShad.y = h() * 0.5 - 100 + 28;
		var cb = () -> {
			App.ME.options.shaders = App.ME.options.shaders == false ? true : false;
			txs.text = App.ME.options.shaders == false ? Std.string("SHADERS ON") : Std.string("SHADERS OFF");
			// TitleScreen.ME.ca.unlock();
			// destroy();
		}
		boutShad.onRelease = (e) -> {
			cb();
		};
		boutShad.callBack = cb;
		boutShad.onOver = (e) -> {
			cd.setS('select', 0.5);
			boutShad.filter = TitleScreen.ME.glow;
			menuIndex = boutShad.index;
			tw.createMs(boutShad.getChildAt(0).scaleX, 2.5, TLinear, 200);
			tw.createMs(boutShad.getChildAt(0).scaleY, 2.5, TBackOut, 200);
		}
		boutShad.onOut = (e) -> {
			cd.setS('select', 0.5);
			// boutShad.filter =null;
			// menuIndex = -1;
			tw.createMs(boutShad.getChildAt(0).scaleX, 2, TLinear, 200);
			tw.createMs(boutShad.getChildAt(0).scaleY, 2, TBackOut, 200);
		}
	}

	override function update() {
		super.update();
		if (!ready)
			return;
		if (ca.isPressed(Pause) || ca.isPressed(Lazer)) {
			TitleScreen.ME.ca.unlock();
			if (Game.exists()) {
				Game.ME.ca.unlock();
				Game.ME.resume();
			}
			destroy();
		}
		if (ca.isKeyboardPressed(K.ESCAPE)) {
			TitleScreen.ME.ca.unlock();
			if (Game.exists()) {
				Game.ME.ca.unlock();
				Game.ME.resume();
			}
			destroy();
		}
		if (ca.isDown(MoveDown) && !cd.has('select')) {
			cd.setS('select', 0.15);
			menuIndex++;
			if (menuIndex > options.length - 1) {
				menuIndex = 0;
			}
		}
		if (ca.isDown(MoveUp) && !cd.has('select')) {
			cd.setS('select', 0.15);
			menuIndex--;
			if (menuIndex < 0) {
				menuIndex = options.length - 1;
			}
		}
		for (i in 0...options.length) {
			if (i == menuIndex) {
				options[i].filter = TitleScreen.ME.glow;
				tw.createMs(options[i].getChildAt(0).scaleX, 2.5, TLinear, 200);
				tw.createMs(options[i].getChildAt(0).scaleY, 2.5, TBackOut, 200);
			} else {
				options[i].filter = null;
				tw.createMs(options[i].getChildAt(0).scaleX, 2, TLinear, 200);
				tw.createMs(options[i].getChildAt(0).scaleY, 2, TBackOut, 200);
			}
		}
		if (ca.isPressed(Jump) || ca.isPressed(Pause)) {
			if (options[menuIndex] != null) {
				if (options[menuIndex].callBack != null) {
					options[menuIndex].callBack();
				}
			}
		}
	}

	override function onDispose() {
		super.onDispose();
		racine.removeChildren();
		racine.remove();
		bouton = null;
		boutShad = null;
		rect = null;
		tx = null;
		txs = null;
	}

	override function onResize() {
		super.onResize();
		upscale = dn.heaps.Scaler.bestFit_i(w() * 0.5, h() * 0.5); // only height matters
		pressStart.setScale(upscale);
		warning.setScale(upscale);
	}
}
