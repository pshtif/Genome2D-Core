package com.genome2d.transitions;
import com.genome2d.debug.GDebug;
import com.genome2d.proto.IGPrototypable;

@:access(com.genome2d.transitions.GTransitionManager)
@:allow(com.genome2d.transitions.GTransitionManager)
class GTransition implements IGPrototypable {
	
	private var g2d_id:String;
    #if swc @:extern #end
    @prototype
	public var id(get, set):String;
    #if swc @:getter(id) #end
    inline private function get_id():String {
        return g2d_id;
    }
    #if swc @:setter(id) #end
    inline private function set_id(p_value:String):String {
        if (p_value != g2d_id && p_value.length > 0) {
            if (GTransitionManager.getTransition(p_value) != null) GDebug.error("Duplicate transition id: "+p_value);
            GTransitionManager.g2d_references.set(p_value,this);

            if (GTransitionManager.getTransition(g2d_id) != null) GTransitionManager.g2d_references.remove(g2d_id);
            g2d_id = p_value;
        }

        return g2d_id;
    }
	
	static private var g2d_instanceCount:Int = 0;
	public function new(p_id:String = "") {
        g2d_instanceCount++;

		id = (p_id != "") ? p_id : "GTransition" + g2d_instanceCount;
    }	
}