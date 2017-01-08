package com.genome2d.tween.easing;
	
	
class GQuint {
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return delta * t * t * t * t * t + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return delta * ((t -= 1) * t * t * t * t + 1) + start;
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		t *= 2;
		if (t < 1) {
			return delta / 2 * t * t * t * t * t + start;
		}
		return delta / 2 * ((t -= 2) * t * t * t * t + 2) + start;
	}	
}
