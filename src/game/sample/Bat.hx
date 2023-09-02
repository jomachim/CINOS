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
class Bat extends Entity {
	public static var ALL:Array<Bat> = [];

	public var tw:Tweenie;
	public var activated:Bool = false;
	public var data:Entity_Bat;

	var group:h2d.filter.Group;

	public function new(ent:Entity_Bat) {
		super(ent.cx, ent.cy);
		activated = ent.f_activated;
		if (game.gameStats.has(ent.iid + "dead")) {
			activated = true;
		}
		ALL.push(this);
		setPosCase(ent.cx, ent.cy - 1);
		data = ent;

		// Placeholder display

		spr.set(Assets.bat);
		tw = new Tweenie(Const.FPS);
		var g = new h2d.Graphics(spr);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.bat);
		spr.anim.registerStateAnim(anims.iddle, 0);
		spr.anim.registerStateAnim(anims.flying, 10, () -> activated == true);
		// wid = 16;
		// hei = 16;
		sprScaleX = 0.5;
		sprScaleY = 0.5;
		life = 4;
		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0xFF0000, 1);
		// bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		group = new h2d.filter.Group([outline]);
		spr.filter = group;
	}

	public function outLined() {
		if (activated == true) {
			spr.filter = group;
		} else {
			spr.filter = null;
		}
	}

	public function collides(?p:Dynamic = null):Bool {
		if (game.player.centerX >= left
			&& game.player.centerX <= right
			&& game.player.centerY >= top
			&& game.player.centerY <= bottom) {
			// trace("collision");
			return true;
		} else {
			return false;
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

		if (activated == false && distCase(game.player) < 3) {
			activated = true;
			outLined();
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (activated == true) {
			if (cd.has('hit') && !cd.has('blink')) {
				blink();
				cd.setMs('blink', 200);
			}

			if (sightCheck(game.player) || cd.has('recentlySeen')) {
				if (!cd.has('attack')) {
					S.bat01().play(false,App.ME.options.volume).pitchRandomly(0.64);
					cd.setMs('recentlySeen', 500);
					var r = irnd(1, 3);
					cd.setS('attack', r);
					tw.createS(spr.x, game.player.attachX, TLinear, r * 0.5);
					tw.createS(spr.y, game.player.attachY, TBurnIn, r * 0.5);
				} else {
					v.dx += Math.cos(angleTo(this, game.player)) * 0.035;
					v.dy += Math.sin(angleTo(this, game.player)) * 0.035;
					if (collides() && !cd.has('hit') && !game.player.cd.has("dashing")) {
						game.player.hit(1, this);
						cd.setS('hit', 2);
					}
				}
			} else {
				v.dx += rnd(-0.1, 0.1, true);
				v.dy = -0.1;
				if (level.hasCollision(cx, cy - 1)) {
					v.dy = 0;
					activated = false;
					outLined();
				}
			}
		}
		if (xr > 0.9 && level.hasCollision(cx + 1, cy)) {
			xr = 0.9;
			vBump.clear();
		}
		if (xr < 0.1 && level.hasCollision(cx - 1, cy)) {
			xr = 0.1;
			vBump.clear();
		}
		if (yr > 0.9 && level.hasCollision(cx, cy + 1)) {
			yr = 0.9;
			vBump.clear();
		}
		if (yr < 0.1 && level.hasCollision(cx, cy - 1)) {
			yr = 0;
			vBump.clear();
		}
	}
	/*override function frameUpdate() {
		super.frameUpdate();	
	}*/
}
