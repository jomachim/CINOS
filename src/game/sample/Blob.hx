package sample;

import dn.heaps.HParticle;

class Blob extends Entity {
	public static var ALL:Array<Blob>=[];
	public var data:Entity_Blob;
	public var activated:Bool;
	

	public function new(blob:Entity_Blob) {
		super(5, 5);
		data = blob;
		setPosCase(blob.cx, blob.cy);
		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.blob);
		spr.set(Assets.blob); 
		spr.scaleX*=irnd(0,1)==0?1:-1;
		spr.rotation=rnd(0,2*M.PI);
		sprScaleX=sprScaleY=rnd(1,2);
		spr.anim.registerStateAnim(anims.idle, 0);
		spr.anim.setSpeed(rnd(0.1,0.5));
		spr.setPivotCoord(wid * 0.5, hei*0.5);
		level.breakables.set(Breaking, blob.cx, blob.cy);
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
		if(rnd(0,100)<10){setSquashY(rnd(0.8,1.2));}
		if(rnd(0,100)<10){setSquashX(rnd(0.8,1.2));}
		if(level.breakables.has(Broken,cx, cy)){
			level.breakables.remove(Broken, cx, cy);
			fx.crap(attachX,attachY,0x9b1340,-1);
			destroy();
		}
		if(distPx(game.player.attachX,game.player.attachY)<24 && game.player.cd.has('dashing')){
			level.breakables.remove(Breaking, cx, cy);
			fx.crap(attachX,attachY,0xc54848,-1);
			destroy();
		}
		
	}
	override function preUpdate() {
		super.preUpdate();
		
	}
}
