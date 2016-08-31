package com.genome2d.scripts;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GScriptManager
{
	static private var g2d_scripts:Map<String,GUISkin>;
    static public function getSkin(p_id:String):GUISkin {
        return g2d_skins.get(p_id);
    }

    static public function g2d_addSkin(p_id:String, p_value:GUISkin):Void {
		var oldSkin:GUISkin = g2d_skins.get(p_id);
        g2d_skins.set(p_id, p_value);
		if (oldSkin != null) {
			g2d_onSkinChanged.dispatch(p_id);
			oldSkin.g2d_internalDispose();
		}
    }

    static public function g2d_removeSkin(p_id:String):Void {
        g2d_skins.remove(p_id);
    }

    static public function getAllSkins():Map<String,GUISkin> {
        return g2d_skins;
    }
	
	static public function disposeAll():Void {
		for (skin in g2d_skins) {
			if (skin.id.indexOf("g2d_") != 0) skin.dispose();
        }
	}	
}