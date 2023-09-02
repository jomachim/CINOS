package sample;

import h3d.mat.Texture;
import GameStats.Achievement;

class WaterPond extends Entity {
	public static var ALL:Array<WaterPond> = [];

	public var actionString:String;
	public var done:Bool = false;
	public var countDown:Int = 10;
	public var iid:String;
	public var data:Entity_Water;
	public var splashfx:dn.heaps.Sfx;

	// public var collides:Bool = false;
	var collides(get, never):Bool;

	inline function get_collides()
		return game.player.cx >= cx
			&& game.player.cx < cx + wid / 16
			&& game.player.cy + game.player.yr >= cy + 8 / 16
			&& game.player.cy <= cy + hei / 16;

	var canBreath(get, never):Bool;

	inline function get_canBreath()
		return game.player.cy + game.player.yr < cy + 1 + 0.5;

	public var entered:Bool;
	public var activated:Bool;
	public var waterColor:Col;
	public var raisewater:Float;
	public var inflow:Dynamic;
	public var bmp:h2d.Bitmap;
	public var pat:h2d.Tile;
	public var patY:Float;
	public var g:h2d.Graphics;
	public var g1:h2d.Graphics;

	public function new(d:Entity_Water) {
		super(0, 0);
		ALL.push(this);
		data = d;
		iid = d.iid;
		entered = false;
		waterColor = Col.fromInt(d.f_Color_int);
		activated = d.f_activated;
		if (game.gameStats.has(data.iid + "activated")) {
			activated = true;
		}
		inflow = d.f_inflow_ref;
		setPosPixel(d.pixelX, d.pixelY);
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.set("empty");
		spr.alpha = data.f_alpha;
		raisewater = data.f_raisewater;
		game.scroller.over(spr);
		g = new h2d.Graphics(spr);
		g1 = new h2d.Graphics(spr);
		wid = d.width;
		hei = d.height - 8;
		if (game.gameStats.has(data.iid + "hei")) {
			hei = game.gameStats.get(data.iid + "hei").data.hei - 8;
			// setPosY(game.gameStats.get(data.iid+"hei").data.posY-hei);
			setPosY(d.pixelY - hei + d.height);
		}
		#if debug
		#end
		pat = Assets.waterfall.tile;
		g.tile = pat;
		g.tileWrap = true;

		// g.filter = new h2d.filter.Blur(8, 1.5, 3);
		g.beginTileFill(0, 0, 1, 1, pat);
		g1.beginFill(waterColor, data.f_alpha);
		g.drawRect(0, 8, wid, hei);
		g1.drawRect(0, 8, wid, hei);
		splashfx = S.splash01();

		/*bmp=new h2d.Bitmap(pat.sub(0,patY,48,16,0,0),spr);
			bmp.tileWrap=true;
			bmp.y=8;
			bmp.width=wid;
			bmp.height=hei; */
		outline = null;
	}

	override function fixedUpdate() {
		if (hei > level.pxHei - 32) {
			activated = false;
		}
		if (inflow != null) {
			for (w in sample.Shower.ALL) {
				if (w.data.iid == inflow.entityIid) {
					activated = w.activated;
					// trace("gégé "+w.activated);
				}
				if (w.activated == true && !cd.has('trace')) {
					cd.setMs('trace', 450);
					//trace(w.data.iid + ' , ' + inflow.entityIid);
				}
			}
		}
		if (activated == true && raisewater != 0.0) {
			hei += raisewater;
			setPosY(sprY - raisewater);
			if (!cd.has('flash')) {
				fx.flashBangEaseInS(waterColor, 0.7, 0.2);
				cd.setMs('flash', 1000);
			}
			game.gameStats.unregisterState(data.iid + "hei");
			var ach = new GameStats.Achievement(data.iid + "hei", "done", () -> true, () -> {}, {hei: hei, posY: sprY});
			game.gameStats.registerState(ach);
			ach = null;
		}

		g.clear();
		g1.clear();
		g1.blendMode = AlphaMultiply;
		g1.beginFill(waterColor, data.f_alpha);
		// g.filter = new h2d.filter.Blur(8, 1.5, 3);
		g.beginTileFill(0, 0, 1, 1, pat);
		g.drawRect(0, 8, wid, hei);
		g1.drawRect(0, 8, wid, hei);
		pat.scrollDiscrete(-0.5, 1);
		if (game.player.cd.has('dashing')
			&& game.player.v.dy >= 0
			&& game.player.attachY + 4 >= cy * 16 + 8
			&& game.player.attachY <= cy * 16 + 8) {
			game.player.v.dy = -0.34;
			fx.splash(game.player.attachX, game.player.attachY + 8, (cy + yr) * Const.GRID + 8, M.fabs(game.player.v.dy), waterColor);
			S.splash01().play(false, App.ME.options.volume * 0.25);
		}

		if (collides && entered == false) {
			entered = true;
			// fx.splash(game.player.attachX,game.player.attachY,M.fabs(game.player.v.dy));
			// fx.splash(game.player.attachX,game.player.attachY,M.fabs(game.player.v.dy));
			if (cy != 0) {
				fx.waveSplash(game.player.attachX, game.player.attachY + 8, false, waterColor);
				fx.splash(game.player.attachX, game.player.attachY + 8, (cy + yr) * Const.GRID + 8, M.fabs(game.player.v.dy), waterColor);
				S.splash01().play(false, App.ME.options.volume * 0.8).pitchRandomly(0.14);
			}
		}
		if (collides && entered == true) {
			game.player.cd.setMs('wasRecentlyInWater', 200);
			game.player.v.dx *= game.player.canSwim ? 0.9 : 0.5;
			game.player.v.dy *= game.player.canSwim ? 0.99 : 0.9;
			if (game.player.v.dy > 0) {
				game.player.v.dy *= game.player.canSwim ? 0.9 : 0.85;
			}
			if (game.player.canSwim == true && game.player.jumps == game.player.maxJumps) {
				game.player.jumps = 0;
			}
		} else if (entered == true) {
			cd.unset('wasRecentlyInWater');
			countDown = 10;
			entered = false;
			if (cy != 0) {
				fx.splash(game.player.attachX, game.player.attachY + 8, (cy + yr) * Const.GRID + 8, M.fabs(game.player.v.dy), waterColor);
				S.splash01().playFadeIn(false, App.ME.options.volume * 0.55, 0.1).pitchRandomly(0.14);
				fx.waveSplash(game.player.attachX, game.player.attachY + 8, true, waterColor);
			}
		}

		if (game.player.cd.has('wasRecentlyInWater') && !cd.has("breath") && !canBreath) {
			cd.setMs('breath', 1000);
			countDown--;
			game.player.blink(0xffffff);
			for (a in 0...8) {
				fx.bubbles(game.player.attachX, game.player.attachY - 18, waterColor.adjustBrightness(2), attachY, 0.25);
			}
			// game.player.debug(countDown, countDown <= 3 ? 0xff0000 : 0xffffff);
			if (countDown <= 3) {
				game.player.cd.setS('hitBump', 2);
				game.player.hit(1, null);
				countDown = 5;
			}
		}

		if (!cd.has("clignotage") && !canBreath) {
			blink(0xffffff);
			cd.setMs("clignotage", 1500);
		}
		if (!cd.has('waterFx') && cy != 0) {
			cd.setMs('waterFx', 30);
			if (rnd(0, 100) < 10) {
				for (a in 0...Std.int(wid / 32)) {
					fx.bubbles(rnd(attachX, attachX + wid), attachY + hei + 8, waterColor.adjustBrightness(0.8), attachY + 8, 0.25);
				}
			}
			for (i in 0...3) {
				for (a in 0...Std.int(wid / 16)) {
					fx.waves(rnd(attachX, attachX + wid), attachY + 8, data.pixelX, data.pixelX + wid, waterColor, attachY + 8, 0.25);
				}
			}
		}
	}
}
