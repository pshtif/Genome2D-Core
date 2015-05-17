package com.genome2d.macros;

import com.genome2d.debug.GDebug;
import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.Context;

class MGProfiler {
    macro static public function PROFILE(expr) {
        return macro {
            var __profileTime:Int = untyped __global__["flash.utils.getTimer"]();
            ${expr};
            __profileTime = untyped __global__["flash.utils.getTimer"]() - __profileTime;
            @:pos(expr.pos) MGProfiler.PROFILE_INTERNAL(__profileTime);
        }
    }

    static public function PROFILE_INTERNAL(p_time:Int, ?pos:PosInfos) {
        com.genome2d.debug.GDebug.trace("PROFILE BLOCK ["+pos.className+":"+pos.methodName+"] END Elapsed: "+p_time+"ms");
    }
}
