package sample;

import GameStats.Achievement;

class Door extends Entity {
	public static var ALL:Array<Door> = [];

	public var actionString:String;
	public var done:Bool = false;
    public var data:Entity_Door;
	// public var collides:Bool = false;
	
	public var activated:Bool;
    public var locked:Bool;

    override function dispose(){
        super.dispose();
        ALL.remove(this);
    }

	public function collides(p:Dynamic):Bool{
		if (game.player.attachX+12 >= left 
			&& game.player.attachX-12 <= right 
			&& game.player.attachY>=top 
			&& game.player.attachY<=bottom ){
				//trace("collision");
				return true;
			}else{return false;}
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
		//if(!activated){trace("THIS EXIT IS LOCKED");}
		setPosPixel(d.pixelX, d.pixelY-hei);//
		pivotX = 0.5;
		pivotY = 0;
		spr.set(D.tiles.closedDoor);
		var g = new h2d.Graphics(spr);
		if (game.gameStats.has(data.iid+"activated")) {
			activated=true;	
		}
		#if debug
		g.beginFill(0x00ff00, 0.25);
		g.drawRect(0, 0, wid, hei);
		#end
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if(activated==false && collides(game.player)){
			blink(0xff0000);
			game.player.v.dx=0;
            game.player.bump(game.player.dir*-0.2,-0.05);
		}
		if(activated==false){
			spr.set(D.tiles.closedDoor);
		}else if(activated==true){
			spr.set(D.tiles.openedDoor);
		}
	}
}
