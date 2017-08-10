package com.genome2d.tween.interp;

import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.easing.GSine;
import com.genome2d.tween.easing.GQuint;
import com.genome2d.tween.easing.GQuart;
import com.genome2d.tween.easing.GExpo;
import com.genome2d.tween.easing.GCubic;
import com.genome2d.tween.easing.GBounce;
import com.genome2d.tween.easing.GBack;
import com.genome2d.tween.easing.GQuad;
import com.genome2d.tween.easing.GEaseEnum;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;
import com.genome2d.geom.GCurve;
import com.genome2d.tween.GTweenStep;
import com.genome2d.tween.IGInterp;

@:access(com.genome2d.create.GTweenStep)
class GCurveInterp implements IGInterp implements IGPrototypable {

    public var tween:GTweenStep;

    @prototype
    public var duration:Float;

    private var g2d_time:Float;

    public var from:Float;

    @prototype
    public var to:GCurve;

    public var current:Float;
    public var ease:GEase;
    public var complete:Bool;

    @prototype
    public var property:String;

    public var hasInitialized:Bool = false;

    public function getFinalValue():Float {
        return from + to.calculate(1);
    }

    public function new(p_tween:GTweenStep) {
        ease = GTween.defaultEase;
        this.tween = p_tween;
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
        if(!hasInitialized) init();

        g2d_time += p_delta;
        var c = current;
        if (g2d_time > duration) {
            g2d_time = duration;
            c = from + to.calculate(1);
            complete = true;
        }else {
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

    @prototype
    public var easeEnum(get,set):GEaseEnum;
    public function get_easeEnum():GEaseEnum {
        if (ease == GQuad.easeIn) {
            return GEaseEnum.QUAD_IN;
        } else if (ease == GQuad.easeOut) {
            return GEaseEnum.QUAD_OUT;
        } else if (ease == GQuad.easeInOut) {
            return GEaseEnum.QUAD_IN_OUT;
        } else if (ease == GBack.easeIn) {
            return GEaseEnum.BACK_IN;
        } else if (ease == GBack.easeOut) {
            return GEaseEnum.BACK_OUT;
        } else if (ease == GBack.easeInOut) {
            return GEaseEnum.BACK_IN_OUT;
        } else if (ease == GBounce.easeIn) {
            return GEaseEnum.BOUNCE_IN;
        } else if (ease == GBounce.easeOut) {
            return GEaseEnum.BOUNCE_OUT;
        } else if (ease == GBounce.easeInOut) {
            return GEaseEnum.BOUNCE_IN_OUT;
        } else if (ease == GCubic.easeIn) {
            return GEaseEnum.CUBIC_IN;
        } else if (ease == GCubic.easeOut) {
            return GEaseEnum.CUBIC_OUT;
        } else if (ease == GCubic.easeInOut) {
            return GEaseEnum.CUBIC_IN_OUT;
        } else if (ease == GExpo.easeIn) {
            return GEaseEnum.EXPO_IN;
        } else if (ease == GExpo.easeOut) {
            return GEaseEnum.EXPO_OUT;
        } else if (ease == GExpo.easeInOut) {
            return GEaseEnum.EXPO_IN_OUT;
        } else if (ease == GQuart.easeIn) {
            return GEaseEnum.QUART_IN;
        } else if (ease == GQuart.easeOut) {
            return GEaseEnum.QUART_OUT;
        } else if (ease == GQuart.easeInOut) {
            return GEaseEnum.QUART_IN_OUT;
        } else if (ease == GQuint.easeIn) {
            return GEaseEnum.QUINT_IN;
        } else if (ease == GQuint.easeOut) {
            return GEaseEnum.QUINT_OUT;
        } else if (ease == GQuint.easeInOut) {
            return GEaseEnum.QUINT_IN_OUT;
        } else if (ease == GSine.easeIn) {
            return GEaseEnum.SINE_IN;
        } else if (ease == GSine.easeOut) {
            return GEaseEnum.SINE_OUT;
        } else if (ease == GSine.easeInOut) {
            return GEaseEnum.SINE_IN_OUT;
        }


        return GEaseEnum.LINEAR;
    }
    public function set_easeEnum(p_value:GEaseEnum):GEaseEnum {
        switch (p_value) {
            case GEaseEnum.BACK_IN:
                ease = GBack.easeIn;
            case GEaseEnum.BACK_OUT:
                ease = GBack.easeOut;
            case GEaseEnum.BACK_IN_OUT:
                ease = GBack.easeInOut;
            case GEaseEnum.BOUNCE_IN:
                ease = GBounce.easeIn;
            case GEaseEnum.BOUNCE_OUT:
                ease = GBounce.easeIn;
            case GEaseEnum.BOUNCE_IN_OUT:
                ease = GBounce.easeInOut;
            case GEaseEnum.CUBIC_IN:
                ease = GCubic.easeIn;
            case GEaseEnum.CUBIC_OUT:
                ease = GCubic.easeOut;
            case GEaseEnum.CUBIC_IN_OUT:
                ease = GCubic.easeInOut;
            case GEaseEnum.EXPO_IN:
                ease = GExpo.easeIn;
            case GEaseEnum.EXPO_OUT:
                ease = GExpo.easeOut;
            case GEaseEnum.EXPO_IN_OUT:
                ease = GExpo.easeInOut;
            case GEaseEnum.QUART_IN:
                ease = GQuart.easeIn;
            case GEaseEnum.QUART_OUT:
                ease = GQuart.easeOut;
            case GEaseEnum.QUART_IN_OUT:
                ease = GQuart.easeInOut;
            case GEaseEnum.QUINT_IN:
                ease = GQuint.easeIn;
            case GEaseEnum.QUINT_OUT:
                ease = GQuint.easeOut;
            case GEaseEnum.QUINT_IN_OUT:
                ease = GQuint.easeInOut;
            case GEaseEnum.SINE_IN:
                ease = GSine.easeIn;
            case GEaseEnum.SINE_OUT:
                ease = GSine.easeOut;
            case GEaseEnum.SINE_IN_OUT:
                ease = GSine.easeInOut;
            case GEaseEnum.QUAD_IN:
                ease = GQuad.easeIn;
            case GEaseEnum.QUAD_OUT:
                ease = GQuad.easeOut;
            case GEaseEnum.QUAD_IN_OUT:
                ease = GQuad.easeInOut;
            case _:
                ease = GLinear.none;
        }
        return p_value;
    }
}