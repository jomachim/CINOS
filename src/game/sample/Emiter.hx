package sample;

import dn.heaps.HParticle;

typedef VPoint = {
	var x:Float;
	var y:Float;
	var d:Float;
	var a:Float;
}

class Emiter extends Entity {
	public static var ALL:Array<Emiter> = [];

	public var data:Entity_Emiter;
	public var color:Col;
	public var activated:Bool;
	public var angle:Float;
	public var lastX:Float;
	public var lastY:Float;
	public var reflexions:Array<VPoint> = [];

	public function new(emiter:Entity_Emiter) {
		super(5, 5);
		data = emiter;
		angle = emiter.f_angle;
		reflexions = [];

		setPosCase(emiter.cx, emiter.cy);

		spr.set('empty'); // D.tiles.fxEmiterCircle
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
		var d:Float = 0.0;
		reflexions = [];
		var ref:VPoint={x:cx + 1 * Math.cos(angle), y:cy + 1 * Math.sin(angle), d:1, a:angle};
		reflexions.push(ref);
		for (i in 0...30) {
			// needs angle int
			var tx = Std.int(i * Math.cos(angle));
			var ty = Std.int(i * Math.sin(angle));
			if (level.hasCollision(cx + tx, cy + ty)) {
				d = distCase(cx + tx, cy + ty);
				var ref:VPoint={x:cx + tx, y:cy + ty, d:d, a:angle};
				reflexions.push(ref);
			}
		}
		var g = new h2d.Graphics(game.scroller);
		g.lineStyle(1.5, 0x00ff00, 0.5);
		for (i in reflexions) {
			
			
			g.moveTo(i.x, i.y);
			g.lineTo(i.x + i.d * Math.cos(i.a), i.y + i.d * Math.sin(i.a));
			g.endFill();
		}
		g.clear();
	}

	override function preUpdate() {
		super.preUpdate();
	}
}
