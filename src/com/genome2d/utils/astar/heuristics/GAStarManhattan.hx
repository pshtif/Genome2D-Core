package com.genome2d.utils.astar.heuristics;

class GAStarManhattan implements IGAStarHeuristic
{
	public function new() {
	}
	
	public function getCost(p_node1:GAStarNode, p_node2:GAStarNode):Float	{
		var dx:Int = p_node1.x - p_node2.x;
		var dy:Int = p_node1.y - p_node2.y;
		
		return (dx > 0 ? dx : -dx) + (dy > 0 ? dy : -dy);
	}
}