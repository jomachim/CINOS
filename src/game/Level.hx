import dn.Gc;
import h2d.filter.Group;
import ui.Hud;
import h2d.filter.Bloom;
import h2d.Tile;
import GameStats;
import sample.NormalShader;
import dn.Cinematic;
import dn.MarkerMap;

class Level extends GameChildProcess {
	/** Level grid-based width**/
	public var cWid(default, null):Int;

	/** Level grid-based height **/
	public var cHei(default, null):Int;

	/** Level pixel width**/
	public var pxWid(default, null):Int;

	/** Level pixel height**/
	public var pxHei(default, null):Int;

	public var data:World_Level;

	var tilesetSource:h2d.Tile;
	var decoTileSetSource:h2d.Tile;

	var normalTileSource:h2d.Tile;
	var norm:NormalShader;
	var bloom:Bloom;

	public var normTex0:h3d.mat.Texture;
	public var normTex1:h3d.mat.Texture;

	/*norm = new NormalShader();
		tex1=new Texture(Std.int(wallColors.tile.width),Std.int(wallColors.tile.height),[ Target ]);
		tex=new Texture(Std.int(wallColors.tile.width),Std.int(wallColors.tile.height),[ Target ]);
		wallColors.drawTo(tex1);//.tile.getTexture()
		wallNormals.drawTo(tex);
		norm.texture=tex1;
		norm.normal=tex;
		norm.mp = new Vector(0.5, 0.5, 0, 0);
		bgCol.addShader(norm);
		bg.addShader(norm);
		wallGloss.addShader(norm); */
	public var marks:dn.MarkerMap<LevelMark>;
	public var breakables:tools.MarkerMap<Types.LevelBreaks>;
	public var tags:dn.MarkerMap<LevelMark>;

	public var cinema:dn.Cinematic;
	public var script:Dynamic;

	var invalidated = true;


	public function new(ldtkLevel:World.World_Level) {
		super();
		cinema = new dn.Cinematic(Const.FPS);
		norm = new NormalShader();
		bloom = new Bloom(4,4,2,2,2);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		data = ldtkLevel;
		cWid = data.l_Collisions.cWid;
		cHei = data.l_Collisions.cHei;
		pxWid = cWid * Const.GRID;
		pxHei = cHei * Const.GRID;
		
		if (!game.gameStats.has(data.identifier+ "_visited")) {
			var ach = new Achievement(data.identifier+"_visited", "visited", () -> true, () -> {
				//trace("level is being visited");
			}, true);
			game.gameStats.registerState(ach);
			ach=null;
		}
		if (data.f_cinematics != null && !game.gameStats.has('cinematics_' + data.iid)) {
			// script=game.hsParser.parseString();
			var scripter = tools.script.Script;

			delayer.addS('levelScript', () -> {
				scripter.run(data.f_cinematics);
			}, 0);
			var cineDone = new Achievement('cinematics_' + data.iid, "done", () -> true, () -> {
				//trace("ACHIEVEMENT : cine done");
			}, true);
			game.gameStats.registerState(cineDone);
		}
		tilesetSource = hxd.Res.levels.sampleWorldTiles.toAseprite().toTile();
		decoTileSetSource = hxd.Res.levels.decoTiles.toAseprite().toTile();
		// normalTileSource = hxd.Res.levels.normalTiles.toAseprite().toTile();

		game.currentLevel=data.iid;
		//trace(game.currentWorld+", "+game.currentLevel);
		for (w in Assets.worldData.worlds) {
			//trace(w.identifier + '(' + w.iid + ')');
			var monde = Assets.worldData.getWorld(w.iid);
			for (l in monde.levels) {
				if (l.iid == data.iid) {
					game.currentLevelIdentifyer = l.identifier;
					game.currentWorldIdentifyer = w.identifier;
					game.currentLevel=data.iid;
					game.currentWorld=w.iid;
					//startLevel(l);
				}
			}
			monde=null;
		}
		game.hud.notify(game.currentWorldIdentifyer+", "+game.currentLevelIdentifyer,Col.blue(true));

		

		marks = new dn.MarkerMap(cWid, cHei);
		breakables = new tools.MarkerMap(cWid, cHei);
		tags = new dn.MarkerMap(cWid, cHei);
		
		for (cy in 0...cHei)
			for (cx in 0...cWid) {
				for (tile in data.l_Tiles.getTileStackAt(cx, cy)) {
					if (data.l_Tiles.tileset.hasTag(tile.tileId, assets.Enum_TileEnum.Checkpoint)) { // 587
						//trace("checkpoint !!!");
						//trace("tile ID ? : " + tile);
						tags.set(M_CHKPT, cx, cy);
					}
					if (data.l_Tiles.tileset.hasTag(tile.tileId, assets.Enum_TileEnum.Jumper)) { // 587
						//trace("jumper !!!");
						//trace("tile ID ? : " + tile);
						tags.set(M_JUMPER, cx, cy);
					}
					if (data.l_Tiles.tileset.hasTag(tile.tileId, assets.Enum_TileEnum.Ice)) { // 587
						//trace("ICE !!!");
						//trace("tile ID ? : " + tile);
						tags.set(M_ICE, cx, cy);
					}
					if (data.l_Tiles.tileset.hasTag(tile.tileId, assets.Enum_TileEnum.PortalSwirl)) { // 587
						//trace("ICE !!!");
						//trace("tile ID ? : " + tile);
						tags.set(M_SWIRL, cx, cy);
					}
				}
				if (data.l_Collisions.getInt(cx, cy) == 1)
					marks.set(M_Coll_Wall, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 2)
					marks.set(M_Coll_Slope_LU, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 3)
					marks.set(M_Coll_Slope_RU, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 4)
					marks.set(M_Coll_Slope_LD, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 5)
					marks.set(M_Coll_Slope_RD, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 6)
					marks.set(M_Coll_Slope_LU2, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 7)
					marks.set(M_Coll_Slope_RU2, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 8)
					marks.set(M_Coll_Slope_LD2, cx, cy);
				if (data.l_Collisions.getInt(cx, cy) == 9)
					marks.set(M_Coll_Slope_RD2, cx, cy);
			}
	}

	override function onDispose() {
		super.onDispose();
		data = null;
		tilesetSource = null;
		decoTileSetSource = null;
		normalTileSource = null;
		marks.dispose();
		marks = null;
		tags.dispose();
		tags=null;
		breakables.dispose();
		breakables = null;
		Gc.runNow();
	}

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx, cy)
		return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx, cy)
		return cx + cy * cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}

	public inline function hasBreakable(cx, cy):Bool {
		return breakables.has(Breaks, cx, cy) || breakables.has(Breaking, cx, cy) || breakables.has(Broken, cx, cy);
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Wall, cx, cy) || hasBreakable(cx, cy);
	}

	public inline function hasCheckPoint(cx, cy):Bool {
		return tags.has(M_CHKPT, cx, cy);
	}
	public inline function hasJumper(cx, cy):Bool {
		return tags.has(M_JUMPER, cx, cy);
	}
	public inline function hasIce(cx, cy):Bool {
		return tags.has(M_ICE, cx, cy);
	}

	public inline function hasSwirl(cx, cy):Bool {
		return tags.has(M_SWIRL, cx, cy);
	}
	/** Return true for slope type "Collisions" layer contains a collision value **/
	public inline function isLUSlope(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_LU, cx, cy);
	}

	public inline function isLUSlope2(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_LU2, cx, cy);
	}

	public inline function isRUSlope(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_RU, cx, cy);
	}

	public inline function isRUSlope2(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_RU2, cx, cy);
	}

	public inline function isLDSlope(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_LD, cx, cy);
	}

	public inline function isLDSlope2(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_LD2, cx, cy);
	}

	public inline function isRDSlope(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_RD, cx, cy);
	}

	public inline function isRDSlope2(cx, cy):Bool {
		return !isValid(cx, cy) ? true : marks.has(M_Coll_Slope_RD2, cx, cy);
	}

	/** Render current level**/
	function render() {
		// Placeholder level render
		// root.removeChildren();
		
		var tgb = new h2d.TileGroup(tilesetSource, root);
		var backlayer = data.l_BackTiles;
		backlayer.render(tgb);
		//App.ME.colorFilter.shader.passed=rnd(0,1);
		//tgb.filter=new Group([App.ME.disp]); // bloom;
		var para = new h2d.TileGroup(tilesetSource, root);
		var paralayer = data.l_ParallaxTiles;
		paralayer.render(para);


		var tg = new h2d.TileGroup(tilesetSource, root);
		var layer = data.l_Collisions;
		layer.render(tg);
		

		var al = new h2d.TileGroup(tilesetSource,root);
		var la = data.l_IntGrider;
		la.render(al);
		al.alpha=0.5;

		game.tile=new h2d.Bitmap(Tile.fromTexture(game.colorTexture));
		//game.displaceLayer.addChild(game.tile);
		//game.frontScroller.add(game.displaceLayer, Const.DP_FRONT);

		
		game.frontScroller.removeChildren();
		var dg = new h2d.TileGroup(decoTileSetSource, game.frontScroller);
		var decoLayer = data.l_Tiles;
		decoLayer.render(dg);
		
		// var ptg:h2d.TileGroup = new h2d.TileGroup(tilesetSource,root);
	}

	override function postUpdate() {
		super.postUpdate();

		if (invalidated) {
			invalidated = false;
			render();
		}
	}
}
