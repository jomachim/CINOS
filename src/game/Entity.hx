import h2d.filter.Nothing;
import h2d.filter.Group;

class Entity {
	public static var ALL:FixedArray<Entity> = new FixedArray(2048);
	public static var GC:FixedArray<Entity> = new FixedArray(ALL.maxSize);

	// Various getters to access all important stuff easily
	public var app(get, never):App;

	inline function get_app()
		return App.ME;

	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	public var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	public var destroyed(default, null) = false;
	public var ftime(get, never):Float;

	inline function get_ftime()
		return game.ftime;

	public var camera(get, never):Camera;

	inline function get_camera()
		return game.camera;

	var tmod(get, never):Float;

	inline function get_tmod()
		return Game.ME.tmod;

	var utmod(get, never):Float;

	inline function get_utmod()
		return Game.ME.utmod;

	public var hud(get, never):ui.Hud;

	inline function get_hud()
		return Game.ME.hud;

	/** Cooldowns **/
	public var cd:dn.Cooldown;

	/** Cooldowns, unaffected by slowmo (ie. always in realtime) **/
	public var ucd:dn.Cooldown;

	/** Cinamtics **/
	var cm:dn.Cinematic;

	/** Temporary gameplay affects **/
	var affects:Map<Affect, Float> = new Map();

	/** State machine. Value should only be changed using `startState(v)` **/
	public var state(default, null):State;

	/** Unique identifier **/
	public var uid(default, null):Int;

	/** Grid X coordinate **/
	public var cx = 0;

	/** Grid Y coordinate **/
	public var cy = 0;

	/** Sub-grid X coordinate (from 0.0 to 1.0) **/
	public var xr = 0.5;

	/** Sub-grid Y coordinate (from 0.0 to 1.0) **/
	public var yr = 1.0;

	var allVelocities:FixedArray<Velocity>;

	/** Base X/Y velocity of the Entity **/
	public var v:tools.Velocity;

	/** "External bump" velocity. It is used to push the Entity in some direction, independently of the "user-controlled" base velocity. **/
	public var vBump:tools.Velocity;

	/** Last known X position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
	var lastFixedUpdateX = 0.;

	/** Last known Y position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
	var lastFixedUpdateY = 0.;

	/** If TRUE, the sprite display coordinates will be an interpolation between the last known position and the current one. This is useful if the gameplay happens in the `fixedUpdate()` (so at 30 FPS), but you still want the sprite position to move smoothly at 60 FPS or more. **/
	var interpolateSprPos = true;

	/** Total of all X velocities **/
	public var dxTotal(get, never):Float;

	inline function get_dxTotal() {
		var t = 0.;
		for (v in allVelocities)
			t += v.dx;
		return t;
	}

	/** Total of all Y velocities **/
	public var dyTotal(get, never):Float;

	inline function get_dyTotal() {
		var t = 0.;
		for (v in allVelocities)
			t += v.dy;
		return t;
	}

	/** Pixel width of entity **/
	public var wid(default, set):Float = Const.GRID;

	inline function set_wid(v) {
		invalidateDebugBounds = true;
		return wid = v;
	}

	public var iwid(get, set):Int;

	inline function get_iwid()
		return M.round(wid);

	inline function set_iwid(v:Int) {
		invalidateDebugBounds = true;
		wid = v;
		return iwid;
	}

	/** Pixel height of entity **/
	public var hei(default, set):Float = Const.GRID;

	inline function set_hei(v) {
		invalidateDebugBounds = true;
		return hei = v;
	}

	public var ihei(get, set):Int;

	inline function get_ihei()
		return M.round(hei);

	inline function set_ihei(v:Int) {
		invalidateDebugBounds = true;
		hei = v;
		return ihei;
	}

	/** Inner radius in pixels (ie. smallest value between width/height, then divided by 2) **/
	public var innerRadius(get, never):Float;

	inline function get_innerRadius()
		return M.fmin(wid, hei) * 0.5;

	/** "Large" radius in pixels (ie. biggest value between width/height, then divided by 2) **/
	public var largeRadius(get, never):Float;

	inline function get_largeRadius()
		return M.fmax(wid, hei) * 0.5;

	/** Horizontal direction, can only be -1 or 1 **/
	public var dir(default, set) = 1;

	/** Current sprite X **/
	public var sprX(get, never):Float;

	inline function get_sprX() {
		return interpolateSprPos ? M.lerp(lastFixedUpdateX, (cx + xr) * Const.GRID, game.getFixedUpdateAccuRatio()) : (cx + xr) * Const.GRID;
	}

	/** Current sprite Y **/
	public var sprY(get, never):Float;

	inline function get_sprY() {
		return interpolateSprPos ? M.lerp(lastFixedUpdateY, (cy + yr) * Const.GRID, game.getFixedUpdateAccuRatio()) : (cy + yr) * Const.GRID;
	}

	/** Sprite X scaling **/
	public var sprScaleX = 1.0;

	/** Sprite Y scaling **/
	public var sprScaleY = 1.0;

	/** Sprite X squash & stretch scaling, which automatically comes back to 1 after a few frames **/
	var sprSquashX = 1.0;

	/** Sprite Y squash & stretch scaling, which automatically comes back to 1 after a few frames **/
	var sprSquashY = 1.0;

	/** Entity visibility **/
	public var entityVisible = true;

	/** Current hit points **/
	public var life(default, null):Int;

	/** Max hit points **/
	public var maxLife(default, null):Int;

	/** Last source of damage if it was an Entity **/
	public var lastDmgSource(default, null):Null<Entity>;

	/** Horizontal direction (left=-1 or right=1): from "last source of damage" to "this" **/
	public var lastHitDirFromSource(get, never):Int;

	inline function get_lastHitDirFromSource()
		return lastDmgSource == null ? -dir : -dirTo(lastDmgSource);

	/** Horizontal direction (left=-1 or right=1): from "this" to "last source of damage" **/
	public var lastHitDirToSource(get, never):Int;

	inline function get_lastHitDirToSource()
		return lastDmgSource == null ? dir : dirTo(lastDmgSource);

	/** Main entity HSprite instance **/
	public var spr:HSprite;

	/** Color vector transformation applied to sprite **/
	public var baseColor:h3d.Vector;

	/** Color matrix transformation applied to sprite **/
	public var colorMatrix:h3d.Matrix;

	// Animated blink color on damage hit
	var blinkColor:h3d.Vector;

	/** Sprite X shake power **/
	var shakePowX = 0.;

	/** Sprite Y shake power **/
	var shakePowY = 0.;

	// Debug stuff
	var debugLabel:Null<h2d.Text>;
	var debugBounds:Null<h2d.Graphics>;
	var invalidateDebugBounds = false;

	/** Defines X alignment of entity at its attach point (0 to 1.0) **/
	public var pivotX(default, set):Float = 0.5;

	/** Defines Y alignment of entity at its attach point (0 to 1.0) **/
	public var pivotY(default, set):Float = 1;

	/** Entity attach X pixel coordinate **/
	public var attachX(get, never):Float;

	inline function get_attachX()
		return (cx + xr) * Const.GRID;

	/** Entity attach Y pixel coordinate **/
	public var attachY(get, never):Float;

	inline function get_attachY()
		return (cy + yr) * Const.GRID;

	// Various coordinates getters, for easier gameplay coding

	/** Left pixel coordinate of the bounding box **/
	public var left(get, never):Float;

	inline function get_left()
		return attachX + (0 - pivotX) * wid;

	/** Right pixel coordinate of the bounding box **/
	public var right(get, never):Float;

	inline function get_right()
		return attachX + (1 - pivotX) * wid;

	/** Top pixel coordinate of the bounding box **/
	public var top(get, never):Float;

	inline function get_top()
		return attachY + (0 - pivotY) * hei;

	/** Bottom pixel coordinate of the bounding box **/
	public var bottom(get, never):Float;

	inline function get_bottom()
		return attachY + (1 - pivotY) * hei;

	/** Center X pixel coordinate of the bounding box **/
	public var centerX(get, never):Float;

	inline function get_centerX()
		return attachX + (0.5 - pivotX) * wid;

	/** Center Y pixel coordinate of the bounding box **/
	public var centerY(get, never):Float;

	inline function get_centerY()
		return attachY + (0.5 - pivotY) * hei;

	/** Current X position on screen (ie. absolute)**/
	public var screenAttachX(get, never):Float;

	inline function get_screenAttachX()
		return game != null && !game.destroyed ? sprX * Const.SCALE + game.scroller.x : sprX * Const.SCALE;

	/** Current Y position on screen (ie. absolute)**/
	public var screenAttachY(get, never):Float;

	inline function get_screenAttachY()
		return game != null && !game.destroyed ? sprY * Const.SCALE + game.scroller.y : sprY * Const.SCALE;

	/** attachX value during last frame **/
	public var prevFrameAttachX(default, null):Float = -Const.INFINITY;

	/** attachY value during last frame **/
	public var prevFrameAttachY(default, null):Float = -Const.INFINITY;

	var actions:FixedArray<{id:ChargedAction, cb:Void->Void, t:Float}>;

	public var outline:dn.heaps.filter.PixelOutline = new dn.heaps.filter.PixelOutline(0x000000, 0.5);

	// Grappin
	public var isGrappling:Bool = false;
	public var grapplingPointX:Float = 0;
	public var grapplingPointY:Float = 0;
	public var grappleLength:Float = 0;
	public var grappleAngle:Float = 0;
	public var grappleVelocity:Float = 0;

	// Éléments visuels pour le grappin
    var grappleGraphics:h2d.Graphics;
    var debugScene:h2d.Scene;


	/**
		Constructor
	**/
	public function new(x:Int, y:Int) {
		uid = Const.makeUniqueId();
		ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		ucd = new dn.Cooldown(Const.FPS);
		cm = new dn.Cinematic(Const.FPS);
		setPosCase(x, y);
		initLife(1);
		state = Normal;
		actions = new FixedArray(15);

		v = new Velocity(0.82);
		vBump = new Velocity(0.93);
		allVelocities = new FixedArray(10);
		allVelocities.push(v);
		allVelocities.push(vBump);

		grappleGraphics = new h2d.Graphics();
        /*debugScene = Game.ME.scroller.getScene(); // Assurez-vous que cette référence est correcte pour votre jeu
        debugScene.addChild(grappleGraphics);*/

		spr = new HSprite(Assets.tiles);
		Game.ME.scroller.add(spr, Const.DP_MAIN);
		Game.ME.scroller.add(grappleGraphics, Const.DP_MAIN);
		spr.colorAdd = new h3d.Vector();
		baseColor = new h3d.Vector();
		blinkColor = new h3d.Vector();
		spr.colorMatrix = colorMatrix = h3d.Matrix.I();
		spr.setCenterRatio(pivotX, pivotY);
		spr.filter = new Group([new Nothing(), outline]);
		if (ui.Console.ME.hasFlag("bounds"))
			enableDebugBounds();
	}

	public function getLocalMouseCoordinates(): h2d.col.Point {
		// Obtenir les coordonnées globales de la souris
		var globalMouseX = hxd.Window.getInstance().mouseX;
		var globalMouseY = hxd.Window.getInstance().mouseY;
		var localX = (globalMouseX - Game.ME.scroller.x) / Game.ME.scroller.scaleX;
    	var localY = (globalMouseY - Game.ME.scroller.y) / Game.ME.scroller.scaleY;
	
		// Convertir les coordonnées globales en coordonnées locales par rapport au scroller
		var localPoint =new h2d.col.Point(localX, localY);// Game.ME.scroller.globalToLocal();
	
		return localPoint;
	}
	public function shootGrapple(targetX:Float, targetY:Float) {
		if (!isGrappling) {
			isGrappling = true;
			trace("grappling");
			targetX= getLocalMouseCoordinates().x;
			targetY= getLocalMouseCoordinates().y;
			grapplingPointX =targetX;
			grapplingPointY =targetY;
			grappleLength = Math.sqrt(Math.pow(targetX - attachX, 2) + Math.pow(targetY - attachY, 2));
			grappleAngle = Math.atan2(targetY - attachY, targetX - attachX);
			grappleVelocity = 0;
			 // Dessiner le grappin initial
			 drawGrapple();
		}
	}
	
	public function releaseGrapple() {
		if (isGrappling) {
			isGrappling = false;
			trace('ungrappling');
			// Appliquer une impulsion basée sur la vitesse actuelle du balancier
			var impulseX = Math.cos(grappleAngle) * grappleVelocity;
			var impulseY = Math.sin(grappleAngle) * grappleVelocity;
			v.dx+=impulseX;
			v.dy+=impulseY;
			var tangentialVelocity = grappleVelocity * grappleLength;
			var releaseAngle = grappleAngle + Math.PI/2; // Tangent à la trajectoire
	
			// Appliquer cette vitesse à l'entité
			v.dx += Math.cos(releaseAngle) * tangentialVelocity;
			v.dy += Math.sin(releaseAngle) * tangentialVelocity;
			clearGrappleGraphics();
		}
	}

	function drawGrapple() {
        grappleGraphics.clear();

        // Dessiner la ligne du grappin
        grappleGraphics.lineStyle(2, 0xFF0000);
        grappleGraphics.moveTo(attachX, attachY);
        grappleGraphics.lineTo(grapplingPointX, grapplingPointY);

        // Dessiner le point d'accroche
        grappleGraphics.lineStyle(1, 0x00FF00);
        grappleGraphics.drawCircle(grapplingPointX, grapplingPointY, 5);

        // Dessiner le point de l'entité
        grappleGraphics.lineStyle(1, 0x0000FF);
        grappleGraphics.drawCircle(attachX, attachY, 5);
    }

    function clearGrappleGraphics() {
        grappleGraphics.clear();
    }

	/** Remove sprite from display context. Only do that if you're 100% sure your entity won't need the `spr` instance itself. **/
	function noSprite() {
		spr.setEmptyTexture();
		spr.remove();
	}

	function set_pivotX(v) {
		pivotX = M.fclamp(v, 0, 1);
		if (spr != null)
			spr.setCenterRatio(pivotX, pivotY);
		return pivotX;
	}

	function set_pivotY(v) {
		pivotY = M.fclamp(v, 0, 1);
		if (spr != null)
			spr.setCenterRatio(pivotX, pivotY);
		return pivotY;
	}

	/** Initialize current and max hit points **/
	public function initLife(v) {
		life = maxLife = v;
		if (life <= 0)
			onDie();
	}

	/** Inflict damage **/
	public function hit(dmg:Int, from:Null<Entity>) {
		if (!isAlive() || dmg <= 0)
			return;
		blink(0xffffff);
		life = M.iclamp(life - dmg, 0, maxLife);

		lastDmgSource = from;
		onDamage(dmg, from);
		if (life <= 0)
			onDie();
	}

	/** Kill instantly **/
	public function kill(by:Null<Entity>) {
		if (isAlive())
			hit(life, by);
	}

	function onDamage(dmg:Int, from:Null<Entity>) {
		if (from == null)
			from = this;
		bump(-dirTo(from) * 0.05, -0.05);
		cd.setS('hitBump', 0.5);
	}

	function onDie() {
		destroy();
	}

	inline function set_dir(v) {
		return dir = v > 0 ? 1 : v < 0 ? -1 : dir;
	}

	/** Return TRUE if current entity wasn't destroyed or killed **/
	public inline function isAlive() {
		return !destroyed && life > 0;
	}

	/** Move entity to grid coordinates **/
	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		onPosManuallyChangedBoth();
	}

	/** Move entity to pixel coordinates **/
	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x / Const.GRID);
		cy = Std.int(y / Const.GRID);
		xr = (x - cx * Const.GRID) / Const.GRID;
		yr = (y - cy * Const.GRID) / Const.GRID;
		onPosManuallyChangedBoth();
	}

	public function setPosX(x:Float) {
		cx = Std.int(x / Const.GRID);
		xr = (x - cx * Const.GRID) / Const.GRID;
		onPosManuallyChangedX();
	};

	public function setPosY(y:Float) {
		cy = Std.int(y / Const.GRID);
		yr = (y - cy * Const.GRID) / Const.GRID;
		onPosManuallyChangedY();
	};

	/** Should be called when you manually (ie. ignoring physics) modify both X & Y entity coordinates **/
	function onPosManuallyChangedBoth() {
		if (M.dist(attachX, attachY, prevFrameAttachX, prevFrameAttachY) > Const.GRID * 2) {
			prevFrameAttachX = attachX;
			prevFrameAttachY = attachY;
		}
		updateLastFixedUpdatePos();
	}

	/** Should be called when you manually (ie. ignoring physics) modify entity X coordinate **/
	function onPosManuallyChangedX() {
		if (M.fabs(attachX - prevFrameAttachX) > Const.GRID * 2)
			prevFrameAttachX = attachX;
		lastFixedUpdateX = attachX;
	}

	/** Should be called when you manually (ie. ignoring physics) modify entity Y coordinate **/
	function onPosManuallyChangedY() {
		if (M.fabs(attachY - prevFrameAttachY) > Const.GRID * 2)
			prevFrameAttachY = attachY;
		lastFixedUpdateY = attachY;
	}

	/** Quickly set X/Y pivots. If Y is omitted, it will be equal to X. **/
	public function setPivots(x:Float, ?y:Float) {
		pivotX = x;
		pivotY = y != null ? y : x;
	}

	/** Return TRUE if the Entity *center point* is in screen bounds (default padding is +32px) **/
	public inline function isOnScreenCenter(padding = 32) {
		return camera.isOnScreen(centerX, centerY, padding + M.fmax(wid * 0.5, hei * 0.5));
	}

	/** Return TRUE if the Entity rectangle is in screen bounds (default padding is +32px) **/
	public inline function isOnScreenBounds(padding = 32) {
		return camera.isOnScreenRect(left, top, wid, hei, padding);
	}

	/**
		Changed the current entity state.
		Return TRUE if the state is `s` after the call.
	**/
	public function startState(s:State):Bool {
		if (s == state)
			return true;

		if (!canChangeStateTo(state, s))
			return false;

		var old = state;
		state = s;
		onStateChange(old, state);
		return true;
	}

	/** Return TRUE to allow a change of the state value **/
	function canChangeStateTo(from:State, to:State) {
		return true;
	}

	/** Called when state is changed to a new value **/
	function onStateChange(old:State, newState:State) {}

	/** Apply a bump/kick force to entity **/
	public function bump(x:Float, y:Float) {
		vBump.add(x, y);
	}

	/** Reset velocities to zero **/
	public function cancelVelocities() {
		v.clear();
		vBump.clear();
	}

	public function is<T:Entity>(c:Class<T>)
		return Std.isOfType(this, c);

	public function as<T:Entity>(c:Class<T>):T
		return Std.downcast(this, c);

	/** Return a random Float value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
	public inline function rnd(min, max, ?sign)
		return Lib.rnd(min, max, sign);

	/** Return a random Integer value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
	public inline function irnd(min, max, ?sign)
		return Lib.irnd(min, max, sign);

	/** Truncate a float value using given `precision` **/
	public inline function pretty(value:Float, ?precision = 1)
		return M.pretty(value, precision);

	public inline function dirTo(e:Entity)
		return e.centerX < centerX ? -1 : 1;

	public inline function dirToAng()
		return dir == 1 ? 0. : M.PI;

	public inline function getMoveTotalAng()
		return Math.atan2(dyTotal, dxTotal);

	public inline function getMoveAng()
		return Math.atan2(v.dy, v.dx);

	/** Return a distance (in grid cells) from this to something **/
	public inline function distCase(?e:Entity, ?tcx:Int, ?tcy:Int, txr = 0.5, tyr = 0.5) {
		if (e != null)
			return M.dist(cx + xr, cy + yr, e.cx + e.xr, e.cy + e.yr);
		else
			return M.dist(cx + xr, cy + yr, tcx + txr, tcy + tyr);
	}

	/** Return a distance (in pixels) from this to something **/
	public inline function distPx(?e:Entity, ?x:Float, ?y:Float) {
		if (e != null)
			return M.dist(attachX, attachY, e.attachX, e.attachY);
		else
			return return M.dist(attachX, attachY, x, y);
	}

	function canSeeThrough(cx:Int, cy:Int) {
		return !level.hasCollision(cx, cy) || this.cx == cx && this.cy == cy;
	}

	/** Check if the grid-based line between this and given target isn't blocked by some obstacle **/
	public inline function sightCheck(?e:Entity, ?tcx:Int, ?tcy:Int) {
		if (e != null)
			return e == this ? true : dn.geom.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
		else
			return dn.geom.Bresenham.checkThinLine(cx, cy, tcx, tcy, canSeeThrough);
	}

	/** Create a LPoint instance from current coordinates **/
	public inline function createPoint()
		return LPoint.fromCase(cx + xr, cy + yr);

	/** Create a LRect instance from current entity bounds **/
	public inline function createRect()
		return tools.LRect.fromPixels(Std.int(left), Std.int(top), Std.int(wid), Std.int(hei));

	public final function destroy() {
		if (!destroyed) {
			destroyed = true;
			GC.push(this);
		}
	}

	public function dispose() {
		ALL.remove(this);

		allVelocities = null;
		baseColor = null;
		blinkColor = null;
		colorMatrix = null;

		spr.remove();
		spr = null;

		if (debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}

		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}

		cd.dispose();
		cd = null;

		ucd.dispose();
		ucd = null;
	}

	/** Print some numeric value below entity **/
	public inline function debugFloat(v:Float, c:Col = 0xffffff) {
		debug(pretty(v), c);
	}

	/** Print some value below entity **/
	public inline function debug(?v:Dynamic, c:Col = 0xffffff) {
		#if debug
		if (v == null && debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}
		if (v != null) {
			if (debugLabel == null) {
				debugLabel = new h2d.Text(Assets.fontPixel, Game.ME.scroller);
				debugLabel.filter = new dn.heaps.filter.PixelOutline();
			}
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	/** Hide entity debug bounds **/
	public function disableDebugBounds() {
		if (debugBounds != null) {
			debugBounds.remove();
			debugBounds = null;
		}
	}

	/** Show entity debug bounds (position and width/height). Use the `/bounds` command in Console to enable them. **/
	public function enableDebugBounds() {
		if (debugBounds == null) {
			debugBounds = new h2d.Graphics();
			game.scroller.add(debugBounds, Const.DP_TOP);
		}
		invalidateDebugBounds = true;
	}

	function renderDebugBounds() {
		var c = Col.fromHsl((uid % 20) / 20, 1, 1);
		debugBounds.clear();

		// Bounds rect
		debugBounds.lineStyle(1, c, 0.5);
		debugBounds.drawRect(left - attachX, top - attachY, wid, hei);

		// Attach point
		debugBounds.lineStyle(0);
		debugBounds.beginFill(c, 0.8);
		debugBounds.drawRect(-1, -1, 3, 3);
		debugBounds.endFill();

		// Center
		debugBounds.lineStyle(1, c, 0.3);
		debugBounds.drawCircle(centerX - attachX, centerY - attachY, 3);
	}

	/** Wait for `sec` seconds, then runs provided callback. **/
	function chargeAction(id:ChargedAction, sec:Float, cb:Void->Void) {
		if (!isAlive())
			return;

		if (isChargingAction(id))
			cancelAction(id);
		if (sec <= 0)
			cb();
		else
			actions.push({id: id, cb: cb, t: sec});
	}

	/** If id is null, return TRUE if any action is charging. If id is provided, return TRUE if this specific action is charging nokw. **/
	public function isChargingAction(?id:ChargedAction) {
		if (!isAlive())
			return false;

		if (id == null)
			return actions.allocated > 0;

		for (a in actions)
			if (a.id == id)
				return true;

		return false;
	}

	public function cancelAction(?id:ChargedAction) {
		if (!isAlive())
			return;

		if (id == null)
			actions.empty();
		else {
			var i = 0;
			while (i < actions.allocated) {
				if (actions.get(i).id == id)
					actions.removeIndex(i);
				else
					i++;
			}
		}
	}

	/** Action management loop **/
	function updateActions() {
		if (!isAlive())
			return;

		var i = 0;
		while (i < actions.allocated) {
			var a = actions.get(i);
			a.t -= tmod / Const.FPS;
			if (a.t <= 0) {
				actions.removeIndex(i);
				if (isAlive())
					a.cb();
			} else
				i++;
		}
	}

	public inline function hasAffect(k:Affect) {
		return isAlive() && affects.exists(k) && affects.get(k) > 0;
	}

	public inline function getAffectDurationS(k:Affect) {
		return hasAffect(k) ? affects.get(k) : 0.;
	}

	/** Add an Affect. If `allowLower` is TRUE, it is possible to override an existing Affect with a shorter duration. **/
	public function setAffectS(k:Affect, t:Float, allowLower = false) {
		if (!isAlive() || affects.exists(k) && affects.get(k) > t && !allowLower)
			return;

		if (t <= 0)
			clearAffect(k);
		else {
			var isNew = !hasAffect(k);
			affects.set(k, t);
			if (isNew)
				onAffectStart(k);
		}
	}

	/** Multiply an Affect duration by a factor `f` **/
	public function mulAffectS(k:Affect, f:Float) {
		if (hasAffect(k))
			setAffectS(k, getAffectDurationS(k) * f, true);
	}

	public function clearAffect(k:Affect) {
		if (hasAffect(k)) {
			affects.remove(k);
			onAffectEnd(k);
		}
	}

	/** Affects update loop **/
	function updateAffects() {
		if (!isAlive())
			return;

		for (k in affects.keys()) {
			var t = affects.get(k);
			t -= 1 / Const.FPS * tmod;
			if (t <= 0)
				clearAffect(k);
			else
				affects.set(k, t);
		}
	}

	function onAffectStart(k:Affect) {}

	function onAffectEnd(k:Affect) {}

	/** Return TRUE if the entity is active and has no status affect that prevents actions. **/
	public function isConscious() {
		return !hasAffect(Stun) && isAlive();
	}

	/** Blink `spr` briefly (eg. when damaged by something) **/
	public function blink(c:Col = 0xffffff) {
		blinkColor.setColor(c);
		cd.setS("keepBlink", 0.06);
	}

	public function shakeS(xPow:Float, yPow:Float, t:Float) {
		cd.setS("shaking", t, true);
		shakePowX = xPow;
		shakePowY = yPow;
	}

	/** Briefly squash sprite on X (Y changes accordingly). "1.0" means no distorsion. **/
	public function setSquashX(scaleX:Float) {
		sprSquashX = scaleX;
		sprSquashY = 2 - scaleX;
	}

	/** Briefly squash sprite on Y (X changes accordingly). "1.0" means no distorsion. **/
	public function setSquashY(scaleY:Float) {
		sprSquashX = 2 - scaleY;
		sprSquashY = scaleY;
	}

	/**
		"Beginning of the frame" loop, called before any other Entity update loop
	**/
	public function preUpdate() {
		ucd.update(utmod);
		cd.update(tmod);
		updateAffects();
		updateActions();

		#if debug
		// Display the list of active "affects" (with `/set affect` in console)
		if (ui.Console.ME.hasFlag("affect")) {
			var all = [];
			for (k in affects.keys())
				all.push(k + "=>" + M.pretty(getAffectDurationS(k), 1));
			debug(all);
		}

		// Show bounds (with `/bounds` in console)
		if (ui.Console.ME.hasFlag("bounds") && debugBounds == null)
			enableDebugBounds();

		// Hide bounds
		if (!ui.Console.ME.hasFlag("bounds") && debugBounds != null)
			disableDebugBounds();
		#end

		if (isGrappling) {
			// Physique du pendule
			var gravity = 9; // Ajustez selon vos besoins
			var dampening = 0.999; // Facteur d'amortissement
	
			// Calculer l'accélération angulaire
			var accelerationAngle:Float = 0.0;
			if(attachX<grapplingPointX){
				accelerationAngle+=gravity * Math.sin(grappleAngle) / grappleLength;
			}else{
				accelerationAngle-=gravity * Math.sin(grappleAngle) / grappleLength;
			}
			
			
			// Mettre à jour la vitesse angulaire
			grappleVelocity += accelerationAngle * tmod;
			grappleVelocity *= dampening;
	
			// Mettre à jour l'angle
			grappleAngle += grappleVelocity * tmod;
	
			// Calculer la nouvelle position
			var newX = grapplingPointX - Math.cos(grappleAngle) * grappleLength;
			var newY = grapplingPointY - Math.sin(grappleAngle) * grappleLength;
	
			// Mettre à jour la position de l'entité
			setPosPixel(newX, newY);
		}
	}

	/**
		Post-update loop, which is guaranteed to happen AFTER any preUpdate/update. This is usually where render and display is updated
	**/
	public function postUpdate() {
		spr.x = sprX;
		spr.y = sprY;
		spr.scaleX = dir * sprScaleX * sprSquashX;
		spr.scaleY = sprScaleY * sprSquashY;
		spr.visible = entityVisible;

		sprSquashX += (1 - sprSquashX) * M.fmin(1, 0.2 * tmod);
		sprSquashY += (1 - sprSquashY) * M.fmin(1, 0.2 * tmod);

		if (cd.has("shaking")) {
			spr.x += Math.cos(ftime * 1.1) * shakePowX * cd.getRatio("shaking");
			spr.y += Math.sin(0.3 + ftime * 1.7) * shakePowY * cd.getRatio("shaking");
		}

		// Blink
		if (!cd.has("keepBlink")) {
			blinkColor.r *= Math.pow(0.60, tmod);
			blinkColor.g *= Math.pow(0.55, tmod);
			blinkColor.b *= Math.pow(0.50, tmod);
		}

		// Color adds
		spr.colorAdd.load(baseColor);
		spr.colorAdd.r += blinkColor.r;
		spr.colorAdd.g += blinkColor.g;
		spr.colorAdd.b += blinkColor.b;

		// Debug label
		if (debugLabel != null) {
			debugLabel.x = Std.int(attachX - debugLabel.textWidth * 0.5);
			debugLabel.y = Std.int(attachY + 1);
		}

		// Debug bounds
		if (debugBounds != null) {
			if (invalidateDebugBounds) {
				invalidateDebugBounds = false;
				renderDebugBounds();
			}
			debugBounds.x = Std.int(attachX);
			debugBounds.y = Std.int(attachY);
		}
	}

	/**
		Loop that runs at the absolute end of the frame
	**/
	public function finalUpdate() {
		prevFrameAttachX = attachX;
		prevFrameAttachY = attachY;
	}

	final function updateLastFixedUpdatePos() {
		lastFixedUpdateX = attachX;
		lastFixedUpdateY = attachY;
	}

	/** Called at the beginning of each X movement step **/
	function onPreStepX() {}

	/** Called at the beginning of each Y movement step **/
	function onPreStepY() {}

	/**
		Main loop, but it only runs at a "guaranteed" 30 fps (so it might not be called during some frames, if the app runs at 60fps). This is usually where most gameplay elements affecting physics should occur, to ensure these will not depend on FPS at all.
	**/
	public function fixedUpdate() {

		

		if (cd.has('hitBump')) {
			cd.setS('hitBlink', 0.5);
		}
		if (cd.has('hitBlink') && !cd.has('blinking')) {
			cd.setS('blinking', 0.2);
			if (isAlive()) {
				blink(0xff5500);
			}
		}

		updateLastFixedUpdatePos();

		/*
			Stepping: any movement greater than 33% of grid size (ie. 0.33) will increase the number of `steps` here. These steps will break down the full movement into smaller iterations to avoid jumping over grid collisions.
		 */
		var steps = M.ceil((M.fabs(dxTotal) + M.fabs(dyTotal)) / 0.33);
		if (steps > 0) {
			var n = 0;
			while (n < steps) {
				// X movement
				xr += dxTotal / steps;

				if (dxTotal != 0)
					onPreStepX(); // <---- Add X collisions checks and physics in here

				while (xr > 1) {
					xr--;
					cx++;
				}
				while (xr < 0) {
					xr++;
					cx--;
				}

				// Y movement
				yr += dyTotal / steps;

				if (dyTotal != 0)
					onPreStepY(); // <---- Add Y collisions checks and physics in here

				while (yr > 1) {
					yr--;
					cy++;
				}
				while (yr < 0) {
					yr++;
					cy--;
				}

				n++;
			}
		}

		// Update velocities
		v.fixedUpdate();
		vBump.fixedUpdate();
	}

	/**
		Main loop running at full FPS (ie. always happen once on every frames, after preUpdate and before postUpdate)
	**/
	public function frameUpdate() {}
}
