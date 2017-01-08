package com.genome2d.tween.easing;

class GLinear
{
	public static inline function none(start:Float, delta:Float, time:Float):Float {
		return start + delta * time;
	}
}