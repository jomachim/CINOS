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
class Rat extends Entity {
	public static var ALL:Array<Rat> = [];

	public var tw:Tweenie;
	public var activated:Bool = false;
	public var data:Entity_Rat;

	var group:h2d.filter.Group;
	var onGround(get, never):Bool;
	var walkSpeed:Float;

	inline function get_onGround()
		return !destroyed && ((v.dy == 0 && yr == 1 && level.hasCollision(cx, cy + 1)));

	public function new(ent:Entity_Rat) {
		super(ent.cx, ent.cy);
		// activated = ent.f_activated;
		if (game.gameStats.has(ent.iid + "dead")) {
			activated = true;
		}
		ALL.push(this);
		setPosCase(ent.cx, ent.cy);
		data = ent;
		walkSpeed = 0;
		// Placeholder display

		spr.set(Assets.rat);
		tw = new Tweenie(Const.FPS);
		var g = new h2d.Graphics(spr);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.rat);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.registerStateAnim(anims.run, 10, () -> activated == true);
		// wid = 16;
		// hei = 16;
		sprScaleX = 1;
		sprScaleY = 1;
		life = 1;
		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0xFF0000, 1);
		// bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		group = new h2d.filter.Group([outline]);
		spr.filter = group;
		outLined();
	}

	public function outLined() {
		if (activated == true) {
			spr.filter = group;
		} else {
			spr.filter = null;
		}
		spr.filter = null;
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

	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();
		// cd.setMs('recentlyOnSlope', 0);
		if (level.hasCollision(cx + dir, cy) && !level.hasCollision(cx + dir, cy - 1) && yr < 0.5) {
			yr = 1;
			cy--;
		}
		// Right collision
		if (xr > 0.8 && level.hasCollision(cx + 1, cy)) {
			if (!level.isLUSlope(cx, cy) && !level.isLUSlope2(cx, cy)) {
				xr = 0.8;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx + 1, cy - 1)) {
				xr = 0.8;
				/*if (!cd.has('recentlyOnGround') && ca.isDown(MoveRight) && ca.isDown(Jump) && !cd.has('wallJump')) {
					cd.setMs('wallJump', 250);
					fx.wallDust(attachX, attachY, dir, 0xffffff);
					v.dx = -0.62;
					v.dy = -0.543;
					cd.setS('startJumping', 0.33+jumpTime*0.001);
				}*/
			}
		}

		// Left collision
		if (xr < 0.2 && level.hasCollision(cx - 1, cy)) {
			if (!level.isRUSlope(cx, cy) && !level.isRUSlope2(cx, cy)) {
				xr = 0.2;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx - 1, cy - 1)) {
				xr = 0.2;
				/*if (!cd.has('recentlyOnGround') && ca.isDown(MoveLeft) && ca.isDown(Jump) && !cd.has('wallJump')) {
					cd.setMs('wallJump', 250);
					fx.wallDust(attachX, attachY, dir, 0xffffff);
					v.dx = 0.62;
					v.dy = -0.543;
					cd.setS('startJumping', 0.33+jumpTime*0.001);
				}*/
			}
		}

		// Slope LU
		if (yr > 1 - xr && level.isLUSlope(cx, cy)) {
			yr = 1 - xr;
			spr.rotation=-(45/180*M.PI);
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (xr < yr && level.isRUSlope(cx, cy)) {
			yr = xr;
			spr.rotation=(45/180*M.PI);
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// slope LU2
		if (yr > 1 - xr / 2 && level.isLUSlope2(cx, cy)) {
			yr = 1 - xr / 2;
			spr.rotation=-(22.5/180*M.PI);
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}
		// slope RU2
		if (yr >= xr / 2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx + 1, cy)) {
			yr = xr / 2;
			spr.rotation=(22.5/180*M.PI);
			cd.setS("recentlyOnGround", 0.1);
		} else if (yr >= 0.5 + xr / 2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx - 1, cy)) {
			yr = 0.5 + xr / 2;
			spr.rotation=(22.5/180*M.PI);
			cd.setS("recentlyOnGround", 0.1);
		}
	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();
		if (cd.has('recentlyOnGround') && level.hasCollision(cx + dir, cy) && !level.hasCollision(cx + dir, cy - 1) && yr <= 0.3) {
			yr = 0;
		}
		// Slope LU
		if (yr >= 1 - xr && level.isLUSlope(cx, cy)) {
			/*v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185 * 0.5;
			vBump.dy += 0.00185 * 0.25;*/
			yr = 1 - xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope LU2
		if (yr >= 1 - xr / 2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx + 1, cy)) {
			/*v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;*/
			yr = 1 - xr / 2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		} else if (yr >= 0.5 - xr / 2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx - 1, cy)) {
			/*v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;*/
			yr = 0.5 - xr / 2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (yr >= xr && level.isRUSlope(cx, cy)) {
			/*v.dx += v.dy * 0.015;
			vBump.dx += 0.00185 * 0.5;
			vBump.dy += 0.00185 * 0.25;*/
			yr = xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU2
		if (yr >= xr / 2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx + 1, cy)) {
			/*v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;*/
			yr = xr / 2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		} else if (yr >= 0.5 + xr / 2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx - 1, cy)) {
			/*v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;*/
			yr = 0.5 + xr / 2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope LD
		if (yr <= xr && level.isLDSlope(cx, cy - 1)) {
			v.dy = M.fabs(v.dx) * 0.5;
			// jumpSpeed -= M.fabs(v.dx);
			yr = xr;
			onPosManuallyChangedY();
		}
		// Slope RD
		if (yr <= 1 - xr && level.isRDSlope(cx, cy - 1)) {
			v.dy = M.fabs(v.dx) * 0.5;
			// jumpSpeed -= M.fabs(v.dx);
			yr = 1 - xr;
			onPosManuallyChangedY();
		}

		// Land on ground
		if (yr > 1 && level.hasCollision(cx, cy + 1)) {
			setSquashY(0.5);
			v.dy = 0;
			vBump.dy = 0;
			yr = 1;
			spr.rotation=(0);
			onPosManuallyChangedY();
			fx.fallDust(attachX, attachY, dirToAng(), dir);
		}

		// Ceiling collision
		if (yr < 0.9 && level.hasCollision(cx, cy - 1)) {
			yr = 0.9;
			v.dy = 0;
		}

		// you're not supposed to be there
		if (level.hasCollision(cx, cy)) {
			yr = 1;
			cy--;
			cd.setS("recentlyOnGround", 0.1);
		}
	}

	override function preUpdate() {
		super.preUpdate();
		walkSpeed=0;
		if (activated == false && distCase(game.player) < 8) {
			activated = true;
			outLined();
		}
		if (activated == true) {
			if (cd.has('hit') && !cd.has('blink')) {
				blink();
				cd.setMs('blink', 200);
			}

			if (sightCheck(game.player) || cd.has('recentlySeen')) {
				if (!cd.has('attack')) {
					cd.setMs('recentlySeen', 500);
					var r = irnd(1, 3);
					cd.setS('attack', r);
					S.rat01().play(false,App.ME.options.volume).pitchRandomly(0.64);
				} else {
					walkSpeed += (game.player.attachX < attachX ? -1 : 1) * 0.0485;
					if(rnd(0,1000)<10) v.dy=-0.51;
					if (collides() && !cd.has('hit') && !game.player.cd.has('dashing')) {
						game.player.hit(1, this);
						cd.setS('hit', 2);
					}
				}
			} else {
				// v.dy = 0;
				activated = false;
				// outLined();
			}
		}
		
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		// Gravity
		if (!onGround)
			v.dy += 0.085;

		// Apply requested walk movement
		if (walkSpeed != 0)
			v.dx += walkSpeed * 0.45; // some arbitrary speed
		sprScaleX = v.dx < 0 ? 1 : -1;
	}
	/*override function frameUpdate() {
		super.frameUpdate();	
	}*/
}
