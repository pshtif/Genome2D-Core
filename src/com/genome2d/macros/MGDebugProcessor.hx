package com.genome2d.macros;

import com.genome2d.debug.GDebugPriority;
import haxe.macro.Expr;
import haxe.macro.Context;

class MGDebugProcessor {
    #if macro
    macro static public function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        //var interfaces = Context.getLocalClass().get().interfaces
        var autoDumpPriority:Int = 1;
        for (inter in Context.getLocalClass().get().interfaces) {
            if (inter.t.get().name == "IGDebuggableInternal") autoDumpPriority = 0;
        }

        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    var ignore:Bool = false;
                    for (access in field.access) {
                        switch (access) {
                            case AInline:
                                ignore = true;
                            case _:
                        }
                    }
                    if (!hasNoDebugMeta(field.meta) && !ignore) {
                        var priority:Int = getDebugPriority(field.meta);
                        if (priority == 0) priority = autoDumpPriority;
                        #if !genome_debug_autodump
                        if (priority>2) {
                        #end
                        var insertedExpr = com.genome2d.macros.MGDebugProcessor.PROCESSOR_DEBUG(Context.makeExpr(priority,pos), f);
                        f.expr = macro {
                            ${insertedExpr};
                            ${f.expr};
                        }
                        #if !genome_debug_autodump
                        }
                        #end
                    }
                case _:
            }
        }

        return fields;
    }

    static public function hasNoDebugMeta(p_meta:Array<MetadataEntry>):Bool {
        for (meta in p_meta) {
            if (meta.name == "genome_no_debug") return true;
        }

        return false;
    }

    static public function getDebugPriority(p_meta:Array<MetadataEntry>):Int {
        for (meta in p_meta) {
            if (meta.name == "genome_debug") {
                if (meta.params.length>0) {
                    switch (meta.params[0].expr) {
                        case EConst(c):
                            switch(c) {
                                case CInt(i):
                                    return Std.parseInt(i);
                                case CString(s):
                                    switch (s) {
                                        case "DUMP":
                                            return GDebugPriority.DUMP;
                                        case "INFO":
                                            return GDebugPriority.INFO;
                                        case "WARNING":
                                            return GDebugPriority.WARNING;
                                        case "ERROR":
                                            return GDebugPriority.ERROR;
                                        case _:
                                    }
                                default:
                            }
                        default:
                    }
                }

                return 2;
            }
        }

        return 0;
    }

    static public function PROCESSOR_DEBUG(p_priority:Expr, p_function:Function) {
        #if genome_debug
        switch (p_function.args.length) {
            case 1:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name});
            case 2:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name});
            case 3:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name});
            case 4:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name});
            case 5:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name});
            case 6:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name});
            case 7:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name});
            case 8:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name});
            case 9:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name});
            case 10:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name});
            case 11:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name});
            case 12:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name});
            case 13:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name});
            case 14:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name});
            case 15:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name});
            case 16:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name}, $i{p_function.args[15].name});
            case 17:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name}, $i{p_function.args[15].name}, $i{p_function.args[16].name});
            case 18:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name}, $i{p_function.args[15].name}, $i{p_function.args[16].name}, $i{p_function.args[17].name});
            case 19:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name}, $i{p_function.args[15].name}, $i{p_function.args[16].name}, $i{p_function.args[17].name}, $i{p_function.args[18].name});
            case 20:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority, $i{p_function.args[0].name}, $i{p_function.args[1].name}, $i{p_function.args[2].name}, $i{p_function.args[3].name}, $i{p_function.args[4].name}, $i{p_function.args[5].name}, $i{p_function.args[6].name}, $i{p_function.args[7].name}, $i{p_function.args[8].name}, $i{p_function.args[9].name}, $i{p_function.args[10].name}, $i{p_function.args[11].name}, $i{p_function.args[12].name}, $i{p_function.args[13].name}, $i{p_function.args[14].name}, $i{p_function.args[15].name}, $i{p_function.args[16].name}, $i{p_function.args[17].name}, $i{p_function.args[18].name}, $i{p_function.args[19].name});
            case _:
                return macro @:pos(p_function.expr.pos) com.genome2d.debug.GDebug.debug($p_priority);
        }
        return macro null;
        #else
        return macro null;
        #end
    }
    #end
}
