package com.genome2d.tween;
import com.genome2d.tween.easing.GEase;
interface IGInterp {

    public var tween:GTweenStep;
    public var complete:Bool;
    public var name:String;
    public var ease:GEase;
    public var from:Float;
    var hasUpdated:Bool;

    public function update(delta:Float):Void;
    public function set(val:Float):Void;
    public function getFinalValue():Dynamic;

    function check():Void;
}
