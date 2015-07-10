package com.genome2d.proto;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GPrototypeProperty<T>
{
	private var g2d_states:Map<String,T>;

	inline public function new() {
		g2d_states = new Map<String,T>();
	}
	
	inline public function addValue(p_value:T, p_stateName:String = "default"):Void {
		g2d_states.set(p_stateName, p_value);
	}	
	
	inline public function getValue(p_stateName:String = "default"):Void {
		g2d_states.get(p_stateName);
	}
}