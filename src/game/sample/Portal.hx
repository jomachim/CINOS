package sample;

import ldtk.Json.EntityReferenceInfos;
import dn.heaps.HParticle;

class Portal extends Entity {
	public static var ALL:Array<Portal> = [];

	public var data:Entity_Portal;
	public var destRef:Array<ldtk.EntityReferenceInfos>;
	public var activable:Bool = false;
	public var isDoor:Bool = false;

	// public var collides:Bool = false;
	var collides(get, never):Bool;

	inline function get_collides()
		return game.player.centerX >= left
			&& game.player.centerX <= right
			&& game.player.centerY >= top
			&& game.player.centerY <= bottom;

	public function new(portal:Entity_Portal) {
		super(5, 5);
		data = portal;
		destRef = portal.f_Entity_refs;
		isDoor = portal.f_isDoor;
		// trace(destRef);
		wid = portal.width;
		hei = portal.height;
		setPosCase(portal.cx, portal.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */

		spr.set("empty"); // D.tiles.fxLightCircle

		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
		spr.filter = null;

		// sprScaleX = sprScaleY = 1;
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
		// don't forget to dispose controller accesses
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (!cd.has('animation') && isDoor) {
			cd.setMs("animation", rnd(100, 600));
			fx.portalDoor(attachX, attachY - hei * 0.5);
			if (App.ME.options.shaders == true) {
				fx.swirl(attachX, attachY - hei * 0.5);
			}
		}
		if (collides && game.player.cd.has('changedLevel')) {
			activable = false;
		} else if (!collides && !game.player.cd.has('changedLevel')) {
			activable = true;
		}
		if (collides && !game.player.cd.has('changedLevel') && activable == true) {
			game.player.destination = {
    			level: data.f_Entity_refs[0].levelIid,
				door: data.f_Entity_refs[0].entityIid,
				layer: data.f_Entity_refs[0].layerIid,
				world: data.f_Entity_refs[0].worldIid
			}
			activable = false;

			if (game.currentLevel == destRef[0].levelIid) {
				var port = ALL.filter((p:Portal) -> {
					return p.data.iid == destRef[0].entityIid;
				})[0];
				game.player.cx = port.cx;
				game.player.cy = port.cy;
				game.player.onPosManuallyChangedBoth();
				game.player.cd.setS('changedLevel', 0.8);
				game.camera.trackEntity(game.player,true,100);
			} else {
				for (w in Assets.worldData.worlds) {
					// trace(w.identifier + '(' + w.iid + ')');
					var monde = Assets.worldData.getWorld(w.iid);
					for (l in monde.levels) {
						if (l.iid == game.player.destination.level) {
							for (por in l.l_Entities.all_Portal) {
								if (por.iid == destRef[0].entityIid) {
									// hud.notify('téléportinge');
									Game.ME.fadeOut(0.25);
									game.delayer.addF("changedLevel", () -> {
										Game.ME.fadeIn(0.25);
										game.startLevel(l);
										game.player.cx = por.cx;
										game.player.cy = por.cy;
										game.player.onPosManuallyChangedBoth();
										game.player.cd.setS('changedLevel', 0.2);
										game.currentLevelIdentifyer = l.identifier;
										game.currentWorldIdentifyer = w.identifier;
										game.camera.trackEntity(game.player,true,100);
									}, 1);
								}
							}
						}
					}
				}
			}

			/*if (Assets.worldData.all_worlds.Monde_1.iid == data.f_Entity_ref.worldIid) {
					for (lvl in Assets.worldData.all_worlds.Monde_1.levels) {
						if (lvl.iid == game.player.destination.level) {
							for (por in lvl.l_Entities.all_Portal) {
								if (por.iid == destRef.entityIid) {
									game.player.cx = por.cx;
									game.player.cy = por.cy;
									game.player.onPosManuallyChangedBoth();
									game.player.cd.setS('changedLevel', 0.2);
									if (game.currentLevel != lvl.iid) {
										game.currentWorld = destRef.worldIid;
										game.currentLevel = lvl.iid;
										hud.notify('téléportinge');
										Game.ME.fadeOut(0.25);
										game.delayer.addF("changedLevel", () -> {
											Game.ME.fadeIn(0.25);
											game.startLevel(lvl);
										}, 1);
									}
								}
							}
						}
					}
				} else {
					for (lvl in Assets.worldData.all_worlds.Monde_2.levels) {
						if (lvl.iid == game.player.destination.level) {
							for (por in lvl.l_Entities.all_Portal) {
								if (por.iid == destRef.entityIid) {
									game.player.cx = por.cx;
									game.player.cy = por.cy;
									game.player.onPosManuallyChangedBoth();
									game.player.cd.setS('changedLevel', 0.2);
									if (game.currentLevel != lvl.iid) {
										hud.notify('téléportinge');
										Game.ME.fadeOut(0.25);
										game.delayer.addF("changedLevel", () -> {
											Game.ME.fadeIn(0.25);
											game.startLevel(lvl);
										}, 1);
									}
								}
							}
						}
					}
			}*/
		}
	}

	override function postUpdate() {
		super.postUpdate();
	}
}
