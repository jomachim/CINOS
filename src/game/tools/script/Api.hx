package tools.script;
import Game;
/**
	Everything in this class will be available in HScript execution context.
**/
@:keep
class Api {
	public var levelWid(get,never) : Int; inline function get_levelWid() return Game.ME.level.pxWid;
	public var levelHei(get,never) : Int; inline function get_levelHei() return Game.ME.level.pxHei;
	public var game(get,never):Game; inline function get_game() return Game.ME;
	public var app(get,never):App; inline function get_app() return App.ME;
	public var fx(get,never):Fx; inline function get_fx() return Game.ME.fx;
	public function playTuto(){
		Game.ME.playTutorial();
	}
	public function kaboom(x:Float,y:Float){
		Game.ME.fx.explosion(x,y,0xff8800,24);
		Game.ME.fx.flashBangS(0x00ff00,0.8,0.5);
	}
	public function new() {}
}