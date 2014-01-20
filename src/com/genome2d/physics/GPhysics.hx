package com.genome2d.physics;

/**
 * ...
 * @author 
 */
class GPhysics
{
	private var __bRunning:Bool = true;
	
	public var minimumTimeStep:Int = 0;
	
	public function new() {
		
	}
	
	public function step(p_deltaTime:Float):Void {
		
	}
	
	public function setGravity(p_x:Float, p_y:Float):Void {
		
	}
	
	public function stop():Void {
		__bRunning = false;
	}
	
	public function start():Void {
		__bRunning = true;
	}
	
	public function dispose():Void {
		
	}
}