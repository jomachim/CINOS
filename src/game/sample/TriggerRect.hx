package sample;

import GameStats;
import dn.heaps.HParticle;

class TriggerRect extends Entity {
	public var data:Entity_TriggerRect;
	public var actionScript:String;
	public var refs:Array<Any>;

	public function new(trigger:Entity_TriggerRect) {
		super(5, 5);
		data = trigger;

		actionScript = trigger.f_ActionScript;
		refs = trigger.f_Entity_ref;
		setPosCase(trigger.cx, trigger.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set('empty'); // D.tiles.fxLightCircle
		wid=data.width;
		hei=data.height;
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
		if (game.player.right >= left 
			&& game.player.left <= right 
			&& game.player.bottom>=top 
			&& game.player.top<=bottom ){
			if (data.f_ActionScript != null && !game.gameStats.has('actionscript_' + data.iid)) {
				// script=game.hsParser.parseString();
				var scripter = tools.script.Script;

				App.ME.delayer.addS('triggeredScript', () -> {
					scripter.run(data.f_ActionScript);
				}, 0);
				var cineDone = new Achievement('actionscript_' + data.iid, "done", () -> true, () -> {
					trace("TRIGGERED ACHIEVEMENT : actionscript done");
				}, true);
				game.gameStats.registerState(cineDone);
				cineDone=null;
				destroy();
			}
		}
	}
	/*override function postUpdate() {
		super.postUpdate();

	}*/
}
