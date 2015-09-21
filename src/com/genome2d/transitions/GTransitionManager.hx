package com.genome2d.transitions;

class GTransitionManager {
    static public function init():Void {
        g2d_references = new Map<String,IGTransition>();
    }

    static private var g2d_references:Map<String,IGTransition>;
    static public function getTransition(p_id:String):IGTransition {
        return g2d_references.get(p_id);
    }

    static public function g2d_addTransition(p_id:String, p_value:IGTransition):Void {
        g2d_references.set(p_id,p_value);
    }

    static public function g2d_removeTransition(p_id:String):Void {
        g2d_references.remove(p_id);
    }

    static public function getAllTransitions():Map<String,IGTransition> {
        return g2d_references;
    }
}