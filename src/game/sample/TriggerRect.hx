package sample;

import GameStats;
import dn.heaps.HParticle;

class TriggerRect extends Entity {
	public var data:Entity_TriggerRect;
	public var actionScript:String;
	public var refs:Array<Dynamic>;
	public var once:Bool;

	var entered:Bool;

	public function new(trigger:Entity_TriggerRect) {
		super(5, 5);
		entered = false;
		data = trigger;
		once = trigger.f_once;
		actionScript = trigger.f_ActionScript;
		refs = trigger.f_Entity_ref;
		setPosCase(trigger.cx, trigger.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set('empty'); // D.tiles.fxLightCircle
		wid = data.width;
		hei = data.height;
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
	}

	override function dispose() {
		super.dispose();
		// don't forget to dispose controller accesses
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (cd.has('notnow')) {
			return;
		}
		if (game.player.right >= left && game.player.left <= right && game.player.bottom >= top && game.player.top <= bottom && entered==false) {
			entered = true;
			if (data.f_ActionScript != null && !game.gameStats.has('actionscript_' + data.iid)) {
				// script=game.hsParser.parseString();
				var scripter = tools.script.Script;

				App.ME.delayer.addS('triggeredScript', () -> {
					scripter.run(data.f_ActionScript);
				}, 0);
				if (once == true) {
					var cineDone = new Achievement('actionscript_' + data.iid, "done", () -> true, () -> {
						//trace("TRIGGERED ACHIEVEMENT : actionscript done");
					}, true);
					game.gameStats.registerState(cineDone);
					cineDone = null;
					destroy();
				} else {
					cd.setMs('notnow', 66);
				}
			}
			for (i in 0...refs.length) {
				var ref=refs[i];
				for (elev in sample.Platform.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
					}
				}
				// water
				for (elev in sample.WaterPond.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellovator');
						//elev.raisewater=true;Bool !
						if (elev.activated == false) {
							elev.activated = true;
						}
					}
				}
				// DOORS
				var here=false;
				for (elev in sample.Door.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
						here=true;
					}
				}
				if(here==false && !game.gameStats.has(ref.entityIid + "activated")){
					var ach = new Achievement(ref.entityIid + "activated", "done", () -> true, () -> {
							//trace("TRIGGERED DOOR ELSEWHERE : "+ref.entityIid);
						}, true);
						game.gameStats.registerState(ach);
						ach = null;
				}

				// MINUTER
				for (elev in sample.Minuter.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;
						}
					}
				}
			}
		} else {
			if (entered == true) {
				//game.camera.zoomTo(game.baseZoom);
			}
			entered = false;
		}
	}
	/*override function postUpdate() {
		super.postUpdate();

	}*/
}
