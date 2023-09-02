package sample;

import dn.heaps.HParticle;

class Light extends Entity {
	public static var ALL:Array<Light>=[];
	public var data:Entity_Light;
	public var color:Col;
	public var front:Bool;
	public var isSpot:Bool;
	public var activated:Bool;

	public function new(light:Entity_Light) {
		super(5, 5);
		data = light;
		color = light.f_Color_int;
		front = light.f_front;
		isSpot = light.f_isSpot;
		activated = light.f_activated;
		if (game.gameStats.has(light.iid+"activated")) {
			activated = true;
		}
		setPosCase(light.cx, light.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set(D.tiles.fxLightCircle0); // 
		spr.adjustColor({ saturation : 0, lightness : 1, hue : 1 * Math.PI / 180, contrast : 0.5} );
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(2);
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
		if (activated == true) {
			if (!cd.has('light')) {
				cd.setS('light', 0.5);
				fx.lightCircle(attachX, attachY, color, front, isSpot);
				if (rnd(0, 1000) < 10) {
					for (i in 0...5) {
						game.delayer.addMs('boomer', () -> {
							fx.embers(attachX + rnd(-3, 3, true), attachY + rnd(-3, 3, true), color);
						}, i * rnd(i + 10, 50));
					}
				}
			}
			
		}
	}
	override function preUpdate() {
		super.preUpdate();
		if (!cd.has('lightHeat')) {
			cd.setS('lightHeat', 0.2);
			if (App.ME.options.shaders == true) {
				fx.heat(attachX, attachY + 8, 0.5, 1.5, 0.5);
			}
		}

	}
}
