package sample;

import dn.Delayer;
import hxd.snd.openal.AudioTypes.BufferHandle;
import sample.Mob;
import sample.Bat;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class Bullet extends Entity {
	public static var ALL:FixedArray<Bullet> = new FixedArray("bulletPool", 256);

	var walkSpeedX = 0.;
	var walkSpeedY = 0.;
	var speed = 0.58;
	var rotation = true;

	public var emiter:Entity;

	var mobs:Array<Mob> = [];
	var bats:Array<Bat> = [];
	var rats:Array<Rat> = [];
	var bosses:Array<Boss> = [];

	// public var collides:Bool = false;
	public function collides(?ent:Entity) {
		if (ent != null) {
			return centerX >= ent.left && centerX <= ent.right && centerY >= ent.top && centerY <= ent.bottom;
		}
		return game.player.centerX >= left
			&& game.player.centerX <= right
			&& game.player.centerY >= top
			&& game.player.centerY <= bottom;
	}

	public function new(_cx, _cy, dr, entity:Entity) {
		super(_cx, _cy);
		setPosCase(_cx, _cy + 1);
		if (entity == null)
			return;
		xr = 0.5;
		yr = 0.8;
		dir = dr;
		emiter = entity;
		mobs = [];
		for (i in 0...sample.Mob.ALL.length) {
			mobs.push(sample.Mob.ALL[i]);
		}
		bosses = [];
		for (i in 0...sample.Boss.ALL.length) {
			bosses.push(sample.Boss.ALL[i]);
		}
		bats=[];
		for(i in 0...sample.Bat.ALL.length){
			bats.push(sample.Bat.ALL[i]);
		}
		rats=[];
		for(i in 0...sample.Rat.ALL.length){
			rats.push(sample.Rat.ALL[i]);
		}
		setPosPixel(entity.attachX, entity.attachY - 8);

		// Misc inits
		v.setFricts(1, 0.9);
		walkSpeedX = M.fmax(0.4, 0.4+M.fabs(entity.dxTotal)*1.5);
		walkSpeedY = 0.;

		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		if (irnd(0, 100) < 50) {
			spr.set(D.tiles.shuriken);
		} else if (irnd(0, 100) < 50) {
			spr.set(D.tiles.onigiri);
		} else if (irnd(0, 100) < 50) {
			spr.set(D.tiles.boomrang);
		} else {
			spr.set(D.tiles.fxCatHead);
		}

		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
		sprScaleX = sprScaleY = 1.0;
		outline = null; // .color = 0x00FFFFFF;
		ALL.push(this);
	}

	override function dispose() {
		bosses = null;
		mobs = null;
		ALL.remove(this);
		super.dispose();

		// don't forget to dispose controller accesses
	}

	public function fade(s:Float = 0) {
		if (game.tw == null || destroyed)
			return;
		if (!cd.has('fading')) {
			cd.setMs('fading', 100);
			v.dx = v.dy = walkSpeedX = walkSpeedY = 0;
			fx.explosion(attachX, attachY, dir, 0xffffff, irnd(1, 2));
			destroy();
			/*game.tw.createS(spr.alpha, 0, s).end(function() {


			});*/
		}
	}

	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		if (xr >= 1 && level.hasCollision(cx + 1, cy)) {
			if (!level.isLUSlope(cx, cy)) {
				xr = 1;
				fade();
			}
			if (level.hasCollision(cx + 1, cy - 1)) {
				xr = 1;
				fade();
			}
		}

		// Left collision
		if (xr <= 0 && level.hasCollision(cx - 1, cy)) {
			if (!level.isRUSlope(cx, cy)) {
				xr = 0;
				fade();
			}
			if (level.hasCollision(cx - 1, cy - 1)) {
				xr = 0;
				fade();
			}
		}

		// Slope LU
		if (yr > 1 - xr && level.isLUSlope(cx, cy)) {
			yr = 1 - xr;
			fade();
		}

		// Slope RU
		if (xr < yr && level.isRUSlope(cx, cy)) {
			yr = xr;
			fade();
		}
	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Slope LU
		if (yr > 1 - xr && level.isLUSlope(cx, cy)) {
			yr = 1 - xr;
			fade();
		}
		// Slope RU
		if (yr > xr && level.isRUSlope(cx, cy)) {
			yr = xr;
			fade();
		}

		// Slope LD
		if (yr < xr && level.isLDSlope(cx, cy - 1)) {
			yr = xr;
			fade();
		}
		// Slope RD
		if (yr < 1 - xr && level.isRDSlope(cx, cy - 1)) {
			yr = 1 - xr;
			fade();
		}

		// Land on ground
		if (yr > 1 && level.hasCollision(cx, cy + 1)) {
			yr = 1;
			fade();
		}

		// Ceiling collision
		if (yr < 0.9 && level.hasCollision(cx, cy - 1)) {
			yr = 0.9;
			fade();
		}

		// you're not supposed to be there
		if (level.hasCollision(cx, cy)) {
			yr = 1;
			cy--;
		}
	}

	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();
		if (App.ME.options.shaders == true) {
			fx.heatSource(attachX, attachY);
			fx.heat(attachX, attachY);
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (!game.player.isAlive())
			return;
		v.dx = dir * walkSpeedX;
		v.dy = dir * walkSpeedY;
		
		if (rotation == true)
			spr.rotate(v.dx * 1.5);
		for(bat in bats){
			if ((distPx(bat) < 16 || collides(bat)) && emiter != bat && emiter.is(SamplePlayer)) {
				// Game.ME.delayer.addF(() -> {hxd.Timer.skip();}, 0);
				// mob.blink(0xffffff);
				bat.hit(1, emiter);
				S.bat01().play(false,App.ME.options.volume).pitchRandomly(0.64);
				fade();
			}
		}
		for(rat in rats){
			if ((distPx(rat) < 16 || collides(rat)) && emiter != rat && emiter.is(SamplePlayer)) {
				// Game.ME.delayer.addF(() -> {hxd.Timer.skip();}, 0);
				// mob.blink(0xffffff);
				S.rat01().play(false,App.ME.options.volume).pitchRandomly(0.64);
				rat.hit(1, emiter);
				fade();
			}
		}
		for (mob in mobs) {
			if ((distPx(mob) < 16 || collides(mob)) && emiter != mob && emiter.is(SamplePlayer)) {
				// Game.ME.delayer.addF(() -> {hxd.Timer.skip();}, 0);
				// mob.blink(0xffffff);
				mob.hit(1, emiter);
				fade();
			}
		}
		for (bos in bosses) {
			if ((distPx(bos) < 16 || collides(bos)) && emiter != bos && emiter.is(sample.SamplePlayer)) {
				// Game.ME.delayer.addF(() -> {hxd.Timer.skip();}, 0);
				// bos.blink(0xffffff);
				S.die02(App.ME.options.volume);
				bos.hit(1, emiter);
				fade();
			}
		}
		if ((emiter.is(sample.Mob) || emiter.is(sample.Boss)) && collides()) {
			if (!game.player.cd.has('hitBump') && !game.player.cd.has('dashing')) {
				game.player.cd.setS('hitBump', 1.2);
				S.ouch04(App.ME.options.volume);
				fx.flashBangEaseInS(Red, 0.4, 1);
				game.player.v.dx += v.dx;
				game.player.v.dy -= 0.3;
				fade();
				if (game.player.life == 1) {
					S.die02(App.ME.options.volume);
				}
				game.player.hit(1, emiter);
			}
		}
		if (emiter.is(sample.SamplePlayer) && game.player.cd.has('heroMustDie') && collides()) {
			if (!game.player.cd.has('hitBump')) {
				game.player.cd.setS('hitBump', 1.2);
				S.ouch04(App.ME.options.volume);
				fx.flashBangEaseInS(Red, 0.4, 1);
				game.player.v.dx += v.dx;
				game.player.v.dy -= 0.3;
				fade();
				if (game.player.life == 1) {
					S.die02(App.ME.options.volume);
				}
				game.player.hit(1, emiter);
			}
		}
	}

	override function postUpdate() {
		super.postUpdate();
		if (spr.alpha == 0)
			dispose();
	}
}
