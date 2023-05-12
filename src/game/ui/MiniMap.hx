package ui;

class MiniMap extends h2d.Object {
	public var game:Game;
	public var containerMask:h2d.Object;//Mask;
	public var containerMap:h2d.Object;
	public var minimap:h2d.Graphics;
	public var mapTexture:h3d.mat.Texture;
	public var z:Float;
	public var player:sample.SamplePlayer;

	public function new(?p:h2d.Object) {
		super(p);
        p.addChild(this);
		game = Game.ME;
		player = game.player;
		// mask
		//containerMask = new h2d.Mask(64, 64, p);

		var mask = new h2d.Graphics();
		mask.beginFill(0x65ffffff);
		mask.drawCircle(4, 4, 64, 64);
		mask.endFill();

		// var mask:h2d.Mask = new h2d.Mask(64,64,root);

		//containerMask.x = 48;
		//containerMask.y = 16;

		// minimap
		containerMap = new h2d.Object(p);
		minimap = new h2d.Graphics(p);

		minimap.x = 32;
		minimap.y = 32;
		z = 0.08;
	}

	public function renderMap() {
		if (player == null) {
			player = game.player;
			trace(player.cx);
			//return;
		}

		var monde = Assets.worldData.getWorld(game.currentWorld);

		for (zone in monde.levels) {
			var vis = game.gameStats.has(zone.identifier + "_visited");
			if (!vis){
				//continue;
            }
			var couleur = vis && zone.identifier == game.level.data.identifier ? 0x00ff00 : 0xffff00;
			minimap.beginFill(couleur, 0.5);
			minimap.lineStyle(1, couleur);
			minimap.drawRect(zone.worldX * z, zone.worldY * z, zone.pxWid * z, zone.pxHei * z);
			minimap.endFill();
		}

		minimap.beginFill(0xffffff, 0.25);
		minimap.lineStyle(1, 0xffffff, 0.8);
		// minimap.drawCircle((currentLevel.worldX*z+player.cx*16*z),(currentLevel.worldY*z+player.cy*16*z),32,64);
		minimap.drawRect((game.level.data.worldX * z + player.cx * 16 * z) - 32, (game.level.data.worldY * z + player.cy * 16 * z) - 32, 64, 64);
		minimap.endFill();
		minimap.beginFill(0xff0000, 0.8);
		minimap.drawCircle((game.level.data.worldX * z + player.cx * 16 * z), (game.level.data.worldY * z + player.cy * 16 * z), 1, 16);
		minimap.endFill();
		minimap.x -= game.level.data.worldX * z + player.cx * 16 * z;
		minimap.y -= game.level.data.worldY * z + player.cy * 16 * z;
		// minimap.clip();
		// minimap.drawTo(mapTexture);
		// minimap.filter=new h2d.filter.Mask(mask);
		//containerMask.addChild(containerMap);
		containerMap.filter = new dn.heaps.filter.PixelOutline();
		//game.root.addChild(containerMask);
	}
}
