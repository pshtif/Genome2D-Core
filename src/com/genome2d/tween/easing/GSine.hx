package com.genome2d.tween.easing;
	
	
class GSine {
	
	
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return -delta * Math.cos(t * (Math.PI / 2)) + delta + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return delta * Math.sin(t * (Math.PI / 2)) + start;
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		return (-delta * 0.5) * (Math.cos(Math.PI * t) - 1) + start;
	}
		
}