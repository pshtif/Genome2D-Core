package com.genome2d.utils.astar.heuristics;

interface IGAStarHeuristic {
	function getCost(p_node1:GAStarNode, p_node2:GAStarNode):Float;
}