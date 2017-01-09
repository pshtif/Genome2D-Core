package com.genome2d.tween.easing;

class GBack {
	
	public static var DRIVE:Float = 1.70158;
	inline static public function easeIn(p_t:Float):Float {
		return p_t * p_t * ((DRIVE + 1) * p_t - DRIVE);
	}
	inline static public function easeOut(p_t:Float):Float {
		return ((p_t -= 1) * p_t * ((DRIVE + 1) * p_t + DRIVE) + 1);
	}
	inline static public function easeInOut(p_t:Float):Float {
		var s = DRIVE * 1.525;
		if ((p_t*=2) < 1) return 0.5 * (p_t * p_t * (((s) + 1) * p_t - s));
		return 0.5 * ((p_t -= 2) * p_t * (((s) + 1) * p_t + s) + 2);
	}	
}