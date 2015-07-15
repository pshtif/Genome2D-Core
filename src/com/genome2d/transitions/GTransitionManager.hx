package com.genome2d.transitions;
import com.genome2d.transitions.GTransition;

class GTransitionManager {
    static public function init():Void {
        g2d_references = new Map<String,GTransition>();
    }

    static private var g2d_references:Map<String,GTransition>;
    static public function getTransition(p_id:String):GTransition {
        return g2d_references.get(p_id);
    }

    static public function g2d_addTransition(p_id:String, p_value:GTransition):Void {
        g2d_references.set(p_id,p_value);
    }

    static public function g2d_removeTransition(p_id:String):Void {
        g2d_references.remove(p_id);
    }

    static public function getAllTransitions():Map<String,GTransition> {
        return g2d_references;
    }
}