package sample;

import hxd.snd.openal.AudioTypes.BufferHandle;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/
class SamplePlayer extends Entity {
	public var ca:ControllerAccess<GameAction>;
	var walkSpeed = 0.;
	var jumpSpeed = 0.;
	public var lazerAngle = 0.1;
	var gamePadDir:Int = 0;
	var dashSpeed:Float = 0.85;
	public var lazerCoolDownTime:Float=2.5;
	var lastDir:Int = 0;

	public var normalShader:NormalShader;
	public var inventory:Array<Dynamic>;

	public var timeBonus:Float = 120;
	public var jumpTime:Float=0;
	public var xp:Float=1;
	public var niveau:Float=1;
	public var speedX(get, never):Float;
	public var speedY(get, never):Float;

	public var destination = {
		level: null,
		door: null,
		layer:null,
		world:null
	}
	public var parented:Null<Entity>=null;


	inline function get_speedX()
		return v.dx;
	
	inline function get_speedY()
		return v.dy;

	// This is TRUE if the player is not falling
	var onGround(get, never):Bool;

	inline function get_onGround()
		return !destroyed && ((v.dy == 0 && yr == 1 && level.hasCollision(cx, cy + 1)) || cd.has('recentlyOnElevator'));//

	var onSlope(get, never):Bool;

	inline function get_onSlope():Bool
		return !destroyed && v.dy == 0 && (level.isLUSlope(cx, cy) || level.isRUSlope(cx, cy));

	public function new() {
		super(5, 5);
		inventory=[];
		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if (start != null)
			setPosCase(start.cx, start.cy);
		if(App.ME.currentSavedGame!=null){
			//trace(App.ME.currentSavedGame);
			var s=App.ME.currentSavedGame;
			cx=s.data.playerPosition.x;
			cy=s.data.playerPosition.y;
			onPosManuallyChangedBoth();
		}
		// Misc inits
		v.setFricts(0.905, 0.955);
		initLife(10);
		hud.setLife(life, maxLife);
		// Camera tracks this
		camera.trackEntity(this, true);
		camera.zoomTo(1.15);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

		// Placeholder display
		/*var b = new h2d.Bitmap(h2d.Tile.fromColor(Green, iwid, ihei), spr);
			b.tile.setCenterRatio(0.5, 1); */

		var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.hero);
		spr.set(Assets.hero);
		spr.setPivotCoord(wid*0.5,25);
		spr.anim.registerStateAnim(anims.jump, 6, () -> !cd.has("recentlyOnGround") && !cd.has('recentlyOnElevator'));
		spr.anim.registerStateAnim(anims.fall, 7, () -> !cd.has("recentlyOnGround") && v.dy > 0);
		spr.anim.registerStateAnim(anims.idle, 0, () -> cd.has('recentlyOnGround') && v.dx == 0);
		spr.anim.registerStateAnim(anims.run, 2, () -> cd.has("recentMove"));
		spr.anim.registerStateAnim(anims.roll, 4,1+M.fabs(v.dx), () -> !cd.has('recentlyOnElevator') && cd.has('recentlyOnGround') && !cd.has("recentMove") && (v.dy > 0 || cd.has('isPressingDown')));
		spr.anim.registerStateAnim(anims.roll, 8, () -> cd.has('dashing'));
		spr.anim.registerStateAnim(anims.speedrun, 3, () -> cd.has("recentMove") && M.fabs(v.dx) > 0.35);
		outline.color = 0x000000;
		
		//spr.colorize(Col.inlineHex('0xaaaaff'), 1);
		// game.player=this;
	}

	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}

	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();
		// cd.setMs('recentlyOnSlope', 0);
		if(level.hasCollision(cx+dir,cy) && !level.hasCollision(cx+dir,cy-1) && yr<0.5){
			yr=1;
			cy--;
		}
		// Right collision
		if (xr > 0.8 && level.hasCollision(cx + 1, cy)) {
			if (!level.isLUSlope(cx, cy) && !level.isLUSlope2(cx,cy)) {
				xr = 0.8;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx + 1, cy-1)) {
				xr = 0.8;
				if (!cd.has('recentlyOnGround') && ca.isDown(MoveRight) && ca.isDown(Jump) && !cd.has('wallJump')) {
					cd.setMs('wallJump', 250);
					fx.wallDust(attachX, attachY, dir, 0xffffff);
					v.dx = -0.62;
					v.dy = -0.543;
					cd.setS('startJumping', 0.33+jumpTime*0.001);
				}
			}
		}

		// Left collision
		if (xr < 0.2 && level.hasCollision(cx - 1, cy)) {
			if (!level.isRUSlope(cx, cy) && !level.isRUSlope2(cx,cy)) {
				xr = 0.2;
				vBump.dx = 0;
			}

			if (level.hasCollision(cx - 1, cy-1)) {
				xr = 0.2;
				if (!cd.has('recentlyOnGround') && ca.isDown(MoveLeft) && ca.isDown(Jump) && !cd.has('wallJump')) {
					cd.setMs('wallJump', 250);
					fx.wallDust(attachX, attachY, dir, 0xffffff);
					v.dx = 0.62;
					v.dy = -0.543;
					cd.setS('startJumping', 0.33+jumpTime*0.001);
				}
			}
		}

		// Slope LU
		if (yr > 1 - xr && level.isLUSlope(cx, cy)) {
			yr = 1 - xr;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (xr < yr && level.isRUSlope(cx, cy)) {
			yr = xr;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// slope LU2
		if (yr > 1 - xr/2 && level.isLUSlope2(cx, cy)) {
			yr = 1 - xr/2;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}
		// slope RU2
		if (yr >= xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx+1, cy)) {
			yr = xr/2;
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5+xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx-1, cy)){
			yr = 0.5+xr/2;
			cd.setS("recentlyOnGround", 0.1);
		}

	}

	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();
		if(cd.has('recentlyOnGround') && level.hasCollision(cx+dir,cy) && !level.hasCollision(cx+dir,cy-1) && yr<=0.3){
			yr=0;
		}
		// Slope LU
		if (yr >= 1 - xr && level.isLUSlope(cx, cy)) {
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185*0.5;
			vBump.dy += 0.00185*0.25;
			yr = 1 - xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope LU2
		if (yr >= 1 - xr/2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx+1, cy)) {
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;
			yr = 1 - xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5 - xr/2 && level.isLUSlope2(cx, cy) && level.isLUSlope2(cx-1, cy)){
			v.dx -= v.dy * 0.015;
			vBump.dx -= 0.00185;
			vBump.dy += 0.00185;
			yr = 0.5 - xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU
		if (yr >= xr && level.isRUSlope(cx, cy)) {
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185*0.5;
			vBump.dy += 0.00185*0.25;
			yr = xr;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope RU2
		if (yr >= xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx+1, cy)) {
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;
			yr = xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}else if(yr >= 0.5+xr/2 && level.isRUSlope2(cx, cy) && level.isRUSlope2(cx-1, cy)){
			v.dx += v.dy * 0.015;
			vBump.dx += 0.00185;
			vBump.dy += 0.00185;
			yr = 0.5+xr/2;
			// v.dy=0;
			// onPosManuallyChangedY();
			cd.setS("recentlyOnGround", 0.1);
		}

		// Slope LD
		if (yr <= xr && level.isLDSlope(cx, cy - 1)) {
			v.dy = M.fabs(v.dx) * 0.5;
			// jumpSpeed -= M.fabs(v.dx);
			yr = xr;
			onPosManuallyChangedY();
		}
		// Slope RD
		if (yr <= 1 - xr && level.isRDSlope(cx, cy - 1)) {
			v.dy = M.fabs(v.dx) * 0.5;
			// jumpSpeed -= M.fabs(v.dx);
			yr = 1 - xr;
			onPosManuallyChangedY();
		}

		// Land on ground
		if (yr > 1 && level.hasCollision(cx, cy + 1)) {
			setSquashY(0.5);
			v.dy = 0;
			vBump.dy = 0;
			yr = 1;
			ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
			fx.fallDust(attachX, attachY, dirToAng(), dir);
		}

		// Ceiling collision
		if (yr < 0.9 && level.hasCollision(cx, cy - 1)) {
			yr = 0.9;
			v.dy = 0;
		}

		// you're not supposed to be there
		if (level.hasCollision(cx, cy)) {
			yr = 1;
			cy--;
			cd.setS("recentlyOnGround", 0.1);
		}
	}

	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/

	public function doDash(){
		cd.setMs('dashing', 500);
		v.dx = gamePadDir*dashSpeed;//dir * 0.85;
	}
	public function doLazer(){
		var d:Float = 0.0;
			for (i in 0...30) {
				// needs angle int 
				var tx=Std.int(i*Math.cos(lazerAngle));
				var ty=Std.int(i*Math.sin(lazerAngle));
				if (level.hasCollision(cx + tx, cy+ty)) {
					d = distCase(cx +tx, cy+ty);
					
					if (level.breakables.has(Breaks, cx +tx, cy+ty)) {
						level.breakables.remove(Breaks, cx +tx, cy+ty);
						level.breakables.set(Breaking, cx +tx, cy+ty);
					}else if(level.breakables.has(Breaking, cx +tx, cy+ty)){
						level.breakables.remove(Breaking, cx +tx, cy+ty);
						level.breakables.set(Broken, cx +tx, cy+ty);
					}
					

					break;
				}
			}
			fx.lazer(centerX, centerY, dir, d * Const.GRID, 0.04,0xff0000,lazerAngle);
	}
	public function doFire(){
		cd.setMs('firing', 150);
		new sample.Bullet(cx, cy - 1, dir, this);
	}

	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;
		jumpSpeed = 0;
		jumpTime = (Std.int(xp)*0.1);
		if (onGround) {
			cd.setS("recentlyOnGround", 0.1); // allows "just-in-time" jumps
		}

		if (ca.isDown(MoveDown)) {
			cd.setS('isPressingDown', 0.1);
		}

		if(cd.has("doLazerTuto")){
			lazerAngle+=0.2;
			doLazer();
		}

		// burnout
		if (cd.has('recentlyOnGround') && M.fabs(v.dx) > 0.6 && !cd.has('burn')) { // && !cd.has("recentMove")
			fx.burnOut(centerX, centerY, getMoveAng(), dir);
			cd.setS('burn', rnd(0.01, 0.03));
		}

		// Jump
		if (cd.has("recentlyOnGround") && ca.isPressed(Jump)) {
			if(cd.has("recentlyOnElevator")) v.dy=0;
			v.dy = -0.34;
			vBump.dy = 0;
			jumpSpeed = 0.24;
			setSquashX(0.9);
			cd.unset("recentlyOnGround");
			cd.setS("startJumping", 0.33+jumpTime*0.08);
			// fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			fx.fallDust(centerX, attachY, getMoveAng(), dir);
			ca.rumble(0.05, 0.06);
		}
		// post jump in fixedUpdate;
		if (cd.has("startJumping")) {
			if (ca.isDown(Jump)) {
				// v.dy - = cd ...
				jumpSpeed = cd.getRatio("startJumping") * 0.1143;
			} else {
				cd.unset("startJumping");
				jumpSpeed = 0;
			}
		}

		// Dash
		if (ca.isPressed(Dash) && !cd.has('dashing')) {
			doDash();
		}
		if (cd.has('dashing')) {
			fx.dash(centerX, centerY, v.dx, getMoveAng());
			fx.powerCircle(centerX,centerY,0.01,this);
		}
		
		// Walk
		if (ca.getAnalogDist2(MoveLeft, MoveRight) > 0) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue2(MoveLeft, MoveRight); // -1 to 1
			gamePadDir=walkSpeed<0?-1:1;
			lazerAngle=ca.getAnalogAngle4(MoveLeft,MoveRight,MoveUp,MoveDown);
			cd.setMs('recentMove', 10);
		}
		if(ca.isDown(Lock)){// & onGround
			walkSpeed = 0;
			if(onGround) v.dy=0;
		}
		
		// fire
		if (ca.isDown(Fire) && !cd.has('firing')) {
			cd.setMs('firing', 150);

			new sample.Bullet(cx, cy - 1, dir, this);
		}
		// gameAction lazer

		if (ca.isDown(Lazer)) {
			doLazer();
		}

	}

	override function onDamage(dmg:Int, from:Null<Entity>) {
		cd.setS('glitch',0.5);
		fx.cat(camera.centerX,camera.centerY,0.8,0xFF0000);// App.ME.w() taille de tout le level
		super.onDamage(dmg, from);
		game.hud.setLife(life, maxLife);
	}
	public function updateHudLife(){
		game.hud.setLife(life, maxLife);
	}
	override function onDie() {
		//
		// ensure all garbage collection is done
		// dispose game ?();

		/*Game.ME.fadeOut(1, () -> {});
			Game.ME.destroy();
		 */
		Game.ME.fx.clear();
		dn.Process.updateAll(1);
		game.destroy();
		hxd.Timer.skip();
		App.ME.startTitleScreen();
		// super.onDie();
		// game.pause();
	}

	public function renderLife() {
		/*lifeBar.visible ==0 && isAlive() && maxLife>0;
			lifeBar.visible = false;
			if( lifeBar.visible ) {
				lifeBar.empty();
				lifeBar.addIcons(D.tiles.iconHeart, life);
		}*/
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		
		if(level.hasCheckPoint(cx,cy) && !cd.has('saving')){
			cd.setS('saving',3);
			//trace('saving game...');
			game.hud.notify('saving...');
			game.saveGame();
			//game.pause();
		}
		if(level.hasJumper(cx,cy) && !cd.has('jumper')){
			//trace('jumper');
			cd.setMs('jumper',100);
			v.dy-=1.7;
		}
		if(level.hasIce(cx,cy+1) && !cd.has('ice')){
			//trace('ICE !');
			cd.setMs('ice',16);
			v.dx*=1.056;
			fx.cloud(spr.x,spr.y+rnd(-16,16),0,dir);
		}
		
		/*if(cd.has('glitch')){
			App.ME.simpleShader.shader.multiplier = Math.sin(cd.getRatio('glitch'))*20;
		}else{
			App.ME.simpleShader.shader.multiplier = 0.4;
		}
		// camera zoom
		if (!camera.isOnScreen(centerX, centerY, -8)) {
			// trace('hey reviens léon');
			camera.zoomTo(camera.zoom * 0.9);
		} else if (!camera.isOnScreen(centerX, centerY, 512)) {
			camera.zoomTo(camera.zoom * 1.1);
		} else {
			camera.zoomTo(1.2);
		}*/

		// jumps

		v.dy -= jumpSpeed;
		#if (hl && debug)
		//if (isAlive())
			//debug(pretty(lazerAngle, 2), 0x00ff00);
		#end
		// Gravity
		if (!onGround && !cd.has('recentlyOnElevator')) {
			v.dy += 0.044;
		}
		/*else{
			v.dx*=0.9;
		}*/
		if (dyTotal > 0.8) {
			v.dy = 0.8;
			vBump.dy = 0.0;
		}
		// Apply requested walk movement
		if (walkSpeed != 0)
			v.dx += walkSpeed * 0.075; // some arbitrary speed
		if (M.fabs(v.dx) < 0.025)
			v.dx *= 0.4;
		dir = v.dx >= 0 ? 1 : -1;
		if (v.dx != 0) {
			lastDir = dir;
			//debug(M.fabs(v.dx));
			if (cd.has('recentlyOnGround') && M.fabs(v.dx) > 0.4)
				fx.flame(centerX, centerY);
				//fx.heat(centerX, centerY);
		} else {
			dir = lastDir;
		}

		if(spr.anim.getAnimId()=="roll"){
			spr.anim.setSpeed(M.fabs(v.dx)*8);
		}
		if(cd.has('recentlyOnElevator')){
			if(parented!=null){
				spr.y=parented.spr.y;
				onPosManuallyChangedY();
			}
		}else{
			parented=null;
		}
		
	}
	override function frameUpdate(){
		super.frameUpdate();
		// time bonus
		if (!cd.has('countDown')) {
			cd.setS('countDown', 1);
			hud.setTimeS(timeBonus);
			hud.invalidate();
			timeBonus++;
			if (timeBonus >= Const.CYCLE_S) {//+game.gameTimeS
				if(!cd.has('hitBump')) {
					cd.setS('hitBump', 1.2);
					S.ouch04(App.ME.options.volume);
					fx.flashBangEaseInS(Red, 0.4, 1);
					hit(1,null);
				}
				timeBonus=0;
				game.gameTimeS=0;
			}
		}
	}
}
