package tools;

class Rule {
    public var name:String;
    public var condition:()->Bool;
    public var callback:()->Void;
    public var context:Null<Dynamic>;
    public static var ALL:Array<Rule> = [];
    public function new(_name:String,_condition:()->Bool,_callback:()->Void){
        name=_name;
        condition=_condition;
        callback=_callback;
        ALL.push(this);
    }
    public function checkCondition(){
        if(condition()==true)
            callback();
    }
}

class RuleManager {

}