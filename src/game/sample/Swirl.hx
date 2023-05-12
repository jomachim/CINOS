package sample;

import dn.heaps.HParticle;

class Swirl extends Entity {
	
	public var data:Entity_Swirl;
	
	public function new(ent:Entity_Swirl) {
		super(5,5);
		data=ent;
		setPosCase(ent.cx, ent.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set('empty');//D.tiles.fxLightCircle
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
		sprScaleX = sprScaleY = 1;
		
	}

	override function dispose() {
		super.dispose();
		// don't forget to dispose controller accesses
	}


	override function fixedUpdate() {
		super.fixedUpdate();
		if(!cd.has('light')){
			cd.setMs('light',600);
			if(App.ME.options.shaders==true){fx.swirl(attachX,attachY);}
		}
	}

	/*override function postUpdate() {
		super.postUpdate();
		
	}*/
}
