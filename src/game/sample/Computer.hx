package sample;

import GameStats;
import GameStats.*;

class Computer extends Entity {
	public static var ALL:Array<Computer> = [];

	var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.computer);
	var ready:Bool=false;

	public var data:Entity_Computer;

	inline function get_ready()
		return spr.anim.getAnimId() == anims.idle;

	public function new(ent:Entity_Computer) {
		super(ent.cx, ent.cy);
		setPosCase(ent.cx, ent.cy);
		// Placeholder display
		data = ent;
		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0x330000, 0.4);
		var bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		var group = new h2d.filter.Group([outline, bloom]);
		spr.filter = group;
		spr.set(Assets.computer);

		// spr.anim.registerStateAnim(anims.closed, 2,()->cd.getS("recentlyTeleported")>0);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.registerStateAnim(anims.idle2, 1, () -> distCase(game.player) <= 2);

		var g = new h2d.Graphics(spr);
	}

	override function dispose() {
		super.dispose();
	}

	override function preUpdate() {
		super.preUpdate();
		if(isOnScreenBounds()){
			ready=true;
		}else{
			ready=false;
		}
	}

	override function fixedUpdate() {
		if(!ready) return;
		super.fixedUpdate();
		// debug(data.f_Entity_ref.entityIid);
		if (distCase(game.player) <= 2 && !cd.has("canard")) {
			fx.markerText(cx, cy - 2, "Press ACTION", 5.0);
			cd.setS("canard", 5.0);
		};

		if (distCase(game.player) <= 2 && !cd.has("recentlyActivated") && (game.ca.isDown(Action) || game.ca.isDown(Lock))) {
			var len = data.f_Entity_ref.length;
			for (i in 0...len) {
				var ref = data.f_Entity_ref[i];
				// var allEntities:Array<Dynamic>=Entity.ALL.mapToArray(e->e);
				if (!game.gameStats.has(ref.entityIid + "activated")) {
					//trace("ENTITY IS NOT IN THIS LEVEL");
					var ach = new Achievement(ref.entityIid + "activated", "Activated", () -> return true, () -> {
						// trace("BIEN PLAYED");
					});
					game.gameStats.registerState(ach);
					if(ref.levelIid!=game.currentLevel && ref.worldIid==game.currentWorld){
						hud.notify("something happened in another level...");
					}else if(ref.levelIid!=game.currentLevel && ref.worldIid!=game.currentWorld){
						hud.notify("something has changed in another world...");
					}
					
					ach=null;
				}
				for (elev in sample.Platform.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellovator');
						if (elev.activated == false) {
							elev.activated = true;

							spr.anim.play("check");
							hud.notify("activation");
							cd.setMs("recentlyActivated", 800);
						} else {
							if(elev.cd!=null) elev.cd.setS('shouldStop', 10);
							fx.markerText(cx, cy + 2, "Please, wait...", 2);
							spr.anim.play("wrong");
							cd.setMs("recentlyActivated", 800);
						}
					} 
				}

                for (elev in sample.Door.ALL) {
					if (elev.data.iid == ref.entityIid && ref.levelIid==game.currentLevel) {
						//trace('hellodoôôor');
						if (elev.activated == false) {
							elev.activated = true;

							spr.anim.play("check");
							//hud.notify("activation");
							cd.setMs("recentlyActivated", 800);
						} else {
							
							fx.markerText(cx, cy + 2, "Please, wait...", 2);
							spr.anim.play("wrong");
							cd.setMs("recentlyActivated", 800);
						}
					}
				}

			}
		}
	}
}
