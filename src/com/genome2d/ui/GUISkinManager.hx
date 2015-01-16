package com.genome2d.ui;
import com.genome2d.ui.skin.GUISkin;
class GUISkinManager {
    static public function init():Void {
        g2d_references = new Map<String,GUISkin>();
    }

    static private var g2d_references:Map<String,GUISkin>;
    static public function getSkinById(p_id:String):GUISkin {
        return g2d_references.get(p_id);
    }

    static public function g2d_setSkinById(p_id:String,p_value:GUISkin):Void {
        g2d_references.set(p_id,p_value);
    }

    static public function g2d_removeSkinById(p_id:String):Void {
        g2d_references.remove(p_id);
    }

    static public function getSkins():Map<String,GUISkin> {
        return g2d_references;
    }
}
