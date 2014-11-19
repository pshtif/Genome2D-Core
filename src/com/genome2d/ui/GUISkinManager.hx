package com.genome2d.ui;
import com.genome2d.ui.skin.GUISkin;
class GUISkinManager {
    static private var g2d_references:Map<String,GUISkin>;
    inline static public function getSkinById(p_id:String):GUISkin {
        if (g2d_references == null) return null;
        return g2d_references[p_id];
    }
}
