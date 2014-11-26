/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.prototype;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.TypeTools;

/**
    Genome2D components build macro to enumerate prototypable properties

    Not used by user
**/
class MGPrototypeProcessor {

    macro public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        //trace(Context.getLocalClass());
        var prototypeNames:Array<String> = [];
        var prototypeTypes:Array<String> = [];

        var prototypeName:String = "prototype";
        var prototypeOverride:Bool = false;
        var localClass = Context.getLocalClass().get();

        for (meta in localClass.meta.get()) {
            // Check for prototypeName within this class
            if (meta.name == 'prototypeName' && meta.params != null) {
                prototypeName = ExprTools.getValue(meta.params[0]);
                prototypeOverride = true;
            }
        }

        var superClass = localClass.superClass;
        var superPrototypeMethods = false;
        while (superClass != null) {
            var c = superClass.t.get();

            if (prototypeName == "prototype") for (meta in localClass.meta.get()) {
                if (meta.name == 'prototypeName' && meta.params != null) prototypeName = ExprTools.getValue(meta.params[0]);
            }

            if (c.fields.get().length == 0) Context.getType(c.name);
            for (field in c.fields.get()) {
                if (field.name == "getPrototype") superPrototypeMethods = true;
                for (meta in field.meta.get()) if (meta.name == 'prototype' && meta.params != null) {
                    switch (field.type) {
                        case TInst(type, params):
                            if (type.toString() != "String") {
                                for (inter in type.get().interfaces) {
                                    if (inter.t.toString() == "com.genome2d.prototype.IGPrototypable") {
                                        prototypeNames.push(field.name);
                                        prototypeTypes.push(type.toString());
                                    }
                                }
                            } else {
                                prototypeNames.push(field.name);
                                prototypeTypes.push(type.toString());
                            }
                        case TAbstract(type, params):
                            prototypeNames.push(field.name);
                            prototypeTypes.push(type.toString());
                        case _:
                            prototypeNames.push(field.name);
                            prototypeTypes.push("NA");
                    }
                    /**/
                }
            }
            superClass = c.superClass;
        }

        var hasPrototypeMethods = false;
        for (i in fields) {
            // Check if we need prototype method
            if (i.name == "getPrototype") hasPrototypeMethods = true;

            if (i.meta.length==0 || i.access.indexOf(APublic) == -1) continue;
            var isPrototype:Bool = false;
            for (meta in i.meta) {
                if (meta.name == "prototype") {
                    isPrototype = true;
                }
            }

            prototypeNames.push(i.name);
            prototypeTypes.push("NA");
            switch (i.kind) {
                case FVar(t,e):
                    if (e!=null) throw "Prototypables can't use default values in Class: "+localClass.name + " Property: " + i.name;
                    if (isPrototype) {
                        switch (t) {
                            case TPath(p):
                                var typeName = extractType(p);
                                prototypeTypes[prototypeTypes.length-1] = typeName;
                            case _:
                        }
                    }
                case FProp(get,set,t,e):
                    if (e!=null) throw "Prototypables can't use default values";
                    if (isPrototype) {
                        switch (t) {
                            case TPath(p):
                                var typeName = extractType(p);
                                prototypeTypes[prototypeTypes.length-1] = typeName;
                            case _:
                        }
                    }
                case _:
            }
        }

        if (!hasPrototypeMethods && (!superPrototypeMethods || prototypeOverride)) {
            var getPrototype = generateGetPrototype();
            switch (getPrototype) {
                case TAnonymous(f):
                    if (prototypeOverride && superPrototypeMethods) f[0].access.push(AOverride);
                    fields = fields.concat(f);
                default:
                    throw "Prototype error!";
            }
            var initPrototype = generateInitPrototype();
                switch (initPrototype) {
                    case TAnonymous(f):
                        if (prototypeOverride && superPrototypeMethods) f[0].access.push(AOverride);
                        fields = fields.concat(f);
                    default:
                        throw "Prototype error!";
            }
        }

        //if (prototype.length>0) trace( Context.getLocalClass().get().name, prototype);
        var decl:Array<Expr> = [];
        for (i in prototypeNames) {
            decl.push({expr:EConst(CString(i)),pos:pos});
        }
        var declTypes:Array<Expr> = [];
        for (i in prototypeTypes) {
            declTypes.push({expr:EConst(CString(i)),pos:pos});
        }
        var kind = TPath({ pack : [], name : "Array", params : [TPType(TPath({name:"String", pack:[], params:[]}))] });
        fields.push({ name : "PROTOTYPE_PROPERTIES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(decl),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_TYPES",      doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(declTypes),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_NAME",       doc : null, meta : [], access : [APublic,AStatic], kind : FVar(macro : String, macro $v{prototypeName}), pos : pos});

        switch (Context.getType("com.genome2d.prototype.IGPrototypable")) {
            case TInst(c,_):
                if (!c.get().meta.has(prototypeName)) c.get().meta.add(prototypeName, [macro $v{localClass.module}], pos);
            default:
        }

        //trace(prototypesClass.fields);
        return fields;
    }

    static private function extractType(type) {
        var typeName = type.name;

        if (type.name == "Array") {
            switch (type.params[0]) {
                case TPType(tp):
                    switch (tp) {
                        case TPath(t):
                            typeName += ";" + t.name;
                        case _:
                            trace("Warning unknown prototypable property "+type.name);
                    }
                case _:
                    trace("Warning unknown prototypable property "+type.name);
            }
        }

        return typeName;
    }

    static private function generateGetPrototype() {
        return macro : {
             public function getPrototype():Xml {
                var prototypeXml:Xml = Xml.createElement(PROTOTYPE_NAME);

                if (PROTOTYPE_PROPERTIES != null) {
                    for (i in 0...PROTOTYPE_PROPERTIES.length) {
                        var name:String = PROTOTYPE_PROPERTIES[i];
                        prototypeXml.set(name,Std.string(Reflect.getProperty(this, name)));
                    }
                }

                return prototypeXml;
            }
        }
    }

    static private function generateInitPrototype() {
        return macro : {
            public function initPrototype(p_prototypeXml:Xml):Void {
                initDefault();

                var properties:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_PROPERTIES");
                var types:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_TYPES");
                var attributes:Iterator<String> = p_prototypeXml.attributes();
                while (attributes.hasNext()) {
                    var attribute:String = attributes.next();
                    var value:String = p_prototypeXml.get(attribute);
                    var type:String = types[properties.indexOf(attribute)];
                    var realValue:Dynamic = null;

                    switch (type) {
                        case "Bool":
                            realValue = (value != "false");
                        case "Int":
                            realValue = Std.parseInt(value);
                        case "Float":
                            realValue = Std.parseFloat(value);
                        case "String":
                            realValue = value;
                        default:

                    }
                    try {
                        Reflect.setProperty(this, attribute, realValue);
                    } catch (e:Dynamic) {

                    }
                }

                init();
            }
        }
    }

}