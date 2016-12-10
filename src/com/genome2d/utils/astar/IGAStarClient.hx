package com.genome2d.utils.astar;

interface IGAStarClient {
	var sizeX(default, never):Int;
	
	var sizeY(default, never):Int;
	
	function isWalkable(p_x:Int, p_y:Int, p_walker:Int):Bool;
	function getCost(p_x:Int, p_y:Int, p_walker:Int):Int;
}