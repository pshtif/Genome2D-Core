package com.genome2d.debug;

import msignal.Signal.Signal1;

class GDebug {
    static private var console:String = "";

    static public var onDebug:Signal1<String>;

    static public function init():Void {
        onDebug = new Signal1<String>();
    }

    static public function trace(p_msg:String):Void {
        console += p_msg+"\n";
        onDebug.dispatch(p_msg);
    }

    static public function info(p_msg:String):Void {
        console += "INFO: "+p_msg+"\n";
        onDebug.dispatch("INFO: "+p_msg);
    }

    static public function warning(p_msg:String):Void {
        console += "WARNING: "+p_msg+"\n";
        onDebug.dispatch("WARNING: "+p_msg);
    }

    static public function error(p_msg:String):Void {
        console += "ERROR: "+p_msg+"\n";
        throw "ERROR: "+p_msg;
    }
}