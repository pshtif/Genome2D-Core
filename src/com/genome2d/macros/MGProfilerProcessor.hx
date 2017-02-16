package com.genome2d.macros;

#if macro
class MGProfilerProcessor {
    static private var hasReturn:Bool;

    macro static public function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        #if !genome_no_profiles
        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    var metaIndex:Int = getProfileMeta(field.meta);
                    if (metaIndex>=0) {
                        // Store the pos info as it will be overwriten by the macro
                        var currentPos = f.expr.pos;
                        f.expr = macro {
                              @:pos(currentPos) com.genome2d.debug.GProfiler.startMethodProfile();
                              ${f.expr};
                        };

                        hasReturn = false;
                        f.expr = remapReturn(f.expr);

                        if (!hasReturn) {
                            f.expr = macro {
                                ${f.expr};
                                @:pos(currentPos) com.genome2d.debug.GProfiler.endMethodProfile();
                            }
                        }
                        // We will restore the pos info, it can be usefull for other build macros such as debug
                        f.expr.pos = currentPos;
                    }
                case _:
            }
        }
        #end
        return fields;
    }

    static public function remapReturn(expr) {
        return
        switch (expr.expr) {
            case EReturn(e):
                hasReturn = true;
                if (e == null) {
                    macro {
                        @pos(expr.pos) com.genome2d.debug.GProfiler.endMethodProfile();
                        return;
                    }
                } else {
                    macro {
                        var ___temp = ${e};
                        @:pos(expr.pos) com.genome2d.debug.GProfiler.endMethodProfile();
                        return ___temp;
                    }
                }
            case _:
                ExprTools.map(expr,remapReturn);
        }
    }

    static public function getProfileMeta(p_meta:Array<MetadataEntry>):Int {
        for (i in 0...p_meta.length) {
            if (p_meta[i].name == "genome_profile") return i;
        }
        return -1;
    }

    static public function getProfileMetaParam(p_meta:Array<MetadataEntry>):Int {
        for (meta in p_meta) {
            if (meta.params.length>0) {
                switch (meta.params[0].expr) {
                    case EConst(c):
                        switch(c) {
                            case CIdent(s):
                            default:
                        }
                    default:
                }
            }
        }

        return 0;
    }
}
#end