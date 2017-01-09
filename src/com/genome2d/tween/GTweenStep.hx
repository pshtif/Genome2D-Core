package com.genome2d.tween;

import com.genome2d.tween.interp.GCurveInterp;
import com.genome2d.geom.GCurve;
import com.genome2d.macros.MGDebug;
import com.genome2d.tween.interp.GFloatInterp;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;

@:access(com.genome2d.tween.GTweenSequence)
class GTweenStep {
    private var g2d_poolNext:GTweenStep;
    static private var g2d_poolFirst:GTweenStep;
    static public function getPoolInstance():GTweenStep {
        var tween:GTweenStep = null;
        if (g2d_poolFirst == null) {
            tween = new GTweenStep();
        } else {
            tween = g2d_poolFirst;
            g2d_poolFirst = g2d_poolFirst.g2d_poolNext;
            tween.g2d_poolNext = null;
        }

        return tween;
    }

    private var g2d_sequence:GTweenSequence;
    private var g2d_previous:GTweenStep;
    private var g2d_next:GTweenStep;
    private var g2d_interps:Map<String,IGInterp>;
    private var g2d_time:Float;
    private var g2d_duration:Float;
    private var g2d_lastInterp:IGInterp;

    private var g2d_onComplete:Void->Void;
    private var g2d_onUpdate:Float->Void;

    private var g2d_empty:Bool;

    inline public function getTarget():Dynamic {
        return g2d_sequence.g2d_target;
    }

    inline public function getSequence():GTweenSequence {
        return g2d_sequence;
    }

    public function new() {
        g2d_time = g2d_duration = 0.0;
        g2d_empty = true;
    }

    private function addInterp(p_property:String, p_duration:Float, p_interp:IGInterp):GTweenStep {
        if(g2d_interps == null) g2d_interps = new Map<String,IGInterp>();
        g2d_duration = Math.max(g2d_duration, p_duration);
        g2d_lastInterp = p_interp;
        if (g2d_interps.exists(p_property)) MGDebug.WARNING("Property interpolator already in sequence", p_property);
        g2d_interps.set(p_property, p_interp);
        g2d_empty = false;
        return this;
    }

    inline public function onUpdate(p_callback:Float->Void):GTweenStep {
        g2d_onUpdate = p_callback;
        return this;
    }

    inline public function onComplete(p_callback:Void->Void):GTweenStep {
        g2d_onComplete = p_callback;
        return this;
    }

    inline public function ease(p_ease:GEase, p_all:Bool = true):GTweenStep {
        if (p_all) {
            if(g2d_interps != null) for (interp in g2d_interps) interp.ease = p_ease;
        } else {
            if (g2d_lastInterp != null ) g2d_lastInterp.ease = p_ease;
        }
        return this;
    }

    public function skip():Void {
        for (interp in g2d_interps) interp.set(interp.getFinalValue());
        finish();
    }

    inline private function finish():Void {
        if (g2d_onComplete != null) g2d_onComplete();
        g2d_sequence.removeStep(this);
        dispose();
    }

    inline private function dispose():Void {
        g2d_sequence = null;
        g2d_previous = null;
        g2d_next = null;
        g2d_interps = null;
        g2d_lastInterp = null;
        g2d_time = g2d_duration = 0;

        // Put back to pool
        g2d_poolNext = g2d_poolFirst;
        g2d_poolFirst = this;
    }

    public function update(p_delta:Float):Void {
        if (g2d_duration == -1) return;

        if (g2d_interps != null) {
            for (interpolator in g2d_interps) {
                if(!interpolator.hasUpdated) interpolator.check();
                interpolator.update(p_delta);
            }
        }

        g2d_time += p_delta;
        if (g2d_onUpdate != null) {
            g2d_onUpdate(g2d_time / g2d_duration);
        }

        if (g2d_time >= g2d_duration) {
            finish();
        }
    }

    inline public function delay(p_duration:Float):GTweenStep {
        var step:GTweenStep = (g2d_empty) ? this : g2d_sequence.addStep(getPoolInstance());
        step.g2d_duration = p_duration;
        g2d_empty = false;
        return g2d_sequence.addStep(getPoolInstance());
    }

    public function propF(p_property:String, p_value:Float, p_duration:Float):GTweenStep {
        return addInterp(p_property, p_duration, new GFloatInterp(this, p_property, p_value, p_duration));
    }

    public function propC(p_property:String, p_value:GCurve, p_duration:Float):GTweenStep {
        return addInterp(p_property, p_duration, new GCurveInterp(this, p_property, p_value, p_duration));
    }
}