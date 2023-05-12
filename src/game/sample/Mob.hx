package sample;

import GameStats.Achievement;
import dn.legacy.Controller;
import hxd.snd.openal.AudioTypes.BufferHandle;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class Mob extends Entity {
	public static var ALL:Array<Mob> = [];

	var walkSpeed = 0.;

	public var data:Entity_Mob;

	// This is TRUE if the player is not falling
	var onGround(get, never):Bool;

	inline function get_onGround()
		return !destroyed && v.dy == 0 && yr == 1 && level.hasCollision(cx, cy + 1);

	var onSlope(get, never):Bool;

	inline function get_onSlope():Bool
		return !destroyed && v.dy == 0 && (level.isLUSlope(cx, cy) || level.isRUSlope(cx, cy));

	public function new(ent:Entity_Mob) {
		super(5, 5);
		data = ent;
		initLife(3);
		if (game.gameStats.has('dead_' + data.iid)) {
			destroy();
			initLife(0);
		}
		if (game.gameStats.has('savePos_' + data.iid)) {
			cx = game.gameStats.get('savePos_' + data.iid).data.posX;
			cy = game.gameStats.get('savePos_' + data.iid).data.posY;
			setPosCase(cx, cy);
		} else {
			setPosCase(ent.cx, ent.cy);
		}

		// Start point using level entity "mobStart"

		// Misc inits
		v.setFricts(0.82, 0.86);

		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */

		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.hero);
		spr.set(Assets.hero);
		spr.colorize(0xD446FF43, 0.4);
		outline.color = 0x0DFF00;
		// spr.setPivotCoord(0.5,1);
		spr.anim.registerStateAnim(anims.jump, 6, () -> !onGround);
		spr.anim.registerStateAnim(anims.fall, 7, () -> !onGround && v.dy > 0);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.registerStateAnim(anims.run, 3, () -> cd.has("recentMove"));
		spr.anim.registerStateAnim(anims.roll, 4, () -> cd.has('recentlyOnGround') && !cd.has("recentMove") && v.dy > 0);
		spr.anim.registerStateAnim(anims.roll, 5, () -> cd.has('dashing'));

		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		// don't forget to dispose controller accesses
	}

	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();
		// cd.setMs('recentlyOnSlope', 0);
		if(level.hasCollision(cx+dir,cy) && !level.hasCollision(cx+dir,cy-1) && yr<0.5){
			yr=1;
			cy--;
		}
		// Right collision
		if (xr > 0.8 && level.hasCollision(cx + 1, cy)) {
			if (!level.isLUSlope(cx, cy) && !level.isLUSlope2(cx,cy)) {
				xr = 0.8;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx + 1, cy-1)) {
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
			if (!level.isRUSlope(cx, cy) && !level.isRUSlope2(cx,cy)) {
				xr = 0.2;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx - 1, cy-1)) {
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
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (xr < yr && level.isRUSlope(cx, cy)) {
			yr = xr;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// slope LU2
		if (yr > 1 - xr/2 && level.isLUSlope2(cx, cy)) {
			yr = 1 - xr/2;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}
		// slope RU2
		if (yr >= xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx+1, cy)) {
			yr = xr/2;
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5+xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx-1, cy)){
			yr = 0.5+xr/2;
			cd.setS("recentlyOnGround", 0.1);
		}

	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();
		if(cd.has('recentlyOnGround') && level.hasCollision(cx+dir,cy) && !level.hasCollision(cx+dir,cy-1) && yr<=0.3){
			yr=0;
		}
		// Slope LU
		if (yr >= 1 - xr && level.isLUSlope(cx, cy)) {
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185*0.5;
			vBump.dy += 0.00185*0.25;
			yr = 1 - xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope LU2
		if (yr >= 1 - xr/2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx+1, cy)) {
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;
			yr = 1 - xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5 - xr/2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx-1, cy)){
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;
			yr = 0.5 - xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (yr >= xr && level.isRUSlope(cx, cy)) {
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185*0.5;
			vBump.dy += 0.00185*0.25;
			yr = xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU2
		if (yr >= xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx+1, cy)) {
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;
			yr = xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5+xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx-1, cy)){
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;
			yr = 0.5+xr/2;
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

	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		
	}

	override function onDie() {
		if (!game.gameStats.has('dead_' + data.iid)) {
			var achdead = new Achievement("dead_" + data.iid, "dead", () -> true, () -> {
				//trace("dead Mob is dead");
			}, true);
			game.gameStats.registerState(achdead);
			achdead=null;
		}
		super.onDie();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (!camera.isOnScreen(centerX, centerY, 32)){
			return;
		}
		// was in pre...
		walkSpeed = 0;
		if (onGround)
			cd.setS("recentlyOnGround", 0.1); // allows "just-in-time" jumps

		// Jump
		if (cd.has("recentlyOnGround") && irnd(0, 1000) < 5) {
			v.dy = -0.55;
			setSquashX(0.8);
			cd.unset("recentlyOnGround");
			fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
		}

		// Dash
		if (irnd(0, 1000) < 5 && !cd.has('dashing')) {
			cd.setMs('dashing', 500);
			v.dx = dir * 0.85;
		}

		// fire
		if (irnd(0, 1000) < 20 && !cd.has('firing') && distCase(game.player) < 32) {
			cd.setMs('firing', 150);
			fx.surprise(centerX + dir * wid * 0.8, centerY, 0.25, outline.color);
			Game.ME.delayer.addS('surpriseMF', () -> {
				if (isAlive())
					new sample.Bullet(cx, cy - 1, dir, this);
			}, 0.15);
		}
		// Walk
		if (irnd(0, 1000) < 250) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = irnd(-1, 1, true); // -1 to 1

			cd.setMs('recentMove', 50);
		}



			// fixed update
		// Gravity
		if (!onGround)
			v.dy += 0.085;

		// Apply requested walk movement
		if (walkSpeed != 0) {
			v.dx += walkSpeed * 0.045; // some arbitrary speed
			dir = v.dx >= 0 ? 1 : -1;
		}
		if(onGround && !cd.has("saving")){
			cd.setS('saving',1);
			game.gameStats.unregisterState('savePos_' + data.iid);
		if (!game.gameStats.has('savePos_' + data.iid)) {
			var pos = {
				posX: cx,
				posY: cy - 1
			}
			var achPos = new Achievement("savePos_" + data.iid, "savePos", () -> onGround, () -> {
				// trace("saved position");
			}, pos);
			game.gameStats.registerState(achPos);
			achPos=null;
			pos=null;
		}
		}
		
	}
}
