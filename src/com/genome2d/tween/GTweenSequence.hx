package com.genome2d.tween;

@:access(com.genome2d.tween.GTween)
@:access(com.genome2d.tween.GTweenStep)
class GTweenSequence {
    private var g2d_poolNext:GTweenSequence;
    static private var g2d_poolFirst:GTweenSequence;
    static public function getPoolInstance(p_target:Dynamic):GTweenSequence {
        var sequence:GTweenSequence = null;
        if (g2d_poolFirst == null) {
            sequence = new GTweenSequence(p_target);
        } else {
            sequence = g2d_poolFirst;
            sequence.g2d_target = p_target;
            g2d_poolFirst = g2d_poolFirst.g2d_poolNext;
            sequence.g2d_poolNext = null;
        }

        return sequence;
    }

    private var g2d_currentTween:GTweenStep;
    private var g2d_lastTween:GTweenStep;
    private var g2d_target:Dynamic;
    private var g2d_tweenCount:Int = 0;

    private var g2d_complete:Bool;
    inline public function isComplete():Bool {
        return g2d_complete;
    }

    public function new(p_target:Dynamic) {
        g2d_target = p_target;
    }

    inline private function dispose():Void {
        g2d_currentTween = null;
        g2d_lastTween = null;
        g2d_target = null;
        g2d_tweenCount = 0;
        g2d_complete = false;

        g2d_poolNext = g2d_poolFirst;
        g2d_poolFirst = this;
    }

    public function update(p_delta:Float):Void {
        if (g2d_complete) return;

        if (g2d_currentTween == null) {
            GTween.g2d_dirty = true;
            g2d_complete = true;
        } else {
            g2d_currentTween.update(p_delta);
        }
    }

    inline private function addStep(p_tween:GTweenStep):GTweenStep {
        p_tween.g2d_sequence = this;
        if (g2d_currentTween == null) {
            g2d_lastTween = g2d_currentTween = p_tween;
        } else {
            g2d_lastTween.g2d_next = p_tween;
            p_tween.g2d_previous = g2d_lastTween;
            g2d_lastTween = p_tween;
        }
        g2d_tweenCount++;
        return p_tween;
    }

    inline private function removeStep(p_tween:GTweenStep):Void {
        g2d_tweenCount--;
        if (g2d_currentTween == p_tween) g2d_currentTween = p_tween.g2d_next;
        if (g2d_lastTween == p_tween) g2d_lastTween = p_tween.g2d_previous;
        if (p_tween.g2d_previous != null) p_tween.g2d_previous.g2d_next = p_tween.g2d_next;
        if (p_tween.g2d_next != null) p_tween.g2d_next.g2d_previous = p_tween.g2d_previous;
    }

    public function skipCurrent() {
        if (g2d_currentTween != null) g2d_currentTween.skip();
    }
}
