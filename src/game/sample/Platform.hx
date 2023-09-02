package sample;

import GameStats;
import h2d.col.Point;
import h2d.filter.Bloom;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class Platform extends Entity {
	public static var ALL:Array<Platform> = [];

	public var dirY:Int = -1;
	// public var activated:Bool=true;
	public var data:Entity_Platform;
	public var startY:Int = 0;
	public var endY:Int = 0;
	public var speed:Float = 0;
	public var maxSpeed:Float = 0.1;
	public var activated:Bool = false;
	public var once:Bool;

	public function new(ent:Entity_Platform) {
		super(ent.cx, ent.cy);
		activated = ent.f_activated;
		if (game.gameStats.has(ent.iid + "activated")) {
			activated = true;
		}
		ALL.push(this);
		setPosCase(ent.cx, ent.cy);
		data = ent;
		once=ent.f_once;
		dirY = ent.f_dirY;
  		startY = M.floor(Math.min(ent.f_startPoint.cy, ent.f_endPoint.cy));
		endY = M.floor(Math.max(ent.f_startPoint.cy, ent.f_endPoint.cy));
		// Placeholder display

		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0xFFFFFF, 0.4);
		// var bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		var group = new h2d.filter.Group([outline]);
		spr.filter = group;
		spr.set(Assets.platform);

		var g = new h2d.Graphics(spr);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.platform);
		spr.anim.registerStateAnim(anims.idle, 0);
		if (game.gameStats.has('savePos_' + data.iid)) {
			cx = game.gameStats.get('savePos_' + data.iid).data.posX;
			cy = game.gameStats.get('savePos_' + data.iid).data.posY;
			dir= game.gameStats.get('savePos_' + data.iid).data.dirY;
			setPosCase(cx, cy);
		} else {
			setPosCase(ent.cx, ent.cy);
		}
	}

	override function dispose() {
		super.dispose();
	}

	override function preUpdate() {
		super.preUpdate();
		// debug(dirY<0?"Up":"Down");
		if (activated == true) {
			if(once==true){cd.setS('shouldStop', 10);}
			speed < maxSpeed ? speed += 0.1 : speed = maxSpeed;
			// speed=maxSpeed;
			v.dy = dirY * speed;
			if (dirY > 0 && (cy >= endY)) { // en bas&& yr>0.5
				yr = 1;
				dirY *= -1;
				v.dy = 0;
				if (cd.has('shouldStop'))
					activated = false;
				speed = 0;
			} else if (dirY < 0 && (cy == startY && yr < 0.8)) { // en haut
				yr = 1;
				cy = startY;
				dirY *= -1;
				v.dy = 0;
				if (cd.has('shouldStop'))
					activated = false;
				speed = 0;
			}
			if (cy <= Std.int(startY))
				cy = Std.int(startY);
			if (cy > endY)
				cy = endY;
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if(activated && !cd.has("saving")){
			cd.setS('saving',1);
			game.gameStats.unregisterState('savePos_' + data.iid);
		if (!game.gameStats.has('savePos_' + data.iid)) {
			var pos = {
				posX: cx,
				posY: cy - 1,
				dirY: dirY
			}
			var achPos = new Achievement("savePos_" + data.iid, "savePos", () -> true, () -> {
				// trace("saved position");
			}, pos);
			game.gameStats.registerState(achPos);
			achPos=null;
			pos=null;
		}
		}
		
	}

	override function frameUpdate() {
		super.frameUpdate();
		if (distCase(game.player) < 2) {
			if (game.player.v.dy < 0 && game.player.top < bottom && game.player.bottom > bottom && game.player.left < right && game.player.right > left
				&& !cd.has('recentlyOnElevator')) {
				game.player.v.dy *= -1;
				return;
			}
			if (game.player.centerX >= left - 16 && game.player.centerX <= right + 16 && game.player.v.dy >= 0) { // && (!cd.has('recentlyOnElevator') )
				// trace('okX');
				// if(game.player.attachY>=top && game.player.attachY<=bottom){//distCase(game.player.cx,game.player.cy,game.player.xr,game.player.yr)<=1
				if ((game.player.attachY >= attachY - 16 && game.player.attachY < attachY)
					&& (!game.player.cd.has("startJumping") || !game.player.cd.has("slamDown"))) {
					game.player.cd.setMs("recentlyOnElevator", 200);

					if (game.player.parented != this) {
						game.player.parented = this;
					}
					/*game.player.yr = yr;
						game.player.v.dy = speed * dirY > 0 ? speed * dirY : 0;

						game.player.preUpdate();
						game.player.setPosPixel(game.player.attachX, top);
						//game.player.fixedUpdate();
						game.player.postUpdate(); */

					game.player.cd.setMs('recentlyOnGround', 200);
					// game.player.cd.setMs("recentMove",50);
				}
			} else {
				game.player.parented = null;
				// game.camera.stopTracking();
			}
		}
	}
	/**/
}
