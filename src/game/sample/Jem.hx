package sample;

import dn.Delayer;
import GameStats.Achievement;
import dn.heaps.HParticle;

class Jem extends Entity {
	public var data:Entity_Jem;
	public var type:Int;
	public static var ALL:Array<Jem> = [];

	public function new(jem:Entity_Jem) {
		super(5, 5);
		data = jem;
		if (game.gameStats.has('jemIsDead_' + data.iid)) {
			initLife(0);
			destroy();
		}
		type = jem.f_type;
		setPosCase(jem.cx, jem.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set(type == 0 ? D.tiles.fxRedJem : type == 1 ? D.tiles.fxGreenJem : type == 2 ? D.tiles.fxBlueJem : D.tiles.fxYellowJem); // D.tiles.fxLightCircle
		type == 0 ? outline.color = 0xff0000 : type == 1 ? outline.color = 0x00ff00 : type == 2 ? outline.color = 0x4c00ff : outline.color = 0xffff00;
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 1;
		spr.scale(1);
		// sprScaleX = sprScaleY = 1;
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		// don't forget to dispose controller accesses
	}

	override function onDie() {
		if (!game.gameStats.has('jemIsDead_' + data.iid)) {
			var achdead = new Achievement("jemIsDead_" + data.iid, "dead", () -> true, () -> {
				//trace("Jem is dead");
			}, true);
			game.gameStats.registerState(achdead);
			achdead=null;
		}
		super.onDie();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (game.gameStats.has('jemIsDead_' + data.iid)) {
			initLife(0);
			destroy();
		}
		if (!camera.isOnScreen(centerX, centerY, 32)){
			return;
		}
		if (distPx(game.player.centerX, game.player.centerY) < 10) {
			fx.star(centerX, centerY, outline.color, irnd(4, 8));
			S.pick01(App.ME.options.volume);
			game.player.timeBonus++;
			if (type == 1) {
				game.player.life++;
				game.player.updateHudLife();
			} else if (type == 0) {
				game.player.xp++;
			} else if (type == 2){
				game.player.initLife(game.player.maxLife);
			}else if(type == 3){
				game.player.lazerCoolDownTime+=0.5;
			}
			initLife(0);
			destroy();
		}
		if (!cd.has('blinking')) {
			cd.setS('blinking', rnd(0.2, 0.8) + 1);
			blink(0xffff00);
			setSquashY(0.6);
			game.delayer.addMs(()->{setSquashX(0.6);},80); 
		}
	}

	/*override function postUpdate() {
		super.postUpdate();
	}*/
}
