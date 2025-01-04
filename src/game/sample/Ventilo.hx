package sample;

import h2d.filter.Bloom;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class Ventilo extends Entity {
	public static var ALL:Array<Ventilo> = [];

	public var activated:Bool = false;
	public var data:Entity_Ventilo;
	public var groupb:h2d.filter.Group;
	public var speed = 1.0;

	var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.ventilo);

	public function new(vent:Entity_Ventilo) {
		super(vent.cx, vent.cy + 2);

		// colors=[for (i in 0...vent.f_Color_int.length) vent.f_Color_int[i]];
		// color=colors[1];
		// trace(colors);
		// Placeholder display
		data = vent;
		data.iid = vent.iid;
		activated = vent.f_activated;

		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0x330000, 0.4);

		groupb = new h2d.filter.Group([outline]);
		spr.filter = groupb;
		spr.set(Assets.ventilo);
		// spr.setCenterRatio(0,0);
		sprScaleY = sprScaleX = 0.5;
		xr = 0.6;
		yr = 0.5;
		// spr.scale(0.5);

		Game.ME.scroller.under(spr);
		speed = rnd(0, 8);
		spr.anim.registerStateAnim(anims.idle, 0, speed, () -> activated == true);
		spr.anim.registerStateAnim(anims.off, 2, speed, () -> activated == false);

		// spr.anim.registerStateAnim(anims.closed, 2,()->cd.getS("recentlyTeleported")>0);
		// spr.anim.registerStateAnim(anims.closed, 0,2,()->!looted);
		// spr.anim.registerStateAnim(anims.opened, 10,2,()->looted);

		var g = new h2d.Graphics(spr);
		sample.Ventilo.ALL.push(this);
	}

	override function dispose() {
		super.dispose();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if (!cd.has("variSpeed")) {
			cd.setS("variSpeed", rnd(0, 2));
			speed = M.fabs(Game.ME.globalWind.x) * 10;
			spr.anim.setGlobalSpeed(speed);
		} else {
			speed *= 0.98765;
			spr.anim.setGlobalSpeed(speed);
		}
	}
}
