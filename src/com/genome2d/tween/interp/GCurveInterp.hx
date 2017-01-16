package com.genome2d.tween.interp;

import com.genome2d.tween.easing.GEase;
import com.genome2d.geom.GCurve;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@:access(com.genome2d.create.GTweenStep)
class GCurveInterp implements IGInterp {

    public var tween:GTweenStep;

    private var g2d_duration:Float;
    private var g2d_durationR:Float;
    @prototype
    public var duration(get,set):Float;
    #if swc @:getter(duration) #end
    inline private function get_duration():Float {
        return g2d_duration;
    }
    #if swc @:setter(duration) #end
    inline public function set_duration(p_value:Float):Float {
        g2d_durationR = 1/p_value;
        return g2d_duration = p_value;
    }

    private var g2d_time:Float;
    public var from:Float;
    public var to:GCurve;
    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;
    public var property:String;

    public var hasUpdated:Bool;

    public function getFinalValue():Float {
        return from + to.calculate(1);
    }

    inline public function new(p_tween:GTweenStep, p_name:String, p_to:GCurve, p_duration:Float) {
        ease = GTween.defaultEase;
        this.duration = p_duration;
        this.tween = p_tween;
        this.to = p_to;
        this.property = p_name;
        g2d_time = 0.0;
    }

    inline function init(p_from:Float) {
        if(!hasUpdated){
            this.from = p_from;
            hasUpdated = true;
        }
    }

    public function reset():Void {
        g2d_time = 0;
    }

    inline public function update(p_delta:Float) {
        g2d_time += p_delta;
        var c = current;
        if (g2d_time > g2d_duration) {
            g2d_time = g2d_duration;
            c = from + to.calculate(1);
            complete = true;
        }else {
            var rt = Math.max(0, g2d_time);
            c = from + to.calculate(ease(g2d_time * g2d_durationR));
            trace(ease(g2d_time * g2d_durationR), c-from);
        }
        set(c);
    }

    inline public function set(p_value:Float) {
        if (p_value != current) {
            apply(current = p_value);
        }
    }

    inline public function check() {
        init( Reflect.getProperty(tween.getTarget(), property) );
    }

    inline private function apply(val:Float) {
        Reflect.setProperty(tween.getTarget(), property, val);
    }

}