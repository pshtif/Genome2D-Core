package com.genome2d.tween.interp;

import com.genome2d.tween.easing.GEase;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@:access(com.genome2d.create.GTweenStep)
class GFloatInterp implements IGInterp {

    public var tween:GTweenStep;
    public var duration:Float;
    public var durationR:Float;
    public var time:Float;
    public var isProperty:Bool;
    public var from:Float;
    public var to:Float;
    public var difference:Float;
    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;
    public var name:String;

    public var hasUpdated:Bool;

    inline public function new(p_tween:GTweenStep, p_name:String, p_to:Float, p_duration:Float) {
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
            difference = to - p_from;
            hasUpdated = true;
        }
    }

    inline public function update(p_delta:Float) {
        time += p_delta;
        var c = current;
        if (time > duration) {
            time = duration;
            c = from + difference;
            complete = true;
        }else {
            var rt = Math.max(0, time);
            c = ease(from, difference, time * durationR);
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