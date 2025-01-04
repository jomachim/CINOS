package sample;

import dn.heaps.HParticle;

class Shower extends Entity {
	public static var ALL:Array<Shower> = [];

	public var data:Entity_Shower;
	public var color:Col;
	public var activated:Bool;
	public var lastX:Float;
	public var lastY:Float;

	public function new(shower:Entity_Shower) {
		super(5, 5);
		data = shower;
		color = shower.f_Color_int;
		activated = shower.f_activated;
		if (game.gameStats.has(shower.iid + "activated")) {
			activated = true;
		}
		setPosCase(shower.cx, shower.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set('empty'); // D.tiles.fxshowerCircle
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
		sprScaleX = sprScaleY = 0.50;
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		// don't forget, to dispose controller accesses
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if(activated==false){
			game.gameStats.unregisterState(data.iid+'activated');
		}
		if (activated == true && !cd.has('shower')) {
			cd.setMs('shower',60);
			for (i in 0...10) {
				game.delayer.addMs('boomer', () -> {
					fx.waterFlow(attachX + rnd(-3, 3, true), attachY + 8+rnd(-3, 3, true), color,1);
					//fx.embers(attachX + rnd(-3, 3, true), attachY + 8+rnd(-3, 3, true), color,1);
				}, i * rnd(i + 10, 50));
			}
		}
	}

	override function preUpdate() {
		super.preUpdate();
	}
}
