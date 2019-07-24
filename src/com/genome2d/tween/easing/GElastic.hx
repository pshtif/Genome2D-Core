package com.genome2d.tween.easing;
	
class GElastic {

	inline static public function easeIn(p_t:Float):Float {
        if (p_t == 0) return 0; if (p_t == 1) return 1;
        var s:Float;
        var a:Float = 1;
        var p:Float = 0.4;
        if (a < 1) { a = 1; s = p / 4; }
        else s = p / (2 * Math.PI) * Math.asin (1 / a);
        return -(a * Math.pow(2, 10 * (p_t -= 1)) * Math.sin( (p_t - s) * (2 * Math.PI) / p ));
	}

	inline static public function easeOut(p_t:Float):Float {
        if (p_t == 0) return 0; if (p_t == 1) return 1;
        var s:Float;
        var a:Float = 1;
        var p:Float = 0.4;
        if (a < 1) { a = 1; s = p / 4; }
        else s = p / (2 * Math.PI) * Math.asin (1 / a);
        return (a * Math.pow(2, -10 * p_t) * Math.sin((p_t - s) * (2 * Math.PI) / p ) + 1);
	}

	inline static public function easeInOut(p_t:Float):Float {
        if (p_t == 0) {
            return 0;
        }
        if ((p_t /= 1 / 2) == 2) {
            return 1;
        }

        var p:Float = (0.3 * 1.5);
        var s:Float = p / 4;

        if (p_t < 1) {
            return -0.5 * (Math.pow(2, 10 * (p_t -= 1)) * Math.sin((p_t - s) * (2 * Math.PI) / p));
        }
        return Math.pow(2, -10 * (p_t -= 1)) * Math.sin((p_t - s) * (2 * Math.PI) / p) * 0.5 + 1;
	}
}