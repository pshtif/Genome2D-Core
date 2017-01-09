package com.genome2d.tween.easing;

class GQuad {
	
	inline static public function easeIn(p_t:Float):Float {
		return p_t * p_t;
	}

	inline static public function easeOut(p_t:Float):Float {
		return -p_t * (p_t - 2);
	}

	inline static public function easeInOut(p_t:Float):Float {
		p_t *= 2;
		if (p_t < 1) {
			return .5 * p_t * p_t;
		}
		return -.5 * ((p_t - 1) * (p_t - 3) - 1);
	}
	
}
