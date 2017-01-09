package com.genome2d.tween.easing;

class GExpo {
	
	inline static public function easeIn(p_t:Float):Float {
		return p_t == 0 ? 0 : Math.pow(2, 10 * (p_t - 1));
	}

	inline static public function easeOut(p_t:Float):Float {
		return p_t == 1 ? 1 : (1 - Math.pow(2, -10 * p_t));
	}

	inline static public function easeInOut(p_t:Float):Float {
		if (p_t == 0 || p_t == 1) return p_t;

		if ((p_t *= 2.0) < 1.0) {
			return 0.5 * Math.pow(2, 10 * (p_t - 1));
		}
		return 0.5 * (2 - Math.pow(2, -10 * --p_t));
	}	
}
