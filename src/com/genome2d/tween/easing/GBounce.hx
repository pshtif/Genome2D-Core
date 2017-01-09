package com.genome2d.tween.easing;

class GBounce {

	inline static public function easeIn(p_t:Float):Float {
		return -easeOut(1 - p_t);
	}
	inline static public function easeOut(p_t:Float):Float {
		if (p_t < (1/2.75)) {
			return (7.5625 * p_t * p_t);
		} else if (p_t < (2/2.75)) {
			return (7.5625 * (p_t -= (1.5 / 2.75)) * p_t + .75);
		} else if (p_t < (2.5/2.75)) {
			return (7.5625 * (p_t -= (2.25 / 2.75)) * p_t + .9375);
		} else {
			return (7.5625 * (p_t -= (2.625 / 2.75)) * p_t + .984375);
		}
	}
	inline static public function easeInOut(p_t:Float):Float {
		if (p_t < 0.5) {
			return easeIn(p_t*2) * .5;
		} else {
			return easeOut(p_t*2-1) * .5 + .5;
		}
	}
		
}