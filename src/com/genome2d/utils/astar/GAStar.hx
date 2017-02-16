package com.genome2d.utils.astar;

import com.genome2d.utils.astar.heuristics.GAStarManhattan;
import com.genome2d.geom.GIntPoint;

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

	private var g2d_heuristic:GAStarManhattan;//IGAStarHeuristic;
	
	private var g2d_nodeArray:Array<Array<GAStarNode>>;
	private var g2d_walker:Int;

	public function new(p_map:IGAStarClient, p_walker:Int) {
		g2d_map = p_map;
		g2d_walker = p_walker;

		g2d_width = g2d_map.sizeY;
		g2d_height = g2d_map.sizeX;
		g2d_nodeArray = new Array<Array<GAStarNode>>();
		
		for (j in 0...g2d_width) {
			var line = g2d_nodeArray[j] = new Array<GAStarNode>();
			for (i in 0...g2d_height) {
				var node = line[i] = new GAStarNode();
				node.x = j;
				node.y = i;
				node.walkable = g2d_map.isWalkable(j, i, g2d_walker);
			}
		}
	}
	
	public function findPath(p_start:GIntPoint, p_dest:GIntPoint):Array<GIntPoint> {
		if (!g2d_map.isWalkable(p_start.x, p_start.y, g2d_walker)
			|| !g2d_map.isWalkable(p_dest.x, p_dest.y, g2d_walker)
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

		g2d_startNode.inOpen = true;
		g2d_openList.push(g2d_startNode);
		
		return searchPath();
	}
	
	inline private function getPath():Array<GIntPoint> {
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

					if (!(currentNode.x == nextNode.x || currentNode.y == nextNode.y)) {
						continue;
						cost = DIAGONAL_COST;
					} else {
						cost = ADJANCED_COST;
					}
					
					g = currentNode.g + cost;
					f = g + g2d_heuristic.getCost(nextNode, g2d_destNode);
					
					//if (g2d_openList.indexOf(nextNode) != -1 || g2d_closedList.indexOf(nextNode) != -1)	{
					if (nextNode.inOpen || nextNode.inClosed)	{
						if (nextNode.f > f)	{
							nextNode.f = f;
							nextNode.g = g;
							nextNode.parent = currentNode;
						}
					} else {
						nextNode.f = f;
						nextNode.g = g;
						nextNode.parent = currentNode;

						nextNode.inOpen = true;
						g2d_openList.push(nextNode);
					}
				}
			}

			currentNode.inClosed = true;
			g2d_closedList.push(currentNode);
			
			if (g2d_openList.length == 0) {
				return null;
			}
			
			//g2d_openList.sort(sort);
			//currentNode = g2d_openList.shift();
			currentNode = getWithLeastCost();
			currentNode.inOpen = false;
			
			if (currentNode == g2d_destNode) {
				completed = true;
			}
		}
		
		return getPath();
	}

	inline private function getWithLeastCost():GAStarNode {
		var min:GAStarNode = g2d_openList[0];
		for (i in 1...g2d_openList.length) {
			if (min.f > g2d_openList[i].f) {
				min = g2d_openList[i];
				trace(i);
			}
		}

		g2d_openList.remove(min);
		return min;
	}

	private function sort(x:GAStarNode, y:GAStarNode):Int {
		return Std.int(x.f - y.f);
	}
	/*
	public function sortChildrenOnY(p_ascending:Bool = true):Void {
		if (g2d_firstChild == null) return;

		var insize:Int = 1;
		var psize:Int;
		var qsize:Int;
		var nmerges:Int;
		var p:GNode;
		var q:GNode;
		var e:GNode;

		while (true) {
			p = g2d_firstChild;
			g2d_firstChild = null;
			g2d_lastChild = null;

			nmerges = 0;

			while (p != null) {
				nmerges++;
				q = p;
				psize = 0;
				for (i in 0...insize) {
					psize++;
					q = q.g2d_next;
					if (q == null) break;
				}

				qsize = insize;

				while (psize > 0 || (qsize > 0 && q != null)) {
					if (psize == 0) {
						e = q;
						q = q.g2d_next;
						qsize--;
					} else if (qsize == 0 || q == null) {
						e = p;
						p = p.g2d_next;
						psize--;
					} else if (p_ascending) {
						if (p.y >= q.y) {
							e = p;
							p = p.g2d_next;
							psize--;
						} else {
							e = q;
							q = q.g2d_next;
							qsize--;
						}
					} else {
						if (p.y <= q.y) {
							e = p;
							p = p.g2d_next;
							psize--;
						} else {
							e = q;
							q = q.g2d_next;
							qsize--;
						}
					}

					if (g2d_lastChild != null) {
						g2d_lastChild.g2d_next = e;
					} else {
						g2d_firstChild = e;
					}

					e.g2d_previous = g2d_lastChild;

					g2d_lastChild = e;
				}

				p = q;
			}

			g2d_lastChild.g2d_next = null;

			if (nmerges <= 1) return;

			insize *= 2;
		}
	}
	/**/
}
