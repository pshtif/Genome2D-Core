package com.genome2d.tween.interp;

import com.genome2d.tween.easing.GEase;
import com.genome2d.geom.GCurve;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@:access(com.genome2d.create.GTweenStep)
class GCurveInterp implements IGInterp {

    public var tween:GTweenStep;
    public var duration:Float;
    public var durationR:Float;
    public var time:Float;
    public var isProperty:Bool;
    public var from:Float;
    public var to:GCurve;
    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;
    public var name:String;

    public var hasUpdated:Bool;

    public function getFinalValue():Float {
        return from + to.calculate(1);
    }

    inline public function new(p_tween:GTweenStep, p_name:String, p_to:GCurve, p_duration:Float) {
        ease = GTween.defaultEase;
        this.duration = p_duration;
        this.durationR = 1 / p_duration;
        this.tween = p_tween;
        this.to = p_to;
        this.name = p_name;
        time = 0.0;
    }

    inline function init(p_from:Float) {
        if(!hasUpdated){
            this.from = p_from;
            hasUpdated = true;
        }
    }

    inline public function update(p_delta:Float) {
        time += p_delta;
        var c = current;
        if (time > duration) {
            time = duration;
            c = from + to.calculate(1);
            complete = true;
        }else {
            var rt = Math.max(0, time);
            c = from + to.calculate(ease(time * durationR));
            trace(ease(time * durationR), c-from);
        }
        set(c);
    }

    inline public function set(p_value:Float) {
        if (p_value != current) {
            apply(current = p_value);
        }
    }

    inline public function check() {
        init( Reflect.getProperty(tween.getTarget(), name) );
    }

    inline private function apply(val:Float) {
        Reflect.setProperty(tween.getTarget(), name, val);
    }

}