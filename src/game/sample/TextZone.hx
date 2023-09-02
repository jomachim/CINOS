package sample;

import GameStats.Achievement;

class TextZone extends Entity {
	public static var ALL:Array<TextZone> = [];

	public var actionString:String;
	public var done:Bool = false;
	public var countDown:Int = 10;
	public var iid:String;
	public var data:Entity_TextZone;
	public var splashfx:dn.heaps.Sfx;

	// public var collides:Bool = false;
	var collides(get, never):Bool;

	inline function get_collides()
		return game.player.cx >= cx && game.player.cx <= cx + wid / 16 && game.player.cy >= cy && game.player.cy <= cy + hei / 16;

	var canBreath(get, never):Bool;

	inline function get_canBreath()
		return game.player.cy + game.player.yr < cy + 1 + 0.5;

	public var entered:Bool;
	public var textColor:Col;
	public var label:h2d.Text;

	public function new(d:Entity_TextZone) {
		super(0, 0);
		ALL.push(this);
		data = d;
		iid = d.iid;
		entered = false;
		textColor = Col.fromInt(d.f_color_int);
		setPosPixel(d.pixelX, d.pixelY);
		pivotX = 0.5;
		pivotY = 0.5;
		var label = new h2d.Text(Assets.fontPixel);
		
		label.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0x272727,
			alpha: 0.8
		};
		label.text=data.f_corpus;
		label.textColor=data.f_color_int;
		label.textAlign=Center;
		label.filter = new h2d.filter.Group([new dn.heaps.filter.PixelOutline(textColor, 0.8)]);//new h2d.filter.Glow(textColor,0.7,0.5,0.5,3),
		spr.set("empty");
		//spr.alpha = 0.75;
		game.scroller.over(spr);
		var g = new h2d.Graphics(spr);
		wid = d.width;
		hei = d.height;
		label.y = hei*0.5;
		label.x = wid*0.5;
		#if debug
		#end
		g.beginFill(textColor, 0.25);
		g.drawRect(0, 0, wid, hei);
		g.alpha=0.75;
		g.filter = new dn.heaps.filter.PixelOutline(textColor, 0.8);//new h2d.filter.Blur(2, 1.5, 3);
		splashfx = S.splash01();

		spr.addChild(label);
	}

	override function fixedUpdate() {
		if (collides && entered == false) {
			entered = true;
		}
		if (collides && entered == true) {
			cd.setMs('isOnText', 100);
		} else if (entered == true) {
			entered = false;
		}
	}
}
