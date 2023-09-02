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
class Sensor extends Entity {
	public static var ALL:Array<Sensor> = [];

	public var activated:Bool = false;
	public var data:Entity_Sensor;
	public var refs:Array<Dynamic>;
	var done:Bool;

	public function new(ent:Entity_Sensor) {
		super(ent.cx, ent.cy);
		// activated = ent.f_activated;
		if (game.gameStats.has(ent.iid+"activated")) {
			activated = true;
		}
		ALL.push(this);
		setPosCase(ent.cx, ent.cy);
		data = ent;
		refs = ent.f_Entity_refs;
		done=false;
		// Placeholder display

		spr.set(Assets.sensor);
		var g = new h2d.Graphics(spr);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.sensor);
		spr.anim.registerStateAnim(anims.idle, 0, () -> activated == false);
		spr.anim.registerStateAnim(anims.active, 10, () -> activated == true);
		// wid = 16;
		// hei = 16;
		sprScaleX = 1;
		sprScaleY = 1;
		life = 1;
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

		if (distCase(game.player) < 6 && sightCheck(game.player) && done==false) {
			cd.setMs('recentlySeen', 2000);
			activated = true;
		} else if (!cd.has('recentlySeen')) {
			activated = false;
			done=false;
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (activated == true && done==false) {
			done=true;
			for (i in 0...refs.length) {
				var ref = refs[i];

				// PLATFORMES
				for (elev in sample.Platform.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
						// trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
					}
				}

				// DOORS
				var here = false;
				for (elev in sample.Door.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
						// trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
						here = true;
					}
				}
				if (here == false && !game.gameStats.has(ref.entityIid + "activated")) {
					var ach = new Achievement(ref.entityIid + "activated", "done", () -> true, () -> {
						//trace("TRIGGERED DOOR ELSEWHERE : " + ref.entityIid);
					}, true);
					game.gameStats.registerState(ach);
					ach = null;
				}

				// MINUTER
				var here = false;
				for (elev in sample.Minuter.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
						// trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
							
						}
						here = true;
					}
				}
				if (here == false && !game.gameStats.has(ref.entityIid + "activated")) {
					var ach = new Achievement(ref.entityIid + "activated", "done", () -> true, () -> {
						//trace("TRIGGERED MINUTER ELSEWHERE : " + ref.entityIid);
					}, true);
					game.gameStats.registerState(ach);
					ach = null;
				}

				// LIGHT
				var here = false;
				for (elev in sample.Light.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
						// trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
						here = true;
					}
				}
				if (here == false && !game.gameStats.has(ref.entityIid + "activated")) {
					var ach = new Achievement(ref.entityIid + "activated", "done", () -> true, () -> {
						//trace("TRIGGERED LIGHT ELSEWHERE : " + ref.entityIid);
					}, true);
					game.gameStats.registerState(ach);
					ach = null;
				}
			}
		}
	}
	/*override function frameUpdate() {
		super.frameUpdate();	
	}*/
}
