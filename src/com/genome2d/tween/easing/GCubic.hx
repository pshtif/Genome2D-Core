package com.genome2d.tween.easing;

class GCubic {
	
	
	inline static public function easeIn(p_t:Float):Float {
		return p_t * p_t * p_t;
	}
	inline static public function easeOut(p_t:Float):Float {
		return ((p_t -= 1) * p_t * p_t + 1);
	}
	inline static public function easeInOut(p_t:Float):Float {
		if ((p_t *= 2) < 1) {
			return 0.5 * p_t * p_t * p_t;
		}else {
			return 0.5 * ((p_t -= 2) * p_t * p_t + 2);
		}
	}
	
}