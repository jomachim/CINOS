import h2d.Tile;
import h2d.Sprite;
import dn.heaps.HParticle;

class Fx extends GameChildProcess {
	var pool:ParticlePool;

	public var bg_add:h2d.SpriteBatch;
	public var bg_normal:h2d.SpriteBatch;
	public var main_add:h2d.SpriteBatch;
	public var main_normal:h2d.SpriteBatch;
	public var displacer_normal:h2d.SpriteBatch;
	public var front_normal:h2d.SpriteBatch;
	public var front_add:h2d.SpriteBatch;

	public function new() {
		super();

		pool = new ParticlePool(Assets.tiles.tile, 8192, Const.FPS);

		bg_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_add, Const.DP_FX_BG);
		bg_add.blendMode = Add;
		bg_add.hasRotationScale = true;

		bg_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_normal, Const.DP_FX_BG);
		bg_normal.hasRotationScale = true;

		main_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_normal, Const.DP_FX_FRONT);
		main_normal.hasRotationScale = true;

		main_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_add, Const.DP_FX_FRONT);
		main_add.blendMode = Add;
		main_add.hasRotationScale = true;
		/* EXTRA LAYER */

		front_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(front_add, Const.DP_FX_FRONT);
		front_add.blendMode = Add;
		front_add.hasRotationScale = true;

		front_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(front_normal, Const.DP_FX_FRONT);
		// front_normal.blendMode = Normal;
		front_normal.hasRotationScale = true;

		// displacement layer ?
		displacer_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		// game.scroller.add(displacer_normal, Const.DP_FX_FRONT);
		game.displaceLayer.add(displacer_normal, Const.DP_FX_BG);
		// displacer_normal.blendMode = Add;
		displacer_normal.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bg_add.remove();
		bg_normal.remove();
		main_add.remove();
		main_normal.remove();
		displacer_normal.remove();
		front_add.remove();
		front_normal.remove();
	}

	/** Clear all particles **/
	public function clear() {
		pool.clear();
	}

	/** Create a HParticle instance in the BG layer, using ADDITIVE blendmode **/
	public inline function allocBg_add(id, x, y)
		return pool.alloc(bg_add, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the BG layer, using NORMAL blendmode **/
	public inline function allocBg_normal(id, x, y)
		return pool.alloc(bg_normal, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the MAIN layer, using ADDITIVE blendmode **/
	public inline function allocMain_add(id, x, y)
		return pool.alloc(main_add, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the MAIN layer, using NORMAL blendmode **/
	public inline function allocMain_normal(id, x, y)
		return pool.alloc(main_normal, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the FORGROUND layer, using NORMAL blendmode **/
	public inline function allocFront_normal(id, x, y)
		return pool.alloc(front_normal, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the FORGROUND layer, using ADD blendmode **/
	public inline function allocFront_add(id, x, y)
		return pool.alloc(front_add, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the DISPLACEMENT layer, using NORMAL blendmode **/
	public inline function allocDisplacer_normal(id, x, y)
		return pool.alloc(displacer_normal, Assets.tiles.getTileRandom(id), x, y);

	public inline function markerEntity(e:Entity, c:Col = Pink, short = false) {
		#if debug
		if (e != null && e.isAlive())
			markerCase(e.cx, e.cy, short ? 0.03 : 3, c);
		#end
	}

	public inline function markerCase(cx:Int, cy:Int, sec = 3.0, c:Col = Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxCircle15, (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocMain_add(D.tiles.pixel, (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public inline function markerFree(x:Float, y:Float, sec = 3.0, c:Col = Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxDot, x, y);
		p.setCenterRatio(0.5, 0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	/* obsolete : texture.clear(0x8888ff,1) do the trick :) */
	public inline function fillZeroNormal(x:Float = 0.0, y:Float = 0.0) {
		var p = pool.alloc(displacer_normal, Tile.fromColor(0x8888ff, stageWid,stageHei, 1.0), x, y);
		p.lifeS = 0.1;
	}

	public inline function pixelRain(x, y, w, h) {
		for (i in 0...2) {
			var p = allocDisplacer_normal(D.tiles.pixel, x + rnd(0, w * 0.8), y + rnd(0, h * 0.7));
			p.setFadeS(rnd(0.2, 0.5), 1, rnd(1, 2));
			p.colorAnimS(Col.inlineHex("#ff6900"), Assets.dark(), rnd(1, 3));
			p.alphaFlicker = rnd(0.2, 0.5);
			p.setScale(irnd(1, 2));
			p.dr = rnd(0, 0.1, true);
			p.gx = rnd(0, 0.03);
			p.gy = rnd(0.002, 0.01);
			p.dx = rnd(-0.1, 0.1);
			// p.dy = rnd(0,1,true);
			p.frict = R.aroundBO(0.98, 5);
			p.lifeS = rnd(1, 2);
			p.onUpdate = function(p:HParticle) {
				heat(p.x, p.y, 0.05, 0.25, 0.5);
			}
		}
	}

	public inline function portalDoor(x:Float, y:Float) {
		var p = allocBg_add(D.tiles.fxPortal, x, y);
		p.rotation = rnd(0, 3.14);
		p.lifeS = rnd(0.1, 1);
		p.setFadeS(0.45, 0.01, 1);
		p.playAnimLoop(A.tiles, D.tiles.fxPortal, rnd(0.5, 1.5));
	}

	public inline function heatSource(x:Float, y:Float, v:Float = 0.0, ?s:Float = 0.1) {
		var p = allocDisplacer_normal(D.tiles.fxSphereNormal, x, y);
		p.alpha = v;
		p.setScale(v > 0.5 ? 0.5 : 0.5 + v);
		p.lifeS = s;
	}

	public inline function swirl(x:Float, y:Float, _alpha:Float = 1.0, _scale:Float = 1.0) {
		var p = allocDisplacer_normal(D.tiles.swirl, x, y);
		p.rotation = rnd(0.01, 3.14);
		p.setFadeS(1, 0.2, 0.2);
		p.scaleMul = 0.99;
		p.alpha = _alpha * 0.5;
		p.scale = _scale;
		// p.gx=rnd(-0.001,0.001);
		// p.gy=rnd(-0.01,-0.05);
		p.lifeS = rnd(0.1, 0.5);
	}

	public inline function heat(x:Float, y:Float, ?s:Float = 0.5, ?_scale:Float = 1.0, _alpha:Float = 1.0, ?color:Col = 0xff8c00) {
		var p = allocDisplacer_normal(D.tiles.fxHeat, x, y);
		p.rotation = rnd(0.01, 3.14);
		p.setFadeS(1, 0.2, 0.2);
		p.scaleMul = 0.99;
		p.alpha = _alpha;
		p.scale = _scale;
		p.gx = rnd(-0.001, 0.001);
		p.gy = rnd(-0.01, -0.05);
		p.lifeS = rnd(0.01, s + 0.1);
	}

	public inline function surprise(x:Float, y:Float, ?s:Float = 1, ?color:Col = 0xff8c00) {
		var p = allocMain_add(D.tiles.fxSurprise, x, y);
		p.setFadeS(1, 0.05, 0.25);
		p.colorize(color);
		p.scaleMul = 1.01;
		p.setScale(0.8);
		p.lifeS = s;
	}

	public inline function cat(x:Float, y:Float, ?s:Float = 1, ?color:Col = 0xff8c00) {
		var p = allocMain_normal(D.tiles.fxCatHead, x, y);
		// flashBangEaseInS(0xffffff, 0.9, 0.60);
		p.setScale(10);
		p.alpha = 1;
		p.setFadeS(1, 0, s);
		p.scaleMul = 0.9;
		// p.colorize(color, 0.1);

		p.lifeS = s;
	}

	public inline function flashBangEaseInS(c:Col, a:Float, t = 0.1) {
		if (game.player.life > 0) {
			var e = new h2d.Bitmap(h2d.Tile.fromColor(c, 1, 1, a));
			game.root.add(e, Const.DP_FX_FRONT);
			e.scaleX = game.stageWid;
			e.scaleY = game.stageHei;
			e.blendMode = Add;
			game.tw.createS(e.alpha, 0 > 1, 0.1).end(() -> game.tw.createS(e.alpha, 0, t).end(e.remove));
		}
	}

	public inline function star(x:Float, y:Float, ?color:Col = 0xffff00, ?n = 1) {
		for (i in 0...n) {
			var p = allocMain_add(D.tiles.fxStar, x + rnd(0, 4, true), y + rnd(0, 4, true));
			p.setFadeS(1, 0.1, 0.4);
			p.colorize(color);
			p.lifeS = 0.4;
			p.frict = 0.9;
			p.scaleMul = 0.99;
			p.rotation = rnd(0, 2 * M.PI);
			p.scale = 1;

			p.delayCallback((p) -> {
				p.moveAwayFrom(x, y, 5);
				/*p.delayCallback((p) -> {
					p.moveTo(game.player.centerX, game.player.centerY, 4);
				}, 0.5);*/
			}, 0);
		}
	}

	public inline function powerCircle(x:Float, y:Float, s:Float = 2, ?ent:Null<Entity> = null) {
		var p = allocBg_normal(D.tiles.fxPower, x, y); // D.tiles.fxDashWave
		p.playAnimLoop(A.tiles, D.tiles.fxPower, 0.1);
		p.randRotation();
		p.randFlipX();
		p.randFlipY();
		p.alphaFlicker = 0.8;
		p.lifeS = s;
		if (ent != null) {
			p.onUpdate = (p) -> {
				p.x = ent.centerX;
				p.y = ent.centerY;
			}
		}
	}

	public inline function dash(x:Float, y:Float, speed:Float = 1, ang:Float = 0) {
		var p = allocBg_normal(D.tiles.fxRoll, x + speed * 8, y); // D.tiles.fxDashWave
		p.playAnimLoop(A.tiles, D.tiles.fxRoll, 1);
		p.alpha = 0.25;
		p.setFadeS(0.8, 0, 0.3);
		p.colorize(Col.inlineHex('0xaaaaff'), 0.1);
		p.colorAnimS(Assets.black(), 0xaaaaff, 0.1);
		p.lifeS = 0.45;
		p.dx = speed;
		p.rotation = ang; // ang < 0 ? ang : -ang; // (ang/180*M.PI)*-dir;
		p.scale = 1;
		p.frict = 0.9;
		p.scaleY = speed > 0 ? 1 : -1;
	}

	public inline function lightCircle(x:Float, y:Float, color:Col = 0xffffff, front:Bool = false, isSpot:Bool = false) {
		var p;
		if (front == false) {
			if (isSpot == true) {
				p = allocBg_add(D.tiles.fxSpotLight, x, y + 8);
			} else {
				p = allocBg_add(D.tiles.fxLightCircle0, x, y);
			}
		} else {
			if (isSpot == true) {
				p = allocMain_add(D.tiles.fxSpotLight, x, y + 8);
			} else {
				p = allocMain_add(D.tiles.fxLightCircle0, x, y);
			}
		}

		p.colorize(color, 1);
		p.setFadeS(0.8, 0.25, 0.25);
		p.lifeS = 0.5;
	}

	public inline function markerText(cx:Int, cy:Int, txt:String, t = 1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontPixel, main_normal);
		tf.text = txt;

		var p = allocMain_add(D.tiles.fxCircle15, (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x - tf.textWidth * 0.5, p.y - tf.textHeight * 0.5);
		#end
	}

	inline function collides(p:HParticle, offX = 0., offY = 0.) {
		return level.hasCollision(Std.int((p.x + offX) / Const.GRID), Std.int((p.y + offY) / Const.GRID));
	}

	public inline function flashBangS(c:Col, a:Float, t = 0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c, 1, 1, a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.stageWid;
		e.scaleY = game.stageHei;
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end(function() {
			e.remove();
		});
	}

	/**
		A small sample to demonstrate how basic particles work. This example produces a small explosion of yellow dots that will fall and slowly fade to purple.

		USAGE: fx.dotsExplosionExample(50,50, 0xffcc00)
	**/
	public inline function dotsExplosionExample(x:Float, y:Float, color:Col) {
		for (i in 0...80) {
			var p = allocMain_add(D.tiles.fxDot, x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.alpha = rnd(0.4, 1);
			p.colorAnimS(color, 0x762087, rnd(0.6, 3)); // fade particle color from given color to some purple
			p.moveAwayFrom(x, y, rnd(1, 3)); // move away from source
			p.frict = rnd(0.8, 0.9); // friction applied to velocities
			p.gy = rnd(0, 0.02); // gravity Y (added on each frame)
			p.lifeS = rnd(2, 3); // life time in seconds
		}
	}

	public inline function wallDust(x:Float, y:Float, dir:Int, color:Col) {
		var p = allocMain_add(D.tiles.fxDuster, x + dir * 4, y);
		p.rotation = (90 / 180 * M.PI) * -dir;
		p.scale = 0.5;
		p.lifeS = 0.5;
		p.playAnimAndKill(A.tiles, D.tiles.fxDuster, rnd(0.3, 0.4));
	}

	public inline function lazer(x:Float, y:Float, dr:Int = 1, dst:Float = 200, ?s:Float = 0.2, ?color:Col = 0xf58500, ?angle:Float = 0.0) {
		var pi = allocBg_add(D.tiles.fxLazerImpact, x, y);
		pi.scaleX = (angle < 0 ? 1 : -1);
		pi.setFadeS(1, 0.01, 0.01);
		pi.lifeS = s;
		pi.rotation = angle;

		var p = allocBg_add(D.tiles.fxLazer, x, y);
		p.setCenterRatio(1, 0.5);
		// p.scaleX = -(angle<0?1:-1);
		p.scaleX *= -((dst - 16) / 16);
		p.setFadeS(1, 0.01, 0.01);
		p.lifeS = s;
		p.scaleY = rnd(0.8, 1.2, false);
		p.rotation = angle;
		if (dst <= 2) {
			p.remove();
		}

		pi.playAnimLoop(A.tiles, D.tiles.fxLazerImpact, rnd(0.06, 0.8));
		var pit = allocMain_add(D.tiles.fxLazerImpact, x + (dst - 16) * Math.cos(angle), y + (dst - 16) * Math.sin(angle));
		pit.playAnimLoop(A.tiles, D.tiles.fxLazerImpact, rnd(0.06, 0.8));
		pit.randomizeAnimCursor();
		pit.scaleX = -1; // (angle<0?1:-1);
		pit.setFadeS(1, 0.01, 0.01);
		pit.lifeS = s;
		pit.rotation = angle;
		pit.onUpdate = _lazerPhysics;
	}

	function _lazerPhysics(p:HParticle) {
		if (collides(p)) {
			p.scaleY = rnd(0.8, 1.2, false);
		}
		if (rnd(0, 3) < 2)
			explosion(p.x, p.y, 1, 0xff0000, 1);
	}

	public inline function crap(x:Float, y:Float, col:Col = 0x882200, dir = -1) {
		var n = irnd(5, 20);
		for (i in 0...n) {
			var p = allocMain_normal(D.tiles.fxDirt2, x, y);
			p.colorize(col, rnd(0, 1));
			p.colorAnimS(col, 0x4B1204, rnd(0.6, 3));
			p.dx = 0.75 * rnd(-2, 2);
			p.dy = dir * rnd(0.5, 2);
			p.gy = 0.15;
			p.lifeS = 2;
			p.dr = rnd(0.1, 0.4, true);
			// p.frict = rnd(0.99, 0.99);
			p.setScale(rnd(0.1, 2));
			p.delayS = i * 0.02 * rnd(0., 0.1, true);
			p.onUpdate = _emberPhysics;
		}
	}

	public inline function waterFlow(x:Float, y:Float, col:Col = 0x004cff, dirY:Float = -1) {
		var n = irnd(1, 5);
		for (i in 0...n) {
			var p = allocMain_add(D.tiles.fxDot0, x, y);
			p.colorize(col, rnd(0, 1));
			p.colorAnimS(col, 0x0ADCFC, rnd(0.6, 3));
			p.dx = 0.75 * rnd(-2, 2);
			p.dy = dirY * rnd(0.5, 2);
			p.gy = 0.1;
			p.lifeS = 6;
			p.dr = rnd(0.1, 0.4, true);
			// p.frict = rnd(0.99, 0.99);
			p.setScale(rnd(0.1, 2));
			p.delayS = i * 0.02 * rnd(0., 0.1, true);
			p.data0 = p.x;
			p.data1 = p.y;
			p.onUpdate = _waterFlowPhysics;
			/*p.groundY=y;
				p.onTouchGround=function(o:HParticle){
					o.dy*=-1;
					o.dx=rnd(-0.5,0.5);
			}*/
		}
	}

	public inline function embers(x:Float, y:Float, col:Col = 0xff5500, dirY:Float = -1) {
		var n = irnd(5, 10);
		for (i in 0...n) {
			var p = allocMain_add(D.tiles.fxDot0, x, y);
			p.colorize(col, rnd(0, 1));
			p.colorAnimS(col, 0xF1F65B, rnd(0.6, 3));
			p.dx = 0.75 * rnd(-2, 2);
			p.dy = dirY * rnd(0.5, 2);
			p.gy = 0.1;
			p.lifeS = 2;
			p.data0 = p.x;
			p.data1 = p.y;
			p.dr = rnd(0.1, 0.4, true);
			// p.frict = rnd(0.99, 0.99);
			p.setScale(rnd(0.1, 2));
			p.delayS = i * 0.02 * rnd(0., 0.1, true);
			p.onUpdate = _emberPhysics;
			/*p.groundY=y;
				p.onTouchGround=function(o:HParticle){
					o.dy*=-1;
					o.dx=rnd(-0.5,0.5);
			}*/
		}
	}

	function _emberPhysics(p:HParticle) {
		p.rotation = Math.atan2(p.y - p.data1, p.x - p.data0);
		p.scaleX = Math.abs(p.dy) * 0.15 * M.dist(p.x, p.y, p.data0, p.data1);
		if (collides(p)) {
			p.dx *= Math.pow(rnd(0.8, 0.9), tmod);
			p.dy = 0;
			p.gy = 0;
			p.dr *= Math.pow(0.8, tmod);
			p.lifeS = 0.5;
		}
		if (!collides(p) && (collides(p, 1, 0) || collides(p, -1, 0))) {
			p.dx = -p.dx * 0.35;
			p.dr *= -1;
		}
		if (!collides(p) && (collides(p, 0, 1) || collides(p, 0, -1))) {
			p.dy = -Math.abs(p.dy) * 0.35;
		}
		p.data0 = p.x;
		p.data1 = p.y;
	}

	function _waterFlowPhysics(p:HParticle) {
		p.rotation = Math.atan2(p.y - p.data1, p.x - p.data0);
		p.scaleX = Math.abs(p.dy) * 0.5 * M.dist(p.x, p.y, p.data0, p.data1);
		if (collides(p)) {
			p.dx *= Math.pow(rnd(0.8, 0.9), tmod);
			p.dy = 0;
			p.gy = 0;
			p.dr *= Math.pow(0.8, tmod);
			p.lifeS = 1.5;
		}
		if (!collides(p) && (collides(p, 1, 0) || collides(p, -1, 0))) {
			p.dx = -p.dx * 0.35;
			p.dr *= -1;
		}
		if (!collides(p) && (collides(p, 0, 1) || collides(p, 0, -1))) {
			p.lifeS = 1.5;
			p.dy = -Math.abs(p.dy) * 0.35;
			if(!level.hasCollision(Std.int(p.x/Const.GRID),Std.int((p.y)/Const.GRID))){
				if(level.waterMarks.has(WaterLevel,Std.int(p.x/Const.GRID),Std.int((p.y)/Const.GRID))){
					var count=level.levelWaterCountMap.get(level.coordId(Std.int(p.x/Const.GRID),Std.int((p.y)/Const.GRID)));
					count+=0.6;
					count=M.fmin(17,count);

					level.levelWaterCountMap.set(level.coordId(Std.int(p.x/Const.GRID),Std.int((p.y)/Const.GRID)),count);
					count=null;

				}else{
					level.waterMarks.set(WaterLevel,Std.int(p.x/Const.GRID),Std.int((p.y)/Const.GRID));
				}
				
			}
		}
		p.data0 = p.x;
		p.data1 = p.y;
	}

	public inline function starField(x:Float, y:Float, col:Col = 0x004cff, dirY:Float = -1) {
		var n = irnd(1, 10);
		for (i in 0...n) {
			var p = allocBg_add(D.tiles.fxDot0, x, y);
			p.colorize(col, rnd(0, 1));
			p.colorAnimS(col, 0x0ADCFC, rnd(0.6, 3));
			var rand=rnd(0,360);
			var speed=rnd(0.1,10);
			p.dx = speed*Math.cos(rand);
			p.dy = speed*Math.sin(rand);
			p.gy = 0.0;
			p.lifeS = 0.15;
			//p.dr = rnd(0.1, 0.4, true);
			// p.frict = rnd(0.99, 0.99);
			p.setScale(rnd(0.1, 2));
			p.delayS = i * 0.02 * rnd(0., 0.1, true);
			p.data0 = p.x;
			p.data1 = p.y;
			p.onUpdate = _starFieldPhysics;
			/*p.groundY=y;
				p.onTouchGround=function(o:HParticle){
					o.dy*=-1;
					o.dx=rnd(-0.5,0.5);
			}*/
		}
	}
	function _starFieldPhysics(p:HParticle) {
		p.rotation = Math.atan2(p.y - p.data1, p.x - p.data0);
		p.scaleX = Math.abs(p.dy) * 10 * M.dist(p.x, p.y, p.data0, p.data1);
		p.data0 = p.x;
		p.data1 = p.y;
	}
	public inline function flame(x:Float, y:Float, color:Col = 0xf58500) {
		var p = allocMain_add(D.tiles.fxFlame, x, y);
		p.scale = rnd(0.1, 1);
		p.alpha = rnd(0.1, 1);
		p.setFadeS(0.7, rnd(0.1, 2), 0.1);
		p.lifeS = rnd(0.1, 2);
		p.colorize(color);
		p.colorAnimS(color, 0xFC3333, rnd(0.6, 3));
		p.playAnimLoop(A.tiles, D.tiles.fxFlame, rnd(0.6, 1.8));
		if (rnd(0, 10) > 7) {
			if (App.ME.options.shaders == true) {
				heat(x, y, 0.5);
			}
			embers(x, y);
		};
	}

	public inline function burnOut(x:Float, y:Float, ang:Float = 0.0, dir:Int) {
		var p = allocMain_normal(D.tiles.fxBurnOut, x - dir * 8, y);
		p.rotation = ang < 0 ? ang : -ang; // (ang/180*M.PI)*-dir;
		p.scale = 1; // rnd(0.1,0.5);

		p.scaleY = dir;
		p.lifeS = 0.8;
		p.playAnimAndKill(A.tiles, D.tiles.fxBurnOut, rnd(0.6, 0.9));
	}

	public inline function fallDust(x:Float, y:Float, ang:Float = 0.0, dir:Int) {
		var p = allocMain_add(D.tiles.fxDuster, x, y);
		p.rotation = (ang / 180 * M.PI) * -dir;
		p.scale = 0.5;
		p.lifeS = 0.4;
		p.playAnimAndKill(A.tiles, D.tiles.fxDuster, rnd(0.3, 0.4));
	}

	public inline function cloud(x:Float, y:Float, ang:Float = 0.0, dir:Int = 0) {
		var p = allocMain_normal(D.tiles.cloud1, x, y);
		p.rotation = (ang / 180 * M.PI) * -dir;
		p.scale = 0.5;
		p.alpha = 0.01;
		// p.lifeS = 0.4;
		p.gx = rnd(-0.02, 0.02);
		p.gy = rnd(-0.02,0.02); // gravity Y (added on each frame)
		p.lifeS = rnd(2, 3);
		p.setFadeS(0.1, rnd(0.1, 2), 0.1);
	}

	/** bubbles **/
	public inline function bubbles(x:Float, y:Float, ?color:UInt = 0xA6EDF5, maxY:Float, ?size:Float = 0.5) {
		for (i in 0...1) {
			var p;
			p = allocFront_add(D.tiles.bubble1, x, y);

			var yy = y;
			p.scale = rnd(0.1, 1);
			p.alpha = rnd(0.1, 0.5);
			p.colorize(color, 0.5);

			// p.colorAnimS(color, 0xffffff, 0.1); // fade particle color from given color to some purple
			// p.fadeIn(0.5, 2);
			p.frict = 0; // friction applied to velocities
			var vy = rnd(0.25, 0.65);
			p.gy = -vy; // gravity Y (added on each frame)
			// p.lifeS = 1.5; // life time in seconds
			p.dx = rnd(0.05, -0.05, true);
			p.dy = -0.2;
			p.gx = p.dx;
			tw.createS(p.a, 0, TLinear, 3).update(function() {
				if (p.y < maxY) {
					// trace("adios amigos, so looong");
					p.kill();
				}
			}).end(p.kill);
		}
	}

	/** sploutch sploutch**/
	public inline function sploutch(x:Float, y:Float, force:Float = 1.0, ?color:UInt = 0xffffff) {
		var p = allocFront_add(D.tiles.pixel, x, y);
		p.scale = rnd(1, 4);
		p.colorAnimS(color, 0x2adfff, 0.1);
		p.gy = 0.5;
		p.frict = 0.9;
		p.dx = rnd(-0.5, 0.5, true) * force;
		p.dy = -force * rnd(0.1, 1.25);
		p.setFadeS(0.8, 0.1, 0.1);
		p.lifeS = 2;
		p.onUpdate = function(p:HParticle) {
			if (collides(p) || p.y > y + 6) {
				p.remove();
			}
		}
	}

	public inline function waveSplash(x:Float, y:Float, up:Bool = true, ?col:Col = 0x0436ff) {
		var p = allocMain_add(D.tiles.waveSplash, x, y);
		p.colorize(col, rnd(0, 1));
		p.colorAnimS(col, 0xFDFDF2, rnd(0.6, 3));
		p.lifeS = 0.3;
		p.setFadeS(0.8, 0.01, 0.2);
		p.gy = 0;
		p.x = x;
		p.y = y + 8;
		p.scaleY *= rnd(1, 2);
		p.scaleYMul = 1.02;
		p.scaleXMul = 0.98;
		if (up) {
			p.y -= 16;
			p.scaleY *= -1;
		}
	}

	public inline function splash(x:Float, y:Float, ?grdY:Float = null, ?force:Float = 1.0, ?col:Col = 0x0436ff) {
		var n = irnd(50, 200);
		for (i in 0...n) {
			var p = allocMain_add(D.tiles.fxDot0, x, y);
			p.colorize(col, rnd(0, 1));
			p.colorAnimS(col, 0xFDFDF2, rnd(0.6, 3));
			p.dx = 0.75 * rnd(-2, 2);
			p.dy = -rnd(0.5, 2.8);
			p.gy = 0.1;
			p.lifeS = 4;
			// p.dr = rnd(0.1, 0.4, true);
			// p.frict = rnd(0.99, 0.99);
			p.setScale(rnd(0.1, 2));
			p.delayS = i * 0.02 * rnd(0., 0.1, true);
			p.onUpdate = _emberPhysics;
			if (grdY != null) {
				p.groundY = grdY; //*Const.SCALE;
				p.onTouchGround = function(p:HParticle) {
					p.dy = 0;
					p.dx *= 0.5;
					if (M.fabs(p.dx) <= 0.01) {
						p.kill();
					}
				}
			} else {}
		}
	}

	/** waves **/
	public inline function waves(x:Float, y:Float, startX:Float, endX:Float, ?color:UInt = 0x1C929F, maxY:Float, ?size:Float = 0.5) {
		for (i in 0...1) {
			var p;
			var r = irnd(0, 2);
			if (r == 0) {
				p = allocFront_add(D.tiles.wave0, x, y);
			} else if (r == 1) {
				p = allocFront_add(D.tiles.wave1, x, y);
			} else {
				p = allocFront_add(D.tiles.wave2, x, y);
			}
			if (rnd(0, 100) < 60) {
				var p1;
				if (x > endX - 8) {
					p1 = allocFront_add(D.tiles.waveBorderTop, endX, y);
					p1.scale = 0.5;
					p1.scaleX = 1;
					p1.setFadeS(0.3, 0.1, 0.1);
					p1.lifeS = 0.15;
					p1.x -= 3;
					p1.y += 4 + Math.sin(hxd.Timer.frameCount * 0.1 + p1.x / 180 * 3.1416 * 6) * 2;
				} else if (x < startX + 8) {
					p1 = allocFront_add(D.tiles.waveBorderTop, startX, y);
					p1.scale = 0.5;
					p1.scaleX = -1;
					p1.x += 3;
					p1.setFadeS(0.1, 0.1, 0.05);
					p1.lifeS = 0.15;
					p1.y += 4 + Math.sin(hxd.Timer.frameCount * 0.1 + p1.x / 180 * 3.1416 * 6) * 2;
				}
			}
			p.y += 4 + Math.sin(hxd.Timer.frameCount * 0.1 + p.x / 180 * 3.1416 * 6) * 2;
			var yy = y;
			p.scale = 0.5; // rnd(0.5, 1);
			p.alpha = rnd(0.2, 0.9);
			p.colorize(color, rnd(0.2, 0.9));
			p.setFadeS(0.3, 0.1, 0.1);
			// p.colorAnimS(color, 0xffffff, 0.1); // fade particle color from given color to some purple
			p.frict = 0; // friction applied to velocities
			var vy = rnd(0.1, 0.25);
			p.gy = 0; // gravity Y (added on each frame)
			p.lifeS = 0.15; // life time in seconds
			p.dx = 0;
			p.dy = 0;
			p.gx = 0;
			/*tw.createS(p.a,0,TLinear,4).update(function(){
				if(p.y<maxY-4){p.remove();}
			}).end(p.remove);*/
		}
	}

	// snow
	public inline function snow(x:Float, y:Float,wind:{x:Float,y:Float}, ?color:UInt = 0xD1F1F4, ?front:Bool = true, ?size:Float = 0.5) {
		for (i in 0...1) {
			var p;
			if (front == false) {
				p = allocBg_add(D.tiles.fxFlake0, x, y);
			} else {
				p = allocMain_add(D.tiles.fxFlake1, x, y);
			}

			p.alpha = rnd(0.1, 1);
			p.colorize(color, 1);
			// p.scaleMul=0.99;
			p.scale = rnd(0.01, 0.35);
			p.rotation = rnd(0, 180);
			// p.colorAnimS(color, 0xffffff, 0.1); // fade particle color from given color to some purple
			// p.fadeIn(0.5,1);
			p.frict = rnd(0,0.9); // friction applied to velocities
			var vy = rnd(0.25, 1);
			p.gy = vy; // gravity Y (added on each frame)
			var vx = wind.x+rnd(-0.2, 0.2, true);
			p.lifeS = 5; // life time in seconds
			p.setFadeS(0.9, 0.1, 0.5);
			p.dx = vx;
			p.gx = vx;
			p.dy = 0.2;
			p.onUpdate=function(p){
				p.dx=p.gx=-wind.x*50;
			}
			// p.scaleY = vy;
			// p.autoRotate(vy*0.05);

			/*tw.createS(p.a,0,TLinear,4).update(function(){
				if(collides(p) && p.y>36){p.remove();}
			}).end(p.remove);*/
		}
	}

	public inline function explosion(x:Float, y:Float, dir:Int, color:Col, n:Int = 12) {
		for (i in 0...n) {
			var d = rnd(0, 20);
			var a = rnd(0, M.PI2);
			var p = allocBg_normal(D.tiles.fxExplo, x + Math.cos(a) * d, y + Math.sin(a) * d);
			p.alpha = rnd(0.8, 1);
			p.playAnimAndKill(A.tiles, D.tiles.fxExplo, rnd(0.3, 0.8));
			p.dx = 0.1 * dir * rnd(1, 3);
			p.frict = rnd(0.9, 0.94);
			p.setScale(rnd(0.2, 1));
			// p.scaleX=i%2==0?1:-1;
			p.delayS = i * 0.02 + rnd(0., 0.1, true);
		}
	}

	public inline function eye(ent:sample.SamplePlayer, x:Float, y:Float, n:Int = 12, dir:Int = 1, color:Col = 0xffffff) {
		for (i in 0...n) {
			var d = i;
			var a = (M.PI2 / (n + 1)) * i;
			var p = allocBg_normal(D.tiles.fxEye, x + Math.cos(a) * d, y + Math.sin(a) * d);
			p.lifeS = 10;
			p.playAnimLoop(A.tiles, D.tiles.fxEye, rnd(0.5, 1.5));
			p.dx = Math.cos(a) * 2.2;
			p.dy = Math.sin(a) * 2.2;
			p.dr = rnd(0, 0.5, true);
			p.frict = 0.9994;
			p.alpha = 0.8;
			p.scaleX = dir;
			p.setScale(rnd(0.5, 1));

			p.delayS = 0.1;
			p.onUpdate = function(p) {
				if (collides(p)) {
					explosion(p.x, p.y, 1, Col.inlineHex("0xffffff"), 4);
					p.remove();
					p.onUpdate = null;
				} else if (hitsPlayer(p)) {
					explosion(p.x, p.y, 1, Col.inlineHex("0xffffff"), 4);

					if (game.player.life > 1) {
						game.player.hit(1, game.player);
					} else {
						game.player.cd.setS('playerMustDie', 0.1);
						new sample.Bullet(Std.int(x / Const.GRID), Std.int(x / Const.GRID), game.player.dir, game.player);
						p.onUpdate = null;
					}
					p.remove();
				} else if (hitBullet(p)) {
					explosion(p.x, p.y, 1, Col.inlineHex("0xffffff"), 4);

					p.remove();
					p.onUpdate = null;
				}
			}
		}
	}

	function hitBullet(p:HParticle) {
		if (game == null)
			return false;
		for (b in sample.Bullet.ALL) {
			if (p.x > b.left && p.x < b.right && p.y < b.bottom && p.y > b.top) {
				b.fade();
				return true;
			}
		}
		return false;
	}

	function hitsPlayer(p:HParticle) {
		if (game == null) {
			return false;
		}
		return p.x > game.player.left && p.x < game.player.right && p.y < game.player.bottom && p.y > game.player.top;
	}

	override function update() {
		super.update();
		pool.update(game.tmod);
	}
}
