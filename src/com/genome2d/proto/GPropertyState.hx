package com.genome2d.proto;

import com.genome2d.transitions.GTransitionManager;
import com.genome2d.transitions.IGTransition;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GPropertyState
{
	private var g2d_name:String;
	private var g2d_value:Dynamic;
	private var g2d_transition:String;
	private var g2d_extras:Int;

	public function new(p_name:String, p_value:Dynamic, p_extras:Int, p_transition:String) {
		g2d_name = p_name;
		g2d_value = p_value;
		g2d_extras = p_extras;
		g2d_transition = p_transition;
	}
	
	public function bind(p_instance:Dynamic):Void {
		if (g2d_transition != "") {
			var transition:IGTransition = GTransitionManager.getTransition(g2d_transition);
			if (transition != null && (g2d_extras & GPrototypeExtras.SETTER) == 0) {
				transition.apply(p_instance, g2d_name, g2d_value);
			} else {
				if ((g2d_extras & GPrototypeExtras.SETTER) != 0) {
					Reflect.callMethod(p_instance, Reflect.field(p_instance, g2d_name), [g2d_value]);
				} else {
					Reflect.setProperty(p_instance, g2d_name, g2d_value);
				}
			}
		} else {
			if ((g2d_extras & GPrototypeExtras.SETTER) != 0) {
				Reflect.callMethod(p_instance, Reflect.field(p_instance, g2d_name), [g2d_value]);
			} else {
				Reflect.setProperty(p_instance, g2d_name, g2d_value);
			}
		}
	}
	
}