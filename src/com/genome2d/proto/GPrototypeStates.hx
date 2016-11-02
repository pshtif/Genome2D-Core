package com.genome2d.proto;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GPrototypeStates
{
	private var g2d_states:Map<String,Map<String,GPropertyState>>;

	inline public function new() {
		g2d_states = new Map<String,Map<String,GPropertyState>>();
	}
	
	inline public function setProperty(p_property:String, p_value:Dynamic, p_extras:Int, p_stateName:String, p_transition:String):Void {
		if (p_stateName == null) p_stateName = "default";
		
		var split:Array<String> = p_stateName.split("-");
		
		if (split.length > 1) {
			for (i in 0...split.length) {
				setProperty(p_property, p_value, p_extras, split[i], p_transition);
			}
		} else {
			var state:Map<String,GPropertyState> = g2d_states.get(p_stateName);
			if (state == null) {
				state = new Map<String,GPropertyState>();
				g2d_states.set(p_stateName, state);
			}
			state.set(p_property, new GPropertyState(p_property, p_value, p_extras, p_transition));
		}
	}	
	
	inline public function getState(p_stateName:String = "default"):Map<String,GPropertyState> {
		return g2d_states.get(p_stateName);
	}

	inline public function hasState(p_stateName:String):Bool {
		return g2d_states.exists(p_stateName);
	}
}