package com.genome2d.proto.parsers;
import com.genome2d.debug.GDebug;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.GPrototypeSpecs;
import com.genome2d.proto.IGPrototypable;

/**
 * @author Peter @sHTiF Stefcek
 */
class GXmlPrototypeParser
{
	static public function createPrototypeFromXmlString(p_xmlString:String):IGPrototypable {
		return GPrototypeFactory.createPrototype(fromXml(Xml.parse(p_xmlString).firstElement()));
	}

	static public function toXml(p_prototype:GPrototype):Xml {
		var xml:Xml = Xml.createElement(p_prototype.prototypeName);
		for (property in p_prototype.properties) {
			if (property.isBasicType() || property.isReference()) {
				xml.set(property.name, property.value);
			} else {
				if (property.isPrototype()) {
					var propertyXml:Xml = Xml.createElement("p:" + property.name);
					propertyXml.addChild(property.value.toXml());
					xml.addChild(propertyXml);
				} else {
					GDebug.error("Error during prototype parsing unknown property type", property.type);
				}
			}
		}
		
		for (groupName in p_prototype.children.keys()) {
			var isDefaultChildGroup:Bool = (groupName == Reflect.field(p_prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_DEFAULT_CHILD_GROUP));
			var groupXml:Xml = (isDefaultChildGroup) ? null : Xml.createElement(groupName);
			var group:Array<GPrototype> = p_prototype.children.get(groupName);
			for (prototype in group) {
				if (!isDefaultChildGroup) groupXml.addChild(toXml(prototype));
				else xml.addChild(toXml(prototype));
			}
			if (!isDefaultChildGroup) xml.addChild(groupXml);
		}
		
		return xml;
	}

	static private function setPropertyFromXml(p_prototype:GPrototype, p_name:String, p_value:Xml):Void {
		var split:Array<String> = p_name.split(".");
		var lookupClass:Class<IGPrototypable> = p_prototype.prototypeClass;
		var propertyNames:Array<String> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		while (propertyNames.indexOf(split[0]) == -1 && lookupClass != null) {
			lookupClass = cast Type.getSuperClass(lookupClass);
			if (lookupClass != null) propertyNames = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		}
		
		if (lookupClass != null) {
			var propertyTypes:Array<String> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES);
			var propertyExtras:Array<Int> = Reflect.field(lookupClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS);
			var propertyIndex:Int = propertyNames.indexOf(split[0]);
			
			p_prototype.createPrototypeProperty(p_name, propertyTypes[propertyIndex], propertyExtras[propertyIndex], fromXml(p_value));
		}
	}
	
	static public function fromXml(p_xml:Xml):GPrototype {
		if (p_xml.nodeType == Xml.Document) p_xml = p_xml.firstElement();
		
		var prototype:GPrototype = new GPrototype();
		
		prototype.prototypeName = p_xml.nodeName;
		prototype.prototypeClass = GPrototypeFactory.getPrototypeClass(prototype.prototypeName);

		var propertyNames:Array<String> = Reflect.field(prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_NAMES);
		var propertyDefaults:Array<Dynamic> = Reflect.field(prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_DEFAULTS);
		var propertyTypes:Array<String> = Reflect.field(prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_TYPES);
		var propertyExtras:Array<Int> = Reflect.field(prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_PROPERTY_EXTRAS);
		var defaultChildGroup:String = Reflect.field(prototype.prototypeClass, GPrototypeSpecs.PROTOTYPE_DEFAULT_CHILD_GROUP);
		
		// We are adding properties on attributes
		for (attribute in p_xml.attributes()) {
			prototype.setPropertyFromString(attribute, p_xml.get(attribute));
		}
		
		for (element in p_xml.elements()) {
			// We are adding a node refering to property
			if (element.nodeName.indexOf("p:") == 0) {
				setPropertyFromXml(prototype, element.nodeName.substr(2), element.firstElement());
				
			// We are adding a default group node
			} else if (element.nodeName == defaultChildGroup || defaultChildGroup == "*") {
				prototype.addChild(fromXml(element), defaultChildGroup);
				
			// Other group nodes
			} else {
				for (child in element.elements()) {
					prototype.addChild(fromXml(child), element.nodeName);
				}
			}
        }
		
		return prototype;
	}
}