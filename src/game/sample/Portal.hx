package sample;

import ldtk.Json.EntityReferenceInfos;
import dn.heaps.HParticle;

class Portal extends Entity {
	public var data:Entity_Portal;
	public var destRef:ldtk.EntityReferenceInfos;
	public var activable:Bool = false;

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
		destRef = portal.f_Entity_ref;
		// trace(destRef);
		wid = portal.width;
		hei = portal.height;
		setPosCase(portal.cx, portal.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set("empty"); // D.tiles.fxLightCircle
		spr.pivot.centerFactorX = 0;
		spr.pivot.centerFactorY = 0;
		spr.scale(1);
		// sprScaleX = sprScaleY = 1;
	}

	override function dispose() {
		super.dispose();
		// don't forget to dispose controller accesses
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (collides && game.player.cd.has('changedLevel')) {
			activable = false;
		} else if (!collides && !game.player.cd.has('changedLevel')) {
			activable = true;
		}
		if (collides && !game.player.cd.has('changedLevel') && activable == true) {
			game.player.destination = {
				level: data.f_Entity_ref.levelIid,
				door: data.f_Entity_ref.entityIid,
				layer: data.f_Entity_ref.layerIid,
				world: data.f_Entity_ref.worldIid
			}
			activable = false;

			for (w in Assets.worldData.worlds) {
				// trace(w.identifier + '(' + w.iid + ')');
				var monde = Assets.worldData.getWorld(w.iid);
				for (l in monde.levels) {
					if (l.iid == game.player.destination.level) {
						for (por in l.l_Entities.all_Portal) {
							if (por.iid == destRef.entityIid) {
								game.player.cx = por.cx;
								game.player.cy = por.cy;
								game.player.onPosManuallyChangedBoth();
								game.player.cd.setS('changedLevel', 0.2);
								game.currentLevelIdentifyer = l.identifier;
								game.currentWorldIdentifyer = w.identifier;
								hud.notify('téléportinge');
								Game.ME.fadeOut(0.25);
								game.delayer.addF("changedLevel", () -> {
									Game.ME.fadeIn(0.25);
									game.startLevel(l);
								}, 1);
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
