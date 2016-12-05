package com.genome2d.utils.astar;

import com.genome2d.geom.GIntPoint;

class GAStarNode extends GIntPoint {
	public var parent:GAStarNode;
	
	public var walkable:Bool;
	
	public var f:Float;
	public var g:Float;
	
	public function toString():String {
		var result:String;
		result = "[Node(" + this.x + "," + this.y + ")";
		if (parent != null)
		{
			result += ", parent=(" + parent.x + "," + parent.y + ")";
		}
		result += (walkable ? ", W" : ", X");
		result += ", f=" + f;
		result += "]";
		
		return result;
	}
	
	public function toPoint():GIntPoint {
		return new GIntPoint(x, y);
	}
}
