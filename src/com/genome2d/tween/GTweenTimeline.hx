package com.genome2d.tween;

import com.genome2d.macros.MGDebug;
@prototypeName("tweenTimeline")
@:access(com.genome2d.tween.GTweenSequence)
class GTweenTimeline {
    private var g2d_dirty:Bool = false;
    private var g2d_sequences:Array<GTweenSequence> = [];

    public function new() {
        g2d_sequences = new Array<GTweenSequence>();
    }

    inline private function addSequence(p_sequence:GTweenSequence):Void {
        p_sequence.g2d_timeline = this;
        g2d_sequences.push(p_sequence);
    }

    private function removeSequence(p_sequence:GTweenSequence):Void {
        g2d_sequences.remove(p_sequence);
        p_sequence.dispose();
    }

    public function abortAllSequences():Void {
        while (g2d_sequences.length>0) {
            var sequence:GTweenSequence = g2d_sequences.shift();
            sequence.dispose();
        }
    }

    public function update(p_delta:Float) {
        for (i in 0...g2d_sequences.length) {
            g2d_sequences[i].update(p_delta);
        }

        if (g2d_dirty) {
            var count:Int = g2d_sequences.length;
            while (count-->0) {
                var sequence:GTweenSequence = g2d_sequences[count];
                if (sequence.isComplete()) {
                    removeSequence(sequence);
                }
            }
            g2d_dirty = false;
        }
    }
}
