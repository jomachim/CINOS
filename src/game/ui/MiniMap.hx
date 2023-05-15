package ui;

class MiniMap extends h2d.Object {
	public var game:Game;
	public var containerMask:h2d.Object;//Mask;
	public var containerMap:h2d.Object;
	public var minimap:h2d.Graphics;
	public var mapTexture:h3d.mat.Texture;
	public var z:Float;
	public var player:sample.SamplePlayer;
	public var mapFlow:h2d.Flow;
	public var carte:h2d.Bitmap;

	public function new(?p:h2d.Object) {
		super(p);
        p.addChild(this);
		game = Game.ME;
		player = game.player;
		
		mapTexture=new h3d.mat.Texture(1024,1024,[Target]);
		
		//game.root.addChild(this);
		mapFlow=new h2d.Flow(this);
		mapFlow.scale(1);
		mapFlow.addSpacing(16);
		mapFlow.overflow=Hidden;
		mapFlow.verticalAlign=Bottom;
		mapFlow.horizontalAlign=Left;
		//mapFlow.backgroundTile=h2d.Tile.fromTexture(mapTexture);
		carte=new h2d.Bitmap(h2d.Tile.fromTexture(mapTexture));
		this.addChild(carte);
		// mask
		containerMask = new h2d.Mask(64, 64, mapFlow);
		
		// minimap
		containerMap = new h2d.Object(containerMask);
		minimap = new h2d.Graphics(containerMap);

		minimap.x = 32;
		minimap.y = 32;
		z = 0.01;
		minimap.filter = new dn.heaps.filter.PixelOutline();


	}

	public function updateMapPosition(){
		/*mapFlow.backgroundTile=h2d.Tile.fromTexture(mapTexture);
		mapFlow.backgroundTile.dx= player.cx * 16 * z+32;
		mapFlow.backgroundTile.dy= player.cy * 16 * z+32;*/
		carte.tile=h2d.Tile.fromTexture(mapTexture);
		carte.x=-game.level.data.worldX * z- player.cx * 16 * z+32;
		carte.y=-game.level.data.worldY * z- player.cy * 16 * z+32;
	}

	public function renderMap() {
		if (player == null) {
			player = game.player;
			return;
			trace(player.cx);
			//
		}
		minimap.clear();
		var monde = Assets.worldData.getWorld(game.currentWorld);
		for (zone in monde.levels) {
			var vis = game.gameStats.has(zone.identifier + "_visited");
			if (!vis){
				continue;
            }
			var couleur = vis && zone.identifier == game.level.data.identifier ? 0x00ff00 : 0xffff00;
			minimap.beginFill(couleur, 0.5);
			minimap.lineStyle(1, couleur);
			minimap.drawRect(zone.worldX * z, zone.worldY * z, zone.pxWid * z, zone.pxHei * z);
			minimap.endFill();
			
		}
		monde=null;
		/*minimap.beginFill(0xffffff, 0.25);
		minimap.lineStyle(1, 0xffffff, 0.8);

		minimap.drawRect(game.level.data.worldX * z+ player.cx * 16 * z-32,game.level.data.worldY * z+ player.cy * 16 * z-32, 64, 64);
		minimap.endFill();
		minimap.beginFill(0xff0000, 0.8);
		minimap.drawCircle((game.level.data.worldX * z + player.cx * 16 * z), (game.level.data.worldY * z + player.cy * 16 * z), 2, 16);
		minimap.endFill();*/
		minimap.x = -game.level.data.worldX * z- player.cx * 16 * z+32;
		minimap.y = -game.level.data.worldY * z- player.cy * 16 * z+32;
		
		minimap.drawTo(mapTexture);
		//minimap.clear();
	}
}

/* TO DO :

- render world map at level start as texture
- attach it to HUD
- use texture for hud and tile for player position
- use M key to tween map size on hud


*/