package sample;

import GameStats;
import GameStats.*;

class Computer extends Entity {
	public static var ALL:Array<Computer> = [];

	var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.computer);
	var ready:Bool = false;
	var locked:Bool;

	public var requierements:Dynamic;
	public var data:Entity_Computer;

	inline function get_ready()
		return spr.anim.getAnimId() == anims.idle;

	public function new(ent:Entity_Computer) {
		super(ent.cx, ent.cy);
		setPosCase(ent.cx, ent.cy);
		// Placeholder display
		data = ent;
		requierements=ent.f_requiered_item;
		locked=ent.f_requiered_item==null?false:true;
		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0x330000, 0.4);
		var bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		var group = new h2d.filter.Group([outline, bloom]);
		spr.filter = group;
		spr.set(Assets.computer);

		// spr.anim.registerStateAnim(anims.closed, 2,()->cd.getS("recentlyTeleported")>0);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.registerStateAnim(anims.idle2, 1, () -> distCase(game.player) <= 2);

		var g = new h2d.Graphics(spr);

		if(game.gameStats.has(data.iid+"unlocked")){
			locked=false;
		}

	}

	override function dispose() {
		super.dispose();
	}

	override function preUpdate() {
		super.preUpdate();
		if (isOnScreenBounds()) {
			ready = true;
		} else {
			ready = false;
		}
	}

	override function fixedUpdate() {
		if (!ready)
			return;
		super.fixedUpdate();
		// debug(data.f_Entity_ref.entityIid);
		if (distCase(game.player) <= 2 && !cd.has("canard")) {
			fx.markerText(cx, cy - 2, "Press ACTION", 5.0);
			cd.setS("canard", 5.0);
		};

		if (distCase(game.player) <= 3 && !cd.has("recentlyActivated") && (game.ca.isDown(Action) || game.ca.isDown(Lock))) {
			if (locked == true && data.f_requiered_item != null && game.player.inventory.contains(data.f_requiered_item)) {
				locked = false;
				//trace('requiered item unlocked the chest');
				game.player.inventory.remove(data.f_requiered_item);
				var ach = new Achievement(data.iid + "unlocked", "done", () -> true, () -> {}, true);
				game.gameStats.registerState(ach);
				ach = null;
			}else if(locked == true && data.f_requiered_item != null && !game.player.inventory.contains(data.f_requiered_item)){
				fx.markerText(cx, cy - 2, "LOCKED");
				S.wrong().play(false, App.ME.options.volume * 0.5).pitchRandomly(0.14);
				spr.anim.play("wrong");
				game.player.ca.lock();
				new ui.DialogBox(["It's LOCKED",data.f_requiered_item+" is requiered"],attachX,attachY,game.scroller,()->{game.player.ca.unlock();});
				cd.setMs("recentlyActivated", 800);
			}
			if (locked == false) {
				var len = data.f_Entity_ref.length;
				for (i in 0...len) {
					var ref = data.f_Entity_ref[i];
					// var allEntities:Array<Dynamic>=Entity.ALL.mapToArray(e->e);
					if (!game.gameStats.has(ref.entityIid + "activated")) {
						// trace("ENTITY IS NOT IN THIS LEVEL");
						var ach = new Achievement(ref.entityIid + "activated", "Activated", () -> return true, () -> {
							// trace("BIEN PLAYED");
						});
						game.gameStats.registerState(ach);
						if (ref.levelIid != game.currentLevel && ref.worldIid == game.currentWorld) {
							hud.notify("something happened in another level...");
						} else if (ref.levelIid != game.currentLevel && ref.worldIid != game.currentWorld) {
							hud.notify("something has changed in another world...");
						}

						ach = null;
					}
					for (minuter in sample.Minuter.ALL) {
						if (minuter.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
							// trace('hellovator');
							minuter.activated = !minuter.activated;
								S.good().play(false, App.ME.options.volume * 0.75).pitchRandomly(0.14);
								spr.anim.play("check");
								hud.notify("Minuter is turned "+(minuter.activated?"on":"off"));
								cd.setMs("recentlyActivated", 800);
							
						}
					}
					for (elev in sample.Platform.ALL) {
						if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
							// trace('hellovator');
							if (elev.activated == false) {
								elev.activated = true;
								S.good().play(false, App.ME.options.volume * 0.75).pitchRandomly(0.14);
								spr.anim.play("check");
								hud.notify("activation");
								cd.setMs("recentlyActivated", 800);
							} else {
								if (elev.cd != null)
									elev.cd.setS('shouldStop', 10);
								fx.markerText(cx, cy + 2, "Please, wait...", 2);
								spr.anim.play("wrong");
								S.wrong().play(false, App.ME.options.volume * 0.75).pitchRandomly(0.14);
								cd.setMs("recentlyActivated", 800);
							}
						}
					}

					for (elev in sample.Door.ALL) {
						if (elev.data.iid == ref.entityIid && ref.levelIid == game.currentLevel) {
							// trace('hellodoôôor');
							if (elev.activated == false) {
								elev.activated = true;
								S.good().play(false, App.ME.options.volume * 0.75).pitchRandomly(0.14);
								spr.anim.play("check");
								// hud.notify("activation");
								cd.setMs("recentlyActivated", 800);
							} else {
								S.wrong().play(false, App.ME.options.volume * 0.75).pitchRandomly(0.14);
								fx.markerText(cx, cy + 2, "Error 504", 2);
								spr.anim.play("wrong");
								cd.setMs("recentlyActivated", 800);
							}
						}
					}
				}
			}
		}
	}
}
