package sample;
import h3d.Vector4;
class FogFilter extends h2d.filter.Shader<FogShader> {
	public function new() {
		super(new FogShader());
		shader.time = 0.0;
		shader.speed = 0.02;
		shader.density = 0.75;
		shader.windX = 0;
		shader.windY = 0;
		shader.customColor = 0xffffff;
		shader.vecolor = new h3d.Vector4Impl(1.0,1.0,1.0,1.0);
		shader.opacity = 0.75;
	}
	function int2vec4(i:Int):h3d.Vector4Impl {
		var r = ((i >> 16) & 0xFF) / 255.0;
		var g = ((i >> 8) & 0xFF) / 255.0;
		var b = (i & 0xFF) / 255.0;
		var a = 1.0;
		return new h3d.Vector4Impl(r, g, b, a);
	}
	public function updateTime(dt:Float, wx:Float = 0.0, wy:Float = 0.0, cc:Int = 0x00ff2a,op:Float=0.75) {
		shader.time += dt;
		shader.windX += wx;
		shader.windY += wy;
		//shader.customColor = cc;
		shader.vecolor = int2vec4(cc);
		shader.opacity=op;
	}
}

private class FogShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture:Sampler2D;
		@param var time:Float;
		@param var speed:Float;
		@param var density:Float;
		@param var windX:Float;
		@param var windY:Float;
		@param var customColor:Int;
		@param var vecolor:Vec4;
		@param var opacity:Float;
		// Fonction de permutation pour le bruit
		function mod289(x:Vec3):Vec3 {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
		}
		function permute(x:Vec3):Vec3 {
			return mod289(((x * 34.0) + 1.0) * x);
		}
		// Bruit de Perlin 2D simplifié
		function noise(st:Vec2):Float {
			var i = floor(st);
			var f = fract(st);

			// Coins du carré
			var p00 = i;
			var p10 = i + vec2(1.0, 0.0);
			var p01 = i + vec2(0.0, 1.0);
			var p11 = i + vec2(1.0, 1.0);

			// Valeurs aléatoires pour chaque coin
			var v00 = fract(sin(dot(p00, vec2(127.1, 311.7))) * 43758.5453123);
			var v10 = fract(sin(dot(p10, vec2(127.1, 311.7))) * 43758.5453123);
			var v01 = fract(sin(dot(p01, vec2(127.1, 311.7))) * 43758.5453123);
			var v11 = fract(sin(dot(p11, vec2(127.1, 311.7))) * 43758.5453123);

			// Lissage cubique
			f = f * f * (3.0 - 2.0 * f);

			// Interpolation bilinéaire
			var n00 = mix(v00, v10, f.x);
			var n01 = mix(v01, v11, f.x);
			return mix(n00, n01, f.y);
		}
		// Bruit de Perlin avec plusieurs octaves (FBM - Fractional Brownian Motion)
		function fbm(st:Vec2):Float {
			var value = 0.0;
			var amplitude = 1.0;
			var frequency = 1.5;

			// Addition de plusieurs octaves de bruit
			for (i in 0...6) {
				value += amplitude * noise(st * frequency);
				frequency *= 1.5+i*0.1;
				amplitude *= 0.6;
			}
			return value;
		}
		
		function fragment() {
			
			// Coordonnées UV avec déplacement dans le temps
			var uv = input.uv;
			var moving_uv = uv + vec2(time * speed * 0.45 + windX, time * speed * 0.45 + windY);

			// Génération du brouillard avec FBM
			var fog = fbm(moving_uv * 1.0);
			fog += fbm(moving_uv * 2.0) * 0.5;

			// Ajout d'une seconde couche de brouillard se déplaçant différemment
			var fog2 = fbm(moving_uv * 2.0 + vec2(time * speed * -0.1 + windX, time * speed * -0.05));
			fog = mix(fog, fog2, 0.5);

			// Ajout d'une seconde couche de brouillard se déplaçant différemment
			var fog3 = fbm(moving_uv * 3.0 + vec2(time * speed * 0.2 + windX, time * speed * 0.1));
			fog = mix(fog, fog3, 0.5);

			// Ajout d'une seconde couche de brouillard se déplaçant différemment
			var fog4 = fbm(vec2(time * -speed * 0.45 + windX, time * speed * 0.45 + windY) * 0.5 + vec2(time * speed * -0.2 + windY, time * speed * -0.1+windX));
			fog = mix(fog, fog*fog4,fog4);

			// Obtenir la couleur de la texture d'origine
			var baseColor = texture.get(uv);

			// Couleur du brouillard (blanc légèrement bleuté)
			var fogColor =vec4(1.0, 1.0, 1.0, 1.0)*vecolor; // .fromColor(customColor);
			
			// Mélanger la texture d'origine avec le brouillard
			fog = fog * density; // Contrôle de la densité
			pixelColor = mix(baseColor * fog + fogColor * 0.25, fogColor * fog * density, fog * opacity); // Le 0.7 contrôle la transparence maximale
		}
	};
}
