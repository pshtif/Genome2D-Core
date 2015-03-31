package com.genome2d.macros;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

class MGDebugProcessor {

    public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var priority:Int = 0;
        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    switch (f.expr.expr) {
                        case EBlock(b):
                            trace(field.name);
                            b.unshift(com.genome2d.macros.MGDebug.PROCESSOR_DEBUG(Context.makeExpr(priority,pos), f));
                        default:
                    }
                case _:
            }
        }

        return fields;
    }
}
