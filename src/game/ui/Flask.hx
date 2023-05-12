package ui;

import h2d.Bitmap;

class Flask extends h2d.Object{

    var canvas:h2d.SpriteBatch;
    var flask:h2d.Bitmap;
    var liquidTile:h2d.Tile;
    var liquid:h2d.Bitmap;
    public inline function clamp(value:Float, min:Float, max:Float):Float {
		if(value < min)
			return min;
		else if(value > max)
			return max;
		else return value;
	}
    public function new(x:Float=0,y:Float=0,?p:h2d.Object){
        super(p);
        this.x=x;
        this.y=y;
        liquidTile = Assets.tiles.getTile(D.tiles.liquid);
        liquid =  new Bitmap(liquidTile);
        this.addChild(liquid);
        flask= new Bitmap(Assets.tiles.getTile(D.tiles.flask));
        this.addChild(flask);
    }
    public function refresh(health:Float,maxHealth:Float){
        health=(health/maxHealth)*48;
        liquid.tile = liquidTile.sub(0, 48 - health, 48, health, 0,48-health);
    }
}