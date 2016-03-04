package com.genome2d.text;

/**
 * ...
 * @author Peter @sHTiF Stefcek
 */
class GTextFormat
{
	public var g2d_formatMap:Map<Int,Int>;
	
	public function new() {
		g2d_formatMap = new Map<Int,Int>();
	}
	
	public function setIndexColor(p_index:Int, p_color:Int):Void {
		g2d_formatMap.set(p_index, p_color);
	}
	
	public function getIndexColor(p_index:Int):Int {
		var color:Int = -1;
		if (g2d_formatMap.exists(p_index)) {
			color = g2d_formatMap.get(p_index);
		}
		return color;
	}
	
}