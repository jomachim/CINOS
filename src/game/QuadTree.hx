class QuadTree {
	var root:TreeNode;
	var entities:Array<Entity> = [];
    var width:Int=0;
    var height:Int=0;
    var splitValue:Int=4;

	public function new(_w:Int,_h:Int,ents:Array<Entity>) {
        width=_w;
        height=_h;
        entities=ents;
        root=new TreeNode(0,0,width,height,entities);
    }

    public function getChildren(x,y):Array<Entity>{
        var found:Array<Entity>=[];
        if(root.hasChildren()){
            for(child in root.children){
                if(child.hasChildren()){

                }
            }
        }else{
            return root.entities;
        }
        return found;
    }

    public function addChild(entity:Entity){
        
    }
}

class TreeNode {
	public var NW:TreeNode = null;
	public var NE:TreeNode = null;
	public var SW:TreeNode = null;
	public var SE:TreeNode = null;
    public var entities:Array<Entity>=[];
    public var x:Int=0;
    public var y:Int=0;
    public var w:Int=0;
    public var h:Int=0;
    public var children:Array<TreeNode>=[];

	public function new(_x,_y,_w,_h,entities) {
        x=_x;
        y=_y;
        w=_w;
        h=_h;
        
    }
    public function hasChildren(){
        if(children.length>0){
            return true;
        }
        return false;
    }
}
