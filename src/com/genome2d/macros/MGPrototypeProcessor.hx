/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
    Genome2D component build macro to enumerate prototypable properties

    Not used by user
**/
class MGPrototypeProcessor {
    macro public static function build() : Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        //trace(Context.getLocalClass());
        var prototypes:Array<String> = [];
        var superCls = Context.getLocalClass().get().superClass;
        var needsPrototypeMethods = true;
        while (superCls != null) {
            var c = superCls.t.get();
            if (c.fields.get().length == 0) Context.getType(c.name);
            for (field in c.fields.get()) {
                if (field.name == "getPrototype") needsPrototypeMethods = false;
                for (meta in field.meta.get()) if (meta.name == 'prototype' && meta.params != null) {
                    switch (field.type) {
                        case TInst(type, params):
                            if (type.toString() != "String") {
                                for (inter in type.get().interfaces) {
                                    if (inter.t.toString() == "com.genome2d.utils.IGPrototypable") {
                                        prototypes.push(field.name+"|"+type.toString());
                                    }
                                }
                            } else {
                                prototypes.push(field.name+"|"+type.toString());
                            }
                        case TAbstract(type, params):
                            prototypes.push(field.name+"|"+type.toString());
                        case _:
                            prototypes.push(field.name+"|NA");
                    }
                }
            }
            superCls = c.superClass;
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
                                    if (type.toString() != "String") {
                                        for (inter in type.get().interfaces) {
                                            if (inter.t.toString() == "com.genome2d.components.IGPrototypable") {
                                                prototypes.push(i.name+"|"+type.toString());
                                            }
                                        }
                                    } else {
                                        prototypes.push(i.name+"|"+type.toString());
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
                                    if (type.toString() != "String") {
                                        for (inter in type.get().interfaces) {
                                            if (inter.t.toString() == "com.genome2d.components.IGPrototypable") {
                                                prototypes.push(i.name+"|"+type.toString());
                                            }
                                        }
                                    } else {
                                        prototypes.push(i.name+"|"+type.toString());
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

        if (needsPrototypeMethods) {
            var getPrototype = generateGetPrototype();
            switch (getPrototype) {
                case TAnonymous(f):
                    fields = fields.concat(f);
                default:
                    throw "N/A";
            }
            var initPrototype = generateInitPrototype();
                switch (initPrototype) {
                    case TAnonymous(f):
                        fields = fields.concat(f);
                    default:
                        throw "N/A";
            }
        }

        //if (prototypes.length>0) trace( Context.getLocalClass().get().name, prototypes);
        var kind = TPath({ pack : [], name : "Array", params : [TPType(TPath({name:"String", pack:[], params:[]}))] });
        var decl:Array<Expr> = [];
        for (i in prototypes) {
            decl.push({expr:EConst(CString(i)),pos:pos});
        }
        fields.push({ name : "PROTOTYPE_PROPERTIES", doc : null, meta : [], access : [APublic,AStatic], kind : FVar(kind,{expr:EArrayDecl(decl),pos:pos}), pos : pos });
        return fields;
    }

    static private function generateGetPrototype() {
        return macro : {
            public function getPrototype():Xml {
                var prototypeXml:Xml = Xml.createElement("component");
                prototypeXml.set("class", Type.getClassName(Type.getClass(this)));

                //prototypeXml.set("id", id);
                //prototypeXml.set("lookupClass", Type.getClassName(g2d_lookupClass));

                var propertiesXml:Xml = null;//Xml.createElement("properties");

                var properties:Array<String> = Reflect.field(Type.getClass(this), "PROTOTYPE_PROPERTIES");

                if (properties != null) {
                    for (i in 0...properties.length) {
                        var property:Array<String> = properties[i].split("|");
                        var name:String = property[0];
                        var type:String = property.length>1?property[1]:"";

                        prototypeXml.set(name,Std.string(Reflect.getProperty(this, name)));
                        /*
                        var propertyXml:Xml = Xml.createElement("property");

                        propertyXml.set("name", name);
                        propertyXml.set("type", type);

                        if (type != "Int" && type != "Bool" && type != "Float" && type != "String") {
                            propertyXml.set("value", "xml");
                            propertyXml.addChild(cast (Reflect.getProperty(this, name),IGPrototypable).getPrototype());
                        } else {
                            propertyXml.set("value", Std.string(Reflect.getProperty(this, name)));
                        }

                        propertiesXml.addChild(propertyXml);
                        /**/
                    }
                }

                if (propertiesXml != null) prototypeXml.addChild(propertiesXml);

                return prototypeXml;
            }
        }
    }

    static private function generateInitPrototype() {
        return macro : {
            public function initPrototype(p_prototypeXml:Xml):Void {
                //id = p_prototypeXml.get("id");

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
            }
        }
    }
}