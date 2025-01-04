package page;

class InventoryPage extends GameChildProcess {
	var racine:h2d.Layers;
	var ca:ControllerAccess<GameAction>;
	var bgCol:h2d.Bitmap;
	var ready:Bool;
	var itemList:h2d.Text;
	var miniMap:ui.MiniMap;

	public function new() {
		super();
		createRootInLayers(parent.root, Const.DP_UI);
		racine = new h2d.Layers(root);
		racine.scale(2);
		ready = false;
		ca = App.ME.controller.createAccess();

		bgCol = new h2d.Bitmap(h2d.Tile.fromColor(Col.inlineHex("#000000")));
		racine.add(bgCol, Const.DP_MAIN);

		var rect = new h2d.Graphics(racine);
		rect.beginFill(Black, 0.85);
		rect.drawRect(0, 0, stageWid, stageHei);
		racine.under(rect);
		rect.x = -stageWid;
		tw.createS(rect.x, 0, 0.5).end(() -> {
			ready = true;
		});
		itemList = new h2d.Text(Assets.fontPixel, racine);
		itemList.text = game.player.inventory.toString();

		var mainFlow = new h2d.Flow(rect);
		mainFlow.layout = Horizontal;
		mainFlow.verticalAlign = Top;
		mainFlow.multiline=true;
		mainFlow.addSpacing(16);
		mainFlow.padding = 8;
		mainFlow.colWidth = 32;
		mainFlow.lineHeight = 32;
		mainFlow.maxHeight = stageHei;
		mainFlow.maxWidth = Std.int(stageWid*0.5);
		mainFlow.minWidth = Std.int(stageWid * 0.15);
		mainFlow.backgroundTile = Assets.tiles.getTile(D.tiles.mainFlowBox);
		mainFlow.borderWidth = 3;
		mainFlow.borderHeight = 3;

		var flowMap = new h2d.Flow(mainFlow);
		flowMap.layout = Vertical;
		flowMap.verticalAlign = Top;
		//flowMap.addSpacing(16);
		flowMap.padding = 8;
		//flowMap.colWidth = 32;
		flowMap.minHeight = 196;
		flowMap.maxHeight = Std.int(stageHei * 0.25);
		flowMap.minWidth = 128;
		flowMap.maxWidth = 512;
		flowMap.backgroundTile = Assets.tiles.getTile(D.tiles.mapBox);
		flowMap.borderWidth = 16;
		flowMap.borderHeight = 16;
		flowMap.scale(2);

		var flow = new h2d.Flow(mainFlow);
		flow.layout = Vertical;
		flow.verticalAlign = Top;
		//flow.addSpacing(16);
		flow.multiline=true;
		flow.padding = 8;
		flow.colWidth = 32;
		flow.lineHeight = 32;
		flow.maxHeight = Std.int(stageHei * 0.25*Const.SCALE);
		flow.maxWidth = Std.int(stageWid * 0.25*Const.SCALE);
		flow.minWidth = Std.int(stageWid * 0.15*Const.SCALE);
		flow.backgroundTile = Assets.tiles.getTile(D.tiles.itemSlot);
		flow.borderWidth = 4;
		flow.borderHeight = 4;

		miniMap = new ui.MiniMap(flowMap);
		miniMap.updateMapPosition();
		miniMap.renderMap();
		miniMap.scale(2);

		for (i in 0...game.player.inventory.length) {
			// trace(game.player.inventory[i]);
			if (game.player.inventory[i] is sample.Craft) {
				// trace(game.player.inventory[i].title);
				var itemFlow = new h2d.Flow(flow);
				itemFlow.layout = Vertical;
				itemFlow.verticalAlign = Top;
				//itemFlow.addSpacing(16);
				itemFlow.padding = 8;
				//itemFlow.colWidth = 32;
				//itemFlow.lineHeight = 32;
				itemFlow.maxHeight = 32;
				itemFlow.maxWidth = 32;
				itemFlow.minWidth = 32;
				itemFlow.backgroundTile = Assets.tiles.getTile(D.tiles.itemSlot);
				itemFlow.borderWidth = 4;
				itemFlow.borderHeight = 4;
				var item = new h2d.Interactive(32, 32, itemFlow);
				item.onOver = (e:hxd.Event) -> {
					item.setScale(1.5);
				};
				item.onOut = (e:hxd.Event) -> {
					item.setScale(1);
				};
				var img = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.bag), item);
				var label = new h2d.Text(Assets.fontPixel, item);
				label.y = 16;
				label.dropShadow = {
					dx: 0.5,
					dy: 0.5,
					color: 0x1BF2E7,
					alpha: 0.8
				};
				label.text = game.player.inventory[i].title + " X" + game.player.inventory[i].quantity;
			} else {
				// trace(game.player.inventory[i]);

				var img = null;
				switch (game.player.inventory[i]) {
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
				var itemFlow = new h2d.Flow(flow);
				itemFlow.layout = Vertical;
				itemFlow.verticalAlign = Top;
				//itemFlow.addSpacing(16);
				itemFlow.padding = 8;
				itemFlow.overflow = Hidden;
				//itemFlow.colWidth = 32;
				//itemFlow.lineHeight = 32;
				itemFlow.maxHeight = 32;
				itemFlow.maxWidth = 32;
				itemFlow.minWidth = 32;
				itemFlow.backgroundTile = Assets.tiles.getTile(D.tiles.itemSlot);
				itemFlow.borderWidth = 4;
				itemFlow.borderHeight = 4;
				var item = new h2d.Interactive(32, 32, itemFlow);
				item.onOver = (e:hxd.Event) -> {
					item.setScale(1.5);
				};
				item.onOut = (e:hxd.Event) -> {
					item.setScale(1);
				};
				var bmp = new h2d.Bitmap(Assets.tiles.getTile(img), item);
				var label = new h2d.Text(Assets.fontPixel, item);
				label.y = 16;
				label.dropShadow = {
					dx: 0.5,
					dy: 0.5,
					color: 0xF21BAA,
					alpha: 0.8
				};
				if (Std.string(game.player.inventory[i]) == "Money") {
					label.text = Std.string(game.player.inventory[i] + " X" + game.player.money);
				} else {
					label.text = Std.string(game.player.inventory[i]);
				}
			}
		}
	}

	override function update() {
		super.update();
		// miniMap.updateMapPosition();
		miniMap.renderMap();
		if (!ready)
			return;
		if (ca.isPressed(Pause) || ca.isPressed(Lazer) || ca.isPressed(InventoryScreen) || ca.isKeyboardPressed(K.I)) {
			if (Game.exists()) {
				Game.ME.ca.unlock();
				Game.ME.resume();
			}
			destroy();
		}
		if (ca.isKeyboardPressed(K.ESCAPE)) {
			if (Game.exists()) {
				Game.ME.ca.unlock();
				Game.ME.resume();
			}
			destroy();
		}
	}
}
