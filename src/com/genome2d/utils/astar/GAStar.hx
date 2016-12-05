package com.genome2d.utils.astar;

import com.genome2d.utils.astar.heuristics.GAStarManhattan;
import com.genome2d.geom.GIntPoint;
import com.genome2d.utils.astar.heuristics.IGAStarHeuristic;

class GAStar
{
	public inline static var ADJANCED_COST:Int = 10;
	public inline static var DIAGONAL_COST:Int = 14;
	
	private var g2d_map:IGAStarClient;
	private var g2d_width:Int;
	private var g2d_height:Int;

	private var g2d_startNode:GAStarNode;
	private var g2d_destNode:GAStarNode;

	private var g2d_openList:Array<GAStarNode>;
	private var g2d_closedList:Array<GAStarNode>;

	private var g2d_heuristic:IGAStarHeuristic;
	
	private var g2d_nodeArray:Array<Array<GAStarNode>>;

	private function new(p_map:IGAStarClient) {
		g2d_map = p_map;

		g2d_width = g2d_map.sizeY;
		g2d_height = g2d_map.sizeX;
		g2d_nodeArray = new Array<Array<GAStarNode>>();
		
		for (j in 0...g2d_width) {
			var line = g2d_nodeArray[j] = new Array<GAStarNode>();
			for (i in 0...g2d_height) {
				var node = line[i] = new GAStarNode();
				node.x = j;
				node.y = i;
				node.walkable = g2d_map.isWalkable(j, i);
			}
		}
	}
	
	public function findPath(p_start:GIntPoint, p_dest:GIntPoint):Array<GIntPoint> {
		if (!g2d_map.isWalkable(p_start.x, p_start.y)
			|| !g2d_map.isWalkable(p_dest.x, p_dest.y)
			|| p_start.equals(p_dest)) {
			return null;
		}
		
		g2d_heuristic = new GAStarManhattan();
		
		g2d_openList = new Array<GAStarNode>();
		g2d_closedList = new Array<GAStarNode>();
		
		g2d_startNode = g2d_nodeArray[p_start.x][p_start.y];
		g2d_destNode = g2d_nodeArray[p_dest.x][p_dest.y];
		
		g2d_startNode.g = 0;
		g2d_startNode.f = g2d_heuristic.getCost(g2d_startNode, g2d_destNode);
		
		g2d_openList.push(g2d_startNode);
		
		return searchPath();
	}
	
	private function getPath():Array<GIntPoint> {
		var path:Array<GIntPoint> = new Array<GIntPoint>();
		
		var node:GAStarNode = g2d_destNode;
		path[0] = node.toPoint();
		
		var completed:Bool = false;
		while (!completed) {
			node = node.parent;
			path.unshift(node.toPoint());
			
			if (node == g2d_startNode) {
				completed = true;
			}
		}
		
		return path;
	}
	
	private function searchPath():Array<GIntPoint> {
		var minX:Int, maxX:Int, minY:Int, maxY:Int;
		var g:Float, f:Float, cost:Float;
		
		var nextNode:GAStarNode = null;
		var currentNode:GAStarNode = g2d_startNode;

		var completed:Bool = false;
		while (!completed) {
			minX = currentNode.x - 1 < 0 ? 0 : currentNode.x - 1;
			maxX = currentNode.x + 1 >= g2d_width ? g2d_width - 1 : currentNode.x + 1;
			minY = currentNode.y - 1 < 0 ? 0 : currentNode.y - 1;
			maxY = currentNode.y + 1 >= g2d_height ? g2d_height - 1 : currentNode.y + 1;
			
			for (y in minY...maxY + 1)
			{
				for (x in minX...maxX + 1)
				{
					nextNode = g2d_nodeArray[x][y];
					
					if (nextNode == currentNode || !nextNode.walkable) continue;
					
					cost = ADJANCED_COST;
					if (!(currentNode.x == nextNode.x || currentNode.y == nextNode.y)) {
						cost = DIAGONAL_COST;
					}
					
					g = currentNode.g + cost;
					f = g + g2d_heuristic.getCost(nextNode, g2d_destNode);
					
					if (Lambda.indexOf(g2d_openList, nextNode) != -1 || Lambda.indexOf(g2d_closedList, nextNode) != -1)	{
						if (nextNode.f > f)	{
							nextNode.f = f;
							nextNode.g = g;
							nextNode.parent = currentNode;
						}
					} else {
						nextNode.f = f;
						nextNode.g = g;
						nextNode.parent = currentNode;
						
						g2d_openList.push(nextNode);
					}
				}
			}
			
			g2d_closedList.push(currentNode);
			
			if (g2d_openList.length == 0) {
				return null;
			}
			
			g2d_openList.sort(sort);
			currentNode = g2d_openList.shift();
			
			if (currentNode == g2d_destNode) {
				completed = true;
			}
		}
		
		return getPath();
	}

	private function sort(x:GAStarNode, y:GAStarNode):Int {
		return Std.int(x.f - y.f);
	}
}
