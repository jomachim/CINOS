package sample;

class Craft {
	public static var ALL:Array<Craft> = [];

	public function is<T:Craft>(c:Class<T>)
		return Std.isOfType(this, c);

	public function as<T:Craft>(c:Class<T>):T
		return Std.downcast(this, c);

	public var title:String;
	public var receipe:Null<Array<Dynamic>>;
	public var quantity:Int;

	public function new(nom:String, ingredients:Null<Array<Dynamic>> = null, _quantity:Int = 1) {
		title = nom;
		quantity = _quantity;
		receipe = ingredients;
		ALL.push(this);
		// trace(Std.string(ALL));
	}

	public function cook() {
		// trace('now cooking');
		if (receipe == null) {
			return;
		}
		var temp = [];
		var success = true;
		for (ing in receipe) {
			for (s in 0...ing.stack) {
				if (hasIngredient(ing.name)) {
					temp.push(ing);
				} else {
					// trace("la recette a échoué car il vous manque "+ing.name);
					success = false;
				}
			}
		}
		// trace("vous utilisez "+temp.toString());
		if (success) {
			for (r in temp) {
				if (Game.ME.player.inventory.contains(r)){
					Game.ME.player.inventory.remove(r);
				}
			}
		}
		temp = null;
		// trace("la recette de "+this.title+" a été effectuée avec succés");
	}

	public function getIngByName(name) {
		for (i in ALL) {
			if (i.title == name) {
				return i;
			}
		}
		return null;
	}

	public function hasIngredient(ingredient) {
		if (Game.ME.player.inventory.contains(getIngByName(ingredient))) {
			return true;
		}
		return false;
	}
}
