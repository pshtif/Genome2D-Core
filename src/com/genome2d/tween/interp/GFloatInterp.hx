package com.genome2d.tween.interp;

import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.easing.GEase;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@prototypeName("tweenFloat")
@:access(com.genome2d.create.GTweenStep)
class GFloatInterp implements IGInterp implements IGPrototypable {

    private var g2d_tween:GTweenStep;

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

    @prototype
    public var to:Float;

    private var g2d_time:Float;
    public var from:Float;

    public var difference:Float;
    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;

    @prototype
    public var property:String;

    public var hasUpdated:Bool;

    public function getFinalValue():Float {
        return from + difference;
    }

    inline public function new(p_tween:GTweenStep) {
        g2d_tween = p_tween;
        ease = GTween.defaultEase;
        g2d_time = 0;
    }

    inline private function init(p_from:Float) {
        if(!hasUpdated){
            this.from = p_from;
            difference = to - p_from;
            hasUpdated = true;
        }
    }

    inline public function reset():Void {
        g2d_time = 0;
        hasUpdated = false;
    }

    inline public function update(p_delta:Float) {
        g2d_time += p_delta;
        var c:Float;
        if (g2d_time > g2d_duration) {
            g2d_time = g2d_duration;
            c = from + difference;
            complete = true;
        } else {
            c = from + ease(g2d_time * g2d_durationR) * difference;
        }

        set(c);
    }

    inline public function set(p_value:Float) {
        if (p_value != current) {
            Reflect.setProperty(g2d_tween.getTarget(), property, p_value);
        }
    }

    inline public function check() {
        init( Reflect.getProperty(g2d_tween.getTarget(), property) );
    }
}