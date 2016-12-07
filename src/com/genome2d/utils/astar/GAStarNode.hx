package com.genome2d.utils.astar;

import com.genome2d.geom.GIntPoint;

class GAStarNode extends GIntPoint {
	public var parent:GAStarNode;
	
	public var walkable:Bool;

	public var inClosed:Bool = false;
	public var inOpen:Bool = false;

	public var f:Float;
	public var g:Float;
	
	inline public function toPoint():GIntPoint {
		return new GIntPoint(x, y);
	}
}
