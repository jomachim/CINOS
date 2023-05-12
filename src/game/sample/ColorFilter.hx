package sample;
import h3d.Engine;

// --- Filter -------------------------------------------------------------------------------
class ColorFilter extends h2d.filter.Shader<InternalShader> {
	public function new() {
		super(new InternalShader());
		shader.pxscale = new hxsl.Types.Vec(1.0 / 1280.0, 1.0 / 720.0);
		shader.passed = 0.5; // channel decay amount default 1.25
	}
	
	public var passed(default,set): Float;
	public inline function set_passed(v:Float) return passed = shader.passed = v;
}

// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture:Sampler2D;
		@param var pxscale:Vec2;
		@param var passed:Float;
		function rand(v:Vec2):Float{
			return cos(fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453))+0.5;
		}
		function fragment() {
			var uv = input.uv;
			var cr = texture.get(uv).r; // 201
			var cg = texture.get(uv).g; // 212
			var cb = texture.get(uv).b; // 253
			if (cr >= 256 / 201 && cg >= 256 / 212 && cb >= 256 / 253) {
				pixelColor.a = 1; // passed;
				pixelColor.r = rand(vec2(1,passed)); // 0.5+cos(passed);
				pixelColor.g = 0; // 0.5+sin(passed);
				pixelColor.b = 1; // 0.5+passed*0.5;
				// fx.cloud(uv.x,uv.y);
			} else {
				pixelColor.r = texture.get(uv).r; //* 0.5;//rand(vec2(cos(passed),cos(passed)));
				pixelColor.g = texture.get(uv).g; //* 0.5;//rand(vec2(sin(passed),cos(passed)));
				pixelColor.b = texture.get(uv).b; //* rand(vec2(passed,0.5+sin(passed)));
			}
		}
	};
}
