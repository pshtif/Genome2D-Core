/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components;

import com.genome2d.prototype.IGPrototypable;
import com.genome2d.node.GNode;
import Type.ValueType;
import com.genome2d.signals.GMouseSignal;

/**
    Component super class all components need to extend it
**/
@:allow(com.genome2d.node.GNode)
class GComponent implements IGPrototypable
{
	private var g2d_active:Bool = false;
    private var g2d_lookupClass:Class<GComponent>;
    private var g2d_previous:GComponent;
    private var g2d_next:GComponent;

	public function isActive():Bool {
		return g2d_active;
	}
	public function setActive(p_value:Bool):Void {
		g2d_active = p_value;
	}

	private var g2d_node:GNode;
    /**
        Component's node reference
     **/
	#if swc @:extern #end
	public var node(get, never):GNode;
	#if swc @:getter(node) #end
	inline private function get_node():GNode {
		return g2d_node;
	}

	public function new() {
        initDefault();
	}

    private function initDefault():Void {
        g2d_active = true;
    }
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/
	public function getPrototype():Xml {
		var prototypeXml:Xml = Xml.createElement("components");

		//prototypeXml.set("id", id);
		prototypeXml.set("class", Type.getClassName(Type.getClass(this)));
		prototypeXml.set("lookupClass", Type.getClassName(g2d_lookupClass));
		
		var propertiesXml:Xml = Xml.createElement("properties");

        var properties:Array<String> = PROTOTYPE_PROPERTIES;

        if (properties != null) {
            for (i in 0...properties.length) {
                var property:Array<String> = properties[i].split("|");
                g2d_addPrototypeProperty(property[0], property.length>1?property[1]:"", propertiesXml);
            }
        }
		
		prototypeXml.addChild(propertiesXml);
		
		return prototypeXml;
	}
	
	private function g2d_addPrototypeProperty(p_name:String, p_type:String, p_parentXml:Xml = null):Void {
		// Discard complex types
		var propertyXml:Xml = Xml.createElement("property");

        propertyXml.set("name", p_name);
        propertyXml.set("type", p_type);

        if (p_type != "Int" && p_type != "Bool" && p_type != "Float" && p_type != "String") {
            propertyXml.set("value", "xml");
            propertyXml.addChild(cast (Reflect.getProperty(this, p_name),IGPrototypable).getPrototype());
        } else {
            propertyXml.set("value", Std.string(Reflect.getProperty(this, p_name)));
        }

		p_parentXml.addChild(propertyXml);
	}

	/**
        Abstract method called after components is initialized on the node
    **/
    public function init():Void {
    }

    /**
	    Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this components is processing mouse events
	**/
    public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
        return false;
    }

    public function dispose():Void {

    }

    /**

    **/
	public function initPrototype(p_prototypeXml:Xml, p_initDefault:Bool = false):Void {
		//id = p_prototypeXml.get("id");

		var propertiesXml:Xml = p_prototypeXml.firstElement();
		
		var it:Iterator<Xml> = propertiesXml.elements();
		while (it.hasNext()) {
			g2d_initPrototypeProperty(it.next());
		}
	}
	
	private function g2d_initPrototypeProperty(p_propertyXml:Xml):Void {
		var value:Dynamic = null;
		var type:Array<String> = p_propertyXml.get("type").split(":");
		
		switch (type[0]) {
			case "Bool":
				value = (p_propertyXml.get("value") == "false") ? false : true;
			case "Int":
				value = Std.parseInt(p_propertyXml.get("value"));
			case "Float":
				value = Std.parseFloat(p_propertyXml.get("value"));
            case "String":
                value = p_propertyXml.get("value");
            case _:
                var property:String = p_propertyXml.get("value");
                if (value != "null") {
                    var c:Class<Dynamic> = cast Type.resolveClass(type[0]);
                    value = Type.createInstance(c,[]);
                    value.initPrototype(Xml.parse(property));
                }
		}

		try {
			Reflect.setProperty(this, p_propertyXml.get("name"), value);
		} catch (e:Dynamic) {
			//trace("bindPrototypeProperty error", e, p_propertyXml.get("name"), value);
		}
	}
	
	/**
	    Base dispose method, if there is a disposing you need to do in your extending components you should override it and always call super.dispose() its used when a node using this components is being disposed
	**/
	private function g2d_dispose():Void {
        dispose();

		g2d_active = false;
		
		g2d_node = null;
		
		g2d_next = null;
		g2d_previous = null;
	}
}