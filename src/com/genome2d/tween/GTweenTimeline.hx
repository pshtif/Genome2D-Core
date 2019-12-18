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
        var index:Int = 0;
        while (index<g2d_sequences.length) {
            if (g2d_sequences[index] != null) {
                g2d_sequences[index].update(p_delta);
            }
            index++;
        }

        if (g2d_dirty) {
            index = g2d_sequences.length;
            while (index-->0) {
                var sequence:GTweenSequence = g2d_sequences[index];
                if (sequence.isComplete()) {
                    removeSequence(sequence);
                }
            }
            g2d_dirty = false;
        }
    }
}
