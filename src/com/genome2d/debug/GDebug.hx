package com.genome2d.debug;

import msignal.Signal.Signal1;

class GDebug {
    static public var onDebug:Signal1<String>;

    static public function init():Void {
        onDebug = new Signal1<String>();
    }

    static public function trace(p_msg:String):Void {
        if (onDebug != null) onDebug.dispatch(p_msg);
    }
}