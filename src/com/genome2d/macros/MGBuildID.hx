package com.genome2d.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

import haxe.crypto.Md5;
import haxe.Timer;

class MGBuildID {

    macro static public function getBuildId() {
        return macro $v{ Md5.encode(Std.string( Timer.stamp()*Math.random() )) };
    }

    macro static public function getBuildDate() {
        return macro $v{ Date.now().toString() };
    }
}
