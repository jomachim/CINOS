package sample;

class Minuter extends Entity {
	public static var ALL:Array<Minuter> = [];

	public var targets:Array<Dynamic>;
	public var delayS:Float = 0;
	public var data:Entity_Minuter;
	public var dl:dn.Delayer;
	public var iid:String;
	public var activated:Bool;

	var done:Bool;

	var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.led);

	public function new(repeater:Entity_Minuter) {
		super(repeater.cx, repeater.cy);
		iid = repeater.iid;
		data = repeater;
		activated = repeater.f_activated;
		delayS = repeater.f_delayS; // in Seconds
		targets = repeater.f_Entity_ref;
		done = false;
		// dl = new dn.Delayer(Const.FIXED_UPDATE_FPS);
		if (game.gameStats.has(repeater.iid + "activated")) {
			activated = true;
		}
		spr.set(Assets.led);
		spr.anim.registerStateAnim(anims.blue, 0, () -> activated == false);
		spr.anim.registerStateAnim(anims.yellow, 2, () -> activated == true);

		var g = new h2d.Graphics(spr);
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if (activated == true && done == false) {
			// trace("Activation du répéteur");
			done = false;

			for (tar in targets) {
				for (i in 0...sample.Shower.ALL.length) {
					var en = sample.Shower.ALL[i];
					if (en.data.iid == tar.entityIid && iid != en.data.iid) {
						game.delayer.addS('waiting_' + en.data.iid, () -> {
							// trace("delayed");
							en.activated = !en.activated;
							if (en.activated == true) {
								var ach = new GameStats.Achievement(en.data.iid + "activated", "activated", () -> true, () -> {}, true);
								game.gameStats.registerState(ach);
								ach = null;
							}
							
							//trace("shower " + en.data.iid + " is " + (en.activated ? "on" : "off"));
							activated = false;
						}, delayS);
						// dl.runImmediately('waiting_'+en.iid);
					}
				}
				for (i in 0...sample.Door.ALL.length) {
					var en = sample.Door.ALL[i];
					if (en.data.iid == tar.entityIid && iid != en.data.iid) {
						game.delayer.addS('waiting_' + en.data.iid, () -> {
							// trace("delayed");
							en.activated = !en.activated;
							en.locked = false;
							activated = false;
						}, delayS);
						// dl.runImmediately('waiting_'+en.iid);
					}
				}
				for (i in 0...sample.Light.ALL.length) {
					var en = sample.Light.ALL[i];
					if (en.data.iid == tar.entityIid) {
						game.delayer.addS('waiting_' + en.data.iid, () -> {
							if (delayS > 100) {
								trace('delay is very long WARNING !!!');
							}
							// trace("delayed");
							en.activated = !en.activated;
							activated = false;
						}, delayS);
						// dl.runImmediately('waiting_'+en.iid);
					}
				}
				for (i in 0...sample.Minuter.ALL.length) {
					var en = sample.Minuter.ALL[i];
					if (en.data.iid == tar.entityIid && iid != en.data.iid) {
						game.delayer.addS('waiting_' + en.data.iid, () -> {
							// trace("delayed");
							en.activated = !en.activated;
							activated = false;
						}, delayS);
						// dl.runImmediately('waiting_'+en.iid);
					}
				}
			}
		}
	}
}
