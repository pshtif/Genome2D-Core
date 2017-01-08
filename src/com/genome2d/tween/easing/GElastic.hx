package com.genome2d.tween.easing;

class GElastic {
	
	static var a = 0.1;
	static var p = 0.4;
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {
		if (t == 0) {
			return start;
		}
		if (t == 1) {
			return start + delta;
		}
		var s:Float;
		if (a < Math.abs(delta)) {
			a = delta;
			s = p / 4;
		}
		else {
			s = p / (2 * Math.PI) * Math.asin(delta / a);
		}
		return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p)) + start;
	}
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {
		if (t == 0) {
			return start;
		}
		if (t == 1) {
			return start + delta;
		}
		var s:Float;
		if (a < Math.abs(delta)) {
			a = delta;
			s = p / 4;
		}
		else {
			s = p / (2 * Math.PI) * Math.asin(delta / a);
		}
		return a * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p) + delta + start;
		
	}
	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {
		if (t == 0) {
			return start;
		}
		t *= 2;
		if (t == 2) {
			return start + delta;
		}
		var s:Float;
		if (a < Math.abs(delta)) {
			a = delta;
			s = p / 4;
		}
		else {
			s = p / (2 * Math.PI) * Math.asin(delta / a);
		}
		if (t < 1) {
			return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p)) + start;
		}
		return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p) * 0.5 + delta + start;
	}
		
}