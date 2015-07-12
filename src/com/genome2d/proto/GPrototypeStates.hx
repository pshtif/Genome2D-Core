package com.genome2d.proto;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GPrototypeStates
{
	private var g2d_states:Map<String,Map<String,Dynamic>>;

	inline public function new() {
		g2d_states = new Map<String,Map<String,Dynamic>>();
	}
	
	inline public function setProperty(p_property:String, p_value:Dynamic, p_stateName:String = "default"):Void {
		//trace(p_property, p_value, p_stateName);
		var state:Map<String,Dynamic> = g2d_states.get(p_stateName);
		if (state == null) {
			state = new Map<String,Dynamic>();
			g2d_states.set(p_stateName, state);
		}
		state.set(p_property, p_value);
	}	
	
	inline public function getState(p_stateName:String = "default"):Map<String,Dynamic> {
		return g2d_states.get(p_stateName);
	}
}