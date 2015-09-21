package com.genome2d.transitions;

/**
 * @author Peter @sHTiF Stefcek
 */

interface IGTransition {
	function apply(p_instance:Dynamic, p_property:String, p_value:Dynamic):Void;
}