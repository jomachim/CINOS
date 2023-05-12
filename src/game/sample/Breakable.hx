package sample;

import hxd.res.Sound;
import GameStats.Achievement;

class Breakable extends Entity {
	public static var ALL:Array<Breakable> = [];

	var f:Int = 0;

	public var actionString:String;
	public var done:Bool = false;
	public var booms:Sound = null;
	public var data:Entity_Breakable = null;

	// public var collides:Bool = false;
	var collides(get, never):Bool;

	inline function get_collides()
		return game.player.centerX >= left
			&& game.player.centerX <= right
			&& game.player.centerY >= top
			&& game.player.centerY <= bottom;

	public function new(d:Entity_Breakable) {
		super(0, 0);
		ALL.push(this);
		data = d;
		// activated = d.f_activated;
		done = false;
		wid = d.width;
		hei = d.height;
		initLife(3);
		setPosPixel(d.pixelX, d.pixelY);
		pivotX = 0;
		pivotY = 0;
		spr.set(D.tiles.breakable0);

		spr.filter = null; // new h2d.filter.Group([new dn.heaps.filter.PixelOutline(0x330000, 0.8)]);
		var g = new h2d.Graphics(spr);
		level.breakables.set(Breaks, d.cx, d.cy);
		#if debug
		g.beginFill(0x000000, 0.025);
		g.drawRect(0, 0, wid, hei);
		#end
		game.scroller.under(spr);
	}

	override function dispose(){
		ALL.remove(this);
		super.dispose();
	}

	override function fixedUpdate() {
		if (done == false) {
			if (f > 2) {
				f = 0;
			}

			// etapes : breaks to breaking to broken
			if (level.breakables.has(Breaking, cx, cy) && !cd.has('breaking')) {
				cd.setS('breaking', 0.5);
				fx.explosion(centerX, centerY, 1, Col.inlineHex("0xffffff"), 4);
				hit(1, game.player);
				cd.setMs('blinc', 800);
				spr.set(D.tiles.breakable1);
				// level.breakables.set(Broken, cx, cy);
			} else if (level.breakables.has(Broken, cx, cy) && !cd.has('breaking')) {
				cd.setS('breaking', 0.5);
				fx.explosion(centerX, centerY, 1, Col.inlineHex("0xffffff"), 4);
				hit(1, game.player);
				cd.setMs('blinc', 800);
				spr.set(D.tiles.breakable2);
			}
			if (life <= 1) {
				if (!game.gameStats.has(data.iid + "broken")) {
					var a = new Achievement(data.iid + "broken", data.iid + "broken", () -> !level.breakables.has(Breaks, cx, cy), 
					() -> true//trace("cassé!")
					);
					game.gameStats.registerState(a);
				}
				level.breakables.remove(Broken, cx, cy);
				fx.explosion(centerX, centerY, 1, Col.inlineHex("0xffffff"), 8);
				// spr.set('empty');
				done = true;
				initLife(0);
				destroy();
			}
			if ((game.gameStats.has(data.iid + "broken") && level.breakables.has(Breaks, cx, cy))) {
				// dispose();
				level.breakables.remove(Breaks, cx, cy);
				spr.set('empty');
				done = true;
				destroy();
			}
		}
	}
}
