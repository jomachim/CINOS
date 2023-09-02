package sample;

import h3d.Engine;

// --- Filter -------------------------------------------------------------------------------
class FadeToBlackShader extends h2d.filter.Shader<InternalShader> {
	public function new(m:Float = 1.25) {
		super(new InternalShader());
		shader.pxscale = new hxsl.Types.Vec(1.0 / 1280.0, 1.0 / 720.0);
		shader.multiplier = m; // channel decay amount default 1.25
		shader.threshold = 0.5;
	}
}

// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture:Sampler2D;
		@param var pxscale:Vec2;
		@param var multiplier:Float;
		@param var threshold:Float;
		function fragment() {
			var uv = input.uv;
			var centerX = uv.x - 0.5;
			var centerY = uv.y - 0.5;
			var dist = sqrt(centerX * centerX + centerY * centerY) * 0.5;
			var ang = atan(centerY, centerX) * 180 / 3.1415;
			
			pixelColor.r = texture.get(vec2(uv.x + pxscale.x * multiplier * dist * cos(ang / 180 * 3.1415) * 4,
				uv.y + pxscale.y * multiplier * dist * sin(ang / 180 * 3.1415) * 4))
				.r;
			pixelColor.g = texture.get(uv).g;
			pixelColor.b = texture.get(vec2(uv.x - pxscale.x * multiplier * dist * cos(ang / 180 * 3.1415) * 4,
				uv.y + pxscale.y * multiplier * dist * sin(ang / 180 * 3.1415) * 4))
				.b;
			/*if (pixelColor.r < threshold && pixelColor.g < threshold && pixelColor.b < threshold) {
				pixelColor.a = 1;
				pixelColor.r = 0;
				pixelColor.g = 0;
				pixelColor.b = 0;
			}else if (pixelColor.r > threshold && pixelColor.g > threshold && pixelColor.b > threshold){
				pixelColor.a = 1;
				pixelColor.r = 1;
				pixelColor.g = 1;
				pixelColor.b = 1;
			}*/

			pixelColor.r = pixelColor.r+pixelColor.g+pixelColor.b < threshold*3?0:1;
			pixelColor.g = pixelColor.r+pixelColor.g+pixelColor.b < threshold*3?0:1;
			pixelColor.b = pixelColor.r+pixelColor.g+pixelColor.b < threshold*3?0:1;
			pixelColor.rgb -= 0.00025 / vec3(0.00025 / dist, 0.00025 / dist, 0.00025 / dist);
		}
	};
}
