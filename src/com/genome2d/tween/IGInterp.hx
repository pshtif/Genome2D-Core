package com.genome2d.tween;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.easing.GEase;

@:allow(com.genome2d.tween.GTweenStep)
interface IGInterp {

    public var duration:Float;
    public var complete:Bool;
    public var property:String;
    public var ease:GEase;
    public var from:Float;

    public function update(p_delta:Float):Void;
    public function setValue(p_value:Float):Void;
    public function getFinalValue():Dynamic;
    public function reset():Void;
}
