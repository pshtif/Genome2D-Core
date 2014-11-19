package com.genome2d.ui;
class GUIStyleManager {
    static private var g2d_defaultStyle:GUIStyle;
    inline static public function getDefaultStyle():GUIStyle {
        if (g2d_defaultStyle == null) g2d_defaultStyle = new GUIStyle("default");
        return g2d_defaultStyle;
    }

    static private var g2d_references:Map<String,GUIStyle>;
    static public function getStyleById(p_id:String):GUIStyle {
        if (g2d_references == null) return null;
        return g2d_references[p_id];
    }
}
