package sample;

/**
	This small class just creates a SamplePlayer instance in current level
**/
class SampleGame extends Game {
	
	public function new() {
		super();
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);
		/*if(player==null) player=new SamplePlayer();
		simpleShader = new sample.SimpleShader(2.0);
		simpleShader.shader.multiplier = 5;
		filterGroup=new h2d.filter.Group([simpleShader, new dn.heaps.filter.Crt()]);
		Game.ME.root.getScene().filter = filterGroup;*/
	}
}

