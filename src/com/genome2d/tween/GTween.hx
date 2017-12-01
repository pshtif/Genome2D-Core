/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.tween;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.tween.easing.GLinear;
import com.genome2d.tween.easing.GEase;

@:access(com.genome2d.tween.GTweenStep)
@:access(com.genome2d.tween.GTweenSequence)
@:access(com.genome2d.tween.GTweenTimeline)
class GTween {
    static public var timeScale:Float = 1.0;
    static public var defaultEase:GEase = GLinear.none;

    static private var g2d_currentTimeline:GTweenTimeline;
    static private var g2d_timelines:Array<GTweenTimeline>;

    inline static private function removeTimeline(p_timeline:GTweenTimeline):Void {

    }

    inline static private function addTimeline(p_timeline:GTweenTimeline, p_setCurrent:Bool = false):Void {
        if (p_setCurrent) g2d_currentTimeline = p_timeline;
        if (g2d_timelines == null) g2d_timelines = new Array<GTweenTimeline>();
        g2d_timelines.push(p_timeline);
    }

    static public function createFromSequencePrototype(p_prototype:GPrototype):GTweenStep {
        var sequence:GTweenSequence = cast GPrototypeFactory.createInstance(p_prototype);
        if (g2d_currentTimeline == null) addTimeline(new GTweenTimeline(), true);
        g2d_currentTimeline.addSequence(sequence);
        return sequence.getLastStep();
    }

    static public function create(p_target:Dynamic, p_autoRun:Bool = true):GTweenStep {
        var sequence:GTweenSequence = GTweenSequence.getPoolInstance();

        if (g2d_currentTimeline == null) addTimeline(new GTweenTimeline(), true);
        g2d_currentTimeline.addSequence(sequence);

        var step:GTweenStep = sequence.addStep(GTweenStep.getPoolInstance());
        if (Std.is(p_target,String)) {
            step.targetId = p_target;
        } else {
            step.g2d_target = p_target;
        }

        if (p_autoRun) sequence.run();

        return step;
    }

    static public function delay(p_time:Float, p_callback:Dynamic, p_args:Array<Dynamic> = null):GTweenStep {
        return create(null).delay(p_time).onComplete(p_callback, p_args);
    }

    static public function update(p_delta:Float):Void {
        p_delta *= timeScale/1000;
        if (g2d_timelines != null) {
            for (timeline in g2d_timelines) {
                timeline.update(p_delta);
            }
        }
    }

    static public function abortAllTimelines():Void {
        if (g2d_timelines != null) {
            while (g2d_timelines.length>0) {
                var timeline:GTweenTimeline = g2d_timelines.shift();
                timeline.abortAllSequences();
            }
        }
        g2d_currentTimeline = null;
    }
}
