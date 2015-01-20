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

    static public function info(p_msg:String):Void {

    }

    static public function warning(p_msg:String):Void {

    }

    static public function error(p_msg:String):Void {

    }

    static public function critical(p_msg:String):Void {

    }
}