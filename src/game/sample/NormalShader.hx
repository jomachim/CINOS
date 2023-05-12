package sample;

class NormalShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		@param var normal:Sampler2D;
		@param var texture:Sampler2D;
		@param var mp:Vec3; // Mouse Position

		function fragment() {
			//if (texture.get(input.uv).a == 0) return;
			

			var lightradius:Float = 512;
			var upscale:Vec2=vec2(1.0/1280.0, 1.0/720.0);

			var normals:Vec4 = vec4(unpackNormal(normal.get(input.uv)), 1);
			normals*=vec4(upscale.x,upscale.y,1,1);
			var dist:Vec3 = vec3(abs(mp.x - absolutePosition.x), abs(mp.y - absolutePosition.y), mp.z);

			var brightness:Float = clamp(dot(dist, normals.rgb), 0, 1);
			brightness *= clamp(1 - (length(dist) / lightradius), 0, 1);

			var lightColor = vec3(1,1,1);

			output.color.rgb+=(lightColor * brightness);
		}
	}
}