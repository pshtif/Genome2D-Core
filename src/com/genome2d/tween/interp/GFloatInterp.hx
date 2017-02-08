package com.genome2d.tween.interp;

import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.easing.GEase;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@prototypeName("tweenFloat")
@:access(com.genome2d.create.GTweenStep)
class GFloatInterp implements IGInterp implements IGPrototypable {

    private var g2d_tween:GTweenStep;

    @prototype
    public var duration:Float;

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

    public var hasInitialized:Bool;

    public function getFinalValue():Float {
        return from + difference;
    }

    public function new(p_tween:GTweenStep) {
        g2d_tween = p_tween;
        ease = GTween.defaultEase;
        g2d_time = 0;
    }

    inline private function init() {
        from = Reflect.getProperty(g2d_tween.getTarget(), property);
        difference = to - from;
        hasInitialized = true;
    }

    inline public function reset():Void {
        g2d_time = 0;
        hasInitialized = false;
    }

    inline public function update(p_delta:Float) {
        if(!hasInitialized) init();

        g2d_time += p_delta;
        var c:Float;
        if (g2d_time > duration) {
            g2d_time = duration;
            c = from + difference;
            complete = true;
        } else {
            c = from + ease(g2d_time/duration) * difference;
        }

        setValue(c);
    }

    inline public function setValue(p_value:Float) {
        if (p_value != current) Reflect.setProperty(g2d_tween.getTarget(), property, p_value);
    }
}