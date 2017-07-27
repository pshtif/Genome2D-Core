package com.genome2d.tween;

import com.genome2d.ui.element.GUIElement;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.proto.GPrototype;

@prototypeName("tweenSequence")
@:access(com.genome2d.tween.GTween)
@:access(com.genome2d.tween.GTweenStep)
@:access(com.genome2d.tween.GTweenTimeline)
class GTweenSequence implements IGPrototypable {
    private var g2d_poolNext:GTweenSequence;
    static private var g2d_poolFirst:GTweenSequence;
    static public function getPoolInstance():GTweenSequence {
        var sequence:GTweenSequence = null;
        if (g2d_poolFirst == null) {
            sequence = new GTweenSequence();
        } else {
            sequence = g2d_poolFirst;
            g2d_poolFirst = g2d_poolFirst.g2d_poolNext;
            sequence.g2d_poolNext = null;
        }

        return sequence;
    }

    private var g2d_firstStep:GTweenStep;
    private var g2d_currentStep:GTweenStep;
    private var g2d_lastStep:GTweenStep;
    public function getLastStep():GTweenStep {
        return g2d_lastStep;
    }

    private var g2d_stepCount:Int = 0;

    private var g2d_running:Bool = false;

    private var g2d_timeline:GTweenTimeline;

    private var g2d_complete:Bool;
    inline public function isComplete():Bool {
        return g2d_complete;
    }

    public function new() {
    }

    private function dispose():Void {
        while (g2d_currentStep!=null) {
            var step:GTweenStep = g2d_currentStep;
            removeStep(step);
            step.dispose();
        }

        g2d_currentStep = null;
        g2d_lastStep = null;
        g2d_stepCount = 0;
        g2d_complete = false;
        g2d_running = false;
        g2d_timeline = null;

        g2d_poolNext = g2d_poolFirst;
        g2d_poolFirst = this;
    }

    public function update(p_delta:Float):Float {
        if (!g2d_running) return p_delta;

        var rest:Float = p_delta;
        while (rest>0 && g2d_currentStep != null) {
            rest = updateCurrentStep(rest);
        }

        return rest;
    }

    private function updateCurrentStep(p_delta:Float):Float {
        var rest:Float = p_delta;
        if (g2d_currentStep == null) {
            finish();
        } else {
            rest = g2d_currentStep.update(p_delta);
        }
        return rest;
    }

    inline private function finish():Void {
        g2d_timeline.g2d_dirty = true;
        g2d_complete = true;
    }

    inline private function addStep(p_tween:GTweenStep):GTweenStep {
        p_tween.g2d_sequence = this;

        if (g2d_currentStep == null) {
            g2d_firstStep = g2d_lastStep = g2d_currentStep = p_tween;
        } else {
            g2d_lastStep.g2d_next = p_tween;
            p_tween.g2d_previous = g2d_lastStep;
            g2d_lastStep = p_tween;
        }
        g2d_stepCount++;
        return p_tween;
    }

    inline private function nextStep():Void {
        g2d_currentStep = g2d_currentStep.g2d_next;
    }

    inline private function removeStep(p_tween:GTweenStep):Void {
        g2d_stepCount--;
        if (g2d_firstStep == p_tween) g2d_firstStep = g2d_firstStep.g2d_next;
        if (g2d_currentStep == p_tween) g2d_currentStep = p_tween.g2d_next;
        if (g2d_lastStep == p_tween) g2d_lastStep = p_tween.g2d_previous;
        if (p_tween.g2d_previous != null) p_tween.g2d_previous.g2d_next = p_tween.g2d_next;
        if (p_tween.g2d_next != null) p_tween.g2d_next.g2d_previous = p_tween.g2d_previous;
    }

    public function skipCurrent() {
        if (g2d_currentStep != null) g2d_currentStep.skip();
    }

    /*
    public function skip() {
        while (g2d_currentStep != null) skipCurrent();
    }
    /**/
    public function abort() {
        g2d_timeline.removeSequence(this);
    }

    public function bind(p_target:GUIElement, p_autoRun:Bool = false):Void {
        var step:GTweenStep = g2d_firstStep;
        while (step != null) {
            if (step.targetId != null) {
                step.g2d_target = p_target.getChildByName(step.targetId, true);
            }
            step = step.g2d_next;
        }
        if (p_autoRun) run();
    }

    public function run():Void {
        g2d_running = true;
    }

    public function repeat():Void {
        g2d_currentStep = g2d_firstStep;
    }

    public function reset():Void {
        var step:GTweenStep = g2d_firstStep;
        while (step != null) {
            step.g2d_currentRepeatCount = 0;
            step = step.g2d_next;
        }
        g2d_currentStep = g2d_firstStep;
    }

    /****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/

    public function getPrototype(p_prototype:GPrototype = null):GPrototype {
        p_prototype = getPrototypeDefault(p_prototype);

        var step:GTweenStep = g2d_firstStep;
        while (step != null) {
            p_prototype.addChild(step.getPrototype(), "tweenSteps");
            step = step.g2d_next;
        }

        return p_prototype;
    }

    public function bindPrototype(p_prototype:GPrototype):Void {
        bindPrototypeDefault(p_prototype);

        var stepPrototypes:Array<GPrototype> = p_prototype.getGroup("tweenSteps");
        if (stepPrototypes != null) {
            for (stepPrototype in stepPrototypes) {
                var step:GTweenStep = GPrototypeFactory.createInstance(stepPrototype);
                addStep(step);
            }
        }
    }
}
