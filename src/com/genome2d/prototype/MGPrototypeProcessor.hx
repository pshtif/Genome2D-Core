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

/**
    Genome2D components build macro to enumerate prototypable properties

    Not used by user
**/
class MGPrototypeProcessor {

    macro public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        //trace(Context.getLocalClass());
        var prototypes:Array<String> = [];
        var prototypeTypes:Array<String> = [];

        var prototypeName:String = "prototype";
        var localClass = Context.getLocalClass().get();

        for (meta in localClass.meta.get()) if (meta.name == 'prototypeName' && meta.params != null) prototypeName = ExprTools.getValue(meta.params[0]);

        var superClass = localClass.superClass;
        var needsPrototypeMethods = true;
        while (superClass != null) {
            var c = superClass.t.get();

            if (prototypeName == "prototype") for (meta in localClass.meta.get()) if (meta.name == 'prototypeName' && meta.params != null) prototypeName = ExprTools.getValue(meta.params[0]);

            if (c.fields.get().length == 0) Context.getType(c.name);
            for (field in c.fields.get()) {
                if (field.name == "getPrototype") needsPrototypeMethods = false;
                for (meta in field.meta.get()) if (meta.name == 'prototype' && meta.params != null) {
                    switch (field.type) {
                        case TInst(type, params):
                            if (type.toString() != "String") {
                                for (inter in type.get().interfaces) {
                                    if (inter.t.toString() == "com.genome2d.prototype.IGPrototypable") {
                                        prototypes.push(field.name);
                                        prototypeTypes.push(type.toString());
                                    }
                                }
                            } else {
                                prototypes.push(field.name);
                                prototypeTypes.push(type.toString());
                            }
                        case TAbstract(type, params):
                            prototypes.push(field.name);
                            prototypeTypes.push(type.toString());
                        case _:
                            prototypes.push(field.name);
                            prototypeTypes.push("NA");
                    }
                }
            }
            superClass = c.superClass;
        }

        for (i in fields) {
            // Check if we need prototype method
            if (i.name == "getPrototype") needsPrototypeMethods = false;

            if (i.meta.length==0 || i.access.indexOf(APublic) == -1) continue;
            var isPrototype:Bool = false;
            for (meta in i.meta) {
                if (meta.name == "prototype") {
                    isPrototype = true;
                }
            }
            if (!isPrototype) continue;

            switch (i.kind) {
                case FVar(t,e):
                    switch (t) {
                        case TPath(p):
                            switch (Context.getType(p.name)) {
                                case TInst(type, params):
                                    if (type.toString() == "Array") {
                                        trace(type, params);
                                    } else if (type.toString() != "String") {
                                        for (inter in type.get().interfaces) {
                                            if (inter.t.toString() == "com.genome2d.component.IGPrototypable") {
                                                prototypes.push(i.name);
                                                prototypeTypes.push(type.toString());
                                            }
                                        }
                                    } else {
                                        prototypes.push(i.name);
                                        prototypeTypes.push(type.toString());
                                    }
                                case TAbstract(type, params):
                                    prototypes.push(i.name);
                                    prototypeTypes.push(type.toString());
                                case _:
                                    prototypes.push(i.name);
                                    prototypeTypes.push("NA");
                            }
                        case _:
                    }
                case FProp(get,set,t,e):
                    switch (t) {
                        case TPath(p):
                            switch (Context.getType(p.name)) {
                                case TInst(type, params):
                                    if (type.toString() != "String") {
                                        for (inter in type.get().interfaces) {
                                            if (inter.t.toString() == "com.genome2d.componentIGPrototypable") {
                                                prototypes.push(i.name);
                                                prototypeTypes.push(type.toString());
                                            }
                                        }
                                    } else {
                                        prototypes.push(i.name);
                                        prototypeTypes.push(type.toString());
                                    }
                                case TAbstract(type, params):
                                    prototypes.push(i.name);
                                    prototypeTypes.push(type.toString());
                                case _:
                                    prototypes.push(i.name);
                                    prototypeTypes.push("NA");
                            }
                        case _:
                    }
                case FFun(e):
            }
        }

        if (needsPrototypeMethods) {
            var getPrototype = generateGetPrototype(prototypeName);
            switch (getPrototype) {
                case TAnonymous(f):
                    fields = fields.concat(f);
                default:
                    throw "NA";
            }
            var initPrototype = generateInitPrototype();
                switch (initPrototype) {
                    case TAnonymous(f):
                        fields = fields.concat(f);
                    default:
                        throw "NA";
            }
        }

        //if (prototype.length>0) trace( Context.getLocalClass().get().name, prototype);
        var decl:Array<Expr> = [];
        for (i in prototypes) {
            decl.push({expr:EConst(CString(i)),pos:pos});
        }
        var declTypes:Array<Expr> = [];
        for (i in prototypeTypes) {
            declTypes.push({expr:EConst(CString(i)),pos:pos});
        }
        var kind = TPath({ pack : [], name : "Array", params : [TPType(TPath({name:"String", pack:[], params:[]}))] });
        fields.push({ name : "PROTOTYPE_PROPERTIES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(decl),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_TYPES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(declTypes),pos:pos}), pos : pos });
        fields.push({ name : "PROTOTYPE_NAME",       doc : null, meta : [], access : [APublic,AStatic], kind : FVar(macro : String, macro $v{prototypeName}), pos : pos});

        var test:String = "aaaa";
        switch (Context.getType("com.genome2d.prototype.IGPrototypable")) {
            case TInst(c,_):
                if (!c.get().meta.has(prototypeName)) c.get().meta.add(prototypeName, [macro $v{localClass.module}], pos);
            default:
        }

        //trace(prototypesClass.fields);
        return fields;
    }

    static private function generateGetPrototype(p_prototypeName) {
        return macro : {
             public function getPrototype():Xml {
                //var name:String = ExprTools.getValue($v{p_prototypeName});
                var prototypeXml:Xml = Xml.createElement(PROTOTYPE_NAME);

                var properties:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_PROPERTIES");

                if (properties != null) {
                    for (i in 0...properties.length) {
                        var name:String = properties[i];
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
                var properties:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_PROPERTIES");
                var types:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_TYPES");
                var attributes:Iterator<String> = p_prototypeXml.attributes();
                while (attributes.hasNext()) {
                    var attribute:String = attributes.next();
                    var value:String = p_prototypeXml.get(attribute);
                    var type:String = types[properties.indexOf(attribute)];
                    var realValue:Dynamic = null;
                    trace(attribute, value, type);
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
                //id = p_prototypeXml.get("id");

                /*
                var propertiesXml:Xml = p_prototypeXml.firstElement();

                var it:Iterator<Xml> = propertiesXml.elements();
                while (it.hasNext()) {
                    var propertyXml:Xml = it.next();
                    var value:Dynamic = null;
                    var type:Array<String> = propertyXml.get("type").split(":");

                    switch (type[0]) {
                        case "Bool":
                            value = (propertyXml.get("value") == "false") ? false : true;
                        case "Int":
                            value = Std.parseInt(propertyXml.get("value"));
                        case "Float":
                            value = Std.parseFloat(propertyXml.get("value"));
                        case "String":
                            value = propertyXml.get("value");
                        case _:
                            var property:String = propertyXml.get("value");
                            if (value != "null") {
                                var c:Class<Dynamic> = cast Type.resolveClass(type[0]);
                                value = Type.createInstance(c,[]);
                                value.initPrototype(Xml.parse(property));
                            }
                    }

                    try {
                        Reflect.setProperty(this, propertyXml.get("name"), value);
                    } catch (e:Dynamic) {
                        //trace("bindPrototypeProperty error", e, p_propertyXml.get("name"), value);
                    }
                }
                /**/
            }
        }
    }
}