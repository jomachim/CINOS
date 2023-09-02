package sample;

import GameStats.Achievement;
import h2d.filter.Bloom;

class Chest extends Entity {
	public static var ALL:Array<Chest> = [];

	var anims = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.chest);

	// public var locked:Bool=false;
	public var requierements:Dynamic;
	public var loots:Array<Dynamic> = [];
	public var looted:Bool = false;
	public var data:Entity_Chest;
	public var locked:Bool = false;
	public var bmp:h2d.Bitmap;

	var opened(get, never):Bool;

	inline function get_opened()
		return spr.anim.isPlaying(anims.opened) && locked == false;

	public function new(ch:Entity_Chest) {
		super(ch.cx, ch.cy);
		data = ch;
		requierements = ch.f_requiered_item;
		locked = requierements != null ? true : ch.f_locked ? true : false;
		loots = ch.f_loots;
		looted = false;

		// Placeholder display

		// trace(ch.iid);
		var outline = spr.filter = new dn.heaps.filter.PixelOutline(0x330000, 0.4);
		var bloom = new h2d.filter.Glow(0xeeffee, 0.5, 4, 0.5, 1, true);
		var group = new h2d.filter.Group([outline, bloom]);
		spr.filter = group;
		spr.set(Assets.chest);

		// spr.anim.registerStateAnim(anims.closed, 2,()->cd.getS("recentlyTeleported")>0);
		spr.anim.registerStateAnim(anims.closed, 0, 2, () -> !looted);
		spr.anim.registerStateAnim(anims.opened, 10, 2, () -> looted);
		spr.anim.registerStateAnim(anims.opened, 100, 2, () -> game.gameStats.has(data.iid + "looted"));

		var img = null;
		if (loots[0] != null) {
			switch (loots[0]) {
				case GoldKey:
					img = D.tiles.goldKey;
				case DashBoard:
					img = D.tiles.dashRune;
				case LazerGun:
					img = D.tiles.lazerGun;
				case SimpleKey:
					img = D.tiles.simpleKey;
				case WallClaws:
					img = D.tiles.wallRune;
				case NinjaKit:
					img = D.tiles.ninjaRune;
				case Money:
					img = D.tiles.money;
				case Health:
					img = D.tiles.apple;
				case Flippers:
					img = D.tiles.flippers;
				case SecurityCard:
					img = D.tiles.idCard;
				case ToolKit:
					img = D.tiles.toolKit;
				case Capsul:
					img = D.tiles.energyCapsul;
				case GreenJem:
					img = D.tiles.greenJem;
				case WorldMap:
					img = D.tiles.worldMap;
				case _:
					img = D.tiles.bag;
			}
			if (!game.gameStats.has(data.iid + "looted") || looted) {
				bmp = new h2d.Bitmap(Assets.tiles.getTile(img), spr);

				bmp.x -= 8;
				bmp.y = -20;
			}
		}
		var g = new h2d.Graphics(spr);
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		// debug(data.f_Entity_ref.entityIid,0xff0000);
		if (locked == true && game.gameStats.has(data.iid + "activated")) {
			locked = false;
		}

		if (looted == true || game.gameStats.has(data.iid + "looted")) {
			looted = true;
			return;
		}

		if (distCase(game.player) <= 2 && opened == false) {
			if (game.player.cd.has("recentlyPressedAction")) {
				if (locked == true && data.f_requiered_item != null && game.player.inventory.contains(data.f_requiered_item)) {
					locked = false;
					S.open01().play(false, App.ME.options.volume).pitchRandomly(0.34);
					S.tvbreak01().play(false, App.ME.options.volume).pitchRandomly(0.34);
					bmp.remove();
					// game.player.upgradeResource.play(false,1.0);
					//trace('requiered item unlocked the chest');
					game.player.inventory.remove(data.f_requiered_item);
				} else if (locked == true) {
					fx.markerText(cx, cy - 2, "LOCKED");
					S.wrong().play(false, App.ME.options.volume * 0.5).pitchRandomly(0.14);
					// game.player.wrongResource.play();
				} else {
					looted = true;
					var i = 0;
					S.tvbreak01().play(false, App.ME.options.volume).pitchRandomly(0.34);
					bmp.remove();
					for (loot in loots) {
						i++;
						if (loot == Money) {
							game.player.money += irnd(1, 100);
							game.delayer.addS('chling', () -> {
								S.chling01().play(false, App.ME.options.volume * 0.5).pitchRandomly(0.34);
							}, i * 0.2);
						}
						/*if(loot==Air_Rune){
								game.player.maxJumps++;
								game.player.giftResource.play(false).volume=1;
							}
							if(loot==Fire_Rune){
								game.player.canFire=true;
								game.player.giftResource.play(false).volume=1;
							}
							if(loot==Earth_Rune){
								game.player.canQuake=true;
								game.player.giftResource.play(false).volume=1;
						}*/
						if (loot == DashBoard) {
							game.player.canDash = true;
							new ui.DialogBox([
								"You can now DASH !",
								"It boosts and lets you invincible for the time of the DASH."
							], game.scroller);
							// game.player.giftResource.play(false).volume=1;
						}
						if (loot == LazerGun) {
							game.player.canLazer = true;
							new ui.DialogBox(["You can now use the LazerGun !", "The Lazer beam will destroy any stone."], game.scroller);
							// game.player.giftResource.play(false).volume=1;
						}
						if (loot == WallClaws) {
							game.player.canWallJump = true;
							new ui.DialogBox([
								"You can now use Wall Claws !",
								"When you are against a wall, just press JUMP with LEFT or RIGHT,",
								"the direction you face the wall."
							], game.scroller);
							// game.player.giftResource.play(false).volume=1;
						}
						if (loot == NinjaKit) {
							game.player.canNinja = true;
							new ui.DialogBox(["You can now throw Ninja stuff !"], game.scroller);
							// game.player.giftResource.play(false).volume=1;
						}
						if (loot == Flippers) {
							game.player.canSwim = true;
							new ui.DialogBox(["You can now SWIM !"], game.scroller);
							// game.player.giftResource.play(false).volume=1;
						}
						if (loot == Health) {
							game.player.maxLife++;
						}
						if (!game.player.inventory.contains(loot)) {
							if (!game.gameStats.has(loot + " Obtained")) {
								var a = new Achievement(loot + " Obtained", loot + " Obtained", () -> game.player.inventory.contains(loot));
								game.gameStats.registerState(a);
								// game.player.upgradeResource.play(false,1.0);
							}
							game.player.inventory.push(loot);
						}
					}
					// trace(game.player.inventory[0]);
					// game.player.goodResource.play(false,0.1);
					spr.anim.play(anims.opened);
					if (!game.gameStats.has(data.iid + "looted")) {
						var a = new Achievement(data.iid + "looted", "looted", () -> looted == true);
						game.gameStats.registerState(a);
					}
				}
			}
		}
	}
}
