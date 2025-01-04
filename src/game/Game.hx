import sample.Fish;
import dn.heaps.filter.Crt;
import sample.Rat;
import page.InventoryPage;
import sample.Chest;
import sample.Bat;
import h2d.Scene;
import hxsl.Types.Vec;
import sample.Door;
import sample.Computer;
import sample.Swirl;
import ldtk.Json.ProjectJson;
import Meteo;
#if hl
import sys.io.File;
#end
import haxe.Json;
import ldtk.Project;
import h2d.Bitmap;
import hxd.res.Resource;
import dn.heaps.filter.Monochrome;
import h2d.filter.Bloom;
import dn.heaps.filter.MotionBlur;
import sample.Platform;
import h3d.Vector;
import sample.NormalShader;
import h2d.filter.Glow;
import h2d.Tile;
import h2d.Flow;
import sample.SimpleShader;
import sample.Mob;
import sample.Light;
import sample.Jem;
import sample.Portal;
import sample.Boss;
import sample.Breakable;
import sample.Craft;
import sample.Flower;
import GameStats;
import eng.GC;
import ui.MiniMap;
import dn.Delayer;
import Internet;

typedef Savable = {
	var niveau:Int;
	var currentLevel:String;
}

typedef Score = {
	var name:String;
	var score:Int;
	var ip:String;
}

typedef HighScoreData = {
	var scores:Array<Score>;
}


class Game extends AppChildProcess {
	public static var ME:Game;

	public var httpInstance:haxe.Http;

	/** hscript parser **/
	public var hsParser:hscript.Parser = new hscript.Parser();

	public var hsInterp:hscript.Interp = new hscript.Interp();

	/** Game controller (pad or keyboard) **/
	public var ca:ControllerAccess<GameAction>;

	public var ca2:ControllerAccess<GameAction>;

	public var baseZoom:Float = 0.5;

	/** Particles **/
	public var fx:Fx;

	public var normalTexture:h3d.mat.Texture;
	public var colorTexture:h3d.mat.Texture;

	/** Basic viewport control **/
	public var camera:Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var fog:sample.FogFilter;
	public var scroller:h2d.Layers;
	public var globalWind:Vector;

	public var frontScroller:h2d.Layers;
	public var parallaxScroller:h2d.Layers;
	public var displaceLayer:h2d.Layers;
	public var fxScene:h2d.Scene;

	public var waterGraphics:h2d.Graphics;

	public var chrono:h2d.Text;
	public var chronometre:String;
	public var miniMap:MiniMap;

	/** Level data **/
	public var level:Level;

	/** UI **/
	public var hud:ui.Hud;

	/** Cinamtics **/
	var cm:dn.Cinematic;

	/** METEO **/
	public var meteo:Meteo;

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;

	var slowMos:Map<SlowMoId, {id:SlowMoId, t:Float, f:Float}> = new Map();

	public var gameTimeS = 0.;

	/** GameStats Achievements **/
	public var gameStats:GameStats = new GameStats();

	/** player **/
	public var player:sample.SamplePlayer;

	public var normalShader:NormalShader;
	public var motionBlur:MotionBlur;
	public var tile:h2d.Bitmap;

	public var currentFrame:Int = 0;
	public var currentLevel:String;
	public var currentWorld:String;
	public var currentLevelIdentifyer:String;
	public var currentWorldIdentifyer:String;

	public var healthFlask:ui.Flask;
	public var crafts:Array<String>;
	public var muz:dn.heaps.Sfx;
	public var highscore:Array<haxe.DynamicAccess<Dynamic>> = [];

	public function new() {
		super();

		ME = this;
		chronometre = "";
		globalWind=new Vector();
		Internet.getHighScore();

		/*var req = new Http( "http://myserver.com/api/userinfo/" );
			req.setParameter( "userID", "34" );
			req.setParameter( "includeFriendList", "true" );
			req.request( false ); // false=GET, true=POST */

		ca = App.ME.controller.createAccess();
		ca.lockCondition = isGameControllerLocked;
		ca2 = App.ME.controller.createAccess();
		ca2.lockCondition = isGameControllerLocked;

		normalTexture = new h3d.mat.Texture(engine.width, engine.height, [Target]);
		colorTexture = new h3d.mat.Texture(engine.width, engine.height, [Target]);

		// createRootInLayers(App.ME.root, Const.DP_BG);
		dn.Gc.runNow();
		cm = new dn.Cinematic(Const.FPS);
		meteo = new Meteo();
		scroller = new h2d.Layers();
		frontScroller = new h2d.Layers();
		parallaxScroller = new h2d.Layers();
		displaceLayer = new h2d.Layers();
		fxScene = new h2d.Scene();
		Const.timeAccumulator = 0;
		root.add(parallaxScroller, Const.DP_BG);
		root.add(scroller, Const.DP_BG);
		waterGraphics = new h2d.Graphics();
		scroller.add(frontScroller, Const.DP_FRONT);
		scroller.add(waterGraphics, Const.DP_FRONT);

		tile = new h2d.Bitmap(Tile.fromTexture(colorTexture));
		root.add(tile, Const.DP_FX_FRONT);
		tile.visible = false;
		App.ME.disp.normalMap = Tile.fromTexture(colorTexture); // tile.tile;

		/*App.ME.disp.normalMap=Tile.fromTexture(colorTexture);*/
		// tile.scale(1-1/Const.SCALE);
		// scroller.addChild(tile);
		// scroller.add(displaceLayer, Const.DP_BG);

		// healthFlask=new ui.Flask(64,64);
		// normalShader = new sample.NormalShader();
		// var wallNormals = new h2d.Bitmap(hxd.Res.atlas.wallNormal.toTile());
		// wallNormals.drawTo(normalTexture);
		// normalShader.mp = new Vector(0, 0, 0,0);
		// normalShader.normal = normalTexture;
		// normalShader.texture = normalTexture;
		motionBlur = new MotionBlur(2);
		// displaceLayer.filter=new dn.heaps.filter.Invert();
		scroller.filter = new h2d.filter.Group([App.ME.disp]); // , ,App.ME.colorFilter,motionBlur force rendering for pixel perfect
		frontScroller.filter = new h2d.filter.Group([new h2d.filter.Nothing()]);// new h2d.filter.Nothing(); 
		/*root.drawTo(colorTexture);
			tile=new h2d.Bitmap(Tile.fromTexture(colorTexture),root);//
			displaceLayer.addChild(tile);
			scroller.add(displaceLayer, Const.DP_FRONT); */

		fxScene = new h2d.Scene();
		//fxScene.getScene().filter = new h2d.filter.Bloom();
		root.addChild(fxScene);
		scroller.add(displaceLayer, Const.DP_FRONT);
		// fxScene.addChild(displaceLayer);
		// displaceLayer.visible=false;

		fog = new sample.FogFilter();
		scroller.filter = new h2d.filter.Group([App.ME.disp,fog,new h2d.filter.Bloom(1.5,1.5,1.5,0.5)]);
		
		//frontScroller.filter = fog;
		fx = new Fx();
		hud = new ui.Hud();
		camera = new Camera();

		GameStats.clearAll();
		chrono = new h2d.Text(Assets.fontPixel, hud.root);
		chrono.scale(2);
		chrono.y = 2;
		chrono.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0x042220,
			alpha: 0.8
		};
		chrono.text = 'Time :' + Const.CHRONO;
		if (App.ME.currentSavedGame != null) {
			var sav = App.ME.currentSavedGame.data;
			// trace(sav.currentWorld);
			// trace(sav.currentLevel);
			// trace(sav);
			for (w in Assets.worldData.worlds) {
				// trace(w.identifier + '(' + w.iid + ')');
				var monde = Assets.worldData.getWorld(w.iid);
				for (l in monde.levels) {
					if (l.iid == sav.currentLevel) {
						currentLevelIdentifyer = l.identifier;
						currentWorldIdentifyer = w.identifier;
						startLevel(l);
					}
				}
				monde = null;
			}
		} else {
			#if debug
			currentWorld = Assets.worldData.all_worlds.Lobbie.iid; // arrayIndex;
			currentWorldIdentifyer = Assets.worldData.all_worlds.Lobbie.identifier;
			currentLevel = Assets.worldData.all_worlds.Lobbie.all_levels.Level_55.iid;
			currentLevelIdentifyer = Assets.worldData.all_worlds.Lobbie.all_levels.Level_55.identifier;
			startLevel(Assets.worldData.all_worlds.Lobbie.all_levels.Level_55);
			cd.setS('intro', 3);
			#else
			currentWorld = Assets.worldData.all_worlds.Venus.iid; // arrayIndex;
			currentWorldIdentifyer = Assets.worldData.all_worlds.Venus.identifier;
			currentLevel = Assets.worldData.all_worlds.Venus.all_levels.Level_68.iid;
			currentLevelIdentifyer = Assets.worldData.all_worlds.Venus.all_levels.Level_68.identifier;
			startLevel(Assets.worldData.all_worlds.Venus.all_levels.Level_68);
			cd.setS('intro', 3);
			#end
		}

		// scroller.filter = new h2d.filter.Bloom(1.9, 1.2, 16, 1.1);
		if (player == null) {
			#if JS
			hxd.Save.delete("save");
			#end
			player = new sample.SamplePlayer();
			// player.spr.addShader(normalShader);
		}
		/*miniMap=new MiniMap(hud.root);
			miniMap.containerMask.scale(1); */
		// displaceLayer.over(player.spr);
		if (muz == null) {
			muz = S.gamebasemusic();
			muz.playFadeIn(true, App.ME.options.volume * 0.5, 2);
		}

		if (App.ME.currentSavedGame != null) {
			// trace(App.ME.currentSavedGame);
			gameStats.load(App.ME.currentSavedGame.data.achievements);
		}

		/*var farine:Craft = new Craft('farine', null);
			var oeuf:Craft = new Craft('oeuf', null);
			var sucre:Craft = new Craft('sucre', null);
			var eau:Craft = new Craft('eau', null);
			var pain:Craft = new Craft('pain', [{name: 'farine', stack: 2}, {name: 'eau', stack: 1}]);
			var crafts = [farine, farine, oeuf, sucre, eau, pain];

			for (i in 0...crafts.length) {
				// trace(crafts[i].title);
				// trace(crafts[i].receipe);
				if (player.inventory.contains(crafts[i])) {
					player.inventory[player.inventory.indexOf(crafts[i])].quantity++;
				} else {
					player.inventory.push(crafts[i]);
				}
			}
			pain.cook(); */

		// miniMap.renderMap();
		// miniMap.updateMapPosition();
	}

	public function saveGame() {
		var achievs = GameStats.save();
		var dat = Date.now();
		var playerPos = {x: player.cx, y: player.cy};
		// TODO canSwin...
		var skills = {
			canWallJump: player.canWallJump,
			canWallRun: player.canWallRun,
			canLazer: player.canLazer,
			canDash: player.canDash,
			canNinja: player.canNinja,
			canSwim: player.canSwim
		};
		var options = App.ME.options;
		var sav = {
			niveau: level.data.iid,
			currentLevel: currentLevel,
			currentLevelID: currentLevelIdentifyer,
			currentWorldID: currentWorldIdentifyer,
			currentWorld: currentWorld,
			achievements: achievs,
			playerPosition: playerPos,
			skills: skills,
			options: options,
			volume: App.ME.options.volume,
			inventory: player.inventory,
			chrono: chronometre,
		};
		// Internet.postHighScore();
		Internet.postSave(haxe.Serializer.run(sav)); //
		/*
			playedTime: dat.getDate()
			+ '_'
			+ dat.getMonth()
			+ '_'
			+ dat.getFullYear()
			+ '_'
			+ dat.getHours()
			+ '_'
			+ dat.getMinutes()
			+ '_'
			+ dat.getSeconds(),
		 */
		hxd.Save.save(sav, './save_0', true);
		sav = null;
	}

	public function playTutorial() {
		if (gameStats.has('tutoDone' + level.data.iid)) {
			// trace('tuto allready done, skipping');
			return;
		}
		// trace('executing tutorial cinematics');
		var bulle:h2d.Flow = new h2d.Flow(scroller);
		var tpad = Assets.tiles.getBitmap(D.tiles.btPad, bulle);
		var tbta = Assets.tiles.getBitmap(D.tiles.btA, bulle);
		var tbtb = Assets.tiles.getBitmap(D.tiles.btB, bulle);
		var tbtx = Assets.tiles.getBitmap(D.tiles.btX, bulle);
		var tbty = Assets.tiles.getBitmap(D.tiles.btY, bulle);
		var nuk = S.nuke();
		nuk.play(false, App.ME.options.volume);
		// var bg= new h2d.ScaleGrid(Assets.tiles.getTile("uiDarkBox"), 8, 12, 8, 8);
		// bg.tile=Assets.tiles.getTile('uiDarkBox');
		bulle.backgroundTile = Assets.tiles.getTile(D.tiles.dialogBox); // D.tiles.uiDarkBox
		bulle.borderWidth = 17; // 8;
		bulle.borderHeight = 20; // 8;
		bulle.padding = 12;
		bulle.addSpacing(16);
		tpad.visible = false;
		// tbta.visible=false;
		tbtb.visible = false;
		tbtx.visible = false;
		tbty.visible = false;

		bulle.filter = new Glow(0x00ffff, 0.8, 1, 1, 1, true);
		var txt:h2d.Text = new h2d.Text(Assets.fontPixelMono);
		txt.filter = new dn.heaps.filter.PixelOutline(0x005892, 0.8);
		txt.text = "TUTORIAL MADE EASY PEASY";
		bulle.x = player.attachX + 32;
		bulle.y = player.attachY - 64;
		bulle.addChild(txt);
		var ready = false;
		// cm.persistantSignal('pressed');
		cm.create({
			// ca.lock();
			player.ca.lock();
			addSlowMo(S_Default, 5, 0.25);
			100;
			fx.flashBangS(0x002288, 1, 1);
			fx.explosion(player.attachX, player.attachY, 1, 0xc6c08e, 240);
			player.v.dx = 1.2;
			player.v.dy = -1.2;
			120;
			fx.flashBangS(0x3655B5, 1, 1);
			fx.explosion(player.attachX, player.attachY, 1, 0xff8800, 24);
			180;
			fx.flashBangS(0x19F6E0, 1, 1);
			fx.explosion(player.attachX, player.attachY, 1, 0xff8800, 24);
			190;
			fx.flashBangS(0xFCE8CC, 1, 1);
			fx.explosion(player.attachX, player.attachY, 1, 0xff8800, 24);
			1500;
			camera.zoomTo(0.75);
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			500;
			txt.text = "Please, press Jump button";
			tbta.visible = true;
			500;
			function waitPressed() {
				cd.setS('areYouWaiting', 0.1);
				// cm.signal('pressed');
				// ('waiting for something to happen...');
			}
			200 >> waitPressed();
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			end('pressedJump');
			10;
			player.v.dy = -1;
			1000;
			txt.text = "Great jump ! now press Dash";
			tbta.visible = false;
			tbtb.visible = true;
			200 >> waitPressed();
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			end('pressedDash');
			player.doDash();
			500;
			txt.text = "Noice dash ! now press Lazer";
			tbtb.visible = false;
			tbtx.visible = true;
			200 >> waitPressed();
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			end('pressedLazer');
			player.doLazer();
			player.cd.setS('doLazerTuto', 4);
			500;
			txt.text = "Noice dash ! now press Fire";
			tbty.visible = true;
			tbtx.visible = false;
			200 >> waitPressed();
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			end('pressedFire');
			player.doFire();
			500;
			txt.text = "Noice dash ! now press Move";
			tbty.visible = false;
			tpad.visible = true;
			200 >> waitPressed();
			end('pressedMove');
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			player.ca.unlock();
			500;
			txt.text = "Awesome, you did it !";
			tpad.visible = false;
			500;
			txt.text = "Now, GO !";
			bulle.x = player.attachX - 32;
			bulle.y = player.attachY - 64;
			ca.unlock();
			500;
			camera.zoomTo(baseZoom);
		});
		cm.onAllComplete = () -> {
			// trace('cinematic terminated !');
			bulle.remove();
			if (!gameStats.has('tutoDone')) {
				var tutoDone = new Achievement("tutoDone" + level.data.iid, "done", () -> true, () -> {
					// trace("ACHIEVEMENT : tuto done");
				}, true);
				gameStats.registerState(tutoDone);
				tutoDone = null;
			}
			txt = null;
			tpad = null;
			tbta = null;
			tbtb = null;
			tbtx = null;
			tbty = null;
			nuk = null;

			saveGame();
			// cm.destroy();
		};
	}

	public static function isGameControllerLocked() {
		return !exists() || ME.isPaused() || App.ME.anyInputHasFocus();
	}

	public static inline function exists() {
		return ME != null && !ME.destroyed;
	}

	/** Load a level **/
	public function startLevel(l:World.World_Level) {
		if (level != null)
			level.destroy();
		fx.clear();
		waterGraphics.removeChildren();
		App.ME.resetFilters();
		for (e in Entity.ALL) // <---- Replace this with more adapted entity destruction (eg. keep the player alive)
			e == player?continue:e.destroy();
		garbageCollectEntities();
		gameTimeS = 0;
		cd.unset("gameTimeLock");

		level = new Level(l);
		gameStats.updateAll();

		// <---- check for scriptd here ?

		// <---- Here: instanciate your level entities

		for (bush in level.data.l_Probs.all_Flower){
			new Flower(bush);
		}

		for (fan in level.data.l_Entities.all_Ventilo){
			new sample.Ventilo(fan);
		}
		
		for (wat in level.data.l_Entities.all_Water) {
			new sample.WaterPond(wat);
		}

		for (mob in level.data.l_Entities.all_Mob) {
			new Mob(mob);
		}
		for (brr in level.data.l_Entities.all_Breakable) {
			new Breakable(brr);
		}
		for (light in level.data.l_Entities.all_Light) {
			new Light(light);
		}

		for (spiral in level.data.l_Entities.all_Swirl) {
			// new Swirl(spiral);
		}
		for (jem in level.data.l_Entities.all_Jem) {
			new Jem(jem);
		}
		for (portal in level.data.l_Entities.all_Portal) {
			new Portal(portal);
		}
		for (trigger in level.data.l_Entities.all_TriggerRect) {
			new sample.TriggerRect(trigger);
		}
		for (boss in level.data.l_Entities.all_Boss) {
			new Boss(boss);
		}

		for (elevator in level.data.l_Entities.all_Platform) {
			new Platform(elevator);
		}
		for (comp in level.data.l_Entities.all_Computer) {
			new Computer(comp);
		}
		for (rat in level.data.l_Entities.all_Rat) {
			new Rat(rat);
		}

		for (fish in level.data.l_Entities.all_Fish) {
			new Fish(fish);
		}

		for (bat in level.data.l_Entities.all_Bat) {
			new Bat(bat);
		}
		/*for (flower in level.data.l_Entities.all_Flower) {
			new Flower(flower);
		}*/

		for (chest in level.data.l_Entities.all_Chest) {
			new Chest(chest);
		}
		for (door in level.data.l_Entities.all_Door) {
			new Door(door);
		}
		for (rep in level.data.l_Entities.all_Minuter) {
			new sample.Minuter(rep);
		}
		for (t in level.data.l_Entities.all_TextZone) {
			new sample.TextZone(t);
		}
		for (s in level.data.l_Entities.all_Sensor) {
			new sample.Sensor(s);
		}
		for (t in level.data.l_Entities.all_Tourette) {
			new sample.Tourette(t);
		}
		for (s in level.data.l_Entities.all_Shower) {
			new sample.Shower(s);
		}
		for (b in level.data.l_Entities.all_Blob) {
			new sample.Blob(b);
		}
		for (t in level.data.l_Entities.all_HtmlZone) {
			new sample.HtmlZone(t);
		}
		for (t in level.data.l_Entities.all_FallingStone) {
			new sample.FallingStone(t);
		}
		for (t in level.data.l_Entities.all_Emiter) {
			new sample.Emiter(t);
		}

		fadeIn(0.25);
		camera.centerOnTarget();

		root.getScene().camera.clipViewport = true;
		hud.onLevelStart();
		dn.Process.resizeAll();
		App.ME.resetFilters();
		dn.Gc.runNow();
	}

	/** Called when either CastleDB or `const.json` changes on disk **/
	@:allow(App)
	function onDbReload() {
		hud.notify("DB reloaded");
	}

	/** Called when LDtk file changes on disk **/
	@:allow(assets.Assets)
	function onLdtkReload() {
		hud.notify("LDtk reloaded");
		if (level != null)
			for (w in Assets.worldData.worlds) {
				var monde = Assets.worldData.getWorld(w.iid);
				for (l in monde.levels) {
					if (l.iid == level.data.iid) {
						currentLevelIdentifyer = l.identifier;
						currentWorldIdentifyer = w.identifier;
						startLevel(l);
					}
				}
				monde = null;
			}
	}

	/** Window/app resize event **/
	override function onResize() {
		super.onResize();
		App.ME.resetFilters();
		dn.Process.resizeAll();
		// displaceLayer.scaleX=scroller.scaleX;
	}

	/** Garbage collect any Entity marked for destruction. This is normally done at the end of the frame, but you can call it manually if you want to make sure marked entities are disposed right away, and removed from lists. **/
	public function garbageCollectEntities() {
		if (Entity.GC == null || Entity.GC.allocated == 0)
			return;

		for (e in Entity.GC)
			e.dispose();
		Entity.GC.empty();
	}

	/** Called if game is destroyed, but only at the end of the frame **/
	override function onDispose() {
		super.onDispose();
		muz.dispose();
		muz = null;
		fx.destroy();
		ca = null;
		cm = null;
		level = null;
		colorTexture = null;
		// Assets.worldData=null;
		for (e in Entity.ALL)
			e.destroy();
		garbageCollectEntities();

		if (ME == this)
			ME = null;
	}

	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and all its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:SlowMoId, sec:Float, speedFactor = 0.3) {
		if (slowMos.exists(id)) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		} else
			slowMos.set(id, {id: id, t: sec, f: speedFactor});
	}

	/** The loop that updates slow-mos **/
	final function updateSlowMos() {
		// Timeout active slow-mos
		for (s in slowMos) {
			s.t -= utmod * 1 / Const.FPS;
			if (s.t <= 0)
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for (s in slowMos)
			targetGameSpeed *= s.f;
		curGameSpeed += (targetGameSpeed - curGameSpeed) * (targetGameSpeed > curGameSpeed ? 0.2 : 0.6);

		if (M.fabs(curGameSpeed - targetGameSpeed) <= 0.001)
			curGameSpeed = targetGameSpeed;
	}

	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}

	function onCycle() {
		gameTimeS = 10;
		cd.unset("gameTimeLock");
	}

	/** Loop that happens at the beginning of the frame **/
	override function preUpdate() {
		super.preUpdate();
		level.cinema.update(tmod);
		cm.update(tmod);
		// miniMap.renderMap();
		// miniMap.updateMapPosition();
		// clearing normal map spritBatch color for disp layer.
		colorTexture.clear(Col.fromRGBi(127, 127, 255), 1);
		if (App.ME.options.shaders == true) {
			displaceLayer.alpha = 1;
			colorTexture.clear(Col.fromRGBi(127, 127, 255), 1);
			fx.heatSource(player.attachX, player.attachY, M.fabs(player.v.dx) + M.fabs(player.v.dy));
			if (!cd.has('rain')) {
				cd.setMs('rain', 5000);
				fx.pixelRain(rnd(0, level.pxWid), rnd(0, level.pxHei), level.pxWid, level.pxHei);
			}
			displaceLayer.drawTo(colorTexture);
			tile.tile = Tile.fromTexture(colorTexture);
			App.ME.disp.normalMap = Tile.fromTexture(colorTexture);
			displaceLayer.alpha = 0;
			// displaceLayer.alpha = 0;
		}
		if (cd.has('areYouWaiting')) {
			cd.setS('areYouWaiting', 0.1);
			if (ca.isPressed(Jump)) {
				// cm.signal('pressed');
			}
		}

		if (cd.has("shake")) {
			var r = cd.getRatio("shake");
			root.y = Math.sin(ftime * 10) * r * 2 * Const.SCALE;
		} else
			root.y = 0;
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.preUpdate();
	}

	/** Loop that happens at the end of the frame **/
	override function postUpdate() {
		super.postUpdate();

		if (App.ME.options.shaders == true) {}
		parallaxScroller.x = -player.attachX * 0.25;
		parallaxScroller.y = -player.attachY * 0.25;
		// currentFrame++;
		// Update slow-motions
		updateSlowMos();
		baseTimeMul = (0.2 + 0.8 * curGameSpeed) * (ucd.has("stopFrame") ? 0.3 : 1);
		Assets.tiles.tmod = tmod;
		Assets.hero.tmod = tmod;
		Assets.boss.tmod = tmod;
		Assets.computer.tmod = tmod;
		Assets.platform.tmod = tmod;
		Assets.door.tmod = tmod;
		//App.ME.fog.updateTime(currentFrame);
		//trace("fog update :"+fog.shader.time);
		hud.healthFlask.refresh(player.life, player.maxLife);

		if (player.isAlive()) {
			if (!cd.has("gameTimeLock")) {
				gameTimeS += tmod * 1 / Const.FPS;
				if (gameTimeS >= Const.CYCLE_S) //
					onCycle();
			}
			hud.setTimeS(gameTimeS);
		} else {
			hud.setTimeS(-1);
		}
		// Entities post-updates
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.postUpdate();

		// Entities final updates
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.finalUpdate();

		// Dispose entities marked as "destroyed"
		garbageCollectEntities();
	}

	/** Main loop but limited to 30 fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();
		//fog.updateTime(0.2);
		currentFrame++;
		App.ME.fadeToBlack.shader.threshold = Math.sin(currentFrame / 3600);
		// fx.starField(camera.centerX,camera.centerY,0xffffff);
		// fx.starField(player.attachX,player.attachY,0xffffff);
		// WATER LEVEL counts & draw
		if (!cd.has('waterLevel')) {
			cd.setS('waterLevel', 0.25);
			waterGraphics.clear();
			waterGraphics.removeChildren();
			// waterGraphics.x=scroller.x;
			// waterGraphics.y=scroller.y;
			for (cy in 0...level.cHei) {
				for (cx in 0...level.cWid) {
					var count = level.levelWaterCountMap.get(level.coordId(cx, cy));
					if (count > 0 && !level.waterMarks.has(WaterLevel, cx, cy + 1) && !level.hasCollision(cx, cy + 1)) {
						level.waterMarks.set(WaterLevel, cx, cy + 1);
						level.levelWaterCountMap.set(level.coordId(cx, cy + 1), 17);
					}

					/*if(count>=16 && level.levelWaterCountMap.get(level.coordId(cx, cy-1))<17){
						var wl=level.levelWaterCountMap.get(level.coordId(cx, cy-1));
						level.levelWaterCountMap.set(level.coordId(cx, cy-1),wl++);

					}*/
					/*if(count>4 && level.levelWaterCountMap.get(level.coordId(cx, cy+1))<16 && !level.hasCollision(cx,cy)){
						var wl=level.levelWaterCountMap.get(level.coordId(cx, cy+1));
						level.levelWaterCountMap.set(level.coordId(cx, cy+1),16);

					}*/

					if (count > 0
						&& !level.waterMarks.has(WaterLevel, cx - 1, cy)
						&& level.hasCollision(cx - 1, cy)
						&& !level.hasCollision(cx - 1, cy - 1)) {
						level.waterMarks.set(WaterLevel, cx - 1, cy);
						level.levelWaterCountMap.set(level.coordId(cx - 1, cy), 1);
					}
					if (count > 0
						&& !level.waterMarks.has(WaterLevel, cx + 1, cy)
						&& level.hasCollision(cx + 1, cy)
						&& !level.hasCollision(cx + 1, cy - 1)) {
						level.waterMarks.set(WaterLevel, cx + 1, cy);
						level.levelWaterCountMap.set(level.coordId(cx + 1, cy), 1);
					}

					if (count > 0 && level.levelWaterCountMap.get(level.coordId(cx - 1, cy)) < count) {
						var wl = level.levelWaterCountMap.get(level.coordId(cx - 1, cy));
						level.levelWaterCountMap.set(level.coordId(cx - 1, cy), wl++);
						count -= 0.5;
					}
					if (count > 0 && level.levelWaterCountMap.get(level.coordId(cx + 1, cy)) < count) {
						var wl = level.levelWaterCountMap.get(level.coordId(cx + 1, cy));
						level.levelWaterCountMap.set(level.coordId(cx + 1, cy), wl++);
						count -= 0.5;
					}
					if (level.levelWaterCountMap.get(level.coordId(cx, cy - 1)) > 0 && !level.hasCollision(cx, cy)) {
						count = 17;
					}
					if (count != null && count > 0) {
						level.levelWaterCountMap.set(level.coordId(cx, cy), M.fmax(0, count -= 0.5));
						var wg = new h2d.Graphics(waterGraphics);
						wg.x = cx * Const.GRID; //*Const.SCALE;
						wg.y = cy * Const.GRID; //*Const.SCALE;
						wg.beginFill(0x0088ff, 0.8);
						wg.drawRect(0, 16, 16, -M.fmin(16, count));
						count = null;
					}
				}
			}
		}

		if (rnd(0, 1000) < 10) {
			meteo.state = [Rainning, Sunny, Snowing][irnd(0, 2)];
			meteo.state=Snowing;
		}
		if (meteo.state == Snowing && !cd.has("snowing")) {
			var rain = Std.int(rnd(0, level.pxWid / Const.GRID) * 0.5);
			cd.setMs('snowing', rain * 10);
			for (i in 0...rain*10){
				fx.snow(rnd(0, scroller.x+level.pxWid), rnd(0, scroller.y+level.pxHei),globalWind, 0x91bde4, i % 4 == 0, rnd(0.01, 0.5));	
				//fx.embers(rnd( scroller.x+0,  scroller.x+level.pxWid), rnd( scroller.y+0,  scroller.y+level.pxHei),  0xabfcff,1);
			}
				
		}

		var minutes = M.floor((Const.CHRONO / 1000) / 60);
		var seconds = M.floor((Const.CHRONO / 1000) % 60);
		var millis = M.floor(Const.CHRONO % 1000);
		chrono.text = "Time : "
			+ (minutes < 10 ? '0' + minutes : '' + minutes)
			+ ':'
			+ (seconds < 10 ? '0' + seconds : '' + seconds)
			+ ':'
			+ (millis < 10 ? '00' + millis : millis < 100 ? '0' + millis : '' + millis);
		chronometre = (minutes < 10 ? '0' + minutes : '' + minutes)
			+ ':'
			+ (seconds < 10 ? '0' + seconds : '' + seconds)
			+ '.'
			+ (millis < 10 ? '00' + millis : millis < 100 ? '0' + millis : '' + millis);
		// scroller.drawTo(normalTexture);
		// Entities "30 fps" loop
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.fixedUpdate();
	}

	/** Main loop **/
	override function update() {
		super.update();
		globalWind.x=Math.cos(currentFrame*0.01)/180*Math.PI;
		globalWind.y=Math.sin(currentFrame*0.01)/180*Math.PI;
		var windX=rnd(-10,10,true)*0.0001;
		var windY=rnd(-10,10,true)*0.0001;
		player.vBump.add(-globalWind.x*0.1,0);
		fog.updateTime(0.16,globalWind.x,globalWind.y,0x44778B,Math.sin(globalWind.x));
		fx.cloud(rnd(0,stageWid),rnd(0,stageHei));
		if (App.ME.options.shaders == true) {
			//App.ME.fog.shader.mousePos.set(App.ME.mousePos.x,App.ME.mousePos.y);
			
			
		}
		// App.ME.disp.normalMap.scrollDiscrete(-0.1+player.v.dx,0.2+player.v.dy);
		// App.ME.simpleShader.shader.multiplier = 2; // +player.v.dx;
		// motionBlur.setHorizontalBlur(player.v.dx);
		// motionBlur.setVerticalBlur(player.v.dy*4);

		// if (App.ME.options.shaders == true) {
		// displaceLayer.drawTo(colorTexture);
		// tile.tile = Tile.fromTexture(colorTexture);
		// }
		if (!cd.has('blinkshader')) {
			cd.setS('blinkshader', 1);
			/*App.ME.resetFilters();
				App.ME.colorFilter=new sample.ColorFilter();
				App.ME.colorFilter.shader.passed=rnd(0,1);

				//level.invalidate();
				App.ME.emitResizeNow();
			 */
		}
		// App.ME.colorFilter.texture=colorTexture;
		// Entities main loop;
		for (e in Entity.ALL)
			if (!e.destroyed)
				e.frameUpdate();

		// Global key shortcuts
		if (!App.ME.anyInputHasFocus() && !ui.Modal.hasAny() && !Console.ME.isActive()) {
			// Exit by pressing ESC twice
			#if hl
			if (ca.isKeyboardPressed(K.ESCAPE) && !cd.has("escaping")) {
				if (!cd.hasSetS("exitWarn", 3)) {
					hud.notify(Lang.t._("Press ESCAPE again to exit."));
				} else {
					cd.setS("escaping", 1);
					fadeOut(1, () -> {
						destroy();
						App.ME.startTitleScreen();
					});
				}
			}
			#end

			if (ca.isKeyboardPressed(K.O)) {
				ca.lock();
				pause();
				new page.OptionPage(App.ME);
			}
			if (ca.isKeyboardPressed(K.I)) {
				ca.lock();
				// pause();
				new page.InventoryPage();
			}
			// Attach debug drone (CTRL-SHIFT-D)
			#if debug
			if (ca.isPressed(ToggleDebugDrone))
				new DebugDrone(); // <-- HERE: provide an Entity as argument to attach Drone near it
			#end

			// Restart whole game
			if (ca.isPressed(Restart) && !cd.has("escaping")) {
				// destroy();
				cd.setS("escaping", 1);
				fadeOut(1, () -> {
					level.destroy();
					destroy();
					App.ME.startTitleScreen();
				});
			}
			if (!cm.isEmpty()) {
				if (ca.isHeld(Jump, 2)) {
					cm.skip();
				}
				if (ca.isPressed(Jump)) {
					cm.signal("pressedJump");
				}
				if (ca.isPressed(Dash)) {
					cm.signal("pressedDash");
				}
				if (ca.isPressed(Lazer)) {
					cm.signal("pressedLazer");
				}
				if (ca.isPressed(Fire)) {
					cm.signal("pressedFire");
				}
				if (ca.isDown(MoveRight) || ca.isDown(MoveLeft)) {
					cm.signal("pressedMove");
				}
			}
		}
	}
}
