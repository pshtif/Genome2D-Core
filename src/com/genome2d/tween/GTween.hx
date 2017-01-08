package com.genome2d.tween;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;

@:access(com.genome2d.tween.GTweenStep)
@:access(com.genome2d.tween.GTweenSequence)
class GTween {
    static private var g2d_dirty:Bool = false;
    static public var timeScale:Float = 1.0;
    static public var defaultEase:GEase = GLinear.none;
    
    static private var g2d_sequences:Array<GTweenSequence> = [];

    inline static private function createSequence(p_target:Dynamic):GTweenSequence {
        var sequence:GTweenSequence = GTweenSequence.getPoolInstance(p_target);
        g2d_sequences.push(sequence);
        return sequence;
    }

    static public function create(p_target:Dynamic):GTweenStep {
        return createSequence(p_target).addStep(GTweenStep.getPoolInstance());
    }

    static public function delay(p_callback:Void->Void, p_interval:Float):GTweenStep {
        return create(null).delay(p_interval).onComplete(p_callback);
    }

    static public function update(p_delta:Float) {
        p_delta *= timeScale/1000;
        for (sequence in g2d_sequences) {
            sequence.update(p_delta);
        }

        if (g2d_dirty) {
            var count:Int = g2d_sequences.length;
            while (count-->0) {
                var sequence:GTweenSequence = g2d_sequences[count];
                if (sequence.isComplete()) {
                    g2d_sequences.splice(count, 1);
                    sequence.dispose();
                }
            }
        }
    }
}
