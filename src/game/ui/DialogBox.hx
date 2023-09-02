package ui;

import dn.Delayer;
import h2d.Flow;

class DialogBox extends Flow {
	public var app(get, never):App;

	inline function get_app()
		return App.ME;

	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.exists() ? Game.ME.fx : null;

	public var level(get, never):Level;

	inline function get_level()
		return Game.exists() ? Game.ME.level : null;

	public var txt:h2d.Text;
	public var lines:Array<String>;
	public var callBack:Null<Dynamic>;

	var lineIndex:Int;
	var offsetX:Float;
	var offsetY:Float;

	public function new(dialog:Array<String>, ?_x:Float, ?_y:Float, ?parent:Null<h2d.Object>, ?cb:Null<Dynamic>) {
		super(parent);
		if (cb != null) {
			callBack = cb;
		}
	
		
		offsetX = 0;
		offsetY = 0;
		
			if (_x + 208 > game.camera.cRight * Const.GRID) {
				offsetX = -208;
			}
			if (_y + 200 > game.camera.cBottom * Const.GRID) {
				offsetY = -200;
			}
		
		if (_x != null && _y != null) {
			moveTo(_x + offsetX, _y + offsetY);
		} else {
			moveTo(game.player.attachX + offsetX, game.player.attachY + 16 + offsetY);
		}
		lineIndex = 0;
		backgroundTile = Assets.tiles.getTile(D.tiles.dialogBox); // D.tiles.uiDarkBox
		borderWidth = 17;
		borderHeight = 20;
		addSpacing(16);
		padding = 16;
		maxWidth = 200;
		minWidth = 148;
		minHeight = 64;
		maxHeight = 320;
		layout = Horizontal;

		filter = new h2d.filter.Glow(0x353a3a, 0.8, 1, 1, 1, true);
		txt = new h2d.Text(hxd.res.DefaultFont.get()); // Assets.fontPixelMono
		txt.textColor=0x000000;
		txt.filter = new dn.heaps.filter.PixelOutline(0x7B7B7B, 0.8);
		lines = dialog;
		txt.text = "Default text placeHolder";
		addChild(txt);
		next();
	}

	public function next() {
		if (lineIndex > lines.length - 1) {
			if (callBack != null) {
				callBack();
			}
			destroy();
			return;
		}
		txt.text = txt.getTextProgress(lines[lineIndex], 0);
		game.delayer.addS(() -> {
			if (lineIndex++ < lines.length)
				next();
		}, 2);
		var tt = game.tw.createS(txt.alpha, 1, TLinear, 0.25);
		tt.onUpdate = function() {
			// trace(Std.int(tt.n*100)+"% progress");
			if (lines[lineIndex] != null) {
				txt.text = txt.getTextProgress(lines[lineIndex], lines[lineIndex].length * tt.n);
			}
		}
	}

	public function moveTo(_x:Float, _y:Float) {
		x = _x;
		y = _y;
	}

	public function attachTo(e:Entity) {
		x = e.attachX;
		y = e.attachY;
	}

	public function destroy() {
		this.remove();
		txt.remove();
	}
}
