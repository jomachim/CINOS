package page;
import h2d.Interactive;
class MenuItem extends Interactive{
	public static var indexInc:Int=0;
	public static var ALL:Array<MenuItem>=[];
	public var index:Int;
	public var callBack:()->Void;
	public function new(w:Int,h:Int,?cb=null,?p:h2d.Object=null){
		super(w,h,p);
		index=indexInc++;
		callBack=cb;
		ALL.push(this);
	}

}