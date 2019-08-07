package com.genome2d.tween;

import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.interp.GCurveInterp;
import com.genome2d.geom.GCurve;
import com.genome2d.tween.interp.GFloatInterp;
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

    private var g2d_stepId:String = "";
    @prototype
    public var stepId(get, set):String;
    #if swc @:getter(stepId) #end
    inline private function get_stepId():String {
        return g2d_stepId;
    }
    #if swc @:setter(stepId) #end
    inline public function set_stepId(p_value:String):String {
        return g2d_stepId = p_value;
    }

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

    private var g2d_gotoStepId:String = "";
    @prototype
    public var gotoStepId(get, set):String;
    #if swc @:getter(gotoStepId) #end
    inline private function get_gotoStepId():String {
        return g2d_gotoStepId;
    }
    #if swc @:setter(gotoStepId) #end
    inline public function set_gotoStepId(p_value:String):String {
        return g2d_gotoStepId = p_value;
    }

    private var g2d_gotoRepeatCount:Int = 0;
    @prototype
    public var gotoRepeatCount(get, set):Int;
    #if swc @:getter(gotoRepeatCount) #end
    inline private function get_gotoRepeatCount():Int {
        return g2d_gotoRepeatCount;
    }
    #if swc @:setter(gotoRepeatCount) #end
    inline public function set_gotoRepeatCount(p_value:Int):Int {
        return g2d_gotoRepeatCount = p_value;
    }

    private var g2d_currentGotoRepeatCount:Int = 0;

    private var g2d_lastInterp:IGInterp;
    private var g2d_target:Dynamic;

    @prototype
    public var targetId:String;

    private var g2d_onComplete:Array<Dynamic>->Void;
    private var g2d_onCompleteArgs:Array<Dynamic>;
    private var g2d_onUpdate:Array<Dynamic>->Void;
    private var g2d_onUpdateArgs:Array<Dynamic>;

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

    inline public function onUpdate(p_callback:Dynamic, p_args:Array<Dynamic> = null):GTweenStep {
        g2d_onUpdateArgs = p_args == null ? [] : p_args;
        g2d_onUpdate = p_callback;
        return this;
    }

    inline public function onComplete(p_callback:Dynamic, p_args:Array<Dynamic> = null):GTweenStep {
        g2d_onCompleteArgs = p_args == null ? [] : p_args;
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
        if (g2d_interps != null) for (interp in g2d_interps) interp.setValue(interp.getFinalValue());
        finish();
    }

    inline private function finish():Void {
        reset();
        if (g2d_sequence != null) {
            if (g2d_currentGotoRepeatCount<g2d_gotoRepeatCount) {
                g2d_currentGotoRepeatCount++;
                g2d_sequence.goto(g2d_sequence.getStepById(g2d_gotoStepId));
            } else {
                if (g2d_onComplete != null) Reflect.callMethod(g2d_onComplete, g2d_onComplete, g2d_onCompleteArgs);
                g2d_currentGotoRepeatCount = 0;
                g2d_sequence.nextStep();
            }
        }
    }

    private function dispose():Void {
        g2d_sequence = null;
        g2d_previous = null;
        g2d_next = null;
        g2d_interps = null;
        g2d_lastInterp = null;
        g2d_time = g2d_duration = 0;
        g2d_empty = true;
        g2d_time = g2d_duration = 0;
        g2d_onComplete = null;
        g2d_onCompleteArgs = null;
        g2d_onUpdate = null;
        g2d_onUpdateArgs = null;
        targetId = "";
        g2d_target = null;
        g2d_gotoStepId = "";
        g2d_gotoRepeatCount = 0;
        g2d_currentGotoRepeatCount = 0;

        // Put back to pool
        g2d_poolNext = g2d_poolFirst;
        g2d_poolFirst = this;
    }

    public function update(p_delta:Float):Float {
        var rest:Float = 0;
        if (g2d_interps != null) {
            for (interp in g2d_interps) {
                interp.update(p_delta);
            }
        }

        g2d_time += p_delta;
        if (g2d_time >= g2d_duration) {
            rest = g2d_time-g2d_duration;
            g2d_time = g2d_duration;
        }

        if (g2d_onUpdate != null) Reflect.callMethod(g2d_onUpdate, g2d_onUpdate, g2d_onUpdateArgs);

        if (g2d_time >= g2d_duration) {
            finish();
        }

        return rest;
    }

    public function delay(p_duration:Float):GTweenStep {
        var step:GTweenStep = (g2d_empty) ? this : g2d_sequence.addStep(getPoolInstance());
        step.g2d_duration = p_duration;
        g2d_empty = false;
        step = g2d_sequence.addStep(getPoolInstance());
        step.g2d_target = g2d_target;
        step.targetId = targetId;
        return step;
    }

    public function id(p_id:String):GTweenStep {
        g2d_stepId = p_id;
        return this;
    }

    public function propF(p_property:String, p_to:Float, p_duration:Float, p_relative:Bool):GTweenStep {
        var interp:GFloatInterp = new GFloatInterp(this);
        interp.relative = p_relative;
        interp.property = p_property;
        interp.duration = p_duration;
        interp.to = p_to;
        return addInterp(interp);
    }

    public function propC(p_property:String, p_to:GCurve, p_duration:Float, p_relative:Bool):GTweenStep {
        var interp:GCurveInterp = new GCurveInterp(this);
        interp.relative = p_relative;
        interp.property = p_property;
        interp.duration = p_duration;
        interp.to = p_to;
        return addInterp(interp);
    }

    public function create(p_target:Dynamic):GTweenStep {
        var step:GTweenStep = g2d_sequence.addStep(getPoolInstance());
        if (Std.is(p_target,String)) {
            step.targetId = p_target;
        } else {
            step.g2d_target = p_target;
        }
        return step;
    }

    public function extend():GTweenStep {
        var step:GTweenStep = g2d_sequence.addStep(getPoolInstance());
        step.g2d_target = g2d_target;
        step.targetId = targetId;
        return step;
    }

    #if swc
    public function gotoId(p_stepId:String, p_repeatCount:Int):GTweenStep {
    #else
    public function goto(p_stepId:String, p_repeatCount:Int):GTweenStep {
    #end
        g2d_gotoRepeatCount = p_repeatCount;
        g2d_gotoStepId = p_stepId;
        return this;
    }

    public function reset():Void {
        g2d_time = 0;
        if (g2d_interps != null) for (interp in g2d_interps) interp.reset();
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