package com.genome2d.tween.interp;

import com.genome2d.tween.easing.GEase;
import com.genome2d.geom.GCurve;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@:access(com.genome2d.create.GTweenStep)
class GCurveInterp implements IGInterp {

    public var tween:GTweenStep;

    @prototype
    public var duration:Float;

    private var g2d_time:Float;

    public var from:Float;
    public var to:GCurve;
    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;
    public var property:String;

    public var hasInitialized:Bool = false;

    public function getFinalValue():Float {
        return from + to.calculate(1);
    }

    public function new(p_tween:GTweenStep, p_name:String, p_to:GCurve, p_duration:Float) {
        ease = GTween.defaultEase;
        this.duration = p_duration;
        this.tween = p_tween;
        this.to = p_to;
        this.property = p_name;
        g2d_time = 0.0;
    }

    inline function init():Void {
        from = Reflect.getProperty(tween.getTarget(), property);
        hasInitialized = true;
    }

    public function reset():Void {
        g2d_time = 0;
        hasInitialized = false;
    }

    inline public function update(p_delta:Float) {
        g2d_time += p_delta;
        var c = current;
        if (g2d_time > duration) {
            g2d_time = duration;
            c = from + to.calculate(1);
            complete = true;
        }else {
            var rt = Math.max(0, g2d_time);
            c = from + to.calculate(ease(g2d_time/duration));
        }
        setValue(c);
    }

    inline public function setValue(p_value:Float) {
        if (p_value != current) {
            apply(current = p_value);
        }
    }

    inline private function apply(val:Float) {
        Reflect.setProperty(tween.getTarget(), property, val);
    }
}