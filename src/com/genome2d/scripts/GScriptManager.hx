package com.genome2d.scripts;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GScriptManager
{
	static private var g2d_scripts:Map<String,GScript>;
    static public function getScript(p_id:String):GScript {
        return g2d_scripts.get(p_id);
    }

	@:access(com.genome2d.scripts.GScript)
    static public function g2d_addSkin(p_id:String, p_value:GScript):Void {
		var oldScript:GScript = g2d_scripts.get(p_id);
        g2d_scripts.set(p_id, p_value);
		if (oldScript != null) {
			//g2d_onScriptChanged.dispatch(p_id);
			oldScript.internalDispose();
		}
    }

    static public function g2d_removeScript(p_id:String):Void {
        g2d_scripts.remove(p_id);
    }

    static public function getAllScripts():Map<String,GScript> {
        return g2d_scripts;
    }
	
	static public function disposeAll():Void {
		for (script in g2d_scripts) {
			if (script.id.indexOf("g2d_") != 0) script.dispose();
        }
	}	
}