package com.genome2d.tween;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.tween.easing.GEase;

@:allow(com.genome2d.tween.GTweenStep)
interface IGInterp {

    public var duration(get,set):Float;
    public var complete:Bool;
    public var property:String;
    public var ease:GEase;
    public var from:Float;
    var hasUpdated:Bool;

    public function update(delta:Float):Void;
    public function set(val:Float):Void;
    public function getFinalValue():Dynamic;
    public function reset():Void;

    function check():Void;
}
