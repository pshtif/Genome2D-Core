/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
package com.genome2d.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

class GComponentMacro {
    @:macro public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var prototypes:Array<String> = [];
        for (i in fields) {
            if (i.meta.length==0 || i.access.indexOf(APublic) == -1) continue;
            var isPrototype:Bool = false;
            for (meta in i.meta) {
                if (meta.name == "prototype") {
                    isPrototype = true;
                }
            }
            if (!isPrototype) continue;
            //trace(i);
            switch (i.kind) {
                case FVar(t,e):
                    switch (t) {
                        case TPath(p):
                            switch (Context.getType(p.name)) {
                                case TInst(type, params):
                                    for (inter in type.get().interfaces) {
                                        if (inter.t.toString() == "com.genome2d.components.IGPrototypable") {
                                            prototypes.push(i.name+"|"+type.toString());
                                        }
                                    }
                                case TAbstract(type, params):
                                    prototypes.push(i.name+"|"+type.toString());
                                case _:
                                    prototypes.push(i.name+"|NA");
                            }
                        case _:
                    }
                case FProp(get,set,t,e):
                    switch (t) {
                        case TPath(p):
                            switch (Context.getType(p.name)) {
                                case TInst(type, params):
                                    for (inter in type.get().interfaces) {
                                        if (inter.t.toString() == "com.genome2d.components.IGPrototypable") {
                                            prototypes.push(i.name+"|"+type.toString());
                                        }
                                    }
                                case TAbstract(type, params):
                                    prototypes.push(i.name+"|"+type.toString());
                                case _:
                                    prototypes.push(i.name+"|NA");
                            }
                        case _:
                    }
                case FFun(e):
            }
        }

        var kind = TPath({ pack : [], name : "Array", params : [TPType(TPath({name:"String", pack:[], params:[]}))] });
        var decl:Array<Expr> = [];
        for (i in prototypes) {
            decl.push({expr:EConst(CString(i)),pos:pos});
        }
        fields.push({ name : "PROTOTYPE_PROPERTIES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(decl),pos:pos}), pos : pos });
        return fields;
    }
}
