/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.macros;

import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.proto.GPrototypeSpecs;
import com.genome2d.proto.GPrototypeStates;
import com.genome2d.proto.IGPrototypable;
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
		var prototypePropertyExtras:Array<Int> = [];
		var prototypePropertyDefaults:Array<Expr> = [];

        var localClass = Context.getLocalClass().get();

        var prototypeName:String = localClass.name;
        var prototypeNameOverride:Bool = false;
		var prototypeDefaultChildGroup:String = "default";

        for (meta in localClass.meta.get()) {
            // Check for prototypeName within this class
            if (meta.name == "prototypeName" && meta.params != null) {
                prototypeName = ExprTools.getValue(meta.params[0]);
                prototypeNameOverride = true;
            }
			if (meta.name == "prototypeDefaultChildGroup" && meta.params != null) {
				prototypeDefaultChildGroup = ExprTools.getValue(meta.params[0]);
			}
        }

        var superClass = localClass.superClass;
        var superPrototype = superClass != null;
		
		var hasGetPrototypeDefault = false;
        var hasBindPrototypeDefault = false;
		
		var hasToReference = false;
		var hasPrototypeStates = false;

        while (superClass != null) {
            var c = superClass.t.get();
			
			for (i in c.fields.get()) {
				if (i.name == "getPrototypeDefault") hasGetPrototypeDefault = true;
				if (i.name == "bindPrototypeDefault") hasBindPrototypeDefault = true;
				if (i.name == "toReference") hasToReference = true;
				if (i.name == "g2d_prototypeStates") hasPrototypeStates = true;
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
			if (i.name == "g2d_prototypeStates") hasPrototypeStates = true;

            if (i.meta.length == 0 || i.access.indexOf(APublic) == -1) continue;
			
			var extras:Int = 0;

            for (meta in i.meta) {
                if (meta.name == "prototype") {
					var param:String = (meta.params.length > 0) ? ExprTools.getValue(meta.params[0]) : "";
					if (param == "getReference") extras += GPrototypeExtras.REFERENCE_GETTER;
                    switch (i.kind) {
						case FFun(f):
							if (i.name.indexOf("set") != 0) throw "Error invalid prototypable function (needs to start with set*).";
							if (f.args.length != 1) throw "Error invalid prototypable function (needs to have single parameter).";
							switch (f.args[0].type) {
								case TPath(p):
									prototypePropertyDefaults.push(extractDefault("setter", null, pos));
                                    prototypePropertyNames.push(i.name);
									
									prototypePropertyTypes.push(extractType(p));
									extras += GPrototypeExtras.SETTER;
									prototypePropertyExtras.push(GPrototypeExtras.SETTER);
                                case _:
							}
                        case FVar(t, e):							
                            switch (t) {
                                case TPath(p):
									prototypePropertyDefaults.push(extractDefault(p.name, e, pos));
                                    prototypePropertyNames.push(i.name);
									
									prototypePropertyTypes.push(extractType(p));
									prototypePropertyExtras.push(extras);
                                case _:
                            }
                        case FProp(get,set,t,e):
                            switch (t) {
                                case TPath(p):
									prototypePropertyDefaults.push(extractDefault(p.name, e, pos));
                                    prototypePropertyNames.push(i.name);

									prototypePropertyTypes.push(extractType(p));
									prototypePropertyExtras.push(extras);
                                case _:
                            }
                        case _:
                    }
                }
            }
        }
		//trace(Type.resolveClass(localClass.module));
		var getPrototype = generateGetPrototype(macro $v { prototypeName });
		switch (getPrototype) {
			case TAnonymous(f):
				if (superPrototype) {
					switch (f[0].kind) {
						case FFun(a):
							switch (a.expr.expr) {
								case EBlock(b):
									b[b.length-1] = macro return super.getPrototype(p_prototype);
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

		var bindPrototype = generateBindPrototype();
		switch (bindPrototype) {
			case TAnonymous(f):
				if (superPrototype) {
					switch (f[0].kind) {
						case FFun(a):
							switch (a.expr.expr) {
								case EBlock(b):
									b.unshift(macro super.bindPrototype(p_prototype));
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
            declPropertyNames.push( { expr:EConst(CString(i)), pos:pos } );
        }
        var declPropertyTypes:Array<Expr> = [];
        for (i in prototypePropertyTypes) {
            declPropertyTypes.push( { expr:EConst(CString(i)), pos:pos } );
        }
		var declPropertyExtras:Array<Expr> = [];
        for (i in prototypePropertyExtras) {
			declPropertyExtras.push( { expr:EConst(CInt(Std.string(i))), pos:pos } );
        }

		if (!hasPrototypeStates) {
			fields.push( { name : "g2d_currentState", doc : null, meta : [], access : [APublic], kind : FVar(macro : String, macro $v { "default" } )              , pos : pos } );
			var kind = TPath( { pack : ["com","genome2d","proto"], name : "GPrototypeStates", params : [] } );
			fields.push( { name : "g2d_prototypeStates", doc : null, meta : [], access : [APublic], kind : FVar(kind, null), pos : pos } );		
			
			var setPrototypeState = generateSetPrototypeState();
			switch (setPrototypeState) {
				case TAnonymous(f):
					fields = fields.concat(f);
				default:
					throw "Prototype error!";
			}
		}
		
        var kind = TPath( { pack : [], name : "Array", params : [TPType(TPath( { name:"Dynamic", pack:[], params:[] } ))] } );
		fields.push( { name : GPrototypeSpecs.PROTOTYPE_PROPERTY_DEFAULTS, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(kind, { expr:EArrayDecl(prototypePropertyDefaults), pos:pos } ), pos : pos } );
		var kind = TPath( { pack : [], name : "Array", params : [TPType(TPath( { name:"String", pack:[], params:[] } ))] } );
        fields.push( { name : GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES,    doc : null, meta : [], access : [APublic, AStatic], kind : FVar(kind, { expr:EArrayDecl(declPropertyNames), pos:pos } )   , pos : pos } );
        fields.push( { name : GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES,    doc : null, meta : [], access : [APublic, AStatic], kind : FVar(kind, { expr:EArrayDecl(declPropertyTypes), pos:pos } )   , pos : pos } );
		var kind = TPath( { pack : [], name : "Array", params : [TPType(TPath( { name:"Int", pack:[], params:[] } ))] } );
		fields.push( { name : GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS,   doc : null, meta : [], access : [APublic, AStatic], kind : FVar(kind, { expr:EArrayDecl(declPropertyExtras), pos:pos } )  , pos : pos } );
        fields.push( { name : GPrototypeSpecs.PROTOTYPE_NAME, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { prototypeName } )              , pos : pos } );
		fields.push( { name : GPrototypeSpecs.PROTOTYPE_DEFAULT_CHILD_GROUP, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { prototypeDefaultChildGroup } ), pos : pos } );

		// Prototype class name lookup
		//var kind = TPath( { pack : [], name : "Class", params : [TPType(TPath( { name : localClass.name, pack : localClass.pack, params : [] } ))] } );
		var field = { name : localClass.name, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { localClass.module } ), pos : pos };
		prototypes.push(field);
		// We have a custom prototype name lookup as well
		if (prototypeName != localClass.name) {
			var field = { name : prototypeName, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { localClass.module } ), pos : pos };
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

    static private function extractDefault(typeName, e, pos) {
        if (e == null) {
            switch (typeName) {
                case "Int":
                    return {expr:EConst(CInt("0")), pos:pos};
                case "Float":
                    return {expr:EConst(CFloat("0.0")), pos:pos};
                case "Bool":
                    return {expr:EConst(CIdent("false")), pos:pos};
                case "String":
                    return {expr:EConst(CString("")), pos:pos};
                default:
                    return {expr:EConst(CIdent("null")), pos:pos};
            }
		} 

		return e;
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

        return typeName;
    }

    inline static private function generateGetPrototype(p_prototypeName) {
        return macro : {
             public function getPrototype(p_prototype:com.genome2d.proto.GPrototype = null):com.genome2d.proto.GPrototype {
				p_prototype = com.genome2d.proto.GPrototypeFactory.g2d_getPrototype(p_prototype, this, $p_prototypeName);
                return p_prototype;
            }
        }
    }

    inline static private function generateBindPrototype() {
        return macro : {
            public function bindPrototype(p_prototype:com.genome2d.proto.GPrototype):Void {
                com.genome2d.proto.GPrototypeFactory.g2d_bindPrototype(this, p_prototype);
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
	
	inline static private function generateSetPrototypeState() {
        return macro : {
            public function setPrototypeState(p_stateName:String):Void {
				if (g2d_currentState != p_stateName) {
					g2d_currentState = p_stateName;
					var state:Map<String,Dynamic> = g2d_prototypeStates.getState(p_stateName);
					if (state != null) {
						for (propertyName in state.keys()) {
							try {
								Reflect.setProperty(this, propertyName, state.get(propertyName));
							} catch (e:Dynamic) {
							}
						}
					}
				}
            }
        }
    }
    #end
}