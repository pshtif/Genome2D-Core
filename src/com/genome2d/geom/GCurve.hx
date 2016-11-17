/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.geom;
import com.genome2d.proto.IGPrototypable;

class GCurve implements IGPrototypable {
    public var start:Float;

    private var g2d_segments:Array<Segment>;
    private var g2d_pathLength:Int;
    private var g2d_totalStrength:Float;

    @prototype
    public var path(get,set):Array<Float>;
    public function get_path():Array<Float> {
        var p:Array<Float> = [start];
        for (segment in g2d_segments) {
            if (Std.is(segment,LinearSegment)) {
                p = p.concat([1, segment.end, segment.strength]);
            }
        }
        return p;
    }
    public function set_path(p_value:Array<Float>):Array<Float> {
        clear();
        start = p_value[0];
        var i:Int = 1;
        while (i<p_value.length) {
            switch (p_value[i]) {
                case 1:
                    addSegment(new LinearSegment(p_value[i+1], p_value[i+2]));
                    i+=3;
                case _:
                    trace("Not implemented");
            }
        }
        return p_value;
    }

    public function new(p_start:Float = 0) {
        start = p_start;
        g2d_segments = new Array<Segment>();
        g2d_pathLength = 0;
        g2d_totalStrength = 0;
    }

    public function isConstant():Bool {
        return g2d_pathLength == 0;
    }

    private function addSegment (p_segment:Segment):Void {
        g2d_segments.push(p_segment);
        g2d_totalStrength += p_segment.strength;
        g2d_pathLength++;
    }

    public function clear():Void {
        g2d_pathLength = 0;
        g2d_segments = new Array<Segment>();
        g2d_totalStrength = 0;
    }

    public function line(p_end:Float, p_strength:Float = 1):GCurve {
        addSegment(new LinearSegment(p_end, p_strength));

        return this;
    }

    public function getEnd():Float {
        return (g2d_pathLength>0) ? g2d_segments[g2d_pathLength-1].end : Math.NaN;
    }

    inline public function calculate(k:Float):Float {
        var r:Float = start;
        if (g2d_pathLength == 1) {
            r = g2d_segments[0].calculate(start, k);
        } else if (g2d_pathLength > 1) {
            var ratio:Float = k * g2d_totalStrength;
            var lastEnd:Float = start;

            for (i in 0...g2d_pathLength) {
                var path:Segment = g2d_segments[i];
                if (ratio > path.strength) {
                    ratio -= path.strength;
                    lastEnd = path.end;
                } else {
                    r = path.calculate(lastEnd, ratio / path.strength);
                }
            }
        }

        return r;
    }

    static public function createLine(p_end:Float, p_strength:Float = 1):GCurve {
        return new GCurve().line(p_end, p_strength);
    }

    public function quadraticBezier(p_end:Float, p_control:Float, p_strength:Float = 1):GCurve {
        addSegment(new QuadraticBezierSegment(p_end, p_strength, p_control));
        return this;
    }

    public function cubicBezier(p_end:Float, p_control1:Float, p_control2:Float, p_strength:Float = 1):GCurve {
        addSegment(new CubicBezierSegment(p_end, p_strength, p_control1, p_control2));
        return this;
    }
}

class Segment {
    public var end:Float;
    public var strength:Float;

    public function new(p_end:Float, p_strength:Float) {
        end = p_end;
        strength = p_strength;
    }

    public function calculate (p_start:Float, p_d:Float):Float {
        return Math.NaN;
    }
}

class LinearSegment extends Segment {
    public function new(p_end:Float, p_strength:Float) {
        super (p_end, p_strength);
    }

    override public function calculate (p_start:Float, p_d:Float):Float {
        return p_start + p_d * (end - p_start);
    }
}

class QuadraticBezierSegment extends Segment {
    public var control:Float;

    public function new(p_end:Float, p_strength:Float, p_control:Float) {
        super(p_end, p_strength);

        control = p_control;
    }


    override public function calculate (p_start:Float, p_d:Float):Float {
        var inv:Float = (1 - p_d);
        return inv * inv * p_start + 2 * inv * p_d * control + p_d * p_d * end;
    }
}

class CubicBezierSegment extends Segment {

    public var control1:Float;
    public var control2:Float;

    public function new(p_end:Float, p_strength:Float, p_control1:Float, p_control2:Float) {
        super(p_end, p_strength);

        control1 = p_control1;
        control2 = p_control2;
    }


    override public function calculate (p_start:Float, p_d:Float):Float {
        var inv:Float = (1 - p_d);
        var inv2:Float = inv*inv;
        var d2:Float = p_d*p_d;
        return inv2 * inv * p_start + 3 * inv2 * p_d * control1 + 3 * inv * d2 * control2 + d2 * p_d * end;
    }
}