package com.genome2d.components;
import haxe.macro.Expr;
import haxe.macro.Context;

class GComponentMacro {
    @:macro public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var prototypes:Array<String> = [];
        for (i in fields) {
            if (i.meta.length==0 || i.meta[0].name != "prototype" || i.access.indexOf(APublic) == -1) continue;
            //trace(i);
            switch (i.kind) {
                case FVar(t,e):
                    switch (t) {
                        case TPath(p):
                            trace(Context.getType(p.name));
                            switch (Context.getType(p.name)) {
                                case TInst(type, params):
                                    prototypes.push(i.name+"|"+type.toString());
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
                                    prototypes.push(i.name+"|"+type.toString());
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
