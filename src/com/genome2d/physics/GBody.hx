package com.genome2d.physics;

import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;

/**
 * ...
 * @author 
 */
class GBody extends GComponent
{
	public var x(get, set):Float;
	private function get_x():Float {
		return 0;
	}
	private function set_x(p_value:Float):Float {
		return 0;
	}
	
	public var y(get, set):Float;
	private function get_y():Float {
		return 0;
	}
	private function set_y(p_value:Float):Float {
		return 0;
	}
	
	public var scaleX(get, set):Float;
	private function get_scaleX():Float {
		return 0;
	}
	private function set_scaleX(p_value:Float):Float {
		return 0;
	}
	
	public var scaleY(get, set):Float;
	private function get_scaleY():Float {
		return 0;
	}
	private function set_scaleY(p_value:Float):Float {
		return 0;
	}
	
	public var rotation(get, set):Float;
	private function get_rotation():Float {
		return 0;
	}
	private function set_rotation(p_value:Float):Float {
		return 0;
	}
	
	public function isDynamic():Bool {
		return false;
	}
	
	public function isKinematic():Bool {
		return false;
	}
	
	public function addToSpace():Void {
	}

	public function removeFromSpace():Void {
	}
		
	public function new(p_node:GNode) {
		super(p_node);
	}
	
}