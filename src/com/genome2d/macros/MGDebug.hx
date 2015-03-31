package com.genome2d.macros;

import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.Context;

class MGDebug {

    static public function PROCESSOR_DEBUG(p_priority:Expr, p_function:Function) {
        #if genome_debug
        switch (p_function.args.length) {
            case 1:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name});
            case 2:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name});
            case 3:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name});
            case 4:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name});
            case 5:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name});
            case 6:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name});
            case 7:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name});
            case 8:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name});
            case 9:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name});
            case 10:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name});
            case 11:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name});
            case 12:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name});
            case 13:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name});
            case 14:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name});
            case 15:
                return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name});
            case _:
                //return macro @:pos(p_function.expr.pos) GDebug.debug($p_priority);
        }
        return macro null;
        #else
        return macro null;
        #end
    }

    macro static public function DUMP(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        #if genome_debug
        //return macro @:pos(p_arg1.pos) GDebug.dump($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
        return macro null;
        #else
        return macro null;
        #end
    }

    macro static public function INFO(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        #if genome_debug
        //return macro @:pos(p_arg1.pos) GDebug.info($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
        return macro null;
        #else
        return macro null;
        #end
    }

}
