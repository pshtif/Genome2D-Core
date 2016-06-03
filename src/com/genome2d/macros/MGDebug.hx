package com.genome2d.macros;

import com.genome2d.debug.GDebug;
import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.Context;

class MGDebug {
    macro static public function DUMP(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        #if genome_debug
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.dump($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
        #else
        return macro null;
        #end
    }

    macro static public function INFO(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.info($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
    }
	
	macro static public function EDITOR(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.editor($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
    }

    macro static public function WARNING(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.warning($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
    }

    macro static public function ERROR(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.error($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
    }
	
	macro static public function G2D_ERROR(?p_arg1, ?p_arg2, ?p_arg3, ?p_arg4, ?p_arg5, ?p_arg6, ?p_arg7, ?p_arg8, ?p_arg9, ?p_arg10, ?p_arg11, ?p_arg12, ?p_arg13, ?p_arg14, ?p_arg15, ?p_arg16, ?p_arg17, ?p_arg18, ?p_arg19, ?p_arg20) {
        return macro @:pos(p_arg1.pos) com.genome2d.debug.GDebug.g2d_error($p_arg1, $p_arg2, $p_arg3, $p_arg4, $p_arg5, $p_arg6, $p_arg7, $p_arg8, $p_arg9, $p_arg10, $p_arg11, $p_arg12, $p_arg13, $p_arg14, $p_arg15, $p_arg16, $p_arg17, $p_arg18, $p_arg19, $p_arg20);
    }
}
