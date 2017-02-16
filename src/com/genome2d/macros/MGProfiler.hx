package com.genome2d.macros;

#if macro
import haxe.PosInfos;

class MGProfiler {
    macro static public function PROFILE(expr) {
        return macro {
            var g2d_profileTime:Int = untyped __global__["flash.utils.getTimer"]();
            ${expr};
            g2d_profileTime = untyped __global__["flash.utils.getTimer"]() - g2d_profileTime;
            @:pos(expr.pos) MGProfiler.PROFILE_INTERNAL(g2d_profileTime);
        }
    }

    static public function PROFILE_INTERNAL(p_time:Int, ?pos:PosInfos) {
        com.genome2d.debug.GDebug.trace("PROFILE BLOCK ["+pos.className+":"+pos.methodName+"] END Elapsed: "+p_time+"ms");
    }
}
#end