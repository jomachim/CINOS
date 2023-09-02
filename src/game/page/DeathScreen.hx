package page;

import h2d.Object;
import dn.legacy.Color;
import h2d.Interactive;
import h2d.Layers;
import h2d.ScaleGrid;
import dn.Process;
import h2d.Text;
import page.MenuItem;
import dn.Delayer;

class DeathScreen extends AppChildProcess {
	public static var ME:DeathScreen;

	var ca:ControllerAccess<GameAction>;
	var ready:Bool;
	var racine:h2d.Layers;
	var bgCol:h2d.Bitmap;
	var rect:h2d.Graphics;
	var texte:h2d.Text;

	public function new(parent:Process) {
		super();
		ME = this;
		ready = false;
		// createRootInLayers(parent.root, Const.DP_UI);
		racine = new Layers(root);
		cd = new dn.Cooldown(Const.FPS);
		ca = App.ME.controller.createAccess();
		S.drama01().play(false, App.ME.options.volume*0.5).pitchRandomly(0.14);
		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex("#000000")));
		racine.add(bgCol, Const.DP_MAIN);

		rect = new h2d.Graphics(racine);
		rect.beginFill(Black, 0.85);
		rect.drawRect(0, 0, w(), h());
		racine.under(rect);
		rect.x = -w();
		texte = new h2d.Text(Assets.fontPixel, racine);
		//texte.font=hxd.res.DefaultFont.get();		
		texte.filter = new dn.heaps.filter.PixelOutline(0x761B1B, 0.8);
		texte.scale(8);
		texte.textColor = 0xff0000;
		texte.textAlign = Center;
		texte.text = 'GAME OVER';
		texte.x = w() * 0.5;
		texte.y = h() * 0.5;
		tw.createS(rect.x, 0, 0.5).end(() -> {
			ready = true;
		});
		cd.setS('gameOver', 5);
		fadeIn(0.8);
	}

	override function update() {
		super.update();
		texte.scaleX=4+(3*cd.getRatio('gameOver'));
		texte.scaleY=texte.scaleX;
		texte.alpha=1-cd.getRatio('gameOver');
		if (!cd.has('gameOver')) {
			App.ME.startTitleScreen();
			destroy();
			fadeOut(0.8, () -> {
				trace('nope');
				App.ME.startTitleScreen();
				destroy();
			});
		}
		if (!ready)
			return;
	}

	override function onDispose() {
		super.onDispose();
		racine.removeChildren();
		racine.remove();
		rect = null;
	}

	override function onResize() {
		super.onResize();
		texte.setScale(dn.heaps.Scaler.bestFit_i(w() * 0.5, h() * 0.5));
	}
}
