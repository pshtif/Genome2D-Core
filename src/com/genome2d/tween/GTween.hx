package com.genome2d.tween;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;

@:access(com.genome2d.tween.GTweenStep)
@:access(com.genome2d.tween.GTweenSequence)
class GTween {
    static private var g2d_dirty:Bool = false;
    static public var timeScale:Float = 1.0;
    static public var defaultEase:GEase = GLinear.none;
    
    static private var g2d_sequences:Array<GTweenSequence> = [];

    inline static private function createSequence():GTweenSequence {
        var sequence:GTweenSequence = GTweenSequence.getPoolInstance();
        g2d_sequences.push(sequence);
        return sequence;
    }

    inline static private function addSequence(p_sequence:GTweenSequence):Void {
        g2d_sequences.push(p_sequence);
    }

    static public function createFromPrototype(p_prototype:GPrototype):GTweenStep {
        var sequence:GTweenSequence = cast GPrototypeFactory.createInstance(p_prototype);
        return sequence.getLastStep();
    }

    static public function create(p_target:Dynamic):GTweenStep {
        var step:GTweenStep = createSequence().addStep(GTweenStep.getPoolInstance());
        if (Std.is(p_target,String)) {
            step.targetId = p_target;
        } else {
            step.g2d_target = p_target;
        }
        return step;
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
