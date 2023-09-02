package page;

import h2d.Object;
import dn.legacy.Color;
import h2d.Interactive;
import h2d.Layers;
import h2d.ScaleGrid;
import dn.Process;
import h2d.Text;
import page.MenuItem;

class IntroPage extends dn.Process {
	public static var ME:IntroPage;

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
	var parentProcess:Process;

	public function new(parent:Process) {
		super(parent);
		parentProcess = parent;
		ME = this;
		ready = false;
		createRootInLayers(parent.root, Const.DP_UI);
		racine = new Layers(root);

		ca = App.ME.controller.createAccess();
		cm = new dn.Cinematic(Const.FPS);
		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex("#000000")));
		racine.add(bgCol, Const.DP_MAIN);
		pressStart = new Text(Assets.fontPixel, racine);
		warning = new Text(Assets.fontPixel, racine);
		warning.color = new h3d.Vector(1, 0, 0);
		warning.textAlign = Align.Center;
		warning.x = w() * 0.5;
		warning.y = h() * 0.5;
		pressStart.text = "";
		pressStart.textAlign = Align.Center;
		pressStart.x = 0;
		rect = new h2d.Graphics(racine);
		rect.beginFill(Black, 1.0);
		rect.drawRect(0, 0, w(), h());
		// racine.under(rect);
		rect.x = 0;
		rect.alpha = 0;
		tw.createS(rect.alpha, 1, 1.5).end(() -> {
			ready = true;
			playIntro();
		});
	}
	
	function playIntro() {
		box = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.titleHead));
		box.tile.setCenterRatio();
		racine.add(box, Const.DP_MAIN);
		logo = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.cinos));
		logo.tile.setCenterRatio();
		racine.add(logo, Const.DP_MAIN);
		/*new ui.DialogBox([
			"Once uppon a time...",
			"A little creature who lived in a small land.",
			"A small land of magics and miracles",
			"unknow from most people."
		], w() * 0.5, h() * 0.5, racine, () -> true);

		cm.create({
			1000;
			box.scale(dn.heaps.Scaler.fill_f(200, 200));
			2000;
			logo.scale(dn.heaps.Scaler.fill_f(200, 200));
			3000;
		});
		*/
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
			TitleScreen.ME.resume();
			destroy();
		}
		if (ca.isKeyboardPressed(K.ESCAPE)) {
			TitleScreen.ME.ca.unlock();
			if (Game.exists()) {
				Game.ME.ca.unlock();
				Game.ME.resume();
			}
			TitleScreen.ME.resume();
			destroy();
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
