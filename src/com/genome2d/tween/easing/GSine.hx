package com.genome2d.tween.easing;
	
	
class GSine {

	inline static public function easeIn(p_t:Float):Float {
		return -Math.cos(p_t * (Math.PI / 2));
	}

	inline static public function easeOut(p_t:Float):Float {
		return Math.sin(p_t * (Math.PI / 2));
	}

	inline static public function easeInOut(p_t:Float):Float {
		return -0.5 * (Math.cos(Math.PI * p_t) - 1);
	}
		
}