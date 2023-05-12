package sample;

import dn.heaps.HParticle;

class Light extends Entity {
	
	public var data:Entity_Light;
	public var color:Col;
	public var front:Bool;
	public var isSpot:Bool;
	public function new(light:Entity_Light) {
		super(5,5);
		data=light;
		color=light.f_Color_int;
		front=light.f_front;
		isSpot=light.f_isSpot;
		setPosCase(light.cx, light.cy);
		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */
		spr.set('empty');//D.tiles.fxLightCircle
		spr.pivot.centerFactorX = 0.5;
		spr.pivot.centerFactorY = 0.5;
		spr.scale(1);
		sprScaleX = sprScaleY = 0.50;
		
	}

	override function dispose() {
		super.dispose();
		// don't forget to dispose controller accesses
	}


	override function fixedUpdate() {
		super.fixedUpdate();
		if(!cd.has('light')){
			cd.setS('light',1);
			fx.lightCircle(attachX,attachY,color,front,isSpot);
		}
		if(!cd.has('lightHeat')){
			cd.setS('lightHeat',0.2);
			if(App.ME.options.shaders==true){fx.heat(attachX,attachY+8,0.5,1.5,0.5);}
		}
	}

	/*override function postUpdate() {
		super.postUpdate();
		
	}*/
}
