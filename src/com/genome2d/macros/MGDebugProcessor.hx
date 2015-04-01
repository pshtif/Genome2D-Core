package com.genome2d.macros;

import haxe.macro.ExprTools;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Compiler;

class MGDebugProcessor {

    static public function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        for (field in fields) {
            getDebugMeta(field.meta);

            switch (field.kind) {
                case FFun(f):
                    f.expr = remapReturn(f.expr);

                    /*
                    var insertedExpr = com.genome2d.macros.MGDebug.PROCESSOR_DEBUG(Context.makeExpr(0,pos), f);
                    f.expr = macro {
                        ${insertedExpr};
                        ${f.expr};
                    }
                    /**/
                case _:
            }
        }

        return fields;
    }

    static public function remapReturn(expr) {
        return
        switch (expr.expr) {
            case EReturn(e):
                if (e == null) {
                    macro {
                        // Call end profile here
                        return;
                    }
                } else {
                    macro {
                        var ___temp = ${e};
                        // Call end profile here
                        return ___temp;
                    }
                }
            case _:
                ExprTools.map(expr,remapReturn);
        }
    }

    static public function getDebugMeta(p_meta:Array<MetadataEntry>):Int {
        for (meta in p_meta) {
            if (meta.params.length>0) {
                switch (meta.params[0].expr) {
                    case EConst(c):
                        switch(c) { case CIdent(s): trace(s); default: }
                    default:
                }
            }
        }

        return 0;
    }
}
