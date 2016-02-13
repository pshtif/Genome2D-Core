package com.genome2d.ui.skin;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.ui.skin.GUISkin;

class GUISkinManager {
    static public function init():Void {
        GUISkin.g2d_batchQueue = new Array<GUISkin>();

        g2d_skins = new Map<String,GUISkin>();
    }

    static private var g2d_skins:Map<String,GUISkin>;
    static public function getSkin(p_id:String):GUISkin {
        return g2d_skins.get(p_id);
    }

    static public function g2d_addSkin(p_id:String, p_value:GUISkin):Void {
        g2d_skins.set(p_id,p_value);
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
