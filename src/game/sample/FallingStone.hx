package sample;

import hxd.res.Sound;
import GameStats.Achievement;

class FallingStone extends Entity {
	public static var ALL:Array<FallingStone> = [];

	var f:Int = 0;

	public var actionString:String;
	public var done:Bool = false;
	public var auto:Bool=false;
	public var booms:Sound = null;
	public var activated:Bool = false;
	public var data:Entity_FallingStone = null;

	// public var collides:Bool = false;
	var collides(get, never):Bool;

	inline function get_collides()
		return game.player.centerX >= left
			&& game.player.centerX <= right
			&& game.player.centerY >= top
			&& game.player.centerY <= bottom;

	public function new(d:Entity_FallingStone) {
		super(0, 0);
		ALL.push(this);
		data = d;
		// activated = d.f_activated;
		done = false;
		auto=d.f_auto;
		wid = d.width;
		hei = d.height;
		activated = d.f_activated;
		setPosPixel(d.pixelX, d.pixelY);
		pivotX = 0;
		pivotY = 0;
		spr.set(D.tiles.falling_stone);

		spr.filter = null; // new h2d.filter.Group([new dn.heaps.filter.PixelOutline(0x330000, 0.8)]);
		var g = new h2d.Graphics(spr);
		#if debug
		g.beginFill(0x000000, 0.025);
		g.drawRect(0, 0, wid, hei);
		#end
		game.scroller.under(spr);
	}

	override function dispose() {
		ALL.remove(this);
		super.dispose();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if(auto==true){
			if (sightCheck(game.player) && (distCase(game.player) < 4 || (game.player.cy>cy && game.player.cx>=cx-2 && game.player.cx<=cx+2))) {
				activated=true;
			}
		}
		if (activated == true) {
			if (!game.gameStats.has(data.iid + "activated")) {
				var a = new Achievement(data.iid + "activated", data.iid + "activated", () -> true, () -> true);
				game.gameStats.registerState(a);
				a = null;
			}
			v.dy = 0.25;
			if (game.player.right >= left && game.player.left <= right && game.player.bottom >= top && game.player.top <= bottom ) {
				game.player.hit(1,null);
				fx.explosion(centerX, centerY, 1, Col.inlineHex("0xffffff"), 8);
				destroy();

			}
			
			if (level.hasCollision(cx, cy+1)) {
				fx.explosion(centerX, centerY, 1, Col.inlineHex("0xffffff"), 8);
				destroy();
			}
		}
	}
}
