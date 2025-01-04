package sample;

import dn.heaps.HParticle;

class Flower extends Entity {
	public static var ALL:Array<Flower>=[];
	public var data:Entity_Flower;
	public var activated:Bool;
	

	public function new(flower:Entity_Flower) {
		super(5, 5);
		data = flower;
		setPosCase(flower.cx, flower.cy);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.flower);
		spr.set(Assets.flower); 
		var idl=flower.f_idle;
		var colours=[0x00ff00,0x00fff0,0xb8f510];
		var colour=colours[irnd(0,colours.length)];
		if(idl==0){
			spr.anim.registerStateAnim(anims.idle, 0);
			spr.colorize(colour,0.5);
		}else{
			spr.anim.registerStateAnim(anims.idle1, 0);
		}
		
		spr.anim.setSpeed(rnd(0.1,1.5));
		
		
		
		ALL.push(this);
		spr.filter=null;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		// don't forget, to dispose controller accesses
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		
	}
	override function preUpdate() {
		super.preUpdate();
		
	}
}
