package com.genome2d.tween;

import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.interp.GCurveInterp;
import com.genome2d.geom.GCurve;
import com.genome2d.macros.MGDebug;
import com.genome2d.tween.interp.GFloatInterp;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;

@prototypeName("tweenStep")
@:access(com.genome2d.tween.GTweenSequence)
class GTweenStep implements IGPrototypable {

    /****************************************************************************************************
	 * 	POOLING CODE
	 ****************************************************************************************************/
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
    private var g2d_interps:Array<IGInterp>;
    private var g2d_time:Float;

    private var g2d_duration:Float;
    @prototype
    public var duration(get, set):Float;
    #if swc @:getter(duration) #end
    inline private function get_duration():Float {
        return g2d_duration;
    }
    #if swc @:setter(duration) #end
    inline public function set_duration(p_value:Float):Float {
        return g2d_duration = p_value;
    }

    private var g2d_lastInterp:IGInterp;
    private var g2d_target:Dynamic;

    @prototype
    public var targetId:String;

    private var g2d_onComplete:Void->Void;
    private var g2d_onUpdate:Float->Void;

    private var g2d_empty:Bool;

    inline public function getTarget():Dynamic {
        return g2d_target;
    }

    inline public function getSequence():GTweenSequence {
        return g2d_sequence;
    }

    public function new() {
        g2d_time = g2d_duration = 0.0;
        g2d_empty = true;
    }

    private function addInterp(p_interp:IGInterp):GTweenStep {
        if(g2d_interps == null) g2d_interps = new Array<IGInterp>();
        g2d_duration = Math.max(g2d_duration, p_interp.duration);
        g2d_lastInterp = p_interp;
        g2d_interps.push(p_interp);
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
            if (g2d_interps != null) for (interp in g2d_interps) interp.ease = p_ease;
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
        g2d_sequence.nextStep();
        g2d_time = 0;
        if (g2d_interps != null) for (interp in g2d_interps) interp.reset();
    }

    private function dispose():Void {
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

    public function update(p_delta:Float):Float {
        var rest:Float = 0;
        if (g2d_interps != null) {
            for (interp in g2d_interps) {
                if(!interp.hasUpdated) interp.check();
                interp.update(p_delta);
            }
        }

        g2d_time += p_delta;
        if (g2d_time >= g2d_duration) {
            rest = g2d_time-g2d_duration;
            g2d_time = g2d_duration;
        }

        if (g2d_onUpdate != null) {
            g2d_onUpdate(g2d_time / g2d_duration);
        }

        if (g2d_time >= g2d_duration) {
            finish();
        }

        return rest;
    }

    inline public function delay(p_duration:Float):GTweenStep {
        var step:GTweenStep = (g2d_empty) ? this : g2d_sequence.addStep(getPoolInstance());
        step.g2d_duration = p_duration;
        g2d_empty = false;
        step = g2d_sequence.addStep(getPoolInstance());
        step.g2d_target = g2d_target;
        step.targetId = targetId;
        return step;
    }

    public function propF(p_property:String, p_to:Float, p_duration:Float):GTweenStep {
        var interp:GFloatInterp = new GFloatInterp(this);
        interp.property = p_property;
        interp.duration = p_duration;
        interp.to = p_to;
        return addInterp(interp);
    }

    public function propC(p_property:String, p_value:GCurve, p_duration:Float):GTweenStep {
        return addInterp(new GCurveInterp(this, p_property, p_value, p_duration));
    }

    inline public function create(p_target:Dynamic):GTweenStep {
        var step:GTweenStep = g2d_sequence.addStep(getPoolInstance());
        if (Std.is(p_target,String)) {
            step.targetId = p_target;
        } else {
            step.g2d_target = p_target;
        }
        return step;
    }

    /****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/

    public function getPrototype(p_prototype:GPrototype = null):GPrototype {
        p_prototype = getPrototypeDefault(p_prototype);

        if (g2d_interps != null) {
            for (interp in g2d_interps) {
                if (Std.is(interp,IGPrototypable)) {
                    p_prototype.addChild(cast (interp, IGPrototypable).getPrototype(), "tweenProps");
                }
            }
        }

        return p_prototype;
    }

    public function bindPrototype(p_prototype:GPrototype):Void {
        bindPrototypeDefault(p_prototype);

        var interpPrototypes:Array<GPrototype> = p_prototype.getGroup("tweenProps");
        if (interpPrototypes != null) {
            for (interpPrototype in interpPrototypes) {
                var interp:IGInterp = cast GPrototypeFactory.createInstance(interpPrototype, [this]);
                addInterp(interp);
            }
        }
    }
}