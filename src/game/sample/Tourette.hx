package sample;

import h2d.col.Point;
import h2d.filter.Bloom;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class Tourette extends Entity {
	public static var ALL:Array<Tourette> = [];

	public var activated:Bool = false;
	public var data:Entity_Tourette;

	public function new(ent:Entity_Tourette) {
		super(ent.cx, ent.cy);
		// activated = ent.f_activated;

		ALL.push(this);
		setPosCase(ent.cx, ent.cy);
		data = ent;
		activated = ent.f_activated;
		if (game.gameStats.has(ent.iid + "activated")) {
			activated = true;
		}
		spr.set(Assets.tourette);
		var g = new h2d.Graphics(spr);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.tourette);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.registerStateAnim(anims.idle, 10, () -> activated == true);
		// wid = 16;
		// hei = 16;

		spr.setPivotCoord(8, 8);
		sprScaleX = 1;
		sprScaleY = 1;
		life = 1;
	}

	public function doLazer() {
		if (spr == null)
			return;
		cd.setS('doLazer', 0.5);
		var d:Float = 0.0;
		var lazerAngle = spr.rotation; // angleTo(this, game.player);
		for (i in 2...30) {
			// needs angle int
			var tx = Std.int(i * Math.cos(lazerAngle));
			var ty = Std.int(i * Math.sin(lazerAngle));
			if (game.player.cx == cx + tx && game.player.cy == cy + ty) {
				d = distCase(cx + tx, cy + ty);
				if (!cd.has('dashing') && !game.player.cd.has('hitBump')) {
					game.player.cd.setS('hitBump', 2);
					game.player.hit(1, null);
				}

				break;
			}
			if (level.hasCollision(cx + tx, cy + ty)) {
				d = distCase(cx + tx, cy + ty);
				break;
			}
		}
		fx.lazer(centerX, centerY + 8, dir, d * Const.GRID, 0.04, 0xff0000, lazerAngle);
		if (!cd.has('lazerSound')) {
			S.lazer().play(false, App.ME.options.volume * 0.25).pitchRandomly(0.14);
			cd.setMs('lazerSound', 700);
		}
	}

	inline function angleTo(entity1:Entity, entity2:Entity):Float {
		return Math.atan2(entity2.attachY - entity1.attachY, entity2.attachX - entity1.attachX);
	}

	inline function distTo(entity1:Entity, entity2:Entity):Float {
		return Math.sqrt(entity2.attachX - entity1.attachX * entity2.attachX - entity1.attachX + entity2.attachY - entity1.attachY * entity2.attachY
			- entity1.attachY);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function preUpdate() {
		super.preUpdate();

		if (distCase(game.player) < 16 && sightCheck(game.player) && !cd.has('recentlySeen') && activated == true) {
			cd.setMs('recentlySeen', 50);
		}

		if (cd.has('recentlySeen') && !cd.has('shooting')) {
			cd.setMs('shooting', 1500);
			fx.surprise(game.player.cx * Const.GRID, game.player.cy * Const.GRID - 8, 0.25, 0xff0000);
			game.delayer.addS('attention', () -> {
				if (sightCheck(game.player))
					doLazer();
			}, 0.5);
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (activated == false) {
			if (game.gameStats.has(data.iid + "activated")) {
				activated = true;
			}
		}
		if (activated == true && !cd.has('doLazer'))
			spr.rotation = M.lerp(spr.rotation, angleTo(this, game.player), 0.05);
	}
	/*override function frameUpdate() {
		super.frameUpdate();	
	}*/
}
