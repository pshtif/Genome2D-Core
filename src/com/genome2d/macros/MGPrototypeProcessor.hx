/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.macros;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Compiler;

/**
    Genome2D components build macro to enumerate prototypable properties

    Not used by user
**/
class MGPrototypeProcessor {
    #if macro

	static public var helperIndex:Int = 0;
    static public var prototypes = [];
    static public var previous:String = "com.genome2d.proto.GPrototypeHelper";

    public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var prototypePropertyNames:Array<String> = [];
        var prototypePropertyTypes:Array<String> = [];

        var localClass = Context.getLocalClass().get();

        var prototypeName:String = localClass.name;
        var prototypeNameOverride:Bool = false;

        for (meta in localClass.meta.get()) {
            // Check for prototypeName within this class
            if (meta.name == 'prototypeName' && meta.params != null) {
                prototypeName = ExprTools.getValue(meta.params[0]);
                prototypeNameOverride = true;
            }
        }

        var superClass = localClass.superClass;
        var superPrototype = superClass != null;
		
		var hasGetPrototypeDefault = false;
        var hasBindPrototypeDefault = false;
		
		var hasToReference = false;

        while (superClass != null) {
            var c = superClass.t.get();
			
			for (i in c.fields.get()) {
				if (i.name == "getPrototypeDefault") hasGetPrototypeDefault = true;
				if (i.name == "bindPrototypeDefault") hasBindPrototypeDefault = true;
				if (i.name == "toReference") hasToReference = true;
			}
			/*
            if (prototypeNameOverride) {
                for (meta in localClass.meta.get()) {
                    if (meta.name == 'prototypeName' && meta.params != null) prototypeName = ExprTools.getValue(meta.params[0]);
                }
            }
			/**/
            superClass = c.superClass;
        }
		
        var hasGetPrototype = false;
        var hasBindPrototype = false;

        for (i in fields) {
            // Check if we need proto methods
            if (i.name == "getPrototype") hasGetPrototype = true;
            if (i.name == "bindPrototype") hasBindPrototype = true;
			if (i.name == "toReference") hasToReference = true;

            if (i.meta.length == 0 || i.access.indexOf(APublic) == -1) continue;

            for (meta in i.meta) {
                if (meta.name == "prototype" || meta.name == "reference") {
					//var param:String = (meta.params.length > 0) ? ExprTools.getValue(meta.params[0]) : "";
                    switch (i.kind) {
                        case FVar(t,e):
                            switch (t) {
                                case TPath(p):
                                    prototypePropertyNames.push(i.name);
									if (meta.name == "prototype") {
										prototypePropertyTypes.push(extractType(p));
									} else {
										prototypePropertyTypes.push("R:"+extractType(p));
									}
                                case _:
                            }
                        case FProp(get,set,t,e):
                            switch (t) {
                                case TPath(p):
                                    prototypePropertyNames.push(i.name);
                                    if (meta.name == "prototype") {
										prototypePropertyTypes.push(extractType(p));
									} else {
										prototypePropertyTypes.push("R:"+extractType(p));
									}
                                case _:
                            }
                        case _:
                    }
                }
            }
        }

        if (true) {//!superPrototype || prototypeNameOverride) {
            var getPrototype = generateGetPrototype();
            switch (getPrototype) {
                case TAnonymous(f):
                    if (superPrototype) {
                        switch (f[0].kind) {
                            case FFun(a):
                                switch (a.expr.expr) {
                                    case EBlock(b):
                                        b[b.length-1] = macro return super.getPrototype(p_prototypeXml);
                                    default:
                                }
                            default:
                        }
                    }
                    if (superPrototype && !hasGetPrototype) {
                        f[0].access.push(AOverride);
                    }
                    if (hasGetPrototype) {
                        f[0].name = "getPrototypeDefault";
						if (hasGetPrototypeDefault) f[0].access.push(AOverride);
                    }
                    fields = fields.concat(f);
                default:
                    throw "Prototype error!";
            }
        }

        if (true) {//!superPrototype || prototypeNameOverride) {
            var bindPrototype = generateBindPrototype();
            switch (bindPrototype) {
                case TAnonymous(f):
                    if (superPrototype) {
                        switch (f[0].kind) {
                            case FFun(a):
                                switch (a.expr.expr) {
                                    case EBlock(b):
                                        b.unshift(macro super.bindPrototype(p_prototypeXml));
                                    default:
                                }
                            default:
                        }
                    }
                    if (superPrototype && !hasBindPrototype) {
                        f[0].access.push(AOverride);
                    }
                    if (hasBindPrototype) {
                        f[0].name = "bindPrototypeDefault";
						if (hasBindPrototypeDefault) f[0].access.push(AOverride);
                    }
                    fields = fields.concat(f);
                default:
                    throw "Prototype error!";
            }
        }
		
		if (!hasToReference) {
			var toReference = generateToReference();
			switch (toReference) {
                case TAnonymous(f):
					fields = fields.concat(f);
				default:
			}
		}

        var declPropertyNames:Array<Expr> = [];
        for (i in prototypePropertyNames) {
            declPropertyNames.push({expr:EConst(CString(i)),pos:pos});
        }
        var declPropertyTypes:Array<Expr> = [];
        for (i in prototypePropertyTypes) {
            declPropertyTypes.push({expr:EConst(CString(i)),pos:pos});
        }

        var kind = TPath({ pack : [], name : "Array", params : [TPType(TPath({name:"String", pack:[], params:[]}))] });
        fields.push({ name : "PROTOTYPE_PROPERTY_NAMES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(declPropertyNames),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_PROPERTY_TYPES",      doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(declPropertyTypes),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_NAME",       doc : null, meta : [], access : [APublic,AStatic], kind : FVar(macro : String, macro $v{prototypeName}), pos : pos});

		// Prototype class name lookup
		//var kind = TPath( { pack : [], name : "Class", params : [TPType(TPath( { name : localClass.name, pack : localClass.pack, params : [] } ))] } );
		var field = { name : localClass.name, doc : null, meta : [], access : [APublic,AStatic], kind : FVar(macro : String, macro $v { localClass.module } ), pos : pos };
		prototypes.push(field);
		// We have a custom prototype name lookup as well
		if (prototypeName != localClass.name) {
			var field = { name : prototypeName, doc : null, meta : [], access : [APublic,AStatic], kind : FVar(macro : String, macro $v { localClass.module } ), pos : pos };
			prototypes.push(field);
		}
		// Prototype class implementation to avoid DCE
		var kind = TPath({ pack : localClass.pack, name : localClass.name, params : []});
        var field = { name : "g2d_"+localClass.name, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(kind, null), pos : pos };
		prototypes.push(field);

        var helperName = "G" + (helperIndex++);
		var helperClass = {
			pack:[], name: helperName, pos: pos,
			meta: [ { name:":native", params:[macro "com.genome2d.proto.GPrototypeHelper"], pos:pos }, { name:":keep", params:[], pos:pos }], //, { name:":rtti", params:[], pos:pos } ],
			kind: TDClass(), fields:prototypes
		}
		Context.defineType( helperClass );
		Compiler.exclude( previous );
		previous = helperName;

        return fields;
    }

    static private function extractDefault(typeName, e) {
        var value = null;
        if (e != null) {
            switch (e.expr) {
                case EConst(c):
                    switch (c) {
                        case CIdent(v):
                            value = c;
                        case CInt(v):
                            value = c;
                        case CFloat(v):
                            value = c;
                        case CString(v):
                            value = c;
                        default:
                            trace(c);
                    }
                default:
            }
        }
        if (value == null) {
            switch (typeName) {
                case "Int":
                    value = CInt("0");
                case "Float":
                    value = CFloat("0.0");
                case "Bool":
                    value = CIdent("false");
                case "String":
                    value = CString("");
                default:
                    trace(typeName, e);
            }
        }
        return value;
    }

	
	inline static private function extractType(typePath) {
        var typeName = typePath.name;
		
		if (typeName == "Array") {
			var param = typePath.params[0];
			switch (param) {
				case TPType(t):
					switch (t) {
						case TPath(p):
							typeName += ":" + p.name;
						case _:
					}
				case _:
			}
		}
		//else if (typeName != "Int" && typeName != "Bool" && typeName != "Float" && typeName != "String") {
        //}

        return typeName;
    }

    inline static private function generateGetPrototype() {
        return macro : {
             public function getPrototype(p_prototypeXml:Xml = null):Xml {
                p_prototypeXml = com.genome2d.proto.GPrototypeFactory.g2d_getPrototype(this, p_prototypeXml, PROTOTYPE_NAME, PROTOTYPE_PROPERTY_NAMES, PROTOTYPE_PROPERTY_TYPES);
                return p_prototypeXml;
            }
        }
    }

    inline static private function generateBindPrototype() {
        return macro : {
            public function bindPrototype(p_prototypeXml:Xml):Void {
                com.genome2d.proto.GPrototypeFactory.g2d_bindPrototype(this, p_prototypeXml, PROTOTYPE_PROPERTY_NAMES, PROTOTYPE_PROPERTY_TYPES);
            }
        }
    }
	
	inline static private function generateToReference() {
        return macro : {
            public function toReference():String {
                return "";
            }
        }
    }
    #end
}