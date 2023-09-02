package assets;

import h2d.Bitmap;
import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
class Assets {
	public static var SLIB = dn.heaps.assets.SfxDirectory.load("sfx", true);

	// Fonts
	public static var fontPixel:h2d.Font;
	public static var fontPixelMono:h2d.Font;

	/** Main atlas **/
	public static var tiles:SpriteLib;

	public static var hero:SpriteLib;
	public static var boss:SpriteLib;
	public static var ventilo:SpriteLib;
	public static var platform:SpriteLib;
	public static var computer:SpriteLib;
	public static var bat:SpriteLib;
	public static var rat:SpriteLib;
	public static var door:SpriteLib;
	public static var chest:SpriteLib;
	public static var led:SpriteLib;
	public static var sensor:SpriteLib;
	public static var tourette:SpriteLib;
	public static var normdisp:Bitmap;
	public static var sphereMap:Bitmap;
	public static var waterfall:Bitmap;
	public static var introPat:Bitmap;
	public static var naledition:Bitmap;
	static var palette:Array<Col> = [];

	/** LDtk world data **/
	public static var worldData:World;

	static var _initDone = false;

	public static function init() {
		if (_initDone)
			return;
		_initDone = true;

		// Fonts
		fontPixel = new hxd.res.BitmapFont(hxd.Res.fonts.pixel_unicode_regular_12_xml.entry).toFont();
		fontPixelMono = new hxd.res.BitmapFont(hxd.Res.fonts.pixica_mono_regular_16_xml.entry).toFont();

		// normal map for displacement
		normdisp = new h2d.Bitmap(hxd.Res.atlas.normaldisp.toTile());
		sphereMap = new h2d.Bitmap(hxd.Res.atlas.dispMap.toTile());
		waterfall = new h2d.Bitmap(hxd.Res.atlas.waterfall.toTile());
		introPat = new h2d.Bitmap(hxd.Res.atlas.introPat.toTile());
		naledition = new h2d.Bitmap(hxd.Res.atlas.nal10ansedition.toTile());
		// Palette
		var pal = hxd.Res.atlas.sweetie_16_1x.getPixels(ARGB);
		palette = [];
		for (i in 0...pal.width) {
			var c:Col = pal.getPixel(i, 0);
			c = c.withoutAlpha();
			palette.push(c);
		}

		// build sprite atlas directly from Aseprite file
		tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
		tiles.defineAnim("fxExplo", "0-4(2)");
		tiles.defineAnim("fxDuster", "0-2(4)");
		tiles.defineAnim("fxBurnOut", "0-4(5)");
		tiles.defineAnim("fxFlame", "0-3(5)");
		tiles.defineAnim("fxEye", "0-3(1),4(4),5(1)");
		tiles.defineAnim("fxLazerImpact", "0-2(1)");
		tiles.defineAnim("breakable", "0-2(1)");
		tiles.defineAnim("fxRoll", "0-2(1)");
		tiles.defineAnim("fxPouf", "0-2(1)");
		tiles.defineAnim("fxPower", "0-2(1)");
		tiles.defineAnim("fxPortal", "0-3(2)");
		hero = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.hero.toAseprite());
		boss = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.boss.toAseprite());
		ventilo = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.ventilo.toAseprite());
		platform = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.platform.toAseprite());
		computer = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.computer.toAseprite());
		door = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.door.toAseprite());
		rat = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.rat.toAseprite());
		bat = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.bat.toAseprite());
		chest = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.chest.toAseprite());
		led = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.led.toAseprite());
		tourette = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tourette.toAseprite());
		sensor = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.sensor.toAseprite());
		// Hot-reloading of CastleDB
		#if debug
		hxd.Res.data.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("cdb");
			App.ME.delayer.addS("cdb", function() {
				CastleDb.load(hxd.Res.data.entry.getBytes().toString());
				Const.db.reload_data_cdb(hxd.Res.data.entry.getText());
			}, 0.2);
		});
		#end

		// Parse castleDB JSON
		CastleDb.load(hxd.Res.data.entry.getText());

		// Hot-reloading of `const.json`
		hxd.Res.const.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("constJson");
			App.ME.delayer.addS("constJson", function() {
				Const.db.reload_const_json(hxd.Res.const.entry.getBytes().toString());
			}, 0.2);
		});

		// LDtk init & parsing
		worldData = new World();

		// LDtk file hot-reloading
		#if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch (_) null; // assume the LDtk file is in "res/" subfolder
		if (res != null)
			res.watch(() -> {
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				App.ME.delayer.cancelById("ldtk");
				App.ME.delayer.addS("ldtk", function() {
					worldData.parseJson(res.entry.getText());
					if (Game.exists())
						Game.ME.onLdtkReload();
				}, 0.2);
			});
		#end
	}

	public static inline function getCol(idx:Int):Col {
		return palette[M.iclamp(idx, 0, palette.length - 1)];
	}

	public static inline function black()
		return getCol(0);

	public static inline function dark()
		return getCol(15);

	public static inline function white()
		return getCol(12);

	public static inline function yellow()
		return getCol(4);

	public static inline function green()
		return getCol(5);

	public static inline function blue()
		return getCol(10);

	public static inline function red()
		return getCol(2);

	public static inline function walls()
		return getCol(17);

	/**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
	public static function update(tmod:Float) {
		if (Game.exists() && Game.ME.isPaused())
			tmod = 0;

		tiles.tmod = tmod;
		hero.tmod = tmod;
		boss.tmod = tmod;
		platform.tmod = tmod;
		rat.tmod = tmod;
		bat.tmod = tmod;
		sensor.tmod = tmod;
		led.tmod = tmod;
		tourette.tmod = tmod;
		chest.tmod = tmod;
		door.tmod = tmod;

		// <-- add other atlas TMOD updates here
	}
}
