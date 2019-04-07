package com.genome2d.proto;

class GPrototypeConstructorLookups {
    static private var _arguments:Map<String,Array<Dynamic>>;

    static public function getArguments(p_prototypeName:String):Array<Dynamic> {
        var args:Array<Dynamic> = _arguments.get(p_prototypeName);
        return args == null ? [] : args;
    } 

    static public function initialize():Void {
        _arguments = new Map<String, Array<Dynamic>>();
        _arguments.set("textureSkin", ["", null, true, null]);
        _arguments.set("fontSkin", ["", null, 1, true, null]);
        _arguments.set("element", [null]);
        _arguments.set("particle_emitter", [null]);
        _arguments.set("GCurve", [0.0]);
        _arguments.set("GIntPoint", [0,0]);
        _arguments.set("GPostProcess", [1, null]);
        _arguments.set("transition", ["", 0, null, 0]);
        _arguments.set("GCurveInterp", [null]);
        _arguments.set("tweenFloat", [null]);
    }
}