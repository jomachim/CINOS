package page;

import dn.legacy.Color;
import h2d.Interactive;
import h2d.Layers;
import h2d.ScaleGrid;
import dn.Process;
import h2d.Text;
import page.MenuItem;

class SavesPage extends dn.Process {
	public static var ME:SavesPage;

	var ca:ControllerAccess<GameAction>;
	var bgCol:h2d.Bitmap;
	var bg:h2d.Bitmap;
	var box:h2d.Bitmap;
	var logo:h2d.Bitmap;
	var upscale = 1.0;
	var pressStart:h2d.Text;
	var warning:h2d.Text;
	var cm:dn.Cinematic;
	var bg9:ScaleGrid;
	var racine:h2d.Layers;
	var saves:Array<Dynamic> = [];
	var bouton:MenuItem;
	var ready:Bool;

	public function new(parent:Process) {
		super(parent);
		ME = this;
		ready=false;
		createRootInLayers(parent.root, Const.DP_UI);
		racine = new Layers(root);
		cm = new dn.Cinematic(Const.FPS);
		ca = App.ME.controller.createAccess();
		// upscale = dn.heaps.Scaler.bestFit_i(box.tile.height, box.tile.height); // only height matters

		// saves.push();
		var saved = {};
		var test = hxd.Save.load(saved, "./save_0", true);
		//trace(test);
		var saving = {data: test};
		saves.push(saving);

		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex("#000000")));
		racine.add(bgCol, Const.DP_MAIN);
		pressStart = new Text(Assets.fontPixel, racine);
		warning = new Text(Assets.fontPixel, racine);
		warning.color = new h3d.Vector(1, 0, 0);
		warning.textAlign = Align.Center;
		warning.x = w() * 0.5;
		warning.y = h() * 0.5;
		pressStart.text = "SELECT A SAVE ";
		pressStart.textAlign = Align.Center;
		tw.createS(pressStart.x, w() * 0.5, 0.5).end(()->{
			ready=true;
		});
		var rect = new h2d.Graphics(racine);
		rect.beginFill(Black, 0.85);
		rect.drawRect(0, 0, w(), h());
		racine.under(rect);
		rect.x = -w();
		tw.createS(rect.x, 0, 0.5);

		for (i in 0...saves.length) {
			var s = saves[i];
            
			bouton = new MenuItem(200, 24, rect);
			var tx = new Text(Assets.fontPixel, bouton);
			bouton.backgroundColor = Col.inlineHex('0xB35710');
			tx.setScale(2);
			// bouton.addChild(tx);
			tx.text = Std.string(s.data.currentWorldID + " : " + s.data.currentLevelID);
			bouton.x = w() * 0.5 - 100;
			bouton.y = h() * 0.5 - 100;
			var cb=()->{
				App.ME.currentSavedGame = s;
                App.ME.options.volume=s.data.volume;
				TitleScreen.ME.ca.unlock();
				destroy();
				if(TitleScreen.ME.zik.isPlaying())
					TitleScreen.ME.zik.stopWithFadeOut(1);

				TitleScreen.ME.fadeOut(1, () -> {
					TitleScreen.ME.destroy();
					App.ME.startGame();
				});
			}
			bouton.callBack=cb;
			bouton.onRelease = (e) -> {
				cb();
			}
		}
	}

	override function update() {
		super.update();
		if(!ready) return;
		if (ca.isPressed(Restart) || ca.isPressed(Lazer)) {
			TitleScreen.ME.ca.unlock();
			destroy();
		}
        if (ca.isKeyboardPressed(K.ESCAPE)){
            TitleScreen.ME.ca.unlock();
			destroy();
        }
		if(ca.isPressed(Jump)){
			bouton.callBack();
		}
		if (saves.length == 0 && !cd.has('nosaves')) {
			warning.text = "NO SAVED GAME HERE";
			warning.visible = !warning.visible;
			cd.setS('nosaves', 0.5);
		}
	}

	override function onDispose() {
		super.onDispose();
		racine.removeChildren();
		racine.remove();
	}

	override function onResize() {
		super.onResize();
		upscale = dn.heaps.Scaler.bestFit_i(w() * 0.5, h() * 0.5); // only height matters
		pressStart.setScale(upscale);
		warning.setScale(upscale);
	}
}
