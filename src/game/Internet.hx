import haxe.ds.Map;
import Game;
import App;

class Internet {
	public static var game:Game = Game.ME;

	public static function requestURL(url:String, ?params:Map<String, Dynamic> = null, ?method:Bool = false):Dynamic { // method true = post else get
		var req = new haxe.Http(url);
		req.onData = function(data) {
			var out:Dynamic = data;
			return out;
		}
		if (params != null) {
			for (i in params.keys()) {
				req.setParameter(i, params[i]);
			}
		}

		req.request(method);
		return req;
	}

	public static function postHighScore() {
		var post = new haxe.Http('https://alterpixel.fr/cdn/cinos.php');
		post.onData = function(data) {
			// trace(data);
			// var json:haxe.DynamicAccess<Dynamic>=haxe.Json.parse(data);
			var json:Dynamic = data;
			// trace("from HTTP POST : " + json);
			// highscore.push(json);
		}
		post.setParameter("highscore", "true");
		post.setParameter("userId", App.ME.pseudo);
		post.setParameter("score", "28750");
		post.setParameter("chrono", Game.ME.chronometre);
		post.setParameter("topicId", "cinos");
		post.request(true);
	}

	public static function getHighScore() {
		var httpInstance = new haxe.Http('https://alterpixel.fr/cdn/cinos.php');
		httpInstance.setParameter("scores", "true");
		httpInstance.onData = function(data) {
			// trace(data);
			if (data == "" || data == null) {
				return null;
			} else {
				var json:Null<HighScoreData>= haxe.Json.parse(data);//
				// trace("from HTTP : " + json.scores);
				// highscore.push(json);
				return json;
			}
		}
		httpInstance.onError = function(error) {
			// trace("from HTTP error : " + error);
		}
		httpInstance.onStatus = function(code:Int) {
			// trace("Status " + code);
		}
		httpInstance.request(false);
	}

	public static function getSave() {}

	public static function postSave(save) {
		// trace('try to save : ' + haxe.Json.stringify(save).length);
		var post = new haxe.Http('https://alterpixel.fr/cdn/cinos.php');
		post.onData = function(data) {
			// trace(data);
			// var json:haxe.DynamicAccess<Dynamic>=haxe.Json.parse(data);
			var json:Dynamic = data;
			// trace("from HTTP POST : " + json);
			// highscore.push(json);
		}
		post.setParameter("saving", "true");
		post.setParameter("userId", "kariboo84");
		post.setParameter("save", haxe.Json.stringify(save)); // ;
		post.setParameter("chrono", Game.ME.chronometre); // );
		post.request(true);
		// post=null;
	}
}
