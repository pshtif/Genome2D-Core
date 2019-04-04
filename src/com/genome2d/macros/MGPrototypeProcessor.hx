/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.macros;

#if macro
import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.proto.GPrototypeSpecs;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.Compiler;

/**
    Genome2D components build macro to enumerate prototypable properties

    Not used by user
**/
class MGPrototypeProcessor {		
	static public var helperIndex:Int = 0;
    static public var prototypes = [];
    static public var previous:String = "com.genome2d.proto.GPrototypeHelper";
	static public var classFlags:Map<String,Int>;

    public static function build() : Array<Field> {
        var pos:Position = Context.currentPos();
        var fields:Array<Field> = Context.getBuildFields();
		var imports:Array<ImportExpr> = Context.getLocalImports();
		var localModule:String = Context.getLocalModule();
		localModule = localModule.substr(0, localModule.lastIndexOf("."));

        var prototypePropertyNames:Array<String> = [];
        var prototypePropertyTypes:Array<String> = [];
		var prototypePropertyExtras:Array<Int> = [];
		var prototypePropertyDefaults:Array<Expr> = [];

        var localClass = Context.getLocalClass().get();
		//trace("Building prototypable type "+localClass.name);

		if (classFlags == null) classFlags = new Map<String,Int>();
		classFlags.set(localClass.name,0);

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

			// Using flags otherwise haxe compiler freezes up when requesting fields of super class
			hasGetPrototypeDefault = hasGetPrototypeDefault || ((classFlags.get(c.name) & 1) == 1);
			hasBindPrototypeDefault = hasBindPrototypeDefault || ((classFlags.get(c.name) & 2) == 2);
			hasToReference = hasToReference || ((classFlags.get(c.name) & 4) == 4);
			hasPrototypeStates = hasPrototypeStates || ((classFlags.get(c.name) & 8) == 8);

			/*
			for (i in c.fields.get()) {
				if (i.name == "getPrototypeDefault") hasGetPrototypeDefault = true;
				else if (i.name == "bindPrototypeDefault") hasBindPrototypeDefault = true;
				else if (i.name == "toReference") hasToReference = true;
				else if (i.name == "g2d_prototypeStates") hasPrototypeStates = true;
			}
			/**/

            superClass = c.superClass;
        }

        var hasGetPrototype = false;
        var hasBindPrototype = false;

        for (i in fields) {
            // Check if we need proto methods
            if (i.name == "getPrototype") hasGetPrototype = true;
            else if (i.name == "bindPrototype") hasBindPrototype = true;
			else if (i.name == "toReference") hasToReference = true;
			else if (i.name == "g2d_prototypeStates") hasPrototypeStates = true;

            if (i.meta.length == 0 || i.access.indexOf(APublic) == -1) continue;
			
			var extras:Int = 0;
			var defaultValue:Dynamic = null;
			for (meta in i.meta) {
				if (meta.name == "default") {
					defaultValue = meta.params[0];
				}
			}

            for (meta in i.meta) {
                if (meta.name == "prototype") {
					var param:String = (meta.params.length > 0) ? ExprTools.getValue(meta.params[0]) : "";
					if (param == "getReference") extras += GPrototypeExtras.REFERENCE_GETTER;
                    switch (i.kind) {
                        case FVar(t, e):
                            switch (t) {
                                case TPath(p):
									prototypePropertyDefaults.push(defaultValue == null?extractDefault(p.name, e, pos):defaultValue);
                                    prototypePropertyNames.push(i.name);
									prototypePropertyTypes.push(extractType(p, imports, localModule));
									prototypePropertyExtras.push(extras);
                                case _:
                            }
                        case FProp(get,set,t,e):
                            switch (t) {
                                case TPath(p):
									prototypePropertyDefaults.push(defaultValue == null?extractDefault(p.name, e, pos):defaultValue);
                                    prototypePropertyNames.push(i.name);
									//var fileName:String = PositionTools.getInfos(i.pos).file;
									prototypePropertyTypes.push(extractType(p, imports, localModule));
									prototypePropertyExtras.push(extras);
                                case _:
                            }
                        case _:
                    }
                }
            }
        }
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
					classFlags.set(localClass.name,classFlags.get(localClass.name)+1);
					if (hasGetPrototypeDefault) f[0].access.push(AOverride);
				}
				fields = fields.concat(f);
			default:
				throw "Prototype error!";
		}

		var bindPrototype = generateBindPrototype(macro $v { prototypeName });
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
					classFlags.set(localClass.name,classFlags.get(localClass.name)+2);
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

		// Set toReference flag for all IGPrototypable
		classFlags.set(localClass.name,classFlags.get(localClass.name)+4);
		// Set prototypeStates flag for all IGPrototypable
		classFlags.set(localClass.name,classFlags.get(localClass.name)+8);

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
		/**/
		// TODO Parsing . to _ for cs target, can be refactored to be more streamlined for all platforms
		var parsedName:String = localModule+"."+localClass.name;
		parsedName = StringTools.replace(parsedName, ".", "_");
		var field = { name : parsedName, doc : null, meta : [], access : [APublic, AStatic], kind : FVar(macro : String, macro $v { localClass.module } ), pos : pos };
		prototypes.push(field);
		/**/
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

	inline static private function extractPackage(imp:ImportExpr):String {
		var p:String = "";
		for (sub in imp.path) {
			p += sub.name+".";
		}
		p = p.substr(0,-1);
		return p;
	}

	inline static private function extractType(p_path:TypePath, p_imports:Array<ImportExpr>, p_localModule:String) {
		var typeName:String = p_path.name;
		if (typeName == "String" || typeName == "Bool" || typeName == "Float" || typeName == "Int") return typeName;

		if (typeName == "Array") {
			var param = p_path.params[0];
			switch (param) {
				case TPType(t):
					switch (t) {
						case TPath(p):
							// TODO extract subtype to support non basic types
							typeName += ":" + p.name;
						case _:
					}
				case _:
			}
		} else {
			var found:Bool = false;
			for (imp in p_imports) {
				var name:String = imp.path[imp.path.length-1].name;
				if (name == typeName) {
					found = true;
					typeName = extractPackage(imp);
				}
			}
			if (!found) {
				typeName = p_localModule+"."+typeName;
				//trace(Context.getModule(typeName);
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

    inline static private function generateBindPrototype(p_prototypeName) {
        return macro : {
            public function bindPrototype(p_prototype:com.genome2d.proto.GPrototype):Void {
                com.genome2d.proto.GPrototypeFactory.g2d_bindPrototype(this, p_prototype, $p_prototypeName);
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
					var state:Map<String,com.genome2d.proto.GPropertyState> = g2d_prototypeStates.getState(p_stateName);
					
					if (state != null) {
						g2d_currentState = p_stateName;
						for (propertyName in state.keys()) {
							state.get(propertyName).bind(this);
						}
					} else {
						state = g2d_prototypeStates.getState("na");
						if (state != null) {
							g2d_currentState = p_stateName;
							for (propertyName in state.keys()) {
								state.get(propertyName).bind(this);
							}
						}
					}
				}
            }
        }
    }
}
#end