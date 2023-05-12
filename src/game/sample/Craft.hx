package sample;

class Craft {
	public static var ALL:Array<Craft> = [];

	public function is<T:Craft>(c:Class<T>)
		return Std.isOfType(this, c);

	public function as<T:Craft>(c:Class<T>):T
		return Std.downcast(this, c);

	public var title:String;
	public var receipe:Null<Array<Dynamic>>;

	public function new(nom:String, ingredients:Null<Array<Dynamic>>=null) {
		title = nom;
		receipe = ingredients;
		ALL.push(this);
        //trace(Std.string(ALL));
	}

	public function cook() {
        //trace('now cooking');
		if (receipe == null) {
			return;
		}
		var temp = [];
		for (ing in receipe) {
			for (s in 0...ing.stack) {
				if (hasIngredient(ing.name)) {
					temp.push(ing);
				}else{
                   // trace("la recette a échoué car il vous manque "+ing.name);
                }
			}
		}
        //trace("vous utilisez "+temp.toString());
        for(r in temp){
            Game.ME.player.inventory.remove(r);
        }
        temp=null;
        //trace("la recette de "+this.title+" a été effectuée avec succés");
	}
    public function getIngByName(name){
        for(i in ALL){
            if(i.title==name){
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
