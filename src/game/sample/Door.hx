package sample;

import GameStats.Achievement;

class Door extends Entity {
	public static var ALL:Array<Door> = [];

	public var actionString:String;
	public var done:Bool = false;
	public var data:Entity_Door;
	//public var tw:dn.Tweenie;

	// public var collides:Bool = false;
	public var activated:Bool;
	public var locked:Bool;

	var scaled:Bool = false;
	var opened:Bool = false;

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function collides(p:Dynamic):Bool {
		if (game.player.right >= left - 4 && game.player.left <= right + 4 && game.player.bottom >= top - 8 && game.player.top <= bottom + 8) {
			// trace("collision");
			return true;
		} else {
			return false;
		}
	}

	public function new(d:Entity_Door) {
		super(0, 0);
		ALL.push(this);
		data = d;
		activated = d.f_activated;
		done = false;
		locked = d.f_locked;
		wid = d.width;
		hei = d.height;
		//tw = new Tweenie(Const.FPS);
		// if(!activated){trace("THIS EXIT IS LOCKED");}
		setPosPixel(d.pixelX-wid*0.5, d.pixelY - hei); //
		pivotX = 0;
		pivotY = 0;
		spr.set(D.tiles.closedDoor);
		level.breakables.set(Door, cx, cy);
		level.breakables.set(Door, cx, cy + 1);
		level.breakables.set(Door, cx, cy + 2);
		var g = new h2d.Graphics(spr);
		if (game.gameStats.has(data.iid + "activated")) {
			//trace('this door has been already openned !');
			activated = true;
		}
		#if debug
		/*g.beginFill(0x00ff00, 0.25);
		g.drawRect(0, 0, wid, hei);*/
		#end
	}
	public function closeDoor(){
		activated=false;
		locked=true;
		opened=false;

		spr.set(D.tiles.closedDoor);
		level.breakables.set(Door, cx, cy);
		level.breakables.set(Door, cx, cy + 1);
		level.breakables.set(Door, cx, cy + 2);
		scaled=false;
		S.doorClose01().play(false,App.ME.options.volume).pitchRandomly(0.64);

	}
	override function fixedUpdate() {
		super.fixedUpdate();
		if (activated == false && collides(game.player)) {
			blink(0xff0000);
			/*if(game.player.centerX<centerX){
				game.player.setPosX(centerX-24);
			}
			if(game.player.centerX>centerX){
				game.player.setPosX(centerX+24);
			}
			game.player.v.dx = 0;*/
			//game.player.bump(game.player.dir * -0.05, -0.05);
		}
		if (activated == false && !opened) {
			opened = true;
			spr.set(D.tiles.closedDoor);
			S.open01().play(false,App.ME.options.volume).pitchRandomly(0.64);
		} else if (activated == true && !scaled) {
			spr.set(D.tiles.openedDoor);
			scaled = true;
			level.breakables.remove(Door, cx, cy);
			level.breakables.remove(Door, cx, cy + 1);
			level.breakables.remove(Door, cx, cy + 2);
			sprScaleX=0.5;
			cd.setS('opening',0.5);
			//tw.createS(sprScaleX, 1, TLinear, 2.5);
			
		}
		if(cd.has('opening')){
			sprScaleX=M.fmax(0.5,1-cd.getRatio('opening'));
		}
	}
}
