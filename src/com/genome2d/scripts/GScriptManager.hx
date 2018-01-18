package com.genome2d.scripts;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
import com.genome2d.callbacks.GCallback.GCallback1;
class GScriptManager
{
    static private var g2d_onScriptChanged:GCallback1<GScript>;

	static private var g2d_scripts:Map<String,GScript>;
    static public function getScript(p_id:String):GScript {
        return g2d_scripts != null ? g2d_scripts.get(p_id) : null;
    }

    static public function createScript(p_id:String, p_source:String = ""):GScript {
        var script:GScript = new GScript();
        script.id = p_id;
        if (p_source != "") script.setSource(p_source);

        return script;
    }

	@:access(com.genome2d.scripts.GScript)
    static public function g2d_addScript(p_script:GScript):Void {
        if (g2d_scripts == null) g2d_scripts = new Map<String,GScript>();
		var oldScript:GScript = g2d_scripts.get(p_script.id);
        g2d_scripts.set(p_script.id, p_script);
		if (oldScript != null && oldScript != p_script) {
			g2d_onScriptChanged.dispatch(oldScript);
			oldScript.internalDispose();
		}
    }

    static public function g2d_removeScript(p_script:GScript):Void {
        if (g2d_scripts != null) g2d_scripts.remove(p_script.id);
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