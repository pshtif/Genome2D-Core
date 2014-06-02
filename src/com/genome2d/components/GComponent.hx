package com.genome2d.components ;
import com.genome2d.node.GNode;
import Type.ValueType;
import com.genome2d.signals.GMouseSignal;

/*
* 	Genome2D - GPU 2D framework utilizing Molehill API
*
*	Copyright 2011 Peter Stefcek. All rights reserved.
*
*	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
*/
class GComponent
{
	private var g2d_active:Bool = true;

	public function isActive():Bool {
		return g2d_active;
	}
	public function setActive(p_value:Bool):Void {
		g2d_active = p_value;
	}

	public var id:String = "";
	
	public var g2d_lookupClass:Class<GComponent>;
	
	/**
	 * 	@private
	 */
	public var g2d_previous:GComponent;
	/**
	 * 	@private
	 */
	public var g2d_next:GComponent;
	
	private var g2d_node:GNode;
	#if swc @:extern #end
	public var node(get, never):GNode;
	#if swc @:getter(node) #end
	inline private function get_node():GNode {
		return g2d_node;
	}
	
	/**
	 *  @private
	 */
	public function new(p_node:GNode) {
		g2d_node = p_node;

	    g2d_prototypableProperties = new Array<String>();
	}
	
	/****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/	
	private var g2d_prototypableProperties:Array<String>;
	 
	public function getPrototype():Xml {
		var prototypeXml:Xml = Xml.parse("<component/>").firstElement();

		prototypeXml.set("id", id);
		prototypeXml.set("componentClass", Type.getClassName(Type.getClass(this)));
		prototypeXml.set("componentLookupClass", Type.getClassName(g2d_lookupClass));
		
		var propertiesXml:Xml = Xml.parse("<properties/>").firstElement();
		
		for (i in 0...g2d_prototypableProperties.length) {
			var propertyName:String = g2d_prototypableProperties[i];
			var propertyValue = Reflect.getProperty(this, propertyName);
			g2d_addPrototypeProperty(propertyName, propertyValue, propertiesXml);
		}
		
		prototypeXml.addChild(propertiesXml);
		
		return prototypeXml;
	}
	
	private function g2d_addPrototypeProperty(p_name:String, p_value:Dynamic, p_propertiesXml:Xml = null):Void {
		// Discard complex types
		var propertyXml:Xml = Xml.parse("<property/>").firstElement();
		var type:String = Type.typeof(p_value).getName();

        if (type == "TClass") {
            type = type+":"+Type.getClassName(Type.getClass(p_value));
        }

		propertyXml.set("name", p_name);
		propertyXml.set("value", Std.string(p_value));
		propertyXml.set("type", type);

		p_propertiesXml.addChild(propertyXml);
	}
	
	
	public function bindFromPrototype(p_prototypeXml:Xml):Void {
		id = p_prototypeXml.get("id");

		var propertiesXml:Xml = p_prototypeXml.firstElement();
		
		var it:Iterator<Xml> = propertiesXml.elements();
		while (it.hasNext()) {
			bindPrototypeProperty(it.next());
		}
	}
	
	public function bindPrototypeProperty(p_propertyXml:Xml):Void {
		var value:Dynamic = null;
		var type:Array<String> = p_propertyXml.get("type").split(":");
		
		switch (type[0]) {
			case "TBool":
				value = (p_propertyXml.get("value") == "false") ? false : true;
			case "TInt":
				value = Std.parseInt(p_propertyXml.get("value"));
			case "TFloat":
				value = Std.parseFloat(p_propertyXml.get("value"));
            case "TClass":
                switch (type[1]) {
                    case "String":
                        value = p_propertyXml.get("value");
                }
		}

		try {
			Reflect.setProperty(this, p_propertyXml.get("name"), value);
		} catch (e:Dynamic) {
			//trace("bindPrototypeProperty error");
		}
	}
	
	/**
	 * 	Abstract method that should be overriden and implemented if you are creating your own components, its called each time a node that uses this component is processing mouse events
	 */
	public function processContextMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
		return false;	
	}
	
	/**
	 * 	Base dispose method, if there is a disposing you need to do in your extending component you should override it and always call super.dispose() its used when a node using this component is being disposed
	 */
	public function dispose():Void {
		g2d_active = false;
		
		g2d_node = null;
		
		g2d_next = null;
		g2d_previous = null;
	}
}