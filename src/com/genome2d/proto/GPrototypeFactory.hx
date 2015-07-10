package com.genome2d.proto;
import com.genome2d.ui.skin.GUISkin;
import com.genome2d.ui.element.GUIElement;
import Reflect;
import com.genome2d.debug.GDebug;
import haxe.rtti.Meta;

//@:access(com.genome2d.protorototypable)
class GPrototypeFactory {
    static private var g2d_helper:GPrototypeHelper;
    static private var g2d_lookupsInitialized:Bool = false;
    static private var g2d_lookups:Map<String,Class<IGPrototypable>>;

    static public function initializePrototypes():Void {
        if (g2d_lookups != null) return;
        g2d_lookups = new Map<String,Class<IGPrototypable>>();
		
		var fields:Array<String> = Type.getClassFields(GPrototypeHelper);
		for (i in fields) {
			if (i.indexOf("g2d_") == 0) continue;
			
			var cls:Class<IGPrototypable> = cast Type.resolveClass(Reflect.field(GPrototypeHelper, i));
            if (cls != null) g2d_lookups.set(i, cls);
		}
    }

    static public function getPrototypeClass(p_prototypeName:String):Class<IGPrototypable> {
        return g2d_lookups.get(p_prototypeName);
    }
	
	static public function getPrototype(p_instance:IGPrototypable):Xml {
		return p_instance.getPrototype();
	}

    static public function createPrototype(p_prototype:Dynamic):IGPrototypable {
        var prototypeXml:Xml;
        if (Std.is(p_prototype,Xml)) {
            prototypeXml = (p_prototype.nodeType == Xml.Document) ? p_prototype.firstChild() : p_prototype;
        } else {
            prototypeXml = Xml.parse(p_prototype).firstElement();
        }
        var prototypeName:String = prototypeXml.nodeName;
        var prototypeClass:Class<IGPrototypable> = g2d_lookups.get(prototypeName);

        if (prototypeClass == null) {
            GDebug.error("Non existing prototype class "+prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) GDebug.error("Invalid prototype class "+prototypeName);

        proto.bindPrototype(prototypeXml);

        return proto;
    }

    static public function createEmptyPrototype(p_prototypeName:String):IGPrototypable {
        var prototypeClass:Class<IGPrototypable> = g2d_lookups[p_prototypeName];
        if (prototypeClass == null) {
            GDebug.error("Non existing prototype class "+p_prototypeName);
        }

        var proto:IGPrototypable = Type.createInstance(prototypeClass,[]);
        if (proto == null) GDebug.error("Invalid prototype class "+p_prototypeName);

        return proto;
    }

    static public function g2d_getPrototype(p_instance:IGPrototypable, p_prototypeXml:Xml, p_prototypeName:String, p_propertyNames:Array<String>, p_propertyTypes:Array<String>, p_propertyDefaults:Array<Dynamic>):Xml {
        if (p_prototypeXml == null) p_prototypeXml = Xml.createElement(p_prototypeName);

        if (p_propertyNames != null) {
            for (i in 0...p_propertyNames.length) {
                var name:String = p_propertyNames[i];
				var type:String = p_propertyTypes[i];
					
				// Array
                if (type.indexOf("Array") == 0) {
					var subtype:String = type.substr(6);
					
					// Prototypable array
					if (subtype != "Int" && subtype != "Bool" && subtype != "Float" && subtype != "String") {
						var xml:Xml = Xml.createElement(name);
						p_prototypeXml.addChild(xml);
						
						var items:Array<IGPrototypable> = Reflect.getProperty(p_instance, name);
						if (items != null) {
							for (item in items) {
								xml.addChild(item.getPrototype());
							}
							
						}
						
					// Array of basic types
					} else {
						var value:String = Std.string(Reflect.getProperty(p_instance, name));
						p_prototypeXml.set(name, value.substr(1,value.length-2));
					}
					
				// Reference
				} else if (type.indexOf("R:") == 0) {
					var field:Dynamic = Reflect.field(p_instance, name);
					p_prototypeXml.set(name, (field == null)?"":field.toReference());
				
				// Prototypable needs an own Xml node
				} else if (type != "Int" && type != "Bool" && type != "Float" && type != "String") {
                    var xml:Xml = Xml.createElement(name);
                    var property:com.genome2d.proto.IGPrototypable = cast Reflect.getProperty(p_instance, name);
                    if (property != null) {
                        xml.addChild(property.getPrototype());
                        p_prototypeXml.addChild(xml);
                    }
				// Basic type
				} else {
					var value = Reflect.getProperty(p_instance, name);
					if (value != p_propertyDefaults[i]) p_prototypeXml.set(name,Std.string(Reflect.getProperty(p_instance, name)));
                }
            }
        }

        return p_prototypeXml;
    }

    static public function g2d_bindPrototype(p_instance:IGPrototypable, p_prototype:Xml, p_propertyNames:Array<String>, p_propertyTypes:Array<String>):Void {
        if (p_prototype == null) GDebug.error("Null prototype");

        for (i in 0...p_propertyNames.length) {
            var name:String = p_propertyNames[i];
            var type:String = p_propertyTypes[i];
            var realValue:Dynamic = null;
			
			// Exists as a Xml attribute
			if (p_prototype.exists(name)) {
                var value:String = p_prototype.get(name);
				
				// Array
				if (type.indexOf("Array") == 0) {
					var subtype:String = type.substr(6);
					switch (subtype) {
						case "Bool":
							realValue = new Array<Bool>();
						case "Int":
							realValue = new Array<Int>();
						case "Float":
							realValue = new Array<Float>();
						case "String":
							realValue = new Array<String>();
						case _:
					}
					var split:Array<String> = value.split(",");
					for (item in split) {
						switch (subtype) {
							case "Bool":
								realValue.push((item != "false" && item != "0"));
							case "Int":
								realValue.push(Std.parseInt(item));
							case "Float":
								realValue.push(Std.parseFloat(item));
							case "String":
								realValue.push(item);
							case _:
						}
					}
					
				// Reference
				} else if (type.indexOf("R:") == 0) {
					type = type.substr(2);
					var c:Class<IGPrototypable> = getPrototypeClass(type);//Type.resolveClass(type.substring(0, type.lastIndexOf(".")));
					realValue = Reflect.callMethod(c, Reflect.field(c, "fromReference"), [value]);//Reflect.callMethod(c, Reflect.field(c, type.substr(type.lastIndexOf(".") + 1)), [value]);
					
				// Basic
				} else {
					switch (type) {
						case "Bool":
							realValue = (value != "false" && value != "0");
						case "Int":
							realValue = Std.parseInt(value);
						case "Float":
							realValue = Std.parseFloat(value);
						case "String":
							realValue = value;
						case _:
					}
				}
		
			// Prototypable has own Xml node
			} else if (type != "Int" && type != "Bool" && type != "Float" && type != "String") {
				var it:Iterator<Xml> = p_prototype.elementsNamed(name);
                if (it.hasNext()) realValue = com.genome2d.proto.GPrototypeFactory.createPrototype(it.next().firstElement());
			}

            if (realValue != null) {
                try {
                    Reflect.setProperty(p_instance, name, realValue);
                } catch (e:Dynamic) {
                }
            }

        }
        /*
        var elements:Iterator<Xml> = p_prototypeXml.elements();
        while (elements.hasNext()) {
            var element:Xml = elements.next();
            var type:String = PROTOTYPE_TYPES[PROTOTYPE_PROPERTIES_FINAL.indexOf(element.nodeName)];
            if (type == "IGPrototypable" && element.firstChild() != null) {
                var proto:com.genome2d.protorototypable = com.genome2d.proto.GPrototypeFactory.createPrototype(element.firstElement());
                try {
                    Reflect.setProperty(this, element.nodeName, proto);
                } catch (e:Dynamic) {
                }
            }
        }
        /**/
    }
	
	static public function g2d_bindPrototype2(p_instance:IGPrototypable, p_prototype:Xml, p_propertyNames:Array<String>, p_propertyTypes:Array<String>):Void {
        if (p_prototype == null) GDebug.error("Null prototype");
		
		var attributes:Iterator<String> = p_prototype.attributes();
		
		while (attributes.hasNext()) {
			var attribute:String = attributes.next();
			var split:Array<String> = attribute.split(".");
			var propertyIndex:Int = p_propertyNames.indexOf(split[0]);
			if (propertyIndex > -1) {
				var type:String = p_propertyTypes[propertyIndex];
				var attributeValue:String = p_prototype.get(attribute);
				var realValue:Dynamic = null;
				
				switch (type) {
					case "Bool":
						realValue = (value != "false" && value != "0");
					case "Int":
						realValue = Std.parseInt(value);
					case "Float":
						realValue = Std.parseFloat(value);
					case "String":
						realValue = value;
					case _:
				}
			}
		}
    }
}
