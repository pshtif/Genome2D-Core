package com.genome2d.utils.astar.heuristics;

class GAStarDiagonal implements IGAStarHeuristic
{
	public function new() {
	}
	
	public function getCost(p_node1:GAStarNode, p_node2:GAStarNode):Float	{
		var dx = Math.abs(p_node1.x - p_node2.x);
		var dy = Math.abs(p_node1.y - p_node2.y);
		
		var diag = Math.min(dx, dy);
		var straight = dx + dy;
		
		return GAStar.ADJANCED_COST * (straight - 2 * diag) + GAStar.DIAGONAL_COST * diag;
	}
}