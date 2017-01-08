package com.genome2d.tween.easing;

class GQuad {
	
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		return delta * t * t + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		return -delta * t * (t - 2) + start;
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		t *= 2;
		if (t < 1) {
			return delta / 2 * t * t + start;
		}
		return -delta / 2 * ((t - 1) * (t - 3) - 1) + start;
	}
	
}
