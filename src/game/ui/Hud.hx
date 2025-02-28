package ui;

class Hud extends GameChildProcess {
	var timeBarCol : Col = "#94b0c2";
	var flow : h2d.Flow;
	var invalidated = true;
	var notifications : Array<h2d.Flow> = [];
	var notifTw : dn.Tweenie;
	var healthFlaskFlow : h2d.Flow;
	var timeFlow : h2d.Flow;
	var timeBar : ui.Bar;
	var lifeBar : ui.IconBar;
	public var healthFlask:ui.Flask;
	var timeS = 0.;
	var debugText : h2d.Text;

	public var miniMap:MiniMap;

	public function new() {
		super();

		notifTw = new Tweenie(Const.FPS);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 1;
		notifications = [];

		debugText = new h2d.Text(Assets.fontPixel, root);
		debugText.filter = new dn.heaps.filter.PixelOutline();
		clearDebug();

		lifeBar = new ui.IconBar(flow);
		lifeBar.overlap = 0;
		lifeBar.scale(1);

		timeFlow = new h2d.Flow(flow);
		timeFlow.verticalAlign = Middle;
		Assets.tiles.getBitmap(D.tiles.iconTime,timeFlow);
		timeBar = new Bar(40,4, timeBarCol, timeFlow);
		
		healthFlaskFlow = new h2d.Flow(root);
		healthFlask = new Flask(64,64,healthFlaskFlow);
		healthFlaskFlow.layout = Vertical;
		healthFlask.scale(1);
		healthFlaskFlow.padding=16;
		healthFlaskFlow.verticalAlign = Bottom;
		healthFlaskFlow.horizontalAlign = Left;

		

	}
	public inline function setTimeS(t:Float) {
		timeFlow.alpha = t>=0 ? 1 : 0;
		timeBar.set(t, Const.CYCLE_S);
		timeS = t;
		if( Const.CYCLE_S-t<=2 )
			timeBar.color = Yellow;
		else
			timeBar.color = timeBarCol;
	}
	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		flow.x = Std.int( 0.5 * stageWid/Const.UI_SCALE - flow.outerWidth*0.5 );
		flow.y = 1;
	}

	public function setLife(n,max) {
		lifeBar.empty();
		lifeBar.addIcons(D.tiles.iconHudHealth, n);
		lifeBar.addIcons(D.tiles.iconHudHealthOff, max-n);
	}


	/** Clear debug printing **/
	public inline function clearDebug() {
		debugText.text = "";
		debugText.visible = false;
	}

	/** Display a debug string **/
	public inline function debug(v:Dynamic, clear=true) {
		if( clear )
			debugText.text = Std.string(v);
		else
			debugText.text += "\n"+v;
		debugText.visible = true;
		debugText.x = Std.int( stageWid/Const.UI_SCALE - 4 - debugText.textWidth );
	}


	/** Pop a quick s in the corner **/
	public function notify(str:String, color:Col=0x0) {
		// Bg
		var t = Assets.tiles.getTile( D.tiles.uiNotification );
		var f = new dn.heaps.FlowBg(t, 5, root);
		f.colorizeBg(color);
		f.paddingHorizontal = 6;
		f.paddingBottom = 4;
		f.paddingTop = 0;
		f.paddingLeft = 9;
		f.y = 4;

		// Text
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = str;
		tf.maxWidth = 0.6 * stageWid/Const.UI_SCALE;
		tf.textColor = 0xffffff;
		tf.filter = new dn.heaps.filter.PixelOutline( color.toBlack(0.2) );

		// Notification lifetime
		var durationS = 2 + str.length*0.04;
		var p = createChildProcess();
		notifications.insert(0,f);
		p.tw.createS(f.x, -f.outerWidth>-2, TEaseOut, 0.1);
		p.onUpdateCb = ()->{
			if( p.stime>=durationS && !p.cd.hasSetS("done",Const.INFINITY) )
				p.tw.createS(f.x, -f.outerWidth, 0.2).end( p.destroy );
		}
		p.onDisposeCb = ()->{
			notifications.remove(f);
			f.remove();
		}

		// Move existing notifications
		var y = 4;
		for(f in notifications) {
			notifTw.terminateWithoutCallbacks(f.y);
			notifTw.createS(f.y, y, TEaseOut, 0.2);
			y+=f.outerHeight+1;
		}

	}

	public inline function invalidate() invalidated = true;

	function render() {}

	public function onLevelStart() {}

	override function preUpdate() {
		super.preUpdate();
		notifTw.update(tmod);
		
	}

	override function postUpdate() {
		super.postUpdate();
		var remainS = Const.CYCLE_S-timeS;
		if( remainS<=2 && !cd.hasSetS("timeBlink",0.25) )
			timeBar.blink(White);

		if( remainS<=4 && !cd.hasSetS("timeBlink",0.5) )
			timeBar.blink(White);
		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
